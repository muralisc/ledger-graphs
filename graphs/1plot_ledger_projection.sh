#!/bin/bash

# Needs dateutils installed
# sudo apt install dateutils

# Forecasting info from : https://beyondrule4.jmmorrissey.com/forecasting

export LEDGER_FILE=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt
export LEDGER_PRICE_DB=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt

ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1750,900 persist"
fi

CURRENCY=USD
yearlyexpenses=40000
targe_amt=$((25*$yearlyexpenses))
lean_FI=$((17*$yearlyexpenses))
half_FI=$((12*$yearlyexpenses))
FU_target=$((3*$yearlyexpenses))

pushd $FOLDER

cat /dev/null > ledgeroutput_assets.tmp
datev=$(date +"%Y-%m-%d")
echo $datev
loop=1
while (( loop < 9 )) ; do
  bal=$(ledger b \
    -R --strict \
    -X $CURRENCY ^Assets \
    --end $datev \
    --balance-format="%(abs(quantity(scrub(floor(display_total)))))\n" | tail -1)
  echo "$datev $bal"
  loop=$((loop+1))
  datev=$(dateadd $datev -1y --format="%Y-%m-%d")
done > ledgeroutput_assets.tmp

cat /dev/null > ledgeroutput_expense.tmp
datev=$(date +"%Y-%m-%d")
loop=1
while (( loop < 8 )) ; do
  bal=$(ledger b \
    -R --strict \
    -X $CURRENCY ^Expense --end $datev --balance-format="%(abs(quantity(scrub(floor(display_total)))))\n" | tail -1)
  echo "$datev $bal"
  loop=$((loop+1))
  datev=$(dateadd $datev -1y --format="%Y-%m-%d")
done > ledgeroutput_expense.tmp

