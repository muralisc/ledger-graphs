#!/bin/bash

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

ledger -X INR -J reg ^Income -M --collapse --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(display_total))))\n" "$@" > ledgeroutput1.tmp
ledger -X INR -J reg ^Expenses -M --collapse --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(display_total))))\n" "$@" > ledgeroutput2.tmp

(cat <<EOF) | gnuplot
  set terminal $LEDGER_TERM
  set xdata time
  set timefmt "%Y-%m-%d"
  unset mxtics
  set mytics 2
  set grid xtics ytics mytics
  set title "Cashflow - Cumulative Income and Expenses"
  set ylabel "Cumulative Income and Expenses"
  set style fill transparent solid 0.6 noborder
  plot "ledgeroutput1.tmp" \
    using 1:2 with filledcurves x1 title "Income" linecolor rgb "light-salmon", '' \
    using 1:2:2 with labels font "Courier,12" rotate by 65 offset 1,3 textcolor linestyle 0 notitle, "ledgeroutput2.tmp" \
    using 1:2 with filledcurves y1=0 title "Expenses" linecolor rgb "seagreen", '' \
    using 1:2:(sprintf('%.2f', \$2)) with labels font "Courier,12" offset 0,0.5 textcolor linestyle 0 notitle
EOF

rm ledgeroutput*.tmp
