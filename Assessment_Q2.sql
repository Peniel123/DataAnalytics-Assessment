-- Assessment Question 2
-- Goal: Categorize customers based on how frequently they perform transactions on a monthly basis.
-- 
-- Approach:
-- 1. Aggregate the number of transactions each customer makes per month.
-- 2. Compute the average monthly transaction frequency for each customer.
-- 3. Categorize customers based on their average frequency:
--    - High Frequency: ≥ 10 transactions/month
--    - Medium Frequency: 3–9 transactions/month
--    - Low Frequency: < 3 transactions/month
-- 4. Return the count of customers per frequency category and their average monthly frequency.

SELECT
  categorized.frequency_category,
  COUNT(categorized.owner_id) AS customer_count,
  ROUND(AVG(categorized.avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM (
  SELECT 
    avg_trans.owner_id,
    avg_trans.avg_transactions_per_month,
    
    -- Classify customers based on their average monthly transaction frequency
    CASE
      WHEN avg_trans.avg_transactions_per_month >= 10 THEN 'High Frequency'
      WHEN avg_trans.avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category

  FROM (
    SELECT 
      mt.owner_id,
      AVG(mt.transactions_count) AS avg_transactions_per_month
    FROM (
      SELECT 
        owner_id,
        YEAR(transaction_date) AS year,
        MONTH(transaction_date) AS month,
        COUNT(*) AS transactions_count  -- Total transactions by customer for each month
      FROM adashi_staging.savings_savingsaccount
      GROUP BY owner_id, year, month
    ) mt
    GROUP BY mt.owner_id
  ) avg_trans
) categorized

GROUP BY categorized.frequency_category

-- Custom sort order: High → Medium → Low
ORDER BY 
  CASE categorized.frequency_category
    WHEN 'High Frequency' THEN 1
    WHEN 'Medium Frequency' THEN 2
    WHEN 'Low Frequency' THEN 3
  END;
