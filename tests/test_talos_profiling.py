"""Profiling can read kernel symbols without exposing them to unprivileged users."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class TalosProfilingTests(unittest.TestCase):
    def test_only_workers_allow_privileged_kernel_symbol_reads(self):
        text = (ROOT / 'talos/main.tf').read_text()
        before_workers, workers = text.split('data "talos_machine_configuration" "worker" {', 1)
        self.assertRegex(workers, r'"kernel\.kptr_restrict"\s*=\s*"1"')
        self.assertNotIn('kernel.kptr_restrict', before_workers)
        self.assertNotRegex(text, r'"kernel\.kptr_restrict"\s*=\s*"0"')


if __name__ == '__main__':
    unittest.main()
