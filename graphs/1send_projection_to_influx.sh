#!/bin/bash

# find the latest ledger run
PROJECTION_FOLDER=$(find /var/tmp -iname "ledger_20*" 2> /dev/null | sort | tail -1)

CURRENT_PROJECTION_FILE=ledgeroutput_current_projection.tmp
CURRENT_COMPOUND=ledgeroutput_current_compound.tmp

CISCO_COMPOUND=ledgeroutput_cisco_compound.tmp

ASSETS_FILE=ledgeroutput_assets.tmp

influx_db_data_file=${PROJECTION_FOLDER}/lines_for_influxdb.log

run_date=$(date +%Y-%m-%d)
run_date_epoch=$(date -d "$(date +%Y-%m-%d)" +%s)
run_date_epoch_ns=$(date -d "$(date +%Y-%m-%d)" +%s%N)

while read line; do
  projecteddate=$(awk '{print $1}' <<< $line)
  projectedamt=$(awk '{print $2}' <<< $line)
  projecteddate_sec=$(date --date $projecteddate +%s%N)
  echo "ledger,prediction_date=${run_date},prediction_date_epoch=${run_date_epoch},type=current_linear assets=${projectedamt},income=43i $projecteddate_sec" >> $influx_db_data_file
done < $PROJECTION_FOLDER/$CURRENT_PROJECTION_FILE

while read line; do
  projecteddate=$(awk '{print $1}' <<< $line)
  projectedamt=$(awk '{print $2}' <<< $line)
  projecteddate_sec=$(date --date $projecteddate +%s%N)
  echo "ledger,prediction_date=${run_date},prediction_date_epoch=${run_date_epoch},type=current_compound assets=${projectedamt},income=43i $projecteddate_sec" >> $influx_db_data_file
done < $PROJECTION_FOLDER/$CURRENT_COMPOUND

while read line; do
  projecteddate=$(awk '{print $1}' <<< $line)
  projectedamt=$(awk '{print $2}' <<< $line)
  projecteddate_sec=$(date --date $projecteddate +%s%N)
  echo "ledger,prediction_date=${run_date},prediction_date_epoch=${run_date_epoch},type=cisco_compound assets=${projectedamt},income=43i $projecteddate_sec" >> $influx_db_data_file
done < $PROJECTION_FOLDER/$CISCO_COMPOUND


while read line; do
  projecteddate=$(awk '{print $1}' <<< $line)
  projectedamt=$(awk '{print $2}' <<< $line)
  projecteddate_sec=$(date --date $projecteddate +%s%N)
  echo "ledger,prediction_date=${run_date},prediction_date_epoch=${run_date_epoch},type=current_assets assets=${projectedamt},income=43i $projecteddate_sec" >> $influx_db_data_file
done < $PROJECTION_FOLDER/$ASSETS_FILE

# End of sending logs to influx from projection files ==============================================================================================================================

# FIND PAST YEAR HOURLY RATE !!

# Whats the past year income
PAST_YEAR=$(ledger b Assets -n -X GBP --begin 2021-01 | awk '{print $1}' | tr -d ',')
# Avg working day is 261 , reduce the holidays 231
AVG_WORKING_DAYS=261
HOURS_PER_DAY=8
TAX_PERCENTAGE=40
HOURLY_RATE=$(bc <<< "scale=2; $PAST_YEAR / ($AVG_WORKING_DAYS * $HOURS_PER_DAY) * (100/ (100-$TAX_PERCENTAGE) )")
echo "ledger,type=hourly_rate hourly_rate=${HOURLY_RATE},income=43i $run_date_epoch_ns" >> $influx_db_data_file


org=my-org
bucket=my-bucket
token=my-super-secret-auth-token
curl --request POST \
"http://192.168.0.26:8086/api/v2/write?org=${org}&bucket=${bucket}&precision=ns" \
  --header "Authorization: Token $token" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "@$influx_db_data_file"


# COPY GENERATED PNG TO PUBLIC FOLDER
mkdir -p ~/public_html/
cp $PROJECTION_FOLDER/ledger_projection.png ~/public_html/ledger_projection.png
