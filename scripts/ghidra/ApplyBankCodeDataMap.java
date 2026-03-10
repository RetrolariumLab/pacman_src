// Apply code/data map from bank_FF.asm onto current program memory.
// This does not copy original source text; it only restores code/data layout.
//@category Pacman

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.Listing;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ApplyBankCodeDataMap extends GhidraScript {

    private static final Pattern ROW_RE = Pattern.compile(
        "^([C-])\\s+.*00:([0-9A-Fa-f]{4}):\\s+([0-9A-Fa-f]{2}(?:\\s+[0-9A-Fa-f]{2})*)\\b");

    private static class Row {
        int start;
        int end;
        boolean code;
    }

    private static class Segment {
        int start;
        int end;
        boolean code;
    }

    private static int byteCount(String bytes) {
        int n = 0;
        for (String p : bytes.trim().split("\\s+")) {
            if (!p.isEmpty()) {
                n++;
            }
        }
        return n;
    }

    private List<Row> parseRows(String listingPath) throws Exception {
        List<Row> rows = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(listingPath))) {
            String line;
            while ((line = br.readLine()) != null && !monitor.isCancelled()) {
                Matcher m = ROW_RE.matcher(line);
                if (!m.find()) {
                    continue;
                }

                int addr = Integer.parseInt(m.group(2), 16);
                int len = byteCount(m.group(3));
                if (len <= 0 || addr < 0xC000 || addr > 0xFFFF) {
                    continue;
                }

                Row r = new Row();
                r.start = addr;
                r.end = Math.min(0xFFFF, addr + len - 1);
                r.code = "C".equals(m.group(1));
                rows.add(r);
            }
        }
        return rows;
    }

    private List<Segment> buildSegments(List<Row> rows) {
        List<Segment> out = new ArrayList<>();
        if (rows.isEmpty()) {
            return out;
        }

        Collections.sort(rows, new Comparator<Row>() {
            @Override
            public int compare(Row a, Row b) {
                return Integer.compare(a.start, b.start);
            }
        });

        Segment cur = null;
        for (Row r : rows) {
            if (cur == null) {
                cur = new Segment();
                cur.start = r.start;
                cur.end = r.end;
                cur.code = r.code;
                continue;
            }
            if (cur.code == r.code && r.start <= cur.end + 1) {
                cur.end = Math.max(cur.end, r.end);
                continue;
            }
            out.add(cur);
            cur = new Segment();
            cur.start = r.start;
            cur.end = r.end;
            cur.code = r.code;
        }
        out.add(cur);
        return out;
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String listingPath = "bank_FF.asm";
        if (args.length >= 1 && args[0] != null && !args[0].isEmpty()) {
            listingPath = args[0];
        }

        List<Row> rows = parseRows(listingPath);
        List<Segment> segments = buildSegments(rows);
        Listing listing = currentProgram.getListing();

        clearListing(toAddr(0xC000), toAddr(0xFFFF));

        int dataSegs = 0;
        int dataBytes = 0;
        for (Segment s : segments) {
            if (monitor.isCancelled() || s.code) {
                continue;
            }
            dataSegs++;
            for (int a = s.start; a <= s.end; a++) {
                try {
                    createByte(toAddr(a));
                    dataBytes++;
                }
                catch (Exception ignored) {
                    // best effort
                }
            }
        }

        int codeRows = 0;
        int codeInsnStarts = 0;
        int codeInsnMissing = 0;
        for (Row r : rows) {
            if (monitor.isCancelled() || !r.code) {
                continue;
            }
            codeRows++;
            Address a = toAddr(r.start);
            try {
                disassemble(a);
            }
            catch (Exception ignored) {
                // best effort
            }
            Instruction ins = listing.getInstructionAt(a);
            if (ins != null) {
                codeInsnStarts++;
            } else {
                codeInsnMissing++;
            }
        }

        println("Applied bank code/data map from: " + listingPath);
        println("Rows parsed: " + rows.size());
        println("Segments built: " + segments.size());
        println("Data segments: " + dataSegs);
        println("Data bytes typed: " + dataBytes);
        println("Code rows: " + codeRows);
        println("Code starts with instruction: " + codeInsnStarts);
        println("Code starts missing instruction: " + codeInsnMissing);
    }
}
