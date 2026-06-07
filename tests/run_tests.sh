#!/bin/bash
# Test runner for ledger-graphs/v1 scripts.
#
# Usage:
#   bash run_tests.sh                  # compare against golden files
#   bash run_tests.sh --update-golden  # overwrite golden files with current output

set -uo pipefail

UPDATE_GOLDEN=false
[[ "${1:-}" == "--update-golden" ]] && UPDATE_GOLDEN=true

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V1_DIR="$(dirname "$TESTS_DIR")/v1"
TEST_LEDGER="$TESTS_DIR/test.ledger"
TEST_PRICEDB="$TESTS_DIR/test.pricedb"
GOLDEN_DIR="$TESTS_DIR/golden"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Fixed reference date — must match the test.ledger window.
# Regenerate golden files (create_golden.sh) after changing this.
export LEDGER_TEST_DATE="2026-06-01"
export MILESTONE_DATE_NEW_JOB="2021-12"
export MILESTONE_DATE_OLD_JOB="2020-11"
export YEARLY_EXPENSES_GBP="46000"

PASS=0
FAIL=0
FAILURES=()

# ── Helpers ──────────────────────────────────────────────────────────────────

pass() { echo "  PASS  $1"; PASS=$((PASS + 1)); }

fail() { echo "  FAIL  $1 — $2"; FAIL=$((FAIL + 1)); FAILURES+=("$1: $2"); }

check_exit() {
    local label=$1 code=$2 log=$3
    if [[ $code -eq 0 ]]; then
        pass "$label exit 0"
    else
        fail "$label exit 0" "script exited $code"
        cat "$log" >&2
    fi
}

check_exists() {
    local label=$1 path=$2
    if [[ -f "$path" && -s "$path" ]]; then
        pass "$label exists"
        return 0
    else
        fail "$label exists" "file missing or empty"
        return 1
    fi
}

compare_or_update() {
    local label=$1 actual=$2 golden=$3
    if $UPDATE_GOLDEN; then
        mkdir -p "$(dirname "$golden")"
        cp "$actual" "$golden"
        echo "  SAVED $label"
        return
    fi
    if [[ ! -f "$golden" ]]; then
        fail "$label" "golden file missing — run create_golden.sh to create"
        return
    fi
    if diff -q "$actual" "$golden" > /dev/null 2>&1; then
        pass "$label"
    else
        fail "$label" "differs from golden"
        diff "$golden" "$actual" | head -20
    fi
}

run_and_check() {
    local script=$1 folder=$2 log=$3
    shift 3
    bash "$V1_DIR/$script" "$@" > "$log" 2>&1
    check_exit "$script" $? "$log"
}

# ── Script 1 ─────────────────────────────────────────────────────────────────

run_script1() {
    local folder="$WORK_DIR/s1" log="$WORK_DIR/s1.log"
    echo "── script 1: yearly cumulative asset/expense ────────────────────────────"
    run_and_check \
        "1-yearly-last10year-cumulative_asset_expense.sh" \
        "$folder" "$log" \
        "$TEST_LEDGER" "$TEST_PRICEDB" "$folder"

    local data_files=(
        graph1_assets.tmp
        graph1_expense.tmp
        graph1_newjob_compound_from_old_job_milestone.tmp
        graph1_old_cisco_compound.tmp
        graph1_newjob_compound_from_now.tmp
        graph1_cisco_compound.tmp
    )
    for f in "${data_files[@]}"; do
        if check_exists "script1/$f" "$folder/$f"; then
            compare_or_update "script1/$f" "$folder/$f" "$GOLDEN_DIR/script1/$f"
        fi
    done
    check_exists "script1/ledger_projection.png" "$folder/ledger_projection.png"
}

# ── Script 2 ─────────────────────────────────────────────────────────────────

run_script2() {
    local folder="$WORK_DIR/s2" log="$WORK_DIR/s2.log"
    echo "── script 2: monthly income/expense ─────────────────────────────────────"
    run_and_check \
        "2-monthly-lastmonth-income_expense.sh" \
        "$folder" "$log" \
        "$TEST_LEDGER" "$TEST_PRICEDB" "$folder"

    local data_files=(
        graph2_monthly_income.txt
        graph2_monthly_expense.txt
        graph2_monthly_savings.txt
        ledger_run_date.txt
    )
    for f in "${data_files[@]}"; do
        if check_exists "script2/$f" "$folder/$f"; then
            compare_or_update "script2/$f" "$folder/$f" "$GOLDEN_DIR/script2/$f"
        fi
    done
    check_exists "script2/graph2_monthly_inc_exp.png" "$folder/graph2_monthly_inc_exp.png"
}

