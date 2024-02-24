import subprocess
from pathlib import Path


class LedgerCommandBuilder:
    def __init__(self):
        self.command = ["ledger"]

    def build(self) -> List[str]:
        return self.command


class LedgerCli:
    def __init__(self):
        self.command = [
            "ledger",
            "b",
            "-f",
            Path("~/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt"),
            "Expenses",
        ]

    def run(self, output_filename):
        print("test print : ls ")
        proc = subprocess.run(
            self.command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        print(proc.stdout.decode("utf-8"))
