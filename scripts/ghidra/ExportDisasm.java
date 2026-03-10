// Export instruction disassembly from current Ghidra program.
//@category Pacman

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.InstructionIterator;
import ghidra.program.model.listing.Listing;
import ghidra.program.model.mem.Memory;
import ghidra.program.model.mem.MemoryAccessException;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolIterator;
import ghidra.program.model.symbol.SymbolTable;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class ExportDisasm extends GhidraScript {

    private static final int MAX_DATA_BYTES = 0x200;

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < bytes.length; i++) {
            if (i != 0) {
                sb.append(' ');
            }
            sb.append(String.format("%02X", bytes[i] & 0xff));
        }
        return sb.toString();
    }

    private static boolean isExportDataSymbol(String name) {
        return name.startsWith("tbl_") ||
               name.startsWith("off_") ||
               name.startsWith("ofs_") ||
               name.startsWith("_off");
    }

    private static boolean isBankStyleLabel(String name) {
        return name.startsWith("vec_") ||
               name.startsWith("sub_") ||
               name.startsWith("loc_") ||
               name.startsWith("bra_") ||
               isExportDataSymbol(name);
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

    private int writeDataSection(BufferedWriter writer, Set<String> emittedLabels) throws Exception {
        Memory mem = currentProgram.getMemory();
        Listing listing = currentProgram.getListing();
        List<Symbol> symbols = collectDataSymbols();
        int written = 0;

        writer.write("; ============================================================\n");
        writer.write("; tbl_*/off_*/ofs_*/_off* data symbols imported from bank_FF.asm\n");
        writer.write("; ============================================================\n\n");

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

            // Emit all bank-style data labels at this address (aliases included),
            // so they do not appear later as "orphan".
            List<String> labelsAtStart = getAllSymbolNamesAt(start);
            boolean wroteAnyLabel = false;
            for (String lbl : labelsAtStart) {
                if (!isExportDataSymbol(lbl)) {
                    continue;
                }
                if (!wroteAnyLabel) {
                    writer.write(lbl + ": ; @" + start + ", size=" + size + "\n");
                    wroteAnyLabel = true;
                }
                else {
                    writer.write(lbl + ":\n");
                }
                emittedLabels.add(lbl);
            }
            if (!wroteAnyLabel) {
                writer.write(cur.getName() + ": ; @" + start + ", size=" + size + "\n");
                emittedLabels.add(cur.getName());
            }
            for (int off = 0; off < size; off += 16) {
                int chunk = Math.min(16, size - off);
                StringBuilder bytes = new StringBuilder();
                for (int j = 0; j < chunk; j++) {
                    if (j != 0) {
                        bytes.append(", ");
                    }
                    int b = 0;
                    try {
                        b = mem.getByte(start.add(off + j)) & 0xff;
                    }
                    catch (MemoryAccessException ignored) {
                        // Keep zero.
                    }
                    bytes.append(String.format("$%02X", b));
                }
                writer.write(String.format("    .byte %s\n", bytes));
            }
            writer.write("\n");
            written++;
        }

        return written;
    }

    private List<String> getAllSymbolNamesAt(Address address) {
        SymbolTable st = currentProgram.getSymbolTable();
        Symbol[] syms = st.getSymbols(address);
        Set<String> uniq = new LinkedHashSet<>();
        for (Symbol s : syms) {
            String n = s.getName();
            if (n != null && !n.isBlank()) {
                uniq.add(n);
            }
        }
        return new ArrayList<>(uniq);
    }

    private int writeOrphanLabels(BufferedWriter writer, Set<String> emittedLabels) throws Exception {
        SymbolIterator it = currentProgram.getSymbolTable().getAllSymbols(true);
        int count = 0;
        writer.write("\n; ============================================================\n");
        writer.write("; orphan labels (present in symbol table, not emitted above)\n");
        writer.write("; ============================================================\n");
        while (it.hasNext() && !monitor.isCancelled()) {
            Symbol s = it.next();
            String n = s.getName();
            if (n == null || n.isBlank() || emittedLabels.contains(n) || !isBankStyleLabel(n)) {
                continue;
            }
            writer.write(n + ": ; @" + s.getAddress() + " (orphan)\n");
            emittedLabels.add(n);
            count++;
        }
        return count;
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String outputPath = "disasm_bank_ff.asm";
        if (args.length >= 1 && args[0] != null && !args[0].isEmpty()) {
            outputPath = args[0];
        }

        int count = 0;
        int dataBlockCount = 0;
        int orphanLabelCount = 0;
        Set<String> emittedLabels = new LinkedHashSet<>();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputPath))) {
            dataBlockCount = writeDataSection(writer, emittedLabels);

            InstructionIterator ii = currentProgram.getListing().getInstructions(true);
            while (ii.hasNext() && !monitor.isCancelled()) {
                Instruction ins = ii.next();
                List<String> labelNames = getAllSymbolNamesAt(ins.getAddress());
                for (String name : labelNames) {
                    if (!isBankStyleLabel(name)) {
                        continue;
                    }
                    writer.write(name);
                    writer.write(":\n");
                    emittedLabels.add(name);
                }

                String bytes = "";
                try {
                    bytes = bytesToHex(ins.getBytes());
                }
                catch (MemoryAccessException ignored) {
                    // Leave bytes empty on access issues.
                }

                String text = ins.toString();
                writer.write(String.format("%s: %-11s %s\n", ins.getAddress(), bytes, text));
                count++;
            }

            orphanLabelCount = writeOrphanLabels(writer, emittedLabels);
        }

        println("Disassembly export done: " + outputPath);
        println("Data blocks exported: " + dataBlockCount);
        println("Instructions exported: " + count);
        println("Orphan labels exported: " + orphanLabelCount);
    }
}
