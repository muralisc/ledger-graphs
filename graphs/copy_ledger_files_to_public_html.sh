#!/bin/bash
# COPY GENERATED PNG TO PUBLIC FOLDER

PROJECTION_FOLDER=$(find /var/tmp -iname "ledger_20*" 2> /dev/null | sort | tail -1)

mkdir -p ~/public_html/
cp $PROJECTION_FOLDER/ledger_projection.png ~/public_html/ledger_projection.png
cp $PROJECTION_FOLDER/ledger_monthly_inc_exp.png ~/public_html/ledger_monthly_inc_exp.png
cp $PROJECTION_FOLDER/ledger_monthly_payee.png ~/public_html/ledger_monthly_payee.png

