#!/bin/bash


# 
# This plots the Assets and Expenses till date


if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

ledger -J reg -R -X INR ^Assets -M --collapse \
  --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" \
  "$@" > ledgeroutput1.tmp
ledger -J reg -R -X INR ^Expenses -M \
  --collapse \
  --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" \
  "$@" > ledgeroutput2.tmp

(cat <<EOF) | gnuplot
  # set terminal canvas mousing size 1750, 900
  set terminal $LEDGER_TERM
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
    using 1:2:2 with labels font "Courier,8" rotate by 45 offset 0,0.5 textcolor linestyle 1 notitle, "ledgeroutput2.tmp" \
    using 1:2 with filledcurves y1=0 title "Expenses" linecolor rgb "violet", '' \
    using 1:2:2 with labels font "Courier,8" offset 0,0.5 textcolor linestyle 1 notitle
EOF

#rm ledgeroutput*.tmp