# ── Script 3 ─────────────────────────────────────────────────────────────────

run_script3() {
    local folder="$WORK_DIR/s3" log="$WORK_DIR/s3.log"
    echo "── script 3: monthly expense accounts ───────────────────────────────────"
    run_and_check \
        "3-monthly-lastmonth-expense_accounts.sh" \
        "$folder" "$log" \
        "$TEST_LEDGER" "$TEST_PRICEDB" "$folder"

    local data_files=(
        graph3_monthly_expense.txt
        graph3_monthly_expense_moving_average.txt
        ledger_monthly_allowance.txt
        ledger_monthly_entertainment.txt
        ledger_monthly_groceries.txt
        ledger_monthly_health.txt
        ledger_monthly_housing.txt
        ledger_monthly_posessions.txt
        ledger_monthly_transport.txt
        ledger_monthly_utilities.txt
        ledger_monthly_allowance_moving_avg.txt
        ledger_monthly_entertainment_moving_avg.txt
        ledger_monthly_groceries_moving_avg.txt
        ledger_monthly_health_moving_avg.txt
        ledger_monthly_housing_moving_avg.txt
        ledger_monthly_posessions_moving_avg.txt
        ledger_monthly_transport_moving_avg.txt
        ledger_monthly_utilities_moving_avg.txt
    )
    for f in "${data_files[@]}"; do
        if check_exists "script3/$f" "$folder/$f"; then
            compare_or_update "script3/$f" "$folder/$f" "$GOLDEN_DIR/script3/$f"
        fi
    done
    check_exists "script3/ledger_monthly_payee.png" "$folder/ledger_monthly_payee.png"
}

# ── Script 4 ─────────────────────────────────────────────────────────────────

run_script4() {
    local folder="$WORK_DIR/s4" log="$WORK_DIR/s4.log"
    echo "── script 4: daily expense ──────────────────────────────────────────────"
    run_and_check \
        "4-daily-lastmonth-expense.sh" \
        "$folder" "$log" \
        "$TEST_LEDGER" "$folder"

    local data_files=(
        graph4_daily_lastmonth_expense.tmp
    )
    for f in "${data_files[@]}"; do
        if check_exists "script4/$f" "$folder/$f"; then
            compare_or_update "script4/$f" "$folder/$f" "$GOLDEN_DIR/script4/$f"
        fi
    done
    check_exists "script4/graph4_daily_lastmonth_expense.png" "$folder/graph4_daily_lastmonth_expense.png"
}

# ── Script 5 ─────────────────────────────────────────────────────────────────

run_script5() {
    local folder="$WORK_DIR/s5" log="$WORK_DIR/s5.log"
    echo "── script 5: rolling 12-month income/expense ────────────────────────────"
    run_and_check \
        "5-monthly-last1year-income_expense.sh" \
        "$folder" "$log" \
        "$TEST_LEDGER" "$TEST_PRICEDB" "$folder"

    local data_files=(
        graph5_yearly_income.tmp
        graph5_yearly_expense.tmp
        ledger_run_date.txt
    )
    for f in "${data_files[@]}"; do
        if check_exists "script5/$f" "$folder/$f"; then
            compare_or_update "script5/$f" "$folder/$f" "$GOLDEN_DIR/script5/$f"
        fi
    done
    check_exists "script5/graph5_yearly_inc_exp.png" "$folder/graph5_yearly_inc_exp.png"
}

# ── Main ─────────────────────────────────────────────────────────────────────

echo "LEDGER_TEST_DATE=$LEDGER_TEST_DATE"
echo ""

run_script1; echo ""
run_script2; echo ""
run_script3; echo ""
run_script4; echo ""
run_script5; echo ""

echo "────────────────────────────────────────────────────────────────────────────"
if $UPDATE_GOLDEN; then
    echo "Golden files saved to $GOLDEN_DIR"
else
    echo "Results: $PASS passed, $FAIL failed"
    if [[ ${#FAILURES[@]} -gt 0 ]]; then
        echo ""
        echo "Failures:"
        for f in "${FAILURES[@]}"; do echo "  - $f"; done
        exit 1
    fi
fi
