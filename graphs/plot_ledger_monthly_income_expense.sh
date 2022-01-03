#!/bin/bash

# -X INR --begin 2020 --price-db pricedb.txt
# https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

ledger -f $LEDGER_FILE -X INR -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Income' "$@" > ledgeroutput1.tmp
ledger -f $LEDGER_FILE -X INR -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Expe' "$@" > ledgeroutput2.tmp

(cat <<EOF) | python3 | sort > ledgeroutput3.tmp
#!/usr/local/bin/python3
import csv
from collections import defaultdict


date_val = defaultdict(int)
with open('ledgeroutput1.tmp') as income:
    inc = csv.reader(income, delimiter=' ')
    for row in inc:
        date_val[row[0]] = int(row[1])
with open('ledgeroutput2.tmp') as income:
    inc = csv.reader(income, delimiter=' ')
    for row in inc:
        date_val[row[0]] = date_val[row[0]] - int(row[1])

for k in date_val:
    print(k, date_val[k])
EOF

(cat <<EOF) | gnuplot
  set terminal $LEDGER_TERM
  # set terminal canvas mousing size 1750, 900
  set xdata time
  set timefmt "%Y-%m-%d"
  set xtics nomirror scale 0 rotate by -55
  set grid ytics
  set title "Monthly Income and Expenses"
  set ylabel "Amount"
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  plot \
    "ledgeroutput1.tmp" using 1:2 with linespoints title "Income" linecolor rgb "blue", \
    "ledgeroutput2.tmp" using 1:2 with linespoints title "Expense" ls 1, \
    "ledgeroutput3.tmp" using 1:2 with linespoints title "Income - Expense" ls 1 linecolor rgb "red", \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 90 offset 1,1 textcolor linestyle 1 notitle
EOF

#rm ledgeroutput*.tmp
