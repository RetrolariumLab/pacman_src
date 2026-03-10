# Import labels/comments from bank_FF.asm into current Ghidra program.
#@category Pacman
#@keybinding
#@menupath
#@toolbar

from ghidra.program.model.listing import CodeUnit
import re

LABEL_RE = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*$')
ADDR_RE = re.compile(r'0x([0-9A-Fa-f]{6})\s+00:([0-9A-Fa-f]{4}):')
COMMENT_RE = re.compile(r';\s*(.+)$')


def _load_lines(path):
    f = open(path, 'r')
    try:
        return f.readlines()
    finally:
        f.close()


def _is_code_symbol(name):
    prefixes = ('vec_', 'sub_', 'loc_', 'ofs_', 'off_')
    return name.startswith(prefixes)


def _maybe_create_function(name, addr):
    if not (name.startswith('vec_') or name.startswith('sub_')):
        return False
    if getFunctionAt(addr) is not None:
        return False

    # Best effort: disassemble first, then create function.
    try:
        disassemble(addr)
    except Exception:
        pass

    try:
        createFunction(addr, name)
        return True
    except Exception:
        return False


args = getScriptArgs()
listing_path = 'bank_FF.asm'
if len(args) >= 1 and args[0]:
    listing_path = args[0]

lines = _load_lines(listing_path)

pending_labels = []
labels_created = 0
functions_created = 0
comments_added = 0

for raw in lines:
    line = raw.rstrip('\n')

    lm = LABEL_RE.match(line)
    if lm:
        pending_labels.append(lm.group(1))
        continue

    am = ADDR_RE.search(line)
    if not am:
        continue

    cpu_addr = int(am.group(2), 16)
    addr = toAddr(cpu_addr)

    if pending_labels:
        for name in pending_labels:
            try:
                createLabel(addr, name, True)
                labels_created += 1
            except Exception:
                # Ignore duplicate / invalid names.
                pass

            if _is_code_symbol(name) and _maybe_create_function(name, addr):
                functions_created += 1
        pending_labels = []

    cm = COMMENT_RE.search(line)
    if cm:
        comment = cm.group(1).strip()
        if comment:
            cu = getCodeUnitAt(addr)
            if cu is not None:
                old = cu.getComment(CodeUnit.EOL_COMMENT)
                if old is None or len(old.strip()) == 0:
                    cu.setComment(CodeUnit.EOL_COMMENT, comment)
                    comments_added += 1

print('Listing imported: %s' % listing_path)
print('Labels created: %d' % labels_created)
print('Functions created: %d' % functions_created)
print('Comments added: %d' % comments_added)
