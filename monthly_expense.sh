#!/bin/bash

# -X INR --begin 2020 --price-db pricedb.txt
# https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

ledger -f $LEDGER_FILE -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Income' "$@" > ledgeroutput1.tmp
ledger -f $LEDGER_FILE -jMn reg --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" '^Expe' "$@" > ledgeroutput2.tmp

(cat <<EOF) | gnuplot
  set terminal $LEDGER_TERM
  set style data histogram
  set style histogram clustered gap 1
  set style fill transparent solid 0.4 noborder
  set xtics nomirror scale 0 center
  set ytics add ('' 0) scale 0
  set border 1
  set grid ytics
  set title "Monthly Income and Expenses"
  set ylabel "Amount"
  plot "ledgeroutput1.tmp" \
    using 2:xticlabels(strftime('%b-%y', strptime('%Y-%m-%d', strcol(1)))) title "Income" linecolor rgb "light-salmon", '' \
    using 0:2:2 with labels left font "Courier,12" rotate by 15 offset -4,0.5 textcolor linestyle 0 notitle, "ledgeroutput2.tmp" \
    using 2 title "Expenses" linecolor rgb "light-green", '' \
    using 0:2:2 with labels left font "Courier,12" rotate by 15 offset 0,0.5 textcolor linestyle 0 notitle
EOF

rm ledgeroutput*.tmp
