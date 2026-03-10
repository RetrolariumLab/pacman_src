// Import labels/comments from bank_FF.asm into current Ghidra program.
//@category Pacman

import ghidra.app.script.GhidraScript;
import ghidra.program.model.symbol.SourceType;
import ghidra.program.model.listing.Function;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.Listing;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ImportBankFfListing extends GhidraScript {

    private static final Pattern LABEL_RE = Pattern.compile("^\\s*([A-Za-z_][A-Za-z0-9_]*)\\s*:\\s*$");
    private static final Pattern ADDR_RE = Pattern.compile("0x([0-9A-Fa-f]{6})\\s+00:([0-9A-Fa-f]{4}):");
    private static final Pattern COMMENT_RE = Pattern.compile(";\\s*(.+)$");

    private boolean isCodeSymbol(String name) {
        return name.startsWith("vec_") ||
               name.startsWith("sub_") ||
               name.startsWith("loc_") ||
               name.startsWith("bra_") ||
               name.startsWith("ofs_") ||
               name.startsWith("off_");
    }

    private void tryDisassemble(Address addr) {
        try {
            disassemble(addr);
        }
        catch (Exception ignored) {
            // Best effort.
        }
    }

    private boolean maybeCreateFunction(String name, Address addr) {
        if (!(name.startsWith("vec_") || name.startsWith("sub_"))) {
            return false;
        }

        Function existing = getFunctionAt(addr);
        if (existing != null) {
            if (!name.equals(existing.getName())) {
                try {
                    existing.setName(name, SourceType.USER_DEFINED);
                }
                catch (Exception ignored) {
                    // keep existing name
                }
            }
            return false;
        }

        Listing listing = currentProgram.getListing();
        Instruction ins = listing.getInstructionAt(addr);
        if (ins == null) {
            try {
                clearListing(addr, addr);
            }
            catch (Exception ignored) {
                // best effort
            }
        }
        tryDisassemble(addr);

        try {
            return createFunction(addr, name) != null;
        }
        catch (Exception ignored) {
            return false;
        }
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String listingPath = "bank_FF.asm";
        if (args.length >= 1 && args[0] != null && !args[0].isEmpty()) {
            listingPath = args[0];
        }

        List<String> pendingLabels = new ArrayList<>();
        int labelsCreated = 0;
        int functionsCreated = 0;
        int commentsAdded = 0;

        try (BufferedReader br = new BufferedReader(new FileReader(listingPath))) {
            String line;
            while ((line = br.readLine()) != null && !monitor.isCancelled()) {

                Matcher lm = LABEL_RE.matcher(line);
                if (lm.matches()) {
                    pendingLabels.add(lm.group(1));
                    continue;
                }

                Matcher am = ADDR_RE.matcher(line);
                if (!am.find()) {
                    continue;
                }

                int cpuAddr = Integer.parseInt(am.group(2), 16);
                Address addr = toAddr(cpuAddr);

                if (!pendingLabels.isEmpty()) {
                    for (String name : pendingLabels) {
                        try {
                            createLabel(addr, name, true, SourceType.USER_DEFINED);
                            labelsCreated++;
                        }
                        catch (Exception ignored) {
                            // Ignore duplicate / invalid label names.
                        }

                        if (isCodeSymbol(name) && maybeCreateFunction(name, addr)) {
                            functionsCreated++;
                        }
                        else if (isCodeSymbol(name)) {
                            tryDisassemble(addr);
                        }
                    }
                    pendingLabels.clear();
                }

                Matcher cm = COMMENT_RE.matcher(line);
                if (cm.find()) {
                    String comment = cm.group(1).trim();
                    if (!comment.isEmpty()) {
                        String old = getEOLComment(addr);
                        if (old == null || old.trim().isEmpty()) {
                            setEOLComment(addr, comment);
                            commentsAdded++;
                        }
                    }
                }
            }
        }

        println("Listing imported: " + listingPath);
        println("Labels created: " + labelsCreated);
        println("Functions created: " + functionsCreated);
        println("Comments added: " + commentsAdded);
    }
}
