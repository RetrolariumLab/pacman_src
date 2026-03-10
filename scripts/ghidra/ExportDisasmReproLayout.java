// Export memory-order disassembly layout suitable for reproducible assembly.
// Uses label placement from bank_FF.asm and bytes from current Ghidra program.
//@category Pacman

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.Listing;
import ghidra.program.model.mem.Memory;
import ghidra.program.model.mem.MemoryAccessException;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolIterator;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ExportDisasmReproLayout extends GhidraScript {

    private static final int BANK_START = 0xC000;
    private static final int VECTORS_START = 0xFFFA;
    private static final int BANK_END = 0xFFFF;

    private static final Pattern LABEL_RE = Pattern.compile("^\\s*([A-Za-z_][A-Za-z0-9_]*)\\s*:\\s*(?:;.*)?$");
    private static final Pattern ADDR_RE = Pattern.compile("0x([0-9A-Fa-f]{6})\\s+00:([0-9A-Fa-f]{4}):");
    private static final Pattern KIND_RE = Pattern.compile("^\\s*([C-])\\s");

    private static String fmtBytes(List<Integer> bytes) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < bytes.size(); i++) {
            if (i != 0) {
                sb.append(", ");
            }
            sb.append(String.format("$%02X", bytes.get(i) & 0xff));
        }
        return sb.toString();
    }

    private static boolean isBankStyleLabel(String name) {
        return name.startsWith("vec_") ||
               name.startsWith("sub_") ||
               name.startsWith("loc_") ||
               name.startsWith("bra_") ||
               name.startsWith("tbl_") ||
               name.startsWith("off_") ||
               name.startsWith("ofs_") ||
               name.startsWith("_off");
    }

    private static String bytesToHexList(byte[] bytes) {
        List<Integer> vals = new ArrayList<>();
        for (byte b : bytes) {
            vals.add(b & 0xff);
        }
        return fmtBytes(vals);
    }

    private Map<Integer, List<String>> parseLabelMap(String listingPath) throws Exception {
        Map<Integer, List<String>> labelsByAddr = new LinkedHashMap<>();
        List<String> pending = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader(listingPath))) {
            String line;
            while ((line = br.readLine()) != null && !monitor.isCancelled()) {
                Matcher lm = LABEL_RE.matcher(line);
                if (lm.matches()) {
                    pending.add(lm.group(1));
                    continue;
                }

                Matcher am = ADDR_RE.matcher(line);
                if (!am.find()) {
                    continue;
                }

                int addr = Integer.parseInt(am.group(2), 16);
                if (addr < BANK_START || addr > BANK_END) {
                    pending.clear();
                    continue;
                }

                if (!pending.isEmpty()) {
                    List<String> out = labelsByAddr.get(addr);
                    if (out == null) {
                        out = new ArrayList<>();
                        labelsByAddr.put(addr, out);
                    }
                    for (String name : pending) {
                        if (!isBankStyleLabel(name)) {
                            continue;
                        }
                        if (!out.contains(name)) {
                            out.add(name);
                        }
                    }
                    pending.clear();
                }
            }
        }

        return labelsByAddr;
    }

    private boolean[] parseCodeMask(String listingPath) throws Exception {
        class Row {
            int addr;
            boolean code;
            Row(int addr, boolean code) {
                this.addr = addr;
                this.code = code;
            }
        }

        List<Row> rows = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(listingPath))) {
            String line;
            while ((line = br.readLine()) != null && !monitor.isCancelled()) {
                Matcher am = ADDR_RE.matcher(line);
                if (!am.find()) {
                    continue;
                }
                int addr = Integer.parseInt(am.group(2), 16);
                if (addr < BANK_START || addr > BANK_END) {
                    continue;
                }
                Matcher km = KIND_RE.matcher(line);
                boolean code = km.find() && "C".equals(km.group(1));
                rows.add(new Row(addr, code));
            }
        }

        Collections.sort(rows, (a, b) -> Integer.compare(a.addr, b.addr));
        boolean[] mask = new boolean[0x10000];
        for (int i = 0; i < rows.size(); i++) {
            Row cur = rows.get(i);
            int next = (i + 1 < rows.size()) ? rows.get(i + 1).addr : (BANK_END + 1);
            if (next <= cur.addr) {
                continue;
            }
            int start = Math.max(cur.addr, BANK_START);
            int end = Math.min(next, BANK_END + 1);
            for (int a = start; a < end; a++) {
                mask[a] = cur.code;
            }
        }
        return mask;
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String outputPath = "pacman_repro_layout_disasm.asm";
        String listingPath = "bank_FF.asm";
        if (args.length >= 1 && args[0] != null && !args[0].isEmpty()) {
            outputPath = args[0];
        }
        if (args.length >= 2 && args[1] != null && !args[1].isEmpty()) {
            listingPath = args[1];
        }

        Map<Integer, List<String>> labelsByAddr = parseLabelMap(listingPath);
        boolean[] codeMask = parseCodeMask(listingPath);
        Set<Integer> labelAddrs = new TreeSet<>(labelsByAddr.keySet());
        Set<String> emitted = new LinkedHashSet<>();
        Memory mem = currentProgram.getMemory();
        Listing listing = currentProgram.getListing();

        int totalLines = 0;
        int totalLabels = 0;
        int cur = BANK_START;

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputPath))) {
            writer.write("; ============================================================\n");
            writer.write("; Memory-order export for reproducible assembly\n");
            writer.write("; Labels sourced from: " + listingPath + "\n");
            writer.write("; Bytes sourced from current Ghidra program memory\n");
            writer.write("; ============================================================\n\n");
            writer.write(".setcpu \"6502\"\n\n");
            writer.write(".segment \"BANK_FF\"\n\n");

            while (cur <= BANK_END && !monitor.isCancelled()) {
                if (cur == VECTORS_START) {
                    writer.write("\n.segment \"VECTORS\"\n\n");
                }

                List<String> names = labelsByAddr.get(cur);
                if (names != null) {
                    for (String n : names) {
                        writer.write(n + ":\n");
                        emitted.add(n);
                        totalLabels++;
                    }
                }

                int nextStop = BANK_END + 1;
                for (Integer a : labelAddrs) {
                    if (a > cur) {
                        nextStop = a.intValue();
                        break;
                    }
                }
                if (cur < VECTORS_START && nextStop > VECTORS_START) {
                    nextStop = VECTORS_START;
                }
                if (nextStop <= cur) {
                    nextStop = cur + 1;
                }

                while (cur < nextStop && cur <= BANK_END && !monitor.isCancelled()) {
                    // In code ranges emit one line per instruction for readability:
                    // byte-exact payload + mnemonic comment.
                    if (codeMask[cur]) {
                        Instruction ins = listing.getInstructionAt(toAddr(cur));
                        if (ins != null) {
                            int len = ins.getLength();
                            if (len > 0 && cur + len <= nextStop) {
                                String bytesTxt = "";
                                try {
                                    bytesTxt = bytesToHexList(ins.getBytes());
                                }
                                catch (MemoryAccessException ignored) {
                                    bytesTxt = "";
                                }
                                String asm = ins.toString();
                                writer.write("    .byte " + bytesTxt + "  ; $" + String.format("%04X", cur) + "  " + asm + "\n");
                                totalLines++;
                                cur += len;
                                continue;
                            }
                        }
                    }

                    // Data / fallback path.
                    int chunkEnd = Math.min(nextStop, cur + 16);
                    List<Integer> bytes = new ArrayList<>();
                    for (int a = cur; a < chunkEnd; a++) {
                        Address addr = toAddr(a);
                        int b = 0;
                        try {
                            if (mem.contains(addr)) {
                                b = mem.getByte(addr) & 0xff;
                            }
                        }
                        catch (MemoryAccessException ignored) {
                            // Keep zero as a defensive fallback.
                        }
                        bytes.add(b);
                    }
                    writer.write("    .byte " + fmtBytes(bytes) + "  ; $" + String.format("%04X", cur) + "\n");
                    totalLines++;
                    cur = chunkEnd;
                }
            }

            // Report labels present in Ghidra but not mapped from listing.
            writer.write("\n; ============================================================\n");
            writer.write("; Extra bank-style labels in Ghidra (not present at parsed listing addresses)\n");
            writer.write("; ============================================================\n");
            List<String> extras = new ArrayList<>();
            SymbolIterator sit = currentProgram.getSymbolTable().getAllSymbols(true);
            while (sit.hasNext()) {
                Symbol s = sit.next();
                String n = s.getName();
                if (n == null || n.isBlank() || !isBankStyleLabel(n) || emitted.contains(n)) {
                    continue;
                }
                extras.add("; " + n + ": @" + s.getAddress());
            }
            Collections.sort(extras);
            for (String e : extras) {
                writer.write(e + "\n");
            }
        }

        println("Repro-layout disasm export done: " + outputPath);
        println("Data lines exported: " + totalLines);
        println("Labels emitted: " + totalLabels);
    }
}
