#!/bin/bash

# https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/

export LEDGER_FILE=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt
export LEDGER_PRICE_DB=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt

ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

CURRENCY=USD

pushd $FOLDER
cat /dev/null > ledgeroutput1.tmp
cat /dev/null > ledgeroutput2.tmp
CURRENT_MONTH_START=$(date +"%Y-%m-01")
TIME_DIFF=1y
START_TIME=$(dateadd $(date +"%Y-%m-01") -1y --format="%Y-%m-%d")

ledger -X $CURRENCY -J reg ^Income -M -R  --collapse \
	--plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" "$@" > ledgeroutput1.tmp
ledger -X $CURRENCY -J reg ^Expenses -M -R  --collapse \
	--plot-total-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_total)))))\n" "$@" > ledgeroutput2.tmp

echo "Creating file in $FOLDER/ledger_cashflow-Cumulative_Income_Expense.png"

(cat <<EOF) | gnuplot
  # set terminal canvas mousing size 1750, 900
  # set terminal $LEDGER_TERM
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  set output "ledger_cashflow-Cumulative_Income_Expense.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  unset mxtics
  set mytics 2
  set grid xtics ytics mytics
  set title "Cashflow - Cumulative Income and Expenses"
  set ylabel "Cumulative Income and Expenses"
  set style fill transparent solid 0.6 noborder
  plot \
    "ledgeroutput1.tmp" using 1:2 with filledcurves x1 title "Income" linecolor rgb "light-salmon", \
    ''                  using 1:2:2 with labels font "Courier,12" rotate by 65 offset 1,3 textcolor linestyle 0 notitle, \
    "ledgeroutput2.tmp" using 1:2 with filledcurves y1=0 title "Expenses" linecolor rgb "seagreen", \
    '' using 1:2:(sprintf('%.2f', \$2)) with labels font "Courier,12" offset 0,0.5 textcolor linestyle 0 notitle
EOF
popd
