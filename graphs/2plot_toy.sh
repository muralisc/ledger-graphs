
ledger_run_date=$(date +%Y-%m-%d)
FOLDER="/var/tmp/ledger/ledger_2_${ledger_run_date}"
mkdir -p $FOLDER

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1280,720 persist"
fi
pushd $FOLDER

TOY_FACTOR=2

awk '{print $1" "$2/'$TOY_FACTOR'}' graph2_monthly_income.txt > graph2_monthly_income_toy.txt
awk '{print $1" "$2/'$TOY_FACTOR'}' graph2_monthly_expense.txt > graph2_monthly_expense_toy.txt
awk '{print $1" "$2/'$TOY_FACTOR'}' graph2_monthly_savings.txt > graph2_monthly_savings_toy.txt


echo "Creating file $FOLDER/graph2_monthly_inc_exp_toy.png"
(cat <<EOF) | gnuplot
  # set terminal $LEDGER_TERM
  set terminal pngcairo size 1750,900 enhanced font "Verdana,10"
  # set terminal canvas mousing size 1750, 900
  set output "$FOLDER/graph2_monthly_inc_exp_toy.png"
  set xdata time
  set timefmt "%Y-%m-%d"
  set format x "%d/%m/%Y-%b"
  set xtics nomirror scale 0 rotate by -55
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  set style line 12 lc rgb '#88ffccff' lt 1 lw 1.5
  set title "Monthly Income and Expenses $ledger_run_date"
  set ylabel "Income, Expense"
  set logscale y 2

  set y2label "(Income) - (Expense)"
  set y2tics textcolor rgb "red"
  set grid xtics ytics ls 12

  set rmargin 10

  plot \
    (500000/$TOY_FACTOR) title "noticed on 2022-01-01 avg exp is 4k" lw 2 , \
    "graph2_monthly_income_toy.txt" using 1:2 with linespoints title "Income" ls 1 linecolor rgb "#ad8c11", \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 15 offset 1,1 textcolor "#3d3ded" notitle, \
    "graph2_monthly_expense_toy.txt" using 1:2 with linespoints title "Expense" ls 1 linecolor rgb "red", \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 45 offset 1,1 textcolor "red" notitle, \
    "graph2_monthly_savings_toy.txt" using 1:2 with linespoints title "Income - Expense" ls 1 linecolor rgb "#dd0060ad" axes x1y2, \
                     '' using 1:2:2 with labels left font "Courier,12" rotate by 45 offset 1,1 textcolor linestyle 1 notitle axes x1y2
EOF
popd
