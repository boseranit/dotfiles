import os
import pathlib
import pty
import select
import signal
import subprocess
import time
import unittest


HELPER = pathlib.Path(__file__).resolve().parents[1] / "home/.config/tmux/is-foreground.sh"


class ForegroundJobsTest(unittest.TestCase):
    def setUp(self):
        self.pid, self.terminal = pty.fork()
        if self.pid == 0:
            os.environ.update(PS1="READY> ", HISTFILE="/dev/null", LC_ALL="C")
            os.execvp("bash", ["bash", "--noprofile", "--norc", "-i"])
        self.read_prompt()
        self.tty = subprocess.check_output(
            ["ps", "-p", str(self.pid), "-o", "tty="], text=True
        ).strip()

    def tearDown(self):
        os.kill(self.pid, signal.SIGHUP)
        os.waitpid(self.pid, 0)
        os.close(self.terminal)

    def read_prompt(self):
        output = b""
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if select.select([self.terminal], [], [], 0.1)[0]:
                output += os.read(self.terminal, 65536)
                if output.endswith(b"READY> "):
                    return
        self.fail(f"Shell did not reach its prompt: {output!r}")

    def start_pipeline(self):
        os.write(self.terminal, b"true | sleep 30\n")
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            processes = subprocess.check_output(
                ["ps", "-t", self.tty, "-o", "pid=,tpgid=,stat=,comm="], text=True
            ).splitlines()
            rows = [line.split() for line in processes]
            for pid, foreground_group, state, command in rows:
                if command == "sleep" and "+" in state:
                    if foreground_group not in {row[0] for row in rows}:
                        return
            time.sleep(0.02)
        self.fail("Pipeline leader did not exit while sleep remained in the foreground")

    def matches_sleep(self):
        return subprocess.run(["sh", str(HELPER), self.tty, "sleep"]).returncode == 0

    def test_matches_pipeline_after_foreground_leader_exits(self):
        self.start_pipeline()
        self.assertTrue(self.matches_sleep())

    def test_ignores_stopped_job_after_shell_regains_foreground(self):
        self.start_pipeline()
        os.write(self.terminal, b"\x1a")
        self.read_prompt()
        self.assertFalse(self.matches_sleep())

    def test_ignores_running_background_job(self):
        os.write(self.terminal, b"sleep 30 &\n")
        self.read_prompt()
        self.assertFalse(self.matches_sleep())


if __name__ == "__main__":
    unittest.main()
