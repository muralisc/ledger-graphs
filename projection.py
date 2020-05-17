#!/usr/bin/python3

TIME_INTERVAL="1year"
UNIT="lakhs"
SAVINGS_AMOUNT_PER_YEAR=12 #lakhs
INITIAL_CORPUS_ENDING_YEAR=2019
INITIAL_CORPUS=42
AGE_ENDING_YEAR=30
RATE_OF_INTEREST=6
Inflation=8
Last_age=60

# Assumptions
# Expense per year == Savings

# Starting with prev corpus and savings rate, estimate: 
# 1. Networth at an age
# 2. Salary required to achieve that
# 3. Corpus required for fire : Interest from corpus should be equal to expanses

YEAR=INITIAL_CORPUS_ENDING_YEAR
PREV_CORPUS=INITIAL_CORPUS
year = INITIAL_CORPUS_ENDING_YEAR
print("AGE,YEAR,Inflation,Savings,Rate,Interest,NetWorth,| SalAfterTax,SalBeforeTax,FIRE_Now")
print("{:3},{:4}, , ,  ,       ,{:6.2f},|".format(AGE_ENDING_YEAR, year, PREV_CORPUS))
for age in range(AGE_ENDING_YEAR+1, Last_age+1):
  INTEREST=PREV_CORPUS*RATE_OF_INTEREST/100
  NEXT_CORPUS=INTEREST + PREV_CORPUS + SAVINGS_AMOUNT_PER_YEAR
  year+=1
  SALARY_REQ_AFTER_TAX=2*SAVINGS_AMOUNT_PER_YEAR
  SALARY_BEFORE_TAX = SALARY_REQ_AFTER_TAX / 0.7
  FIRE_CORPUS_REQ = SAVINGS_AMOUNT_PER_YEAR / RATE_OF_INTEREST * 100
  print("{:3},{:4},{}, {:5.2f},{:3},{:5.2f},{:6.2f},| {:0.2f},{:0.2f},{:0.2f}".format(age, year, Inflation, SAVINGS_AMOUNT_PER_YEAR, RATE_OF_INTEREST, INTEREST,
      NEXT_CORPUS, SALARY_REQ_AFTER_TAX, SALARY_BEFORE_TAX, FIRE_CORPUS_REQ))
  PREV_CORPUS= NEXT_CORPUS
  SAVINGS_AMOUNT_PER_YEAR *= 1.00 + Inflation/100
