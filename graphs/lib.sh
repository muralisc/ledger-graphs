#!/bin/bash


function ledger_b() {
    FILTER=$1
    CURRENCY=$2
    DATE_BEGIN=$3
    DATE_END=$4

    OPT_DATE_BEGIN=""
    if [[ -n $DATE_BEGIN ]]; then
        OPT_DATE_BEGIN="--begin $DATE_BEGIN"
    fi

    if [[ -z $DATE_END ]]; then
        echo "ledger_b: DATE_END not provided"
        exit 1
    fi

    # set -x
    ledger b \
        "$FILTER" \
        --real \
        --strict \
        -X "$CURRENCY" \
        "$OPT_DATE_BEGIN" \
        --collapse \
        --end "$DATE_END" \
        --balance-format="%(abs(quantity(scrub(floor(display_total)))))\n" \
    | tail -1
    set +x
}

function net_yearly() {
    FILENAME="$1"
    FILTER="$2"
    loop_max="$3"
    CURRENCY="USD"
    date_start=$(date +"%Y-%m-%d")

    cat /dev/null > "$FILENAME"
    loop=1
    echo "Calulating net yearly $FILTER from $date_start back $loop_max years"
    while (( loop < loop_max )) ; do
      DATE_BEGIN=""
      bal=$(ledger_b "$FILTER" $CURRENCY "$DATE_BEGIN" "$date_start" )
      echo "$date_start $bal" # output to $FILENAME
      loop=$((loop+1))
      date_start=$(dateadd "$date_start" -1y --format="%Y-%m-%d")
    done > "$FILENAME"
}

get_past12_mothly_avg_savings() {
    dateEnd=$1
    YEARLY_INTEREST=$2
    LOOKBACK_MONTHS=12
    CURRENCY="USD"

    dateBeg=$(dateadd "$dateEnd" -${LOOKBACK_MONTHS}mo --format="%Y-%m")
    FILTER="^Income ^Expense"
    DATE_BEGIN="$dateBeg"
    DATE_END="$dateEnd"
    durationsav=$(ledger_b "$FILTER" $CURRENCY "$DATE_BEGIN" "$DATE_END" )
    monthsav=$((durationsav/LOOKBACK_MONTHS)) #600000
    echo "$monthsav"
}


function projection() {
    FILENAME="$1"
    AVG_MONTH_SAV="$2"
    TARGET_AMT="$3"
    date_value="$4"
    YEARLY_INTEREST=8

    CURRENCY="USD"
    cur_balence=$(ledger b \
        Assets \
        --real \
        --strict \
        -X $CURRENCY \
        --collapse \
        --end "$date_value" \
        --balance-format=" %(abs(quantity(scrub(floor(display_total)))))\n")
    loop=1
    while (( $(echo "$cur_balence < $TARGET_AMT" | bc -l) )) && (( loop < 10 )) ; do
        echo "$date_value $cur_balence" ; 
        cur_balence=$(bc <<< "scale=2; $cur_balence * (1 + $YEARLY_INTEREST/100) + ($AVG_MONTH_SAV * 12)")
        date_value=$(dateadd "$date_value" +12mo --format "%Y-%m-%d");  
        loop=$((loop+1))
    done > "$FILENAME"
}
