#!/bin/bash


# 
# This plots the Assets and Expenses till date


if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger_${ledger_run_date}"
mkdir -p $FOLDER

CURRENCY=USD

pushd $FOLDER

ledger -J reg -X $CURRENCY ^Assets -M -R --collapse \
  --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" \
  "$@" > ledgeroutput1.tmp
ledger -J reg -X $CURRENCY ^Expenses -M -R  \
  --collapse \
  --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" \
  "$@" > ledgeroutput2.tmp

echo "Creating file in $FOLDER/ledger_cashflow-Cumulative_Asset_Expense.png"
(cat <<EOF) | gnuplot
  # set terminal canvas mousing size 1750, 900
  # set terminal $LEDGER_TERM
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  set output "ledger_cashflow-Cumulative_Asset_Expense.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  set xtics nomirror scale 0 center
  unset mxtics
  set mytics 2
  set grid xtics ytics mytics
  set title "Wealthgrow"
  set ylabel "Amount"
  set style fill transparent solid 0.6 noborder
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  xPos = "2020-12-01"
  set arrow 1 at xPos, graph 0 to xPos, graph 1 nohead lc "red" dt 4
  set label 1 at xPos, graph 1 "Joined Meta" offset 0.5,-5.0
  plot "ledgeroutput1.tmp" \
    using 1:2 with filledcurves x1 title "Assets" linecolor rgb "goldenrod", '' \
    using 1:2:2 with labels font "Courier,12" rotate by 45 offset 0,0.5 textcolor linestyle 1 notitle, "ledgeroutput2.tmp" \
    using 1:2 with filledcurves y1=0 title "Expenses" linecolor rgb "violet", '' \
    using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 1 notitle
EOF
popd
#rm ledgeroutput*.tmp
