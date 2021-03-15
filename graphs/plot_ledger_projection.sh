#!/bin/bash

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1750,900 persist"
fi

ledger -J reg -X INR ^Assets -M --collapse \
  --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" \
  "$@" > ledgeroutput1.tmp
ledger -J reg -X INR ^Expenses -M \
  --collapse \
  --plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" \
  "$@" > ledgeroutput2.tmp

durMonths=12
yearlyInterest=10
dateEnd=2021-03 # $(date +"%Y-%m")
dateBeg=$(dateadd $dateEnd -${durMonths}mo --format="%Y-%m")
durationsav=$(ledger b Income Expense -X INR -n --begin $dateBeg --end $dateEnd --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n" | tail -1)
monthsav_old=138074 # avg cisco savings
monthsav=600000 # $((durationsav/$durMonths))

# Calculated with no compound Interest
cur=$(ledger b Assets -X INR -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
while (( $cur < 80000000)); do echo "$datev $cur" ; cur=$((cur+monthsav*12)); datev=$(dateadd $datev +12mo --format "%Y-%m-%d");  done > ledgeroutput3.tmp

# TODO: make this function
cur=$(ledger b Assets -X INR -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
while (( $cur < 80000000)); do echo "$datev $cur" ; cur=$((cur+monthsav_old*12)); datev=$(dateadd $datev +12mo --format "%Y-%m-%d");  done > ledgeroutput5.tmp

# Project with Compound Interest
cur=$(ledger b Assets -X INR -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
while (( $(echo "$cur < 80000000" | bc -l) )); do
  echo "$datev $cur" ;
  cur=$(bc <<< "scale=2; $cur * (1 + $yearlyInterest/100) + ($monthsav * 12)")
  datev=$(dateadd $datev +12mo --format "%Y-%m-%d");
done > ledgeroutput4.tmp

# TODO : make function
cur=$(ledger b Assets -X INR -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
while (( $(echo "$cur < 80000000" | bc -l) )); do
  echo "$datev $cur" ;
  cur=$(bc <<< "scale=2; $cur * (1 + $yearlyInterest/100) + ($monthsav_old * 12)")
  datev=$(dateadd $datev +12mo --format "%Y-%m-%d");
done > ledgeroutput6.tmp

echo $LEDGER_TERM
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
  #linestyle for 3
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  #linestyle for 4
  set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 7 pi -1 ps 1.5
  set pointintervalbox 3

  plot "ledgeroutput1.tmp" \
    using 1:2 with filledcurves x1 title "Assets" linecolor rgb "goldenrod", '' \
    using 1:2:2 with labels font "Courier,8" rotate by 45 offset 0,0.5 textcolor linestyle 0 notitle, "ledgeroutput2.tmp" \
    using 1:2 with filledcurves y1=0 title "Expenses" linecolor rgb "violet", '' \
    using 1:2:2 with labels font "Courier,8" offset 0,0.5 textcolor linestyle 0 notitle, \
    "ledgeroutput3.tmp" using 1:2 with linespoints ls 1 title "Projection" ,\
                     '' using 1:2:2 with labels font "Courier,12" rotate by 40 offset 1,-1 textcolor linestyle 0 notitle, \
    "ledgeroutput4.tmp" using 1:2 with linespoints ls 2 title "ProjectionCompound", \
                     '' using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 2 notitle, \
    "ledgeroutput5.tmp" using 1:2 with linespoints ls 1 title "Projection old" ,\
                     '' using 1:2:2 with labels font "Courier,12" rotate by 40 offset 1,-1 textcolor linestyle 3 notitle, \
    "ledgeroutput6.tmp" using 1:2 with linespoints ls 2 title "ProjectionCompound 0ld", \
                     '' using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 3 notitle
EOF

#rm ledgeroutput*.tmp
