#!/bin/bash

# find the latest ledger run
PROJECTION_FOLDER=$(find /var/tmp -iname "ledger_20*" 2> /dev/null | sort | tail -1)

CURRENT_PROJECTION_FILE=ledgeroutput_current_projection.tmp
CURRENT_COMPOUND=ledgeroutput_current_compound.tmp

CISCO_COMPOUND=ledgeroutput_cisco_compound.tmp

influx_db_data_file=${PROJECTION_FOLDER}/lines_for_influxdb.log

run_date=$(date +%Y-%m-%d)

while read line; do
  projecteddate=$(awk '{print $1}' <<< $line)
  projectedamt=$(awk '{print $2}' <<< $line)
  projecteddate_sec=$(date --date $projecteddate +%s%N)
  echo "ledger,prediction_date=${run_date},type=current_linear assets=${projectedamt},income=43i $projecteddate_sec" >> $influx_db_data_file
done < $PROJECTION_FOLDER/$CURRENT_PROJECTION_FILE

while read line; do
  projecteddate=$(awk '{print $1}' <<< $line)
  projectedamt=$(awk '{print $2}' <<< $line)
  projecteddate_sec=$(date --date $projecteddate +%s%N)
  echo "ledger,prediction_date=${run_date},type=current_compound assets=${projectedamt},income=43i $projecteddate_sec" >> $influx_db_data_file
done < $PROJECTION_FOLDER/$CURRENT_COMPOUND

while read line; do
  projecteddate=$(awk '{print $1}' <<< $line)
  projectedamt=$(awk '{print $2}' <<< $line)
  projecteddate_sec=$(date --date $projecteddate +%s%N)
  echo "ledger,prediction_date=${run_date},type=cisco_compound assets=${projectedamt},income=43i $projecteddate_sec" >> $influx_db_data_file
done < $PROJECTION_FOLDER/$CISCO_COMPOUND

org=my-org
bucket=my-bucket
token=my-super-secret-auth-token
curl --request POST \
"http://192.168.0.26:8086/api/v2/write?org=${org}&bucket=${bucket}&precision=ns" \
  --header "Authorization: Token $token" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "@$influx_db_data_file"
