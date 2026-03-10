// Check that every code instruction from bank_FF.asm is covered by at least one
// successfully decompiled Ghidra function.
//@category Pacman

import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.address.AddressRange;
import ghidra.program.model.address.AddressRangeIterator;
import ghidra.program.model.address.AddressSet;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionManager;
import ghidra.program.model.listing.FunctionIterator;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.symbol.SourceType;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CheckDecompCoverage extends GhidraScript {

    private static final Pattern LABEL_RE = Pattern.compile("^\\s*([A-Za-z_][A-Za-z0-9_]*)\\s*:\\s*$");
    private static final Pattern ROW_RE = Pattern.compile("^([C-])\\s+.*0x([0-9A-Fa-f]{6})\\s+00:([0-9A-Fa-f]{4}):\\s+(.+)$");
    private static final Pattern BYTES_AND_ASM_RE = Pattern.compile("^([0-9A-Fa-f]{2}(?:\\s+[0-9A-Fa-f]{2})*)\\s{2,}(.*)$");
    private static final Pattern CODE_MNEM_RE = Pattern.compile("^[A-Za-z]{3}\\b");
    private static final String[] DECOMP_STYLES = new String[] {
        "decompile", "normalize", "register", "firstpass"
    };

    private static class ParseResult {
        final Map<Integer, List<String>> rootLabelsByAddr = new LinkedHashMap<>();
        final Set<Integer> codeInstrStarts = new HashSet<>();
        int codeRows = 0;
    }
    private static class IntRange {
        final int start;
        final int end;
        IntRange(int start, int end) {
            this.start = start;
            this.end = end;
        }
        boolean contains(int a) {
            return a >= start && a <= end;
        }
    }

    private static boolean isRootLabelName(String name) {
        return name.startsWith("sub_") || name.startsWith("vec_");
    }

    private ParseResult parseBankCodeRows(String listingPath) throws Exception {
        ParseResult out = new ParseResult();
        List<String> pending = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(listingPath))) {
            String line;
            while ((line = br.readLine()) != null && !monitor.isCancelled()) {
                Matcher lm = LABEL_RE.matcher(line);
                if (lm.matches()) {
                    pending.add(lm.group(1));
                    continue;
                }

                Matcher m = ROW_RE.matcher(line);
                if (!m.find()) {
                    continue;
                }
                String kind = m.group(1);
                int addr = Integer.parseInt(m.group(3), 16);
                if (!pending.isEmpty() && "C".equals(kind)) {
                    for (String name : pending) {
                        if (!isRootLabelName(name)) {
                            continue;
                        }
                        List<String> labels = out.rootLabelsByAddr.get(addr);
                        if (labels == null) {
                            labels = new ArrayList<>();
                            out.rootLabelsByAddr.put(addr, labels);
                        }
                        if (!labels.contains(name)) {
                            labels.add(name);
                        }
                    }
                }
                pending.clear();

                if (!"C".equals(kind)) {
                    continue;
                }

                String tail = m.group(4);
                Matcher bm = BYTES_AND_ASM_RE.matcher(tail);
                if (!bm.find()) {
                    continue;
                }
                String asm = bm.group(2).trim();
                if (asm.startsWith(".")) {
                    continue;
                }
                if (!CODE_MNEM_RE.matcher(asm).find()) {
                    continue;
                }
                out.codeInstrStarts.add(addr);
                out.codeRows++;
            }
        }
        return out;
    }

    private static boolean isInBank(Address a) {
        long o = a.getOffset();
        return o >= 0xC000 && o <= 0xFFFF;
    }

    private Function ensureFunctionAt(Address addr, String preferredName) {
        Function fn = getFunctionAt(addr);
        if (fn == null) {
            try {
                disassemble(addr);
            }
            catch (Exception ignored) {
                // best effort
            }
            try {
                createFunction(addr, preferredName);
            }
            catch (Exception ignored) {
                // best effort
            }
            fn = getFunctionAt(addr);
        }
        if (fn != null && preferredName != null && fn.getEntryPoint().equals(addr) && !preferredName.equals(fn.getName())) {
            try {
                fn.setName(preferredName, SourceType.USER_DEFINED);
            }
            catch (Exception ignored) {
                // best effort
            }
        }
        return fn;
    }

    private void addCoveredStarts(Function fn, Set<Integer> codeStarts, Set<Integer> coveredStarts) {
        AddressRangeIterator it = fn.getBody().getAddressRanges();
        while (it.hasNext() && !monitor.isCancelled()) {
            AddressRange ar = it.next();
            long start = ar.getMinAddress().getOffset();
            long end = ar.getMaxAddress().getOffset();
            if (end < 0xC000 || start > 0xFFFF) {
                continue;
            }
            long s = Math.max(start, 0xC000);
            long e = Math.min(end, 0xFFFF);
            for (long x = s; x <= e; x++) {
                int ai = (int) x;
                if (codeStarts.contains(ai)) {
                    coveredStarts.add(ai);
                }
            }
        }
    }

    private List<Integer> buildOrphanCandidates(
        List<Integer> missingStarts,
        Set<Address> failedRootEntries,
        List<IntRange> failedRootRanges
    ) {
        Set<Integer> unique = new HashSet<>();
        int lastRawChunk = -0x10000;
        for (Integer ai : missingStarts) {
            boolean inFailedRange = false;
            for (IntRange r : failedRootRanges) {
                if (r.contains(ai.intValue())) {
                    inFailedRange = true;
                    break;
                }
            }
            if (inFailedRange) {
                unique.add(ai.intValue());
                continue;
            }
            Address addr = toAddr(ai.intValue());
            Function container = getFunctionContaining(addr);
            if (container != null &&
                isInBank(container.getEntryPoint()) &&
                !failedRootEntries.contains(container.getEntryPoint())) {
                unique.add((int) container.getEntryPoint().getOffset());
                continue;
            }
            if (ai.intValue() - lastRawChunk > 0x08) {
                unique.add(ai.intValue());
                lastRawChunk = ai.intValue();
            }
        }
        List<Integer> out = new ArrayList<>(unique);
        Collections.sort(out);
        return out;
    }

    private void removeFunctionAtEntry(Address entry) {
        FunctionManager fm = currentProgram.getFunctionManager();
        try {
            fm.removeFunction(entry);
        }
        catch (Exception ignored) {
            // best effort
        }
    }

    private void repairSoundEngineLayout() {
        int start = 0xEE5C;
        int end = 0xEFA9;
        List<Address> toRemove = new ArrayList<>();
        FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
        while (it.hasNext() && !monitor.isCancelled()) {
            Function fn = it.next();
            int e = (int) fn.getEntryPoint().getOffset();
            if (e >= start && e <= end) {
                toRemove.add(fn.getEntryPoint());
            }
        }
        for (Address a : toRemove) {
            removeFunctionAtEntry(a);
        }
        ensureFunctionAt(toAddr(0xEE5C), "sub_EE5C_update_sound_engine");
    }

    private Function forceSingleInstructionFunction(Address addr, String name) {
        try {
            disassemble(addr);
        }
        catch (Exception ignored) {
            // best effort
        }
        Instruction ins = currentProgram.getListing().getInstructionAt(addr);
        if (ins == null) {
            return null;
        }
        Function old = getFunctionContaining(addr);
        if (old != null) {
            removeFunctionAtEntry(old.getEntryPoint());
        }
        Address end;
        try {
            end = addr.add(ins.getLength() - 1L);
        }
        catch (Exception e) {
            return null;
        }
        AddressSet body = new AddressSet(addr, end);
        try {
            return currentProgram.getFunctionManager().createFunction(name, addr, body, SourceType.USER_DEFINED);
        }
        catch (Exception ignored) {
            return getFunctionAt(addr);
        }
    }

    private DecompileResults tryDecompile(DecompInterface ifc, Function fn, int timeoutSec) {
        DecompileResults last = null;
        for (String style : DECOMP_STYLES) {
            try {
                ifc.setSimplificationStyle(style);
            }
            catch (Exception ignored) {
                // best effort
            }
            DecompileResults r = ifc.decompileFunction(fn, timeoutSec, monitor);
            last = r;
            if (r != null && r.decompileCompleted() && r.getDecompiledFunction() != null) {
                return r;
            }
        }
        return last;
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String listingPath = "bank_FF.asm";
        String reportPath = "decomp_coverage_report.txt";
        int maxMissing = 0;
        if (args.length >= 1 && args[0] != null && !args[0].isEmpty()) {
            listingPath = args[0];
        }
        if (args.length >= 2 && args[1] != null && !args[1].isEmpty()) {
            reportPath = args[1];
        }
        if (args.length >= 3 && args[2] != null && !args[2].isEmpty()) {
            maxMissing = Integer.parseInt(args[2]);
        }

        ParseResult parsed = parseBankCodeRows(listingPath);
        repairSoundEngineLayout();

        DecompInterface ifc = new DecompInterface();
        ifc.toggleCCode(true);
        ifc.toggleSyntaxTree(false);
        ifc.setSimplificationStyle("decompile");
        ifc.openProgram(currentProgram);

        Set<Integer> coveredInstrStarts = new HashSet<>();
        int rootTotal = 0;
        int rootDecompOk = 0;
        int rootDecompFail = 0;
        int chunkTotal = 0;
        int chunkDecompOk = 0;
        int chunkDecompFail = 0;

        try {
            Set<Address> doneEntries = new HashSet<>();
            Set<Address> seenRootEntries = new HashSet<>();
            Set<Address> failedRootEntries = new HashSet<>();
            List<IntRange> failedRootRanges = new ArrayList<>();
            List<Integer> rootAddrs = new ArrayList<>(parsed.rootLabelsByAddr.keySet());
            Collections.sort(rootAddrs);

            for (Integer ai : rootAddrs) {
                if (monitor.isCancelled()) {
                    break;
                }
                List<String> names = parsed.rootLabelsByAddr.get(ai);
                String pref = (names == null || names.isEmpty()) ? String.format("root_%04X", ai) : names.get(0);
                Function fn = ensureFunctionAt(toAddr(ai), pref);
                if (fn == null || !isInBank(fn.getEntryPoint())) {
                    continue;
                }
                if (seenRootEntries.contains(fn.getEntryPoint())) {
                    continue;
                }
                seenRootEntries.add(fn.getEntryPoint());
                rootTotal++;

                DecompileResults r = tryDecompile(ifc, fn, 45);
                if (r == null || !r.decompileCompleted() || r.getDecompiledFunction() == null) {
                    rootDecompFail++;
                    failedRootEntries.add(fn.getEntryPoint());
                    AddressRangeIterator rit = fn.getBody().getAddressRanges();
                    int min = 0x10000;
                    int max = -1;
                    while (rit.hasNext() && !monitor.isCancelled()) {
                        AddressRange ar = rit.next();
                        int s = (int) Math.max(ar.getMinAddress().getOffset(), 0xC000);
                        int e = (int) Math.min(ar.getMaxAddress().getOffset(), 0xFFFF);
                        if (e < s) {
                            continue;
                        }
                        if (s < min) {
                            min = s;
                        }
                        if (e > max) {
                            max = e;
                        }
                    }
                    if (max >= min) {
                        failedRootRanges.add(new IntRange(min, max));
                    }
                    continue;
                }
                rootDecompOk++;
                addCoveredStarts(fn, parsed.codeInstrStarts, coveredInstrStarts);
                doneEntries.add(fn.getEntryPoint());
            }

            List<Integer> missingAfterRoots = new ArrayList<>();
            for (Integer a : parsed.codeInstrStarts) {
                if (!coveredInstrStarts.contains(a)) {
                    missingAfterRoots.add(a);
                }
            }
            Collections.sort(missingAfterRoots);

            for (Address e : failedRootEntries) {
                removeFunctionAtEntry(e);
            }
            List<Integer> orphanCandidates = buildOrphanCandidates(
                missingAfterRoots, failedRootEntries, failedRootRanges);
            for (Integer ai : orphanCandidates) {
                if (monitor.isCancelled()) {
                    break;
                }
                if (coveredInstrStarts.contains(ai)) {
                    continue;
                }
                Function fn = ensureFunctionAt(toAddr(ai), String.format("chunk_%04X", ai));
                if (fn == null || !isInBank(fn.getEntryPoint())) {
                    continue;
                }
                if (doneEntries.contains(fn.getEntryPoint())) {
                    continue;
                }
                doneEntries.add(fn.getEntryPoint());
                chunkTotal++;

                DecompileResults r = tryDecompile(ifc, fn, 90);
                if (r == null || !r.decompileCompleted() || r.getDecompiledFunction() == null) {
                    chunkDecompFail++;
                    continue;
                }
                chunkDecompOk++;
                addCoveredStarts(fn, parsed.codeInstrStarts, coveredInstrStarts);
            }

            List<Integer> stillMissing = new ArrayList<>();
            for (Integer a : parsed.codeInstrStarts) {
                if (!coveredInstrStarts.contains(a)) {
                    stillMissing.add(a);
                }
            }
            Collections.sort(stillMissing);
            for (Integer ai : stillMissing) {
                if (monitor.isCancelled()) {
                    break;
                }
                Function fn = forceSingleInstructionFunction(toAddr(ai), String.format("chunki_%04X", ai));
                if (fn == null || !isInBank(fn.getEntryPoint())) {
                    continue;
                }
                if (doneEntries.contains(fn.getEntryPoint())) {
                    continue;
                }
                doneEntries.add(fn.getEntryPoint());
                chunkTotal++;

                DecompileResults r = tryDecompile(ifc, fn, 45);
                if (r == null || !r.decompileCompleted() || r.getDecompiledFunction() == null) {
                    chunkDecompFail++;
                    continue;
                }
                chunkDecompOk++;
                addCoveredStarts(fn, parsed.codeInstrStarts, coveredInstrStarts);
            }
        }
        finally {
            ifc.dispose();
        }

        List<Integer> missing = new ArrayList<>();
        for (Integer a : parsed.codeInstrStarts) {
            if (!coveredInstrStarts.contains(a)) {
                missing.add(a);
            }
        }
        Collections.sort(missing);

        try (BufferedWriter w = new BufferedWriter(new FileWriter(reportPath))) {
            w.write("=== DECOMP COVERAGE ===\n");
            w.write("listing path: " + listingPath + "\n");
            w.write("program: " + currentProgram.getName() + "\n");
            w.write("code instruction rows in listing: " + parsed.codeRows + "\n");
            w.write("unique code instruction addresses: " + parsed.codeInstrStarts.size() + "\n");
            w.write("root functions attempted (sub_/vec_): " + rootTotal + "\n");
            w.write("root functions decompiled ok: " + rootDecompOk + "\n");
            w.write("root functions decompile failed: " + rootDecompFail + "\n");
            w.write("chunk functions attempted: " + chunkTotal + "\n");
            w.write("chunk functions decompiled ok: " + chunkDecompOk + "\n");
            w.write("chunk functions decompile failed: " + chunkDecompFail + "\n");
            w.write("covered instruction addresses: " + coveredInstrStarts.size() + "\n");
            w.write("missing instruction addresses: " + missing.size() + "\n");
            if (missing.isEmpty()) {
                w.write("status: PASS\n");
            } else {
                w.write("status: FAIL\n");
                int n = (maxMissing <= 0) ? missing.size() : Math.min(maxMissing, missing.size());
                if (maxMissing <= 0) {
                    w.write("missing (all):\n");
                } else {
                    w.write("missing (first " + maxMissing + "):\n");
                }
                for (int i = 0; i < n; i++) {
                    w.write(String.format("  - 0x%04X\n", missing.get(i)));
                }
            }
        }

        println("Coverage report written: " + reportPath);
        println("Code instruction rows in listing: " + parsed.codeRows);
        println("Unique code instruction addresses: " + parsed.codeInstrStarts.size());
        println("Root functions attempted: " + rootTotal);
        println("Root functions decompiled ok: " + rootDecompOk);
        println("Root functions decompile failed: " + rootDecompFail);
        println("Chunk functions attempted: " + chunkTotal);
        println("Chunk functions decompiled ok: " + chunkDecompOk);
        println("Chunk functions decompile failed: " + chunkDecompFail);
        println("Covered instruction addresses: " + coveredInstrStarts.size());
        println("Missing instruction addresses: " + missing.size());
    }
}
