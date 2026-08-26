from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "workflow"))

from check_scoring_trace_setup import EXPECTED_HOOKS, validate_hooks  # noqa: E402


class ScoringTraceSetupTests(unittest.TestCase):
    def test_scoring_hooks_follow_semantic_labels(self) -> None:
        labels = "".join(
            f"al 00C000 .{symbol}\n" for symbol in EXPECTED_HOOKS.values()
        )
        lua = "\n".join(
            f'memory.registerexecute(symbol("{symbol}"), '
            f'function() emit("{event}") end)'
            for event, symbol in EXPECTED_HOOKS.items()
        )

        self.assertEqual(validate_hooks(labels, lua), [])

    def test_wrong_scoring_symbol_is_rejected(self) -> None:
        labels = "".join(
            f"al 00C000 .{symbol}\n" for symbol in EXPECTED_HOOKS.values()
        )
        labels += "al 00C100 .wrong_symbol\n"
        lua = (
            'memory.registerexecute(symbol("wrong_symbol"), '
            'function() emit("power_pellet") end)'
        )

        failures = validate_hooks(labels, lua)
        self.assertTrue(any("wrong semantic hook" in failure for failure in failures))


if __name__ == "__main__":
    unittest.main()
