from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "workflow"))

from validate_runtime_traces import (  # noqa: E402
    check_ghost_releases,
    check_intermission,
    check_mode_boundaries,
    check_pause_resume,
    check_sound_classes,
)


def row(event: str, detail: str = "", **values: str) -> dict[str, str]:
    return {"event": event, "detail": detail, **values}


class RuntimeTraceTests(unittest.TestCase):
    def test_all_three_house_slots_must_reach_active_state(self) -> None:
        rows = []
        for before, queued, active in (
            ("04000000", "04020000", "04040000"),
            ("04040000", "04040200", "04040400"),
            ("04040400", "04040402", "04040404"),
        ):
            rows.extend([
                row("ghost_states_changed", f"{before}>{queued}"),
                row("ghost_states_changed", f"{queued}>{active}"),
            ])
        self.assertTrue(check_ghost_releases(rows))
        self.assertFalse(check_ghost_releases(rows[:-1]))

    def test_mode_boundaries_require_reversal_evidence(self) -> None:
        rows = [
            row("mode_phase_changed", "00>01"), row("ghost_reversal"),
            row("mode_phase_changed", "01>02"),
            row("mode_phase_changed", "02>03"), row("ghost_reversal"),
        ]
        self.assertTrue(check_mode_boundaries(rows))
        self.assertFalse(check_mode_boundaries(rows[:-1]))

    def test_intermission_requires_entry_substates_and_exit(self) -> None:
        rows = [row("script_changed", "0E>10")]
        rows.extend(row("intermission_state_changed", scene="02", substate=value) for value in ("00", "02", "04"))
        rows.append(row("script_changed", "10>00"))
        self.assertTrue(check_intermission(rows, "02", {"00", "02", "04"}))

    def test_pause_and_sound_checks_are_value_aware(self) -> None:
        pause = [row("pause_changed", "00>01"), row("pause_changed", "01>02")]
        sound = [
            row("sound_note", "ch00:31"), row("sound_duration", "ch00:C0"),
            row("sound_control", "ch00:F0"), row("sound_control", "ch04:F5"),
        ]
        self.assertTrue(check_pause_resume(pause))
        self.assertTrue(check_sound_classes(sound))


if __name__ == "__main__":
    unittest.main()