durMonths=12
yearlyInterest=8
dateEnd=2023-01 # $(date +"%Y-%m")
dateBeg=$(dateadd $dateEnd -${durMonths}mo --format="%Y-%m")
echo "Calulating avg monthly savings from $dateBeg to $dateEnd"
durationsav=$(ledger b Income Expense \
    -R --strict \
    -X $CURRENCY -n --begin $dateBeg --end $dateEnd --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n" | tail -1)
monthsav=$((durationsav/$durMonths)) #600000
echo "Monthly Savings: $monthsav"

durationsav_old=$(ledger b Income Expense \
    -R --strict \
    -X $CURRENCY -n --begin 2019-11 --end 2020-11 --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n" | tail -1) # Cisco savings
monthsav_old=$((durationsav_old/$durMonths)) # avg cisco savings
echo "Monthly Savings Old: $monthsav_old"


# projection from end of cisco at meta rate
cur=$(ledger b Assets \
    -R --strict \
    -X $CURRENCY --end 2020-11 -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev="2020-11-01"
while (( $(echo "$cur < $targe_amt" | bc -l) )); do
    echo "$datev $cur" ; 
    cur=$(bc <<< "scale=2; $cur * (1 + $yearlyInterest/100) + ($monthsav * 12)")
    datev=$(dateadd $datev +12mo --format "%Y-%m-%d");  
done > ledgeroutput_old_meta_projection.tmp

# Projection from end of cisco at cisco rate
cur=$(ledger b Assets \
    -R --strict \
    -X $CURRENCY --end 2020-11 -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev="2020-11-01"
loop=1
while (( $(echo "$cur < $targe_amt" | bc -l) )) && (( loop < 10 )) ; do 
  echo "$datev $cur" ; 
  cur=$(bc <<< "scale=2; $cur * (1 + $yearlyInterest/100) + ($monthsav_old * 12)")
  datev=$(dateadd $datev +12mo --format "%Y-%m-%d");  
  loop=$((loop+1))
done > ledgeroutput_cisco.tmp

# Project with Compound Interest
cur=$(ledger b Assets \
    -R --strict \
    -X $CURRENCY -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
while (( $(echo "$cur < $targe_amt" | bc -l) )); do
  echo "$datev $cur" ;
  cur=$(bc <<< "scale=2; $cur * (1 + $yearlyInterest/100) + ($monthsav * 12)")
  datev=$(dateadd $datev +12mo --format "%Y-%m-%d");
done > ledgeroutput_meta_compound.tmp

# TODO : make function
cur=$(ledger b Assets \
    -R --strict \
    -X $CURRENCY -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
loop=1
while (( $(echo "$cur < $targe_amt" | bc -l) )) && (( loop < 10 )); do
  echo "$datev $cur" ;
  cur=$(bc <<< "scale=2; $cur * (1 + $yearlyInterest/100) + ($monthsav_old * 12)")
  datev=$(dateadd $datev +12mo --format "%Y-%m-%d");
  loop=$((loop+1))
done > ledgeroutput_cisco_compound.tmp


echo "Creating file in $FOLDER/ledger_projection.png"
#
# Enabled the UserDir module in apache so we can access this form index.html
#
echo $LEDGER_TERM
(cat <<EOF) | gnuplot
  # set terminal canvas mousing size 1750, 900
  # set terminal $LEDGER_TERM
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  set output "$FOLDER/ledger_projection.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y"
  set xtics nomirror scale 0 center
  unset mxtics
  set mytics 2
  set key bottom right
  set grid xtics ytics mytics
  set title "Wealthgrow $CURRENCY $ledger_run_date"
  set ylabel "Amount"
  set style fill transparent solid 0.6 noborder
  #linestyle for 1
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  #linestyle for 2
  set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 pi -1 ps 1.5
  #linestyle for 3
  set style line 3 lc rgb '#dd181f' lt 1 lw 2 pt 3 pi -1 ps 1.5
  set pointintervalbox 3
  set arrow 1 from graph 0,first $half_FI to graph 1,first $half_FI nohead lc "red" dashtype 3 linewidth 2
  set label 1 at graph 0,first $half_FI "half FI" offset 0.5,1.0
  set arrow 2 from graph 0,first $targe_amt to graph 1,first $targe_amt nohead lc "red" dashtype 3 linewidth 2
  set label 2 at graph 0,first $targe_amt "FI" offset 0.5,1.0
  set arrow 3 from graph 0,first $FU_target to graph 1,first $FU_target nohead linestyle 3
  set label 3 at graph 0,first $FU_target "FU" offset 0.5,1.0
  set arrow 4 from graph 0,first $lean_FI to graph 1,first $lean_FI nohead linestyle 4
  set label 4 at graph 0,first $lean_FI "Lean FI" offset 0.5,1.0

  plot \
    "ledgeroutput_assets.tmp"               using 1:2   with filledcurves x1 title "Assets" linecolor rgb "goldenrod", \
    ""                            every 1   using 1:2:2 with labels font "Courier,12" rotate by 05 offset 0,0.5 textcolor linestyle 0 notitle, \
    "ledgeroutput_expense.tmp"              using 1:2   with filledcurves y1=0 title "Expenses" linecolor rgb "violet", \
    ""                                      using 1:2:2 with labels font "Courier,8" offset 0,0.5 textcolor linestyle 0 notitle, \
    "ledgeroutput_old_meta_projection.tmp"  using 1:2   with linespoints ls 1 title "Job Change Projection Meta" ,\
    ""                                      using 1:2:2 with labels font "Courier,12" rotate by 10 offset -3,0 textcolor linestyle 0 notitle, \
    "ledgeroutput_meta_compound.tmp"        using 1:2   with linespoints ls 2 title "Current ProjectionCompound", \
    ""                                      using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 2 notitle, \
    "ledgeroutput_cisco.tmp"                using 1:2   with linespoints ls 3 title "Job Change Projection Cisco" ,\
    ""                                      using 1:2:2 with labels font "Courier,12" rotate by 40 offset 1,-1 textcolor linestyle 3 notitle, \
    "ledgeroutput_cisco_compound.tmp"       using 1:2   with linespoints ls 4 title "ProjectionCompound Cisco", \
    ""                                      using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 4 notitle
EOF
popd

#rm ledgeroutput*.tmp
