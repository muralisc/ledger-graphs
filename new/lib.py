import subprocess
from pathlib import Path
from typing import List


class LedgerCommandBuilder:
    def __init__(self):
        self.command = ["ledger"]

    def add_ledger_file(self, filepath: Path):
        self.command.extend(["-f", filepath])
        return self

    def add_ledger_pricedb(self, filepath: Path):
        self.command.extend(["--price-db", filepath])
        return self

    def add_begin(self, yyyy_mm_dd):
        self.command.extend(["--begin", yyyy_mm_dd])
        return self

    def add_end(self, yyyy_mm_dd):
        self.command.extend(["--end", yyyy_mm_dd])
        return self

    def add_ledger_command_balance(self):
        self.command.append("balance")
        return self

    def add_ledger_command_register(self):
        self.command.append("reg")
        return self

    def add_plot_amount_format(self):
        self.command.extend(
            [
                "--plot-amount-format",
                '%(format_date(date, "%Y-%m-%d")) %(abs(quantity(scrub(floor(display_amount)))))\n',
            ]
        )
        return self

    def add_amount_data(self):
        self.command.append("--amount-data")
        return self

    def add_group_month(self):
        self.command.append("--monthly")
        return self

    def add_collapse(self):
        self.command.append("--collapse")
        return self

    def add_query(self, query):
        self.command.append(query)
        return self

    def add_currency(self, currency):
        self.command.extend(["-X", currency])
        return self

    def build(self) -> List[str]:
        return self.command


class LedgerCli:
    def __init__(self, command=None):
        if command is None:
            lcb = LedgerCommandBuilder()
            self.command = (
                lcb.add_ledger_file(
                    Path(
                        "~/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt"
                    )
                )
                .add_ledger_command_balance()
                .add_query("Expense")
                .build()
            )
        else:
            self.command = command

    def run(self, output_filename):
        print("Running command:", self.command)
        proc = subprocess.run(
            self.command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        print("Writing to output file", output_filename)
        with open(output_filename, "a") as file:
            file.write(proc.stdout.decode("utf-8"))
