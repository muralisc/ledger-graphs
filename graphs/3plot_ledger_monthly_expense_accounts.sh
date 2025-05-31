#!/bin/bash

# https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/

export LEDGER_FILE=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt
export LEDGER_PRICE_DB=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt

ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger/ledger_3_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi


pushd $FOLDER
cat /dev/null > ledger_monthly_allowance.tmp
cat /dev/null > ledger_monthly_entertainment.tmp
cat /dev/null > ledger_monthly_groceries.tmp
cat /dev/null > ledger_monthly_health.tmp
cat /dev/null > ledger_monthly_housing.tmp
cat /dev/null > ledger_monthly_posessions.tmp
cat /dev/null > ledger_monthly_transport.tmp
cat /dev/null > ledger_monthly_utilities.tmp

cat /dev/null > graph3_monthly_expense.txt

CURRENT_MONTH_START=$(date +"%Y-%m-01")
TIME_DIFF=13mo
START_TIME=$(dateadd $(date +"%Y-%m-01") -$TIME_DIFF --format="%Y-%m-%d")
for cdate in $(dateseq $START_TIME 1mo $CURRENT_MONTH_START); do

  BLUE=$(tput setaf 4)  
  echo "${BLUE} Adding data for ${cdate} $(tput sgr0)"

  echo "monthly expense"
  ledger -f $LEDGER_FILE \
      --begin $cdate --end $(dateadd $cdate 1mo) \
      -X GBP \
      -jMn reg \
      --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
      '^Expe' "$@" >> graph3_monthly_expense.txt

  echo "monthly allowance"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) \
    -X GBP \
    -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Allowance' >> ledger_monthly_allowance.tmp

  echo "monthly entertainment"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Entertainment' >> ledger_monthly_entertainment.tmp

  echo "monthly groceries"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Groceries' >> ledger_monthly_groceries.tmp

  echo "monthly health"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Health' >> ledger_monthly_health.tmp

  echo "monthly housing"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Housing' >> ledger_monthly_housing.tmp

  echo "monthly posessions"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Posessions' >> ledger_monthly_posessions.tmp

  echo "monthly transport"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Transport' >> ledger_monthly_transport.tmp

  echo "monthly utilities"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Utilities' >> ledger_monthly_utilities.tmp
done

echo "Creating $FOLDER/ledger_monthly_payee.png"
(cat <<EOF) | gnuplot
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  set output "$FOLDER/ledger_monthly_payee.png"
  set xdata time
  set logscale y 2
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y-%b"
  set xtics nomirror scale 0 rotate by -55
  set grid ytics

  set ylabel "Cost of Expense::SubItems"
  set y2label "Expense"
  set y2tics textcolor rgb "red"

  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  set style line 2 lt 1 lw 2 pt 4 pi -1 ps 1.5
  set style line 2 lt 1 lw 2 pt 5 pi -1 ps 1.5
  set style line 3 lt 1 lw 2 pt 6 pi -1 ps 1.5
  set style line 4 lt 1 lw 2 pt 8 pi -1 ps 1.5
  set style line 5 lt 1 lw 2 pt 9 pi -1 ps 1.5
  set style line 6 lt 1 lw 2 pt 10 pi -1 ps 1.5
  set style line 7 lt 1 lw 2 pt 11 pi -1 ps 1.5
  set style line 8 lt 1 lw 2 pt 12 pi -1 ps 1.5
  set style line 9 lt 1 lw 2 pt 13 pi -1 ps 1.5
  set title "Payee split $ledger_run_date"

  set label 1 at $START_TIME, graph 1 "line to center graphs" offset 0.5,-1000.0
  plot \
    "graph3_monthly_expense.txt" using 1:2 with linespoints title "Expense" ls 1 linecolor rgb "red" axes x1y2, \
    25000 title "line" lw 2 , \
    "ledger_monthly_allowance.tmp" using 1:2 with linespoints title "Expense:Allowance" ls 2 linecolor rgb "#ff0000", \
    "ledger_monthly_entertainment.tmp" using 1:2 with linespoints title "Expense:Entertainment" ls 3 linecolor rgb "#00aa00", \
    "ledger_monthly_groceries.tmp" using 1:2 with linespoints title "Expense:Groceries" ls 4 linecolor rgb "#0000ff", \
    "ledger_monthly_health.tmp" using 1:2 with linespoints title "Expense:Health" ls 5 linecolor rgb "#FF5733", \
    "ledger_monthly_housing.tmp" using 1:2 with linespoints title "Expense:Housing" ls 6 linecolor rgb "#af7ac5", \
                     '' using 1:2:2 with labels left font "Courier,4" rotate by 15 offset 1,1 textcolor "#3d3ded" notitle, \
    "ledger_monthly_posessions.tmp" using 1:2 with linespoints title "Expense:Posessions" ls 7 linecolor rgb "#1abc9c", \
    "ledger_monthly_transport.tmp" using 1:2 with linespoints title "Expense:Transport" ls 8 linecolor rgb "#d4ac0d", \
    "ledger_monthly_utilities.tmp" using 1:2 with linespoints title "Expense:Utilities" ls 9 linecolor rgb "#283747", \
                     '' using 1:2:2 with labels left font "Courier,14" rotate by 15 offset 1,1 textcolor "#3d3ded" notitle
EOF
popd
