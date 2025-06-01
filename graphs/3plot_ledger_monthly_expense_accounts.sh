#!/bin/bash

# https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/

export LEDGER_FILE=$1
export LEDGER_PRICE_DB=$2

shift #unset $2 if any
shift #unset $1 if any


ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger/ledger_3_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi


pushd $FOLDER
cat /dev/null > ledger_monthly_allowance.txt
cat /dev/null > ledger_monthly_entertainment.txt
cat /dev/null > ledger_monthly_groceries.txt
cat /dev/null > ledger_monthly_health.txt
cat /dev/null > ledger_monthly_housing.txt
cat /dev/null > ledger_monthly_posessions.txt
cat /dev/null > ledger_monthly_transport.txt
cat /dev/null > ledger_monthly_utilities.txt

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
      --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount))))) %(abs(quantity(scrub(floor(display_amount))))).exp\n" \
      '^Expe' "$@" >> graph3_monthly_expense.txt

  echo "monthly allowance"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) \
    -X GBP \
    -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Allowance' >> ledger_monthly_allowance.txt

  echo "monthly entertainment"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Entertainment' >> ledger_monthly_entertainment.txt

  echo "monthly groceries"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Groceries' >> ledger_monthly_groceries.txt

  echo "monthly health"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Health' >> ledger_monthly_health.txt

  echo "monthly housing"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Housing' >> ledger_monthly_housing.txt

  echo "monthly posessions"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Posessions' >> ledger_monthly_posessions.txt

  echo "monthly transport"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Transport' >> ledger_monthly_transport.txt

  echo "monthly utilities"
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount))))) %(abs(quantity(scrub(floor(display_amount))))).util\n" \
    '^Expenses:Utilities' >> ledger_monthly_utilities.txt
done

min_exp=1000
min_exp=$(awk 'BEGIN{min='$min_exp'}{if ($2<0+min) min=$2} END{print min}' ledger_monthly_entertainment.txt)
min_exp=$(awk 'BEGIN{min='$min_exp'}{if ($2<0+min) min=$2} END{print min}' ledger_monthly_posessions.txt)
min_exp=$(awk 'BEGIN{min='$min_exp'}{if ($2<0+min) min=$2} END{print min}' ledger_monthly_health.txt)
max_exp=$(awk 'BEGIN{max=0}{if ($2>0+max) max=$2} END{print max}' ledger_monthly_housing.txt)

echo "Creating $FOLDER/ledger_monthly_payee.png"
(cat <<EOF) | gnuplot
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  set output "$FOLDER/ledger_monthly_payee.png"
  set xdata time
  set logscale y 2
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y-%b"
  set xtics nomirror scale 0 rotate by -55
  set timefmt '%Y-%m-%d'
  set xrange [*:'$CURRENT_MONTH_START']
  set yrange [$min_exp:$max_exp]
  set y2range [-5000:6000]
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

  plot \
    "graph3_monthly_expense.txt" using 1:2 with linespoints title "Expense" ls 1 linecolor rgb "red" axes x1y2, \
                     '' using 1:2:3 with labels left font "Courier,12" rotate by 0 offset 1,0 textcolor "red" notitle axes x1y2, \
    "ledger_monthly_allowance.txt" using 1:2 with linespoints title "Expense:Allowance" ls 2 linecolor rgb "#ff0000", \
    "ledger_monthly_entertainment.txt" using 1:2 with linespoints title "Expense:Entertainment" ls 3 linecolor rgb "#00aa00", \
                     '' using 1:2:2 with labels left font "Courier,8" rotate by 15 offset 1,1 textcolor "#00aa00" notitle, \
    "ledger_monthly_groceries.txt" using 1:2 with linespoints title "Expense:Groceries" ls 4 linecolor rgb "#0000ff", \
                     '' using 1:2:2 with labels left font "Courier,8" rotate by 15 offset 1,1 textcolor "#0000ff" notitle, \
    "ledger_monthly_health.txt" using 1:2 with linespoints title "Expense:Health" ls 5 linecolor rgb "#FF5733", \
    "ledger_monthly_housing.txt" using 1:2 with linespoints title "Expense:Housing" ls 6 linecolor rgb "#af7ac5", \
                     '' using 1:2:2 with labels left font "Courier,8" rotate by 15 offset 1,1 textcolor "#3d3ded" notitle, \
    "ledger_monthly_posessions.txt" using 1:2 with linespoints title "Expense:Posessions" ls 7 linecolor rgb "#1abc9c", \
                     '' using 1:2:2 with labels left font "Courier,14" rotate by 15 offset 1,1 textcolor "#1abc9c" notitle, \
    "ledger_monthly_transport.txt" using 1:2 with linespoints title "Expense:Transport" ls 8 linecolor rgb "#d4ac0d", \
                     '' using 1:2:2 with labels left font "Courier,14" rotate by 15 offset 1,1 textcolor "#d4ac0d" notitle, \
    "ledger_monthly_utilities.txt" using 1:2 with linespoints title "Expense:Utilities" ls 9 linecolor rgb "#283747", \
                     '' using 1:2:3 with labels left font "Courier,14" rotate by 15 offset 1,1 textcolor "#283747" notitle
EOF
popd
