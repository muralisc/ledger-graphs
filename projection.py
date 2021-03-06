#!/usr/bin/python3

SAVINGS_AMOUNT_PER_YEAR=12.0 # lakhs
EXPENSE_PER_YEAR = 12.0 # lakhs
INITIAL_CORPUS=42.0 #lakhs
INITIAL_CORPUS_YEAR=2019
AGE_INITIAL_CORPUS=30
RATE_OF_INTEREST=6.0
Inflation=8.0
Last_age=35

# Assumptions
# Expense per year == Savings

# Starting with prev corpus and savings rate, estimate:
# 1. Networth at an age
# 2. Salary required to achieve that
# 3. Corpus required for fire : Interest from corpus should be equal to expanses

YEAR=INITIAL_CORPUS_YEAR
PREV_CORPUS=INITIAL_CORPUS
year = INITIAL_CORPUS_YEAR
titles = ""
titles += "{:3}".format("AGE")
titles += ",YEAR"
titles += ",Inflation"
titles += ",Savings"
titles += ",Rate"
titles += ",Interest"
titles += ",NetWorth"
titles += ",|"
titles += ",SalReqAfterTax"
titles += ",SalReqBeforeTax"
titles += ",FIRE_Now"
print(titles)
titles = ""
titles += " {:3}"    .format(AGE_INITIAL_CORPUS)
titles += ",{:5}"    .format(year)
titles += ",{:7}%"   .format(8.0)
titles += ",{:6}"    .format("")
titles += ",{:5}"    .format("")
titles += ",{:7}"    .format("")
titles += ",{:8.2f}" .format(PREV_CORPUS)
titles += ",|"
titles += ",{:14}".format("")
titles += ",{:15}".format("")
titles += ",{:8}".format("")
print(titles)
for age in range(AGE_INITIAL_CORPUS+1, Last_age+1):
  INTEREST=PREV_CORPUS*RATE_OF_INTEREST/100
  NEXT_CORPUS=INTEREST + PREV_CORPUS + SAVINGS_AMOUNT_PER_YEAR
  year+=1
  # savings should increase per year
  SAVINGS_AMOUNT_PER_YEAR = SAVINGS_AMOUNT_PER_YEAR * (1 + Inflation/100)
  EXPENSE_PER_YEAR = EXPENSE_PER_YEAR * (1 + Inflation/100)
  SALARY_REQ_AFTER_TAX=EXPENSE_PER_YEAR + SAVINGS_AMOUNT_PER_YEAR # assuming will save half of the salary
  SALARY_BEFORE_TAX = SALARY_REQ_AFTER_TAX / 0.70 # add the tax , assuming 30 tax bracket
  FIRE_CORPUS_REQ = SALARY_REQ_AFTER_TAX / 0.04 # 4percent of corpus should be your salary
  msg = ""
  msg += " {:3}"    .format (age)
  msg += ",{:5}"    .format (year)
  msg += ",{:7}%"   .format (Inflation)
  msg += ",{:6.2f}" .format (SAVINGS_AMOUNT_PER_YEAR)
  msg += ",{:5}"    .format (RATE_OF_INTEREST)
  msg += ",{:7.2f}" .format (INTEREST)
  msg += ",{:8.2f}" .format (NEXT_CORPUS)
  msg += ",|"
  msg += ",{:14.2f}" .format (SALARY_REQ_AFTER_TAX)
  msg += ",{:15.2f}" .format (SALARY_BEFORE_TAX)
  msg += ",{:8.2f}" .format (FIRE_CORPUS_REQ)
  print(msg)
  PREV_CORPUS= NEXT_CORPUS
  SAVINGS_AMOUNT_PER_YEAR *= 1.00 + Inflation/100
