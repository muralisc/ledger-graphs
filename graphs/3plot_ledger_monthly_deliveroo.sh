
export LEDGER_FILE=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt
export LEDGER_PRICE_DB=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt

ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

SELECTED_PAYEE="${1:-@Deliveroo}"

pushd $FOLDER
cat /dev/null > ledger_monthly_payee.tmp
cat /dev/null > ledger_monthly_allowance.tmp
cat /dev/null > ledger_monthly_entertainment.tmp
cat /dev/null > ledger_monthly_groceries.tmp
cat /dev/null > ledger_monthly_health.tmp
cat /dev/null > ledger_monthly_housing.tmp
cat /dev/null > ledger_monthly_posessions.tmp
cat /dev/null > ledger_monthly_transport.tmp
cat /dev/null > ledger_monthly_utilities.tmp
CURRENT_MONTH_START=$(date +"%Y-%m-01")
TIME_DIFF=1y
START_TIME=$(dateadd $(date +"%Y-%m-01") -1y --format="%Y-%m-%d")
for cdate in $(dateseq $START_TIME 1mo $CURRENT_MONTH_START); do
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jMn reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(quantity(scrub(floor(display_amount))))\n" \
    '^Expense' and $SELECTED_PAYEE >> ledger_monthly_payee.tmp
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Allowance' >> ledger_monthly_allowance.tmp
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Entertainment' >> ledger_monthly_entertainment.tmp
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Groceries' >> ledger_monthly_groceries.tmp
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Health' >> ledger_monthly_health.tmp
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Housing' >> ledger_monthly_housing.tmp
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Posessions' >> ledger_monthly_posessions.tmp
  ledger \
    -f $LEDGER_FILE \
    --begin $cdate --end $(dateadd $cdate 1mo) -X GBP -jM reg \
    --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(floor(display_amount)))))\n" \
    '^Expenses:Transport' >> ledger_monthly_transport.tmp
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
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y-%b"
  set xtics nomirror scale 0 rotate by -55
  set grid ytics
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
    "ledger_monthly_payee.tmp" using 1:2 with linespoints title "$SELECTED_PAYEE" ls 1, \
    "ledger_monthly_allowance.tmp" using 1:2 with linespoints title "Expense:Allowance" ls 2 linecolor rgb "#ff0000", \
    "ledger_monthly_entertainment.tmp" using 1:2 with linespoints title "Expense:Entertainment" ls 3 linecolor rgb "#00aa00", \
    "ledger_monthly_groceries.tmp" using 1:2 with linespoints title "Expense:Groceries" ls 4 linecolor rgb "#0000ff", \
    "ledger_monthly_health.tmp" using 1:2 with linespoints title "Expense:Health" ls 5 linecolor rgb "#FF5733", \
    "ledger_monthly_housing.tmp" using 1:2 with linespoints title "Expense:Housing" ls 6 linecolor rgb "#af7ac5", \
    "ledger_monthly_posessions.tmp" using 1:2 with linespoints title "Expense:Posessions" ls 7 linecolor rgb "#1abc9c", \
    "ledger_monthly_transport.tmp" using 1:2 with linespoints title "Expense:Transport" ls 8 linecolor rgb "#d4ac0d", \
    "ledger_monthly_utilities.tmp" using 1:2 with linespoints title "Expense:Utilities" ls 9 linecolor rgb "#283747"
EOF
popd
