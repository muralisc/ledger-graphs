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

SELECTED_PAYEE=("@Tesco" "or" "@Deliveroo" "or" "@Best Foods")

pushd $FOLDER
cat /dev/null > ledger_monthly_custom.tmp
CURRENT_MONTH_START=$(date +"%Y-%m-01")
TIME_DIFF=1y
START_TIME=$(dateadd $(date +"%Y-%m-01") -1y --format="%Y-%m-%d")
for cdate in $(dateseq $START_TIME 1mo $CURRENT_MONTH_START); do
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) \
    -X GBP \
    -jMn reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(quantity(scrub(floor(display_amount))))\n" \
    '^Expense' and \( "${SELECTED_PAYEE[@]}" \) >> ledger_monthly_custom.tmp
done

echo "Creating $FOLDER/ledger_monthly_custom.png"
(cat <<EOF) | gnuplot
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  set output "$FOLDER/ledger_monthly_custom.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y-%b"
  set xtics nomirror scale 0 rotate by -55
  set grid ytics
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  set title "Payee custom $ledger_run_date"
  plot \
    "ledger_monthly_custom.tmp" using 1:2   with linespoints title "${SELECTED_PAYEE[@]//@/}" ls 1, \
    ""                          using 1:2:2 with labels font "Courier,12" offset 0,0.9 textcolor linestyle 0 notitle
EOF
popd

