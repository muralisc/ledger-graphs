#!/bin/bash
# Forecasting info from : https://beyondrule4.jmmorrissey.com/forecasting

CURRENT_FILE_PATH="${BASH_SOURCE[0]:-$0}"
source "$(dirname "$CURRENT_FILE_PATH")/lib.sh"

if ! command -v dateadd &> /dev/null
then
    echo "'dateadd' could not be found"
    echo "  Needs dateutils installed"
    echo "  sudo apt install dateutils"
    exit 1
fi


export LEDGER_FILE=$1
export LEDGER_PRICE_DB=$2
export FOLDER="$3"

shift #unset $3 if any
shift #unset $2 if any
shift #unset $1 if any

mkdir -p "$FOLDER"

if [[ -z "$LEDGER_TERM" ]]; then
  LEDGER_TERM="qt size 1750,900 persist"
fi

CURRENCY=GBP
yearly_expenses_gbp=${YEARLY_EXPENSES_GBP:-46000}
targe_amt=$((2*25*yearly_expenses_gbp))
financialInd=$((25*yearly_expenses_gbp))
lean_FI=$((17*yearly_expenses_gbp))
half_FI=$((12*yearly_expenses_gbp))
FU_target=$((3*yearly_expenses_gbp))

LEDGER_RUN_DATE=${LEDGER_RUN_DATE:-${LEDGER_TEST_DATE:-$(date +%Y-%m-%d)}}

pushd "$FOLDER" || return


# get_past_years_assets
net_yearly "graph1_assets.tmp" "^Assets" "9" &
# get_past_years_expense
net_yearly "graph1_expense.tmp" "^Expense" "8" &
wait

YEARLY_INTEREST=8
dateEnd=${MILESTONE_DATE_NEW_JOB:-2021-12}
echo "Calculating avg monthly savings from -12m to $dateEnd"
avg_monthsav_new_job=$(get_past12_mothly_avg_savings $dateEnd $YEARLY_INTEREST)
echo "Monthly Savings at $dateEnd : $avg_monthsav_new_job"

dateEnd=${MILESTONE_DATE_OLD_JOB:-2020-11}
echo "Calculating avg monthly savings from -12m to $dateEnd"
monthsav_old=$(get_past12_mothly_avg_savings $dateEnd $YEARLY_INTEREST)
echo "Monthly Savings Old at $dateEnd : $monthsav_old"



# projection from end of old-job milestone at new-job rate
projection graph1_newjob_compound_from_old_job_milestone.tmp "$avg_monthsav_new_job" $targe_amt "${MILESTONE_DATE_OLD_JOB:-2020-11}-01" &

# Projection from end of old-job milestone at old-job rate
projection graph1_oldjob_compound_from_old_job_milestone.tmp "$monthsav_old" $targe_amt "${MILESTONE_DATE_OLD_JOB:-2020-11}-01" &

# Project from now at new-job rate
projection graph1_newjob_compound_from_now.tmp "$avg_monthsav_new_job" $targe_amt "${LEDGER_TEST_DATE:-$(date +%Y-%m-%d)}" &

# Project from now at old-job rate
projection graph1_oldjob_compound_from_now.tmp "$monthsav_old" $targe_amt "${LEDGER_TEST_DATE:-$(date +%Y-%m-%d)}" &

wait


echo "Creating file in $FOLDER/ledger_projection.png"

# echo $LEDGER_TERM
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
  set title "Wealthgrow on $LEDGER_RUN_DATE"
  set ylabel "Amount"
  set style fill transparent solid 0.6 noborder
  set decimal locale "en_US.UTF-8"

  #linestyle for 1
  set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
  #linestyle for 2
  set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 pi -1 ps 1.5
  #linestyle for 3
  set style line 3 lc rgb '#dd181f' lt 1 lw 2 pt 3 pi -1 ps 1.5
  #linestyle for 5
  set style line 5 lc rgb '#00181f' lt 1 lw 2 pt 15 pi -1 ps 1.5

  set pointintervalbox 3

  set arrow 1 from graph 0,first $half_FI to graph 1,first $half_FI nohead lc "red" dashtype 3 linewidth 2
  set label 1 at graph 0,first $half_FI "half FI" offset 0.5,1.0
  set arrow 2 from graph 0,first $financialInd to graph 1,first $financialInd nohead lc "red" dashtype 3 linewidth 2
  set label 2 at graph 0,first $financialInd "FI" offset 0.5,1.0
  set arrow 3 from graph 0,first $FU_target to graph 1,first $FU_target nohead linestyle 3
  set label 3 at graph 0,first $FU_target "FU" offset 0.5,1.0
  set arrow 4 from graph 0,first $lean_FI to graph 1,first $lean_FI nohead linestyle 4
  set label 4 at graph 0,first $lean_FI "Lean FI" offset 0.5,1.0
  set arrow 5 from graph 0,first $targe_amt to graph 1,first $targe_amt nohead lc "red" dashtype 3 linewidth 2
  set label 5 at graph 0,first $targe_amt "Target" offset 0.5,1.0

  plot \
    "graph1_assets.tmp"               using 1:2   with filledcurves x1 title "Assets" linecolor rgb "goldenrod", \
    ""                                using 1:2   with points ls 5, \
    ""                      every 1   using 1:2:2 with labels font "Courier,12" rotate by 05 offset 0,0.5 textcolor linestyle 0 notitle, \
    "graph1_expense.tmp"              using 1:2   with filledcurves y1=0 title "Expenses" linecolor rgb "violet", \
    ""                                using 1:2:2 with labels font "Courier,8" offset 0,0.5 textcolor linestyle 0 notitle, \
    "graph1_newjob_compound_from_old_job_milestone.tmp" using 1:2   with linespoints ls 1 title "Job Change ProjectionCompound at NewJob Rate" ,\
    ""                                using 1:2:2 with labels font "Courier,12" rotate by 1 offset 7,0 textcolor linestyle 0 notitle, \
    "graph1_newjob_compound_from_now.tmp" using 1:2   with linespoints ls 2 title "ProjectionCompound at NewJob Rate", \
    ""                                using 1:2:2 with labels font "Courier,12" offset 0,1 textcolor linestyle 2 notitle, \
    "graph1_oldjob_compound_from_old_job_milestone.tmp"   using 1:2   with linespoints ls 3 title "Job Change ProjectionCompound at OldJob Rate" ,\
    ""                                using 1:2:2 with labels font "Courier,12" rotate by 40 offset 1,-1 textcolor linestyle 3 notitle, \
    "graph1_oldjob_compound_from_now.tmp"       using 1:2   with linespoints ls 4 title "ProjectionCompound at OldJob Rate", \
    ""                                using 1:2:2 with labels font "Courier,12" offset 0,0.5 textcolor linestyle 4 notitle
EOF
popd || return

#rm ledgeroutput*.tmp
