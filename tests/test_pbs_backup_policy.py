"""PBS must not snapshot itself while receiving the cluster backups."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_GUESTS = {
    '100', '110', '111', '112', '113', '114', '115', '120', '125',
    '126', '151', '152', '153', '160', '180', '181', '200', '201',
}


class PbsBackupPolicyTests(unittest.TestCase):
    def test_explicit_guest_coverage_excludes_the_backup_server(self):
        text = (ROOT / 'vms/storage.tf').read_text()
        job = text.split('resource "proxmox_backup_job" "pbs_daily_backup" {', 1)[1]
        job = job.split('\nresource ', 1)[0]
        # The installed provider rejects all + vmid even when all is false.
        self.assertNotRegex(job, r'\ball\s*=')
        match = re.search(r'\bvmid\s*=\s*\[([^]]*)\]', job, re.S)
        self.assertIsNotNone(match)
        assert match is not None
        ids = re.findall(r'"([0-9]+)"', match.group(1))
        self.assertEqual(set(ids), EXPECTED_GUESTS)
        self.assertEqual(len(ids), len(EXPECTED_GUESTS))
        self.assertNotIn('154', ids)
        self.assertNotIn('9153', ids)
        self.assertNotIn('176', ids)


    def test_verified_backups_are_scheduled_daily_with_original_retention(self):
        text = (ROOT / 'vms/storage.tf').read_text()
        job = text.split('resource "proxmox_backup_job" "pbs_daily_backup" {', 1)[1]
        job = job.split('\nresource ', 1)[0]
        self.assertRegex(job, r'\benabled\s*=\s*true\b')
        self.assertRegex(job, r'\bschedule\s*=\s*"02:00"')
        self.assertRegex(job, r'\bstorage\s*=\s*proxmox_storage_pbs\.pbs_lxc\.id')
        for policy, count in [('keep-last', '7'), ('keep-daily', '7'), ('keep-weekly', '4')]:
            self.assertRegex(job, rf'{policy}\s*=\s*"{count}"')


if __name__ == '__main__':
    unittest.main()
