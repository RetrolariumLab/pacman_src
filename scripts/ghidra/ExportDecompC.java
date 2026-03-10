// Export decompiled C for code discovered from bank_FF.asm labels.
//@category Pacman

import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.program.model.address.Address;
import ghidra.program.model.address.AddressRange;
import ghidra.program.model.address.AddressRangeIterator;
import ghidra.program.model.address.AddressSet;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionManager;
import ghidra.program.model.listing.FunctionIterator;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.Listing;
import ghidra.program.model.mem.Memory;
import ghidra.program.model.mem.MemoryAccessException;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolIterator;
import ghidra.program.model.symbol.SourceType;

import java.io.BufferedWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ExportDecompC extends GhidraScript {

    private static final int MAX_DATA_BYTES = 0x200;
    private static final Pattern LABEL_RE = Pattern.compile("^\\s*([A-Za-z_][A-Za-z0-9_]*)\\s*:\\s*$");
    private static final Pattern ROW_ADDR_RE = Pattern.compile("^([C-])\\s+.*0x([0-9A-Fa-f]{6})\\s+00:([0-9A-Fa-f]{4}):\\s+(.+)$");
    private static final Pattern BYTES_AND_ASM_RE = Pattern.compile("^([0-9A-Fa-f]{2}(?:\\s+[0-9A-Fa-f]{2})*)\\s{2,}(.*)$");
    private static final Pattern CODE_MNEM_RE = Pattern.compile("^[A-Za-z]{3}\\b");
    private static final String[] DECOMP_STYLES = new String[] {
        "decompile", "normalize", "register", "firstpass"
    };
    // Keep final C output readable: chunk_* is used for diagnostics/coverage, not for final export.
    private static final boolean EXPORT_CHUNKS = false;

    private static String hex2(int v) {
        return String.format("0x%02X", v & 0xff);
    }

    private static boolean isExportDataSymbol(String name) {
        return name.startsWith("tbl_") ||
               name.startsWith("off_") ||
               name.startsWith("ofs_") ||
               name.startsWith("_off");
    }

    private static boolean isCodeEntryLabelName(String name) {
        return name.startsWith("sub_") ||
               name.startsWith("vec_");
    }

    private static boolean isInBank(Address a) {
        long o = a.getOffset();
        return o >= 0xC000 && o <= 0xFFFF;
    }

    private List<Symbol> collectDataSymbols() {
        List<Symbol> syms = new ArrayList<>();
        SymbolIterator it = currentProgram.getSymbolTable().getAllSymbols(true);
        while (it.hasNext()) {
            Symbol s = it.next();
            String name = s.getName();
            if (name != null && isExportDataSymbol(name)) {
                syms.add(s);
            }
        }
        Collections.sort(syms, new Comparator<Symbol>() {
            @Override
            public int compare(Symbol a, Symbol b) {
                int c = a.getAddress().compareTo(b.getAddress());
                if (c != 0) {
                    return c;
                }
                return a.getName().compareTo(b.getName());
            }
        });
        return syms;
    }

    private int writeDataSection(BufferedWriter writer) throws Exception {
        Memory mem = currentProgram.getMemory();
        Listing listing = currentProgram.getListing();
        List<Symbol> symbols = collectDataSymbols();

        writer.write("/* ============================================================ */\n");
        writer.write("/* tbl_*/off_*/ofs_*/_off* data symbols imported from bank_FF.asm */\n");
        writer.write("/* ============================================================ */\n\n");

        int written = 0;
        for (int i = 0; i < symbols.size() && !monitor.isCancelled(); i++) {
            Symbol cur = symbols.get(i);
            Address start = cur.getAddress();
            if (!mem.contains(start)) {
                continue;
            }

            MemoryBlock block = mem.getBlock(start);
            if (block == null) {
                continue;
            }

            Address end = block.getEnd();
            if (i + 1 < symbols.size()) {
                Address next = symbols.get(i + 1).getAddress();
                if (next.getAddressSpace().equals(start.getAddressSpace()) && next.compareTo(start) > 0) {
                    Address prev = next.previous();
                    if (prev != null && prev.compareTo(end) < 0) {
                        end = prev;
                    }
                }
            }

            Instruction nextIns = listing.getInstructionAt(start);
            if (nextIns == null) {
                nextIns = listing.getInstructionAfter(start);
            }
            if (nextIns != null) {
                Address insAddr = nextIns.getAddress();
                if (insAddr.compareTo(start) > 0) {
                    Address prev = insAddr.previous();
                    if (prev != null && prev.compareTo(end) < 0) {
                        end = prev;
                    }
                }
            }

            long sizeLong = end.subtract(start) + 1;
            if (sizeLong <= 0) {
                continue;
            }
            int size = (int) Math.min(sizeLong, MAX_DATA_BYTES);

            writer.write("unsigned char " + cur.getName() + "[] = {\n");
            for (int off = 0; off < size; off++) {
                if (off % 16 == 0) {
                    writer.write("    ");
                }
                try {
                    int b = mem.getByte(start.add(off));
                    writer.write(hex2(b));
                }
                catch (MemoryAccessException e) {
                    writer.write("0x00");
                }
                if (off != size - 1) {
                    writer.write(", ");
                }
                if (off % 16 == 15 || off == size - 1) {
                    writer.write("\n");
                }
            }
            writer.write("}; /* @" + start + ", size=" + size + " */\n\n");
            written++;
        }

        return written;
    }

    private static class ListingParse {
        final Map<Address, List<String>> rootCodeLabelsByAddr = new LinkedHashMap<>();
        final Set<Integer> codeInstrStarts = new HashSet<>();
    }

    private ListingParse parseListing(String listingPath) throws Exception {
        ListingParse out = new ListingParse();
        List<String> pending = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader(listingPath))) {
            String line;
            while ((line = br.readLine()) != null && !monitor.isCancelled()) {
                Matcher lm = LABEL_RE.matcher(line);
                if (lm.matches()) {
                    pending.add(lm.group(1));
                    continue;
                }

                Matcher am = ROW_ADDR_RE.matcher(line);
                if (!am.find()) {
                    continue;
                }

                boolean isCodeRow = "C".equals(am.group(1));
                int cpuAddr = Integer.parseInt(am.group(3), 16);
                Address addr = toAddr(cpuAddr);
                String tail = am.group(4);

                if (!pending.isEmpty()) {
                    if (isCodeRow) {
                        for (String name : pending) {
                            if (!isCodeEntryLabelName(name)) {
                                continue;
                            }
                            List<String> names = out.rootCodeLabelsByAddr.get(addr);
                            if (names == null) {
                                names = new ArrayList<>();
                                out.rootCodeLabelsByAddr.put(addr, names);
                            }
                            if (!names.contains(name)) {
                                names.add(name);
                            }
                        }
                    }
                    pending.clear();
                }

                if (!isCodeRow) {
                    continue;
                }
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
                out.codeInstrStarts.add(cpuAddr);
            }
        }
        return out;
    }

    private List<Function> collectRootFunctionsForExport(Map<Address, List<String>> codeLabelsByAddr) throws Exception {
        Set<Address> seen = new HashSet<>();
        List<Function> out = new ArrayList<>();

        for (Map.Entry<Address, List<String>> e : codeLabelsByAddr.entrySet()) {
            if (monitor.isCancelled()) {
                break;
            }
            Address addr = e.getKey();
            String prefName = e.getValue().isEmpty() ? null : e.getValue().get(0);

            Function fn = getFunctionContaining(addr);
            if (fn == null) {
                try {
                    disassemble(addr);
                }
                catch (Exception ignored) {
                    // best effort
                }
                try {
                    if (prefName != null) {
                        createFunction(addr, prefName);
                    }
                }
                catch (Exception ignored) {
                    // best effort
                }
                fn = getFunctionContaining(addr);
            }
            if (fn == null) {
                continue;
            }

            if (fn.getEntryPoint().equals(addr) && prefName != null && !prefName.equals(fn.getName())) {
                try {
                    fn.setName(prefName, SourceType.USER_DEFINED);
                }
                catch (Exception ignored) {
                    // best effort
                }
            }

            Address entry = fn.getEntryPoint();
            if (seen.contains(entry)) {
                continue;
            }
            seen.add(entry);
            out.add(fn);
        }

        Collections.sort(out, new Comparator<Function>() {
            @Override
            public int compare(Function a, Function b) {
                long sa = a.getBody().getNumAddresses();
                long sb = b.getBody().getNumAddresses();
                int c = Long.compare(sb, sa); // larger first
                if (c != 0) {
                    return c;
                }
                return a.getEntryPoint().compareTo(b.getEntryPoint());
            }
        });

        return out;
    }

    private List<Integer> getCodeStartsInBody(Function fn, Set<Integer> codeInstrStarts) {
        List<Integer> out = new ArrayList<>();
        AddressRangeIterator it = fn.getBody().getAddressRanges();
        while (it.hasNext() && !monitor.isCancelled()) {
            AddressRange r = it.next();
            long s = Math.max(r.getMinAddress().getOffset(), 0xC000);
            long e = Math.min(r.getMaxAddress().getOffset(), 0xFFFF);
            if (e < s) {
                continue;
            }
            for (long a = s; a <= e; a++) {
                int ai = (int) a;
                if (codeInstrStarts.contains(ai)) {
                    out.add(ai);
                }
            }
        }
        return out;
    }

    private static class RangeInfo {
        int start = 0x10000;
        int end = -1;
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

    private RangeInfo getFunctionRangeInBank(Function fn) {
        RangeInfo ri = new RangeInfo();
        AddressRangeIterator it = fn.getBody().getAddressRanges();
        while (it.hasNext() && !monitor.isCancelled()) {
            AddressRange r = it.next();
            int s = (int) Math.max(r.getMinAddress().getOffset(), 0xC000);
            int e = (int) Math.min(r.getMaxAddress().getOffset(), 0xFFFF);
            if (e < s) {
                continue;
            }
            if (s < ri.start) {
                ri.start = s;
            }
            if (e > ri.end) {
                ri.end = e;
            }
        }
        if (ri.end < ri.start) {
            ri.start = -1;
        }
        return ri;
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

    private boolean isFullyCovered(List<Integer> bodyStarts, Set<Integer> coveredStarts) {
        if (bodyStarts.isEmpty()) {
            return true;
        }
        for (Integer a : bodyStarts) {
            if (!coveredStarts.contains(a)) {
                return false;
            }
        }
        return true;
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
        String outputPath = "decomp_bank_ff.c";
        String listingPath = "bank_FF.asm";
        if (args.length >= 1 && args[0] != null && !args[0].isEmpty()) {
            outputPath = args[0];
        }
        if (args.length >= 2 && args[1] != null && !args[1].isEmpty()) {
            listingPath = args[1];
        }

        DecompInterface ifc = new DecompInterface();
        ifc.toggleCCode(true);
        ifc.toggleSyntaxTree(false);
        ifc.setSimplificationStyle("decompile");
        ifc.openProgram(currentProgram);

        int countOk = 0;
        int countFail = 0;
        int countDedup = 0;
        int dataBlockCount = 0;
        int countChunks = 0;
        Set<Integer> coveredInstrStarts = new HashSet<>();
        Set<Address> exportedEntries = new HashSet<>();
        Set<Address> failedRootEntries = new HashSet<>();
        List<IntRange> failedRootRanges = new ArrayList<>();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputPath))) {
            dataBlockCount = writeDataSection(writer);

            ListingParse parsed = parseListing(listingPath);
            repairSoundEngineLayout();
            List<Function> rootFunctions = collectRootFunctionsForExport(parsed.rootCodeLabelsByAddr);

            List<Function> worklist = new ArrayList<>(rootFunctions);
            Collections.sort(worklist, new Comparator<Function>() {
                @Override
                public int compare(Function a, Function b) {
                    return a.getEntryPoint().compareTo(b.getEntryPoint());
                }
            });

            int pass = 0;
            while (!monitor.isCancelled() && pass < 2) {
                pass++;
                boolean exportedInThisPass = false;

                for (Function fn : worklist) {
                    if (monitor.isCancelled()) {
                        break;
                    }
                    if (!isInBank(fn.getEntryPoint())) {
                        continue;
                    }
                    if (exportedEntries.contains(fn.getEntryPoint())) {
                        continue;
                    }

                    List<Integer> bodyStarts = getCodeStartsInBody(fn, parsed.codeInstrStarts);
                    if (isFullyCovered(bodyStarts, coveredInstrStarts)) {
                        countDedup++;
                        exportedEntries.add(fn.getEntryPoint());
                        continue;
                    }

                    int timeoutSec = (pass == 1) ? 60 : 120;
                    DecompileResults result = tryDecompile(ifc, fn, timeoutSec);
                    RangeInfo ri = getFunctionRangeInBank(fn);

                    writer.write("/* ============================================================ */\n");
                    writer.write("/* " + fn.getName() + " @ " + fn.getEntryPoint() + " */\n");
                    if (ri.start >= 0) {
                        writer.write(String.format("/* ROM range: 0x%04X-0x%04X | ASM covered: %d */\n",
                            ri.start, ri.end, bodyStarts.size()));
                    }
                    writer.write("/* ============================================================ */\n");

                    if (result == null || !result.decompileCompleted()) {
                        String msg = "decompile failed";
                        if (result != null && result.getErrorMessage() != null && !result.getErrorMessage().isBlank()) {
                            msg = result.getErrorMessage().trim();
                        }
                        writer.write("/* " + msg + " */\n\n");
                        countFail++;
                        if (pass == 1) {
                            failedRootEntries.add(fn.getEntryPoint());
                            if (ri.start >= 0) {
                                failedRootRanges.add(new IntRange(ri.start, ri.end));
                            }
                        } else {
                            exportedEntries.add(fn.getEntryPoint());
                        }
                        continue;
                    }

                    if (result.getDecompiledFunction() == null) {
                        writer.write("/* decompiler returned no function body */\n\n");
                        countFail++;
                        if (pass == 1) {
                            failedRootEntries.add(fn.getEntryPoint());
                            if (ri.start >= 0) {
                                failedRootRanges.add(new IntRange(ri.start, ri.end));
                            }
                        } else {
                            exportedEntries.add(fn.getEntryPoint());
                        }
                        continue;
                    }

                    writer.write(result.getDecompiledFunction().getC());
                    writer.write("\n\n");
                    coveredInstrStarts.addAll(bodyStarts);
                    countOk++;
                    exportedEntries.add(fn.getEntryPoint());
                    exportedInThisPass = true;
                }

                if (pass == 1) {
                    if (!EXPORT_CHUNKS) {
                        break;
                    }
                    List<Integer> missing = new ArrayList<>();
                    for (Integer a : parsed.codeInstrStarts) {
                        if (!coveredInstrStarts.contains(a)) {
                            missing.add(a);
                        }
                    }
                    Collections.sort(missing);
                    for (Address e : failedRootEntries) {
                        removeFunctionAtEntry(e);
                    }
                    List<Integer> orphanStarts = buildOrphanCandidates(missing, failedRootEntries, failedRootRanges);
                    worklist.clear();
                    Set<Address> seen = new HashSet<>();
                    for (Integer a : orphanStarts) {
                        Function at = getFunctionAt(toAddr(a.intValue()));
                        String name = (at != null) ? at.getName() : String.format("chunk_%04X", a.intValue());
                        Function fn = ensureFunctionAt(toAddr(a.intValue()), name);
                        if (fn == null || !isInBank(fn.getEntryPoint())) {
                            continue;
                        }
                        if (seen.contains(fn.getEntryPoint())) {
                            continue;
                        }
                        seen.add(fn.getEntryPoint());
                        if (name.startsWith("chunk_")) {
                            countChunks++;
                        }
                        worklist.add(fn);
                    }
                    Collections.sort(worklist, new Comparator<Function>() {
                        @Override
                        public int compare(Function a, Function b) {
                            return a.getEntryPoint().compareTo(b.getEntryPoint());
                        }
                    });
                    if (worklist.isEmpty()) {
                        break;
                    }
                    continue;
                }

                if (!exportedInThisPass) {
                    break;
                }
            }

            if (EXPORT_CHUNKS) {
                List<Integer> stillMissing = new ArrayList<>();
                for (Integer a : parsed.codeInstrStarts) {
                    if (!coveredInstrStarts.contains(a)) {
                        stillMissing.add(a);
                    }
                }
                Collections.sort(stillMissing);
                for (Integer a : stillMissing) {
                    if (monitor.isCancelled()) {
                        break;
                    }
                    Address addr = toAddr(a.intValue());
                    Function fn = forceSingleInstructionFunction(addr, String.format("chunki_%04X", a.intValue()));
                    if (fn == null || !isInBank(fn.getEntryPoint())) {
                        continue;
                    }
                    if (exportedEntries.contains(fn.getEntryPoint())) {
                        continue;
                    }
                    List<Integer> bodyStarts = getCodeStartsInBody(fn, parsed.codeInstrStarts);
                    if (bodyStarts.isEmpty() || isFullyCovered(bodyStarts, coveredInstrStarts)) {
                        exportedEntries.add(fn.getEntryPoint());
                        continue;
                    }

                    DecompileResults result = tryDecompile(ifc, fn, 45);
                    RangeInfo ri = getFunctionRangeInBank(fn);

                    writer.write("/* ============================================================ */\n");
                    writer.write("/* " + fn.getName() + " @ " + fn.getEntryPoint() + " */\n");
                    if (ri.start >= 0) {
                        writer.write(String.format("/* ROM range: 0x%04X-0x%04X | ASM covered: %d */\n",
                            ri.start, ri.end, bodyStarts.size()));
                    }
                    writer.write("/* ============================================================ */\n");

                    if (result == null || !result.decompileCompleted() || result.getDecompiledFunction() == null) {
                        writer.write("/* decompile failed */\n\n");
                        countFail++;
                        exportedEntries.add(fn.getEntryPoint());
                        continue;
                    }

                    writer.write(result.getDecompiledFunction().getC());
                    writer.write("\n\n");
                    coveredInstrStarts.addAll(bodyStarts);
                    countOk++;
                    countChunks++;
                    exportedEntries.add(fn.getEntryPoint());
                }
            }
        }
        finally {
            ifc.dispose();
        }

        println("Decompilation export done: " + outputPath);
        println("Listing path: " + listingPath);
        println("Data blocks exported: " + dataBlockCount);
        println("Functions exported: " + countOk);
        println("Chunk functions exported: " + countChunks);
        println("Functions skipped as already covered: " + countDedup);
        println("Functions failed: " + countFail);
        println("Covered instruction starts: " + coveredInstrStarts.size());
    }
}
