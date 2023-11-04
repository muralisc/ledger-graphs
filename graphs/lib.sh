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
