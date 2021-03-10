#!/usr/local/bin/python3
import csv
from collections import defaultdict


date_val = defaultdict(int)
with open('ledgeroutput1.tmp') as income:
    inc = csv.reader(income, delimiter=' ')
    for row in inc:
        date_val[row[0]] = int(row[1])
with open('ledgeroutput2.tmp') as income:
    inc = csv.reader(income, delimiter=' ')
    for row in inc:
        date_val[row[0]] = date_val[row[0]] - int(row[1])

for k in date_val:
    print(k, date_val[k])
