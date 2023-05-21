

export LEDGER_FILE=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/ledger.main.txt
export LEDGER_PRICE_DB=$HOME/shared_folders/minimal/Pensieve/textfiles/ledger/pricedb.txt

ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi

pushd $FOLDER
cat /dev/null > ledger_yearly_income.tmp
cat /dev/null > ledger_yearly_expense.tmp

CURRENT_MONTH_START=$(date +"%Y-%m-01")
TIME_DIFF=1y
START_TIME=$(dateadd $(date +"%Y-%m-01") -1y --format="%Y-%m-%d")

for cdate in $(dateseq $START_TIME 1mo $CURRENT_MONTH_START); do
  ledger \
      -f $LEDGER_FILE \
      --begin $(dateadd $cdate -1y) --end $cdate\
      -X GBP \
      -jsn reg \
      --plot-amount-format="$cdate %(abs(quantity(scrub(floor(display_amount)))))\n" \
      '^Income' "$@" >> ledger_yearly_income.tmp
  ledger -f $LEDGER_FILE \
      --begin $(dateadd $cdate -1y) --end $cdate\
      -X GBP \
      -jsn reg \
      --plot-amount-format="$cdate %(abs(quantity(scrub(floor(display_amount))))) %(quantity(floor(display_amount*30)))\n" \
      '^Expe' "$@" >> ledger_yearly_expense.tmp
done

echo "Creating file $FOLDER/ledger_yearly_inc_exp.png"
(cat <<EOF) | gnuplot
  # set terminal $LEDGER_TERM
  set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
  # set terminal canvas mousing size 1750, 900
  set output "$FOLDER/ledger_yearly_inc_exp.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y-%b"
  set xtics nomirror scale 0 rotate by -55
  set grid back ls 12
  set title "Yearly Income and Expenses $ledger_run_date"
  set ylabel "Amount"
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  plot \
    "ledger_yearly_income.tmp" using 1:2 with linespoints title "Income" ls 1 linecolor rgb "#ad8c11", \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 45 offset 1,1 textcolor "red" notitle, \
    "ledger_yearly_expense.tmp" using 1:2 with linespoints title "Expense" ls 1 linecolor rgb "red", \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 45 offset 1,1 textcolor "red" notitle, \
                     '' using 1:3   with linespoints title "Expense x 30" ls 1 linecolor rgb "red"
EOF
popd
