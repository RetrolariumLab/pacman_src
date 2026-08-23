import importlib.util
import sys
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "workflow" / "analyze_revision_alignment.py"
SPEC = importlib.util.spec_from_file_location("analyze_revision_alignment", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class RevisionAlignmentTests(unittest.TestCase):
    def test_inserted_region_changes_later_address_delta(self):
        reference = b"AAAABBBBCCCCDDDD"
        candidate = b"AAAAXXXXBBBBCCCCDDDD"
        blocks, changes = MODULE.analyze(reference, candidate, min_block=4)

        self.assertEqual([(block.a, block.b, block.size) for block in blocks], [(0, 0, 4), (4, 8, 12)])
        self.assertEqual(changes, [("insert", 4, 4, 4, 8)])

    def test_address_uses_nrom_cpu_window(self):
        self.assertEqual(MODULE.address(0), "$C000")
        self.assertEqual(MODULE.address(0x3FFF), "$FFFF")


if __name__ == "__main__":
    unittest.main()
