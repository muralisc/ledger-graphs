#!/bin/bash

# -X INR --begin 2020 --price-db pricedb.txt
# https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

ledger -f $LEDGER_FILE -X INR -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Income' "$@" > ledgeroutput1.tmp
ledger -f $LEDGER_FILE -X INR -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Expe' "$@" > ledgeroutput2.tmp

python3 plot_ledger_monthly_expense.py | sort > ledgeroutput3.tmp

(cat <<EOF) | gnuplot
  set terminal $LEDGER_TERM
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
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 90 offset 1,1 textcolor linestyle 1 notitle, \
    "ledgeroutput3.tmp" using 1:2 with linespoints title "Income - Expense" linecolor rgb "red"
EOF

#rm ledgeroutput*.tmp
