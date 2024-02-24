from lib import LedgerCli, LedgerCommandBuilder
from pathlib import Path
from datetime import datetime


lcb = LedgerCommandBuilder()

l = LedgerCli(
    command=lcb.add_amount_data()
    .add_ledger_file(
        Path("~/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt")
    )
    .add_ledger_pricedb(
        Path("~/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt")
    )
    .add_begin("2023-01-01")
    .add_group_month()
    .add_collapse()
    .add_currency("GBP")
    .add_plot_amount_format()
    .add_ledger_command_register()
    .add_query("^Income")
    .build()
)


output_dir = Path("/var/tmp/py_ledger_2_" + datetime.now().strftime("%Y-%m-%d"))
output_dir.mkdir(parents=True, exist_ok=True)
l.run(output_dir / "graph2_monthly_income.tmp")
