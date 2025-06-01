#!/bin/bash

TIME_DIFF=120mo
START_TIME=$(dateadd $(date +"%Y-%m-01") -$TIME_DIFF --format="%Y-%m-%d")
CURRENT_MONTH_START=$(date +"%Y-%m-01")

echo "# Made with ledger-graphs/simulate-txns.sh on '$(date)'"

for cdate in $(dateseq $START_TIME 1mo $CURRENT_MONTH_START); do

SALARY_MIN=700
SALARY_MAX=1000
RANDOM_SAL="$(($SALARY_MIN + $RANDOM % ($SALARY_MAX-$SALARY_MIN)))"

DEFAULT_EXPENSE_MIN=2
DEFAULT_EXPENSE_MAX=20

RANDOM_ALO_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"
RANDOM_ENT_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"
RANDOM_GRO_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"
RANDOM_HEA_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"
RANDOM_HOU_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"
RANDOM_POS_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"
RANDOM_TRA_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"
RANDOM_UTI_EXP="$(($DEFAULT_EXPENSE_MIN + $RANDOM % ($DEFAULT_EXPENSE_MAX-$DEFAULT_EXPENSE_MIN)))"

echo "
$cdate * \"Interest for Mar 2025\"
        Assets:Bank:HSBC:Savings         $RANDOM_SAL GBP
        Income:Salary

$cdate * \"Allowance for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_ALO_EXP GBP
        Expenses:Allowance

$cdate * \"Entertainment for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_ENT_EXP GBP
        Expenses:Entertainment

$cdate * \"Groceries for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_GRO_EXP GBP
        Expenses:Groceries

$cdate * \"Health for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_HEA_EXP GBP
        Expenses:Health

$cdate * \"Housing for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_HOU_EXP GBP
        Expenses:Housing

$cdate * \"Posessions for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_POS_EXP GBP
        Expenses:Posessions

$cdate * \"Transport for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_TRA_EXP GBP
        Expenses:Transport

$cdate * \"Utilities for $cdate\"
        Assets:Bank:HSBC:Savings         -$RANDOM_UTI_EXP GBP
        Expenses:Utilities

"
done
