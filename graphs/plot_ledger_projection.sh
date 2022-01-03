#!/bin/bash

# Needs dateutils installed
# sudo apt install dateutils

export LEDGER_FILE=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt
export LEDGER_PRICE_DB=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt

ledger_run_date=$(date +%Y-%m-%d_%H)
FOLDER="/var/tmp/ledger_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1750,900 persist"
fi

CURRENCY=INR
targe_amt=$((1000000*80))

CURRENCY=USD
targe_amt=$((1000000/2))

pushd $FOLDER
cat /dev/null > ledgeroutput_assets.tmp
datev=$(date +"%Y-%m-%d")
echo $datev
loop=1
while (( loop < 5 )) ; do
  bal=$(ledger b \
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
while (( loop < 5 )) ; do
  bal=$(ledger b -X $CURRENCY ^Expense --end $datev --balance-format="%(abs(quantity(scrub(floor(display_total)))))\n" | tail -1)
  echo "$datev $bal"
  loop=$((loop+1))
  datev=$(dateadd $datev -1y --format="%Y-%m-%d")
done > ledgeroutput_expense.tmp

durMonths=12
yearlyInterest=8
dateEnd=2021-08 # $(date +"%Y-%m")
dateBeg=$(dateadd $dateEnd -${durMonths}mo --format="%Y-%m")
echo "Calulating avg monthly savings from $dateBeg to $dateEnd"
durationsav=$(ledger b Income Expense -X $CURRENCY -n --begin $dateBeg --end $dateEnd --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n" | tail -1)
durationsav_old=$(ledger b Income Expense -X $CURRENCY -n --begin 2019-11 --end 2020-11 --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n" | tail -1) # Cisco savings
monthsav_old=$((durationsav_old/$durMonths)) # avg cisco savings
echo "Monthly Savings Old: $monthsav_old"
monthsav=$((durationsav/$durMonths)) #600000
echo "Monthly Savings: $monthsav"


# Calculated with no compound Interest
cur=$(ledger b Assets -X $CURRENCY -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
while (( $cur < $targe_amt)); do echo "$datev $cur" ; cur=$((cur+monthsav*12)); datev=$(dateadd $datev +12mo --format "%Y-%m-%d");  done > ledgeroutput_current_projection.tmp

# TODO: make this function
cur=$(ledger b Assets -X $CURRENCY -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
loop=1
while (( $cur < $targe_amt)) && (( loop < 10 )) ; do 
	echo "$datev $cur" ; 
	cur=$((cur+monthsav_old*12)); 
	datev=$(dateadd $datev +12mo --format "%Y-%m-%d");  
  loop=$((loop+1))
done > ledgeroutput_cisco.tmp

# Project with Compound Interest
cur=$(ledger b Assets -X $CURRENCY -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
datev=$(dateadd now 0mo --format "%Y-%m-%d")
while (( $(echo "$cur < $targe_amt" | bc -l) )); do
  echo "$datev $cur" ;
  cur=$(bc <<< "scale=2; $cur * (1 + $yearlyInterest/100) + ($monthsav * 12)")
  datev=$(dateadd $datev +12mo --format "%Y-%m-%d");
done > ledgeroutput_current_compound.tmp

# TODO : make function
cur=$(ledger b Assets -X $CURRENCY -n --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
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
  set xtics nomirror scale 0 center
  unset mxtics
  set mytics 2
  set key bottom right
  set grid xtics ytics mytics
  set title "Wealthgrow"
  set ylabel "Amount"
  set style fill transparent solid 0.6 noborder
  #linestyle for 1
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  #linestyle for 2
  set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 pi -1 ps 1.5
  #linestyle for 3
  set style line 3 lc rgb '#dd181f' lt 1 lw 2 pt 3 pi -1 ps 1.5
  set pointintervalbox 3

  plot \
    "ledgeroutput_assets.tmp" 	            using 1:2   with filledcurves x1 title "Assets" linecolor rgb "goldenrod", \
    ""				              every 1   using 1:2:2 with labels font "Courier,12" rotate by 05 offset 0,0.5 textcolor linestyle 0 notitle, \
    "ledgeroutput_expense.tmp"              using 1:2   with filledcurves y1=0 title "Expenses" linecolor rgb "violet", \
    ""     			                        using 1:2:2 with labels font "Courier,8" offset 0,0.5 textcolor linestyle 0 notitle, \
    "ledgeroutput_current_projection.tmp"   using 1:2   with linespoints ls 1 title "Projection" ,\
    "" 	                                    using 1:2:2 with labels font "Courier,12" rotate by 40 offset 1,-1 textcolor linestyle 0 notitle, \
    "ledgeroutput_current_compound.tmp"     using 1:2   with linespoints ls 2 title "ProjectionCompound", \
    "" 					                    using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 2 notitle, \
    "ledgeroutput_cisco.tmp" 		        using 1:2   with linespoints ls 3 title "Projection Cisco" ,\
    "" 					                    using 1:2:2 with labels font "Courier,12" rotate by 40 offset 1,-1 textcolor linestyle 3 notitle, \
    "ledgeroutput_cisco_compound.tmp" 	    using 1:2   with linespoints ls 4 title "ProjectionCompound Cisco", \
    "" 					                    using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 4 notitle
EOF
popd

#rm ledgeroutput*.tmp
