find /var/tmp -maxdepth 1 -type d -iname 'ledger_20*' | sort | head -n -5 | xargs rm -vrf
find /var/tmp -maxdepth 1 -iname 'ledger_cron*' | sort | head -n 5 | xargs rm -v
find /var/tmp -maxdepth 1 -iname 'ledger_monthly_cron*' | sort | head -n 5 | xargs rm -v

