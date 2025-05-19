-- Assessment_Q4.sql
-- ----------------------------------------------
-- Customer Lifetime Value (CLV) Estimation
-- ----------------------------------------------
-- This query estimates the Customer Lifetime Value based on:
-- 1. Total confirmed transactions (converted from kobo to naira),
-- 2. Tenure in months (since signup),
-- 3. A simplified profit model:
--    Estimated CLV = (transaction_value / tenure_months) * 12 * 0.1% (profit per transaction)
-- 
-- The query uses two CTEs:
--   - transaction_summary: summarizes transaction value and volume
--   - tenure_summary: calculates tenure per user
-- Results are sorted by estimated CLV in descending order.

WITH transaction_summary AS (
  SELECT 
    owner_id AS customer_id,
    -- Convert transaction value from kobo to naira
    SUM(confirmed_amount) / 100 AS total_transaction_value,  
    COUNT(*) AS total_transactions
  FROM savings_savingsaccount
  GROUP BY owner_id
),
tenure_summary AS (
  SELECT 
    id AS customer_id,
    CONCAT(first_name, ' ', last_name) AS name,
    -- Calculate number of full months since the user signed up
    TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) AS tenure_months
  FROM users_customuser
)

SELECT 
  t.customer_id,
  u.name,
  u.tenure_months,
  t.total_transactions,
  
  -- Estimate CLV using the formula: (total_transaction_value / tenure_months) * 0.001 (0.1%) * 12 months
  ROUND(
    (t.total_transaction_value / u.tenure_months) * 0.001 * 12, 
    2
  ) AS estimated_clv

FROM transaction_summary t
JOIN tenure_summary u 
  ON t.customer_id = u.customer_id

-- Only include users who have been active for at least 1 month
WHERE u.tenure_months > 0

-- Show highest CLVs first
ORDER BY estimated_clv DESC;
