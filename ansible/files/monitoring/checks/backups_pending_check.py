import os
import time
from sys import platform

from datadog_checks.base import AgentCheck


class BackupsPendingCheck(AgentCheck):

    def check(self, instance):
        if platform != "linux":
            self.log.debug("Skipping check: Platform is not Linux.")
            return

        path = "/opt/backups/"

        # Handle directory missing error safely to prevent the agent thread from crashing
        if not os.path.exists(path):
            self.log.warning(f"Backup path not found: {path}")
            self.gauge('backups.pending', 0)
            self.gauge('backups.failing', 0)
            return

        try:
            all_files = os.listdir(path)
        except OSError as e:
            self.log.error(f"Unable to read backup directory: {e}")
            return

        now = time.time()
        belated_files = []

        for f in all_files:
            # os.path.join handles trailing/missing slashes cleanly
            full_file_path = os.path.join(path, f)
            try:
                # Filter out directories if you only want to monitor files
                if os.path.isfile(full_file_path):
                    if os.path.getmtime(full_file_path) < now - 1 * 86400:
                        belated_files.append(f)
            except OSError:
                # Catch cases where a file gets deleted mid-execution
                continue

        # Submit metrics to the Agent forwarder
        self.gauge('backups.pending', len(all_files))
        self.gauge('backups.failing', len(belated_files))
