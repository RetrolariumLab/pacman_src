// Analyze missing instruction coverage from CheckDecompCoverage report.
// Produces grouped diagnostics by function and address ranges.
//@category Pacman

import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.Listing;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolTable;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AnalyzeDecompCoverageGaps extends GhidraScript {

    private static final Pattern MISSING_RE = Pattern.compile("^\\s*-\\s*0x([0-9A-Fa-f]{4})\\s*$");

    private static class FnStats {
        Function fn; // null means no containing function
        List<Integer> addrs = new ArrayList<>();
        boolean decompOk = false;
        String decompErr = "";
    }

    private static class Range {
        int start;
        int end;
        List<Integer> addrs = new ArrayList<>();
        String owner;
    }

    private static String shortErr(String s) {
        if (s == null) {
            return "";
        }
        String t = s.replace('\n', ' ').trim();
        if (t.length() <= 160) {
            return t;
        }
        return t.substring(0, 160) + "...";
    }

    private List<Integer> parseMissingAddrs(String reportPath) throws Exception {
        List<Integer> out = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(reportPath))) {
            String line;
            while ((line = br.readLine()) != null && !monitor.isCancelled()) {
                Matcher m = MISSING_RE.matcher(line);
                if (m.find()) {
                    out.add(Integer.parseInt(m.group(1), 16));
                }
            }
        }
        Collections.sort(out);
        return out;
    }

    private String ownerForAddr(Function fn) {
        if (fn == null) {
            return "<no_function>";
        }
        return fn.getName() + " @" + fn.getEntryPoint();
    }

    private String firstLabelAt(Address a) {
        SymbolTable st = currentProgram.getSymbolTable();
        Symbol[] syms = st.getSymbols(a);
        if (syms == null || syms.length == 0) {
            return "";
        }
        for (Symbol s : syms) {
            String n = s.getName();
            if (n != null && !n.isBlank()) {
                return n;
            }
        }
        return "";
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String reportPath = "decomp_coverage_report.txt";
        String outPath = "decomp_coverage_diagnostics.txt";
        if (args.length >= 1 && args[0] != null && !args[0].isEmpty()) {
            reportPath = args[0];
        }
        if (args.length >= 2 && args[1] != null && !args[1].isEmpty()) {
            outPath = args[1];
        }

        List<Integer> missing = parseMissingAddrs(reportPath);
        Listing listing = currentProgram.getListing();

        Map<String, FnStats> byFn = new LinkedHashMap<>();
        for (int aInt : missing) {
            Address a = toAddr(aInt);
            Function fn = getFunctionContaining(a);
            String key = ownerForAddr(fn);
            FnStats st = byFn.get(key);
            if (st == null) {
                st = new FnStats();
                st.fn = fn;
                byFn.put(key, st);
            }
            st.addrs.add(aInt);
        }

        DecompInterface ifc = new DecompInterface();
        ifc.toggleCCode(true);
        ifc.toggleSyntaxTree(false);
        ifc.setSimplificationStyle("decompile");
        ifc.openProgram(currentProgram);
        try {
            for (FnStats st : byFn.values()) {
                if (monitor.isCancelled()) {
                    break;
                }
                if (st.fn == null) {
                    st.decompOk = false;
                    st.decompErr = "no containing function";
                    continue;
                }
                DecompileResults r = ifc.decompileFunction(st.fn, 30, monitor);
                if (r != null && r.decompileCompleted() && r.getDecompiledFunction() != null) {
                    st.decompOk = true;
                    st.decompErr = "";
                } else {
                    st.decompOk = false;
                    st.decompErr = (r == null) ? "null decompile result" : shortErr(r.getErrorMessage());
                }
            }
        } finally {
            ifc.dispose();
        }

        // Build gap ranges (addresses are instruction starts; keep small gaps in same range).
        List<Range> ranges = new ArrayList<>();
        if (!missing.isEmpty()) {
            Range cur = new Range();
            cur.start = missing.get(0);
            cur.end = missing.get(0);
            cur.addrs.add(missing.get(0));
            cur.owner = ownerForAddr(getFunctionContaining(toAddr(missing.get(0))));
            for (int i = 1; i < missing.size(); i++) {
                int a = missing.get(i);
                String owner = ownerForAddr(getFunctionContaining(toAddr(a)));
                if (a - cur.end <= 3 && owner.equals(cur.owner)) {
                    cur.end = a;
                    cur.addrs.add(a);
                } else {
                    ranges.add(cur);
                    cur = new Range();
                    cur.start = a;
                    cur.end = a;
                    cur.addrs.add(a);
                    cur.owner = owner;
                }
            }
            ranges.add(cur);
        }

        List<Map.Entry<String, FnStats>> fnList = new ArrayList<>(byFn.entrySet());
        Collections.sort(fnList, new Comparator<Map.Entry<String, FnStats>>() {
            @Override
            public int compare(Map.Entry<String, FnStats> a, Map.Entry<String, FnStats> b) {
                return Integer.compare(b.getValue().addrs.size(), a.getValue().addrs.size());
            }
        });

        try (BufferedWriter w = new BufferedWriter(new FileWriter(outPath))) {
            w.write("=== COVERAGE GAP DIAGNOSTICS ===\n");
            w.write("report source: " + reportPath + "\n");
            w.write("program: " + currentProgram.getName() + "\n");
            w.write("missing instruction addresses: " + missing.size() + "\n");
            w.write("affected function buckets: " + fnList.size() + "\n\n");

            w.write("== By Function ==\n");
            for (Map.Entry<String, FnStats> e : fnList) {
                FnStats st = e.getValue();
                int first = st.addrs.get(0);
                int last = st.addrs.get(st.addrs.size() - 1);
                w.write("- " + e.getKey());
                w.write(" | missing=" + st.addrs.size());
                w.write(" | range=0x" + String.format("%04X", first) + "-0x" + String.format("%04X", last));
                w.write(" | decomp=" + (st.decompOk ? "ok" : "fail"));
                if (!st.decompOk) {
                    w.write(" | err=" + shortErr(st.decompErr));
                }
                w.write("\n");
            }

            w.write("\n== Missing Ranges ==\n");
            for (Range r : ranges) {
                Address a0 = toAddr(r.start);
                Instruction ins = listing.getInstructionAt(a0);
                String firstIns = (ins == null) ? "<no ins>" : ins.toString();
                String lbl = firstLabelAt(a0);
                w.write("- 0x" + String.format("%04X", r.start) + "-0x" + String.format("%04X", r.end));
                w.write(" | count=" + r.addrs.size());
                w.write(" | owner=" + r.owner);
                if (!lbl.isEmpty()) {
                    w.write(" | label=" + lbl);
                }
                w.write(" | first=" + firstIns + "\n");
            }
        }

        println("Coverage diagnostics written: " + outPath);
        println("Missing addresses: " + missing.size());
        println("Function buckets: " + fnList.size());
        println("Ranges: " + ranges.size());
    }
}
