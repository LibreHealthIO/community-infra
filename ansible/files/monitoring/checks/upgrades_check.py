import os
import time
import subprocess
from sys import platform

from datadog_checks.base import AgentCheck


class UpgradesCheck(AgentCheck):

    def check(self, instance):
        if platform != "linux":
            self.log.debug("Skipping check: Platform is not Linux.")
            return

        output = self.get_subprocess_output()
        if output is None:
            return

        # Python 3 requires decoding bytes to a string before splitting
        output_str = output.decode('utf-8').strip()
        parts = output_str.split(';', 1)

        if len(parts) != 2:
            self.log.debug(f"Unknown format from apt-check: {output_str}")
            return

        num_updates, num_security = parts
        try:
            num_updates = int(num_updates)
            num_security = int(num_security)
        except ValueError as e:
            self.log.debug(f"Could not convert to integer: {e}")
            return

        # Post modern custom gauge metrics
        self.gauge('updates.available', num_updates)
        self.gauge('updates.security', num_security)

        pending_reboot = os.path.isfile('/var/run/reboot-required')
        self.gauge('updates.restart.required', int(pending_reboot))

        # Check if pending reboot is over a week old
        now = time.time()
        if pending_reboot and os.path.getmtime('/var/run/reboot-required') < (
                now - 7 * 86400):
            pending_reboot_belated = 1
        else:
            pending_reboot_belated = 0

        self.gauge('updates.restart.belated', pending_reboot_belated)

    def get_subprocess_output(self):
        """Run apt-check and handle process execution safely."""
        try:
            output = subprocess.check_output(
                ['/usr/lib/update-notifier/apt-check'],
                stderr=subprocess.STDOUT)
            self.log.debug(f"Ran apt-check successfully: {output}")
            return output
        except subprocess.CalledProcessError as e:
            self.log.debug(
                f"Could not run apt-check. Exit code: {e.returncode}")
            return None
        except FileNotFoundError:
            self.log.debug(
                "/usr/lib/update-notifier/apt-check not found on this system.")
            return None
