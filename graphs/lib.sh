#!/bin/bash


function ledger_b() {
    FILTER=$1
    CURRENCY=$2
    DATE_BEGIN=$3
    DATE_END=$4

    OPT_DATE_BEGIN=""
    if [[ ! -z $DATE_BEGIN ]]; then
        OPT_DATE_BEGIN="--begin $DATE_BEGIN"
    fi

    if [[ -z $DATE_END ]]; then
        echo "ledger_b: DATE_END not provided"
        exit 1
    fi

    # set -x
    ledger b \
        $FILTER \
        --real \
        --strict \
        -X $CURRENCY \
        $OPT_DATE_BEGIN \
        --collapse \
        --end $DATE_END \
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

    cat /dev/null > $FILENAME
    loop=1
    echo "Calulating net yearly $FILTER from $date_start back $loop_max years"
    while (( loop < loop_max )) ; do
      DATE_BEGIN=""
      bal=$(ledger_b $FILTER $CURRENCY "$DATE_BEGIN" $date_start)
      echo "$date_start $bal" # output to $FILENAME
      loop=$((loop+1))
      date_start=$(dateadd $date_start -1y --format="%Y-%m-%d")
    done > $FILENAME
}
