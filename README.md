# DataAnalytics-Assessment
SQL solutions for a Cowrywise Data Analytics assessment.

# Data Analytics SQL Assessment

This repository contains SQL solutions to a four-question data analytics assessment focused on customer behavior using savings and investment data.

---

## Files Included

- `Assessment_Q1.sql`: Summary of customers with savings/investment plans and total deposits.
- `Assessment_Q2.sql`: Classification of customers based on their average transaction frequency.
- `Assessment_Q3.sql`: Identification of inactive plans based on recent transactions.
- `Assessment_Q4.sql`: Estimation of Customer Lifetime Value (CLV) using transaction value and tenure.

---

## Per-Question Explanations

### Question 1: Savings and Investment Summary
**Goal**: For each user, count the number of savings and investment plans, and calculate the total confirmed deposits.

**Approach**:
- Used subqueries to calculate:
  - Count of savings and investment plans from `plans_plan`.
  - Sum of `confirmed_amount` from `savings_savingsaccount`, converted from kobo to naira.
- Used `JOIN`s to combine metrics per user.
- The final result includes the user’s full name and is sorted by total deposits in descending order.

---

### Question 2: Customer Transaction Frequency
**Goal**: Classify customers based on how frequently they perform transactions.

**Approach**:
- Nested subqueries were used to calculate average transactions per customer per month.
- Customers were bucketed into `High`, `Medium`, and `Low` frequency categories.
- Final aggregation returned the count of customers per category and their average frequency.

---

### Question 3: Inactive Plans
**Goal**: Identify plans where the associated customer has not transacted in over 365 days.

**Approach**:
- Used CTEs (and subquery variant) to:
  - Get each customer's most recent transaction date.
  - Label each plan as `Savings` or `Investment`.
- Joined the two datasets and filtered for inactivity >365 days or no transactions.
- Sorted results by the number of days inactive.

---

### Question 4: Estimated Customer Lifetime Value (CLV)
**Goal**: Estimate CLV using transaction history and customer tenure.

**Approach**:
- Two CTEs were used to compute:
  - Total transaction value and count.
  - Customer tenure in months based on registration and last transaction dates.
  - CLV = (Total Transaction Value / Tenure in Months) * 12 * 0.001
- Customers with tenure below one month were excluded to avoid divide-by-zero errors.

---

## Challenges & Resolutions

### Challenge 1: Performance Comparison Between CTEs and Subqueries
- **Problem**: For some questions, the subquery approach appeared slower than the CTE version.
- **Solution**: Timed and compared both; performance difference was negligible, so subqueries were used for better inline readability.

### Challenge 2: Handling Missing Names in Question 1
- **Problem**: Some rows had `NULL` or empty values in `first_name` or `last_name` columns.
- **Solution**: Used `CONCAT(u.first_name, ' ', u.last_name)` to gracefully construct a full name, even if one of the fields is missing.

### Challenge 3: Labeling Plan Types
- **Problem**: Plan type (Savings or Investment) had to be derived from multiple boolean columns.
- **Solution**: Used a `CASE` expression to create a unified `type` column based on flags.

### Challenge 4: Nulls and Divide-by-Zero in CLV Calculation
- **Problem**: Customers with no tenure or no transactions led to null or divide-by-zero issues.
- **Solution**: Added filters and `COALESCE` to handle these edge cases.

---

## Next Steps
- Test performance with larger datasets and investigate use of indexes.

---

## Author
Ilechie Peniel

---
