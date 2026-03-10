# Export decompiled C for all discovered functions in current Ghidra program.
#@category Pacman
#@keybinding
#@menupath
#@toolbar

from ghidra.app.decompiler import DecompInterface
from java.io import BufferedWriter, FileWriter


def _open_writer(path):
    return BufferedWriter(FileWriter(path))


args = getScriptArgs()
output_path = 'decomp_bank_ff.c'
if len(args) >= 1 and args[0]:
    output_path = args[0]

ifc = DecompInterface()
ifc.toggleCCode(True)
ifc.toggleSyntaxTree(False)
ifc.setSimplificationStyle('decompile')
ifc.openProgram(currentProgram)

writer = _open_writer(output_path)
count_ok = 0
count_fail = 0

try:
    funcs = currentProgram.getFunctionManager().getFunctions(True)
    while funcs.hasNext() and not monitor.isCancelled():
        fn = funcs.next()
        entry = fn.getEntryPoint()

        result = ifc.decompileFunction(fn, 60, monitor)
        writer.write('/* ============================================================ */\n')
        writer.write('/* %s @ %s */\n' % (fn.getName(), entry))
        writer.write('/* ============================================================ */\n')

        if result is None or not result.decompileCompleted():
            msg = 'decompile failed'
            if result is not None and result.getErrorMessage() is not None:
                msg = result.getErrorMessage().strip()
            writer.write('/* %s */\n\n' % msg)
            count_fail += 1
            continue

        decomp_fn = result.getDecompiledFunction()
        if decomp_fn is None:
            writer.write('/* decompiler returned no function body */\n\n')
            count_fail += 1
            continue

        writer.write(decomp_fn.getC())
        writer.write('\n\n')
        count_ok += 1
finally:
    writer.close()
    ifc.dispose()

print('Decompilation export done: %s' % output_path)
print('Functions exported: %d' % count_ok)
print('Functions failed: %d' % count_fail)
