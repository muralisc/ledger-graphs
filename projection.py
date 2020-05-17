#!/usr/bin/python3

TIME_INTERVAL="1year"
UNIT="lakhs"
SAVINGS_AMOUNT_PER_YEAR=12 #lakhs
INITIAL_CORPUS_ENDING_YEAR=2019
INITIAL_CORPUS=42
AGE_ENDING_YEAR=30
RATE_OF_INTEREST=6
Inflation=8
Last_age=35

# Assumptions
# Expense per year == Savings

# Starting with prev corpus and savings rate, estimate: 
# 1. Networth at an age
# 2. Salary required to achieve that
# 3. Corpus required for fire : Interest from corpus should be equal to expanses

YEAR=INITIAL_CORPUS_ENDING_YEAR
PREV_CORPUS=INITIAL_CORPUS
year = INITIAL_CORPUS_ENDING_YEAR
titles = ""
titles += "{:5}".format("AGE")
titles += ",YEAR"
titles += ",Inflation"
titles += ",Savings"
titles += ",Rate"
titles += ",Interest"
titles += ",NetWorth"
titles += ",|"
titles += ",SalAfterTax"
titles += ",SalBeforeTax"
titles += ",FIRE_Now"
print(titles)
titles = ""
titles += "{:5}".format(AGE_ENDING_YEAR)
titles += ",{:5}".format(year)
titles += ", " 
titles += ", "
titles += ", "
titles += ", "
titles += ",{:5.2f}" .format(PREV_CORPUS)
titles += ",|"
titles += ", "
titles += ", "
titles += ", "
print(titles)
for age in range(AGE_ENDING_YEAR+1, Last_age+1):
  INTEREST=PREV_CORPUS*RATE_OF_INTEREST/100
  NEXT_CORPUS=INTEREST + PREV_CORPUS + SAVINGS_AMOUNT_PER_YEAR
  year+=1
  SALARY_REQ_AFTER_TAX=2*SAVINGS_AMOUNT_PER_YEAR
  SALARY_BEFORE_TAX = SALARY_REQ_AFTER_TAX / 0.7
  FIRE_CORPUS_REQ = SAVINGS_AMOUNT_PER_YEAR / RATE_OF_INTEREST * 100
  msg = ""
  msg += "{:5}"     .format (age)
  msg += ",{:5}"    .format (year)
  msg += ",{}%"     .format (Inflation)
  msg += ",{:5.2f}" .format (SAVINGS_AMOUNT_PER_YEAR)
  msg += ",{:5}"    .format (RATE_OF_INTEREST)
  msg += ",{:5.2f}" .format (INTEREST)
  msg += ",{:5.2f}" .format (NEXT_CORPUS)
  msg += ",|"
  msg += ",{:5.2f}" .format (SALARY_REQ_AFTER_TAX)
  msg += ",{:5.2f}" .format (SALARY_BEFORE_TAX)
  msg += ",{:5.2f}" .format (FIRE_CORPUS_REQ)
  print(msg)
  PREV_CORPUS= NEXT_CORPUS
  SAVINGS_AMOUNT_PER_YEAR *= 1.00 + Inflation/100
