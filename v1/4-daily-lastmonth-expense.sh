#!/bin/bash

export LEDGER_FILE=$1
export FOLDER="$2"

shift #unset $2 if any
shift #unset $1 if any


ledger_run_date=$(date +%Y-%m-%d)
mkdir -p "$FOLDER"
if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi


pushd $FOLDER
cat /dev/null > graph4_daily_lastmonth_expense.tmp

ledger -f $LEDGER_FILE \
    -X GBP \
    reg \
    --amount-data \
    --daily \
    --collapse \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" \
    Expenses > graph4_daily_lastmonth_expense.tmp

echo "Creating file $FOLDER/graph4_daily_lastmonth_expense.png"
(cat <<EOF) | gnuplot
  # set terminal $LEDGER_TERM
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  # set terminal canvas mousing size 1750, 900
  set output "$FOLDER/graph4_daily_lastmonth_expense.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y"
  set format y "%g"
  set xtics 86400
  set xtics nomirror scale 0 rotate by -55
  set grid back ls 12
  set title "Daily LastMonth Expenses as on ${ledger_run_date}"
  set decimal locale "en_US.UTF-8"
  set ylabel "Amount"
  set rmargin 10
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  plot \
    "graph4_daily_lastmonth_expense.tmp" using 1:2 with linespoints title "Expense" ls 1 linecolor rgb "red", \
                     '' using 1:2:(sprintf("%'g", \$2)) with labels left font "Courier,12" rotate by 45 offset 1,1 textcolor "red" notitle
EOF
popd
