#!/bin/bash

# -X INR --begin 2020 --price-db pricedb.txt
# https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/

export LEDGER_FILE=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt
export LEDGER_PRICE_DB=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt

ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

pushd $FOLDER
cat /dev/null > ledger_monthly_income.tmp
cat /dev/null > ledger_monthly_expense.tmp
CURRENT_MONTH_START=$(date +"%Y-%m-01")
TIME_DIFF=1y
START_TIME=$(dateadd $(date +"%Y-%m-01") -1y --format="%Y-%m-%d")
for cdate in $(dateseq $START_TIME 1mo $CURRENT_MONTH_START); do
  ledger -f $LEDGER_FILE --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Income' "$@" >> ledger_monthly_income.tmp
  ledger -f $LEDGER_FILE --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Expe' "$@" >> ledger_monthly_expense.tmp
done


(cat <<EOF) | python3 | sort > ledger_monthly_savings.tmp
#!/usr/local/bin/python3
import csv
from collections import defaultdict


date_val = defaultdict(int)
with open('ledger_monthly_income.tmp') as income:
    inc = csv.reader(income, delimiter=' ')
    for row in inc:
        date_val[row[0]] = int(row[1])
with open('ledger_monthly_expense.tmp') as expense:
    inc = csv.reader(expense, delimiter=' ')
    for row in inc:
        date_val[row[0]] = date_val[row[0]] - int(row[1])

for k in date_val:
    print(k, date_val[k])
EOF

(cat <<EOF) | gnuplot
  # set terminal $LEDGER_TERM
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  # set terminal canvas mousing size 1750, 900
  set output "$FOLDER/ledger_monthly.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  set xtics nomirror scale 0 rotate by -55
  set grid ytics
  set title "Monthly Income and Expenses $ledger_run_date"
  set ylabel "Amount"
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  # last noted label
  xPos = "2022-01-01"
  set arrow 1 at xPos, graph 0 to xPos, graph 1 nohead lc "red" dt 4
  set label 1 at xPos, graph 1 "noticed 4k exp" offset 0.5,-5.0
  plot \
    "ledger_monthly_income.tmp" using 1:2 with linespoints title "Income" ls 1 linecolor rgb "#ad8c11", \
    "ledger_monthly_expense.tmp" using 1:2 with linespoints title "Expense" ls 1 linecolor rgb "red", \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 45 offset 1,1 textcolor "red" notitle, \
    "ledger_monthly_savings.tmp" using 1:2 with linespoints title "Income - Expense" ls 1 linecolor rgb "#dd0060ad", \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 90 offset 1,1 textcolor linestyle 1 notitle
EOF
popd

#rm ledgeroutput*.tmp
