-- Assessment Question 1
-- Objective: For each customer, show the number of savings plans, investment plans, and total confirmed deposits.
-- Approach:
--   - Use subqueries to calculate savings and investment plan counts per customer.
--   - Use a subquery to sum total confirmed deposits per customer from the savings_savingsaccount table.
--   - Use COALESCE to handle customers with no deposits.
--   - Convert the total deposit amount from kobo to naira by dividing by 100.
--   - Filter to include only users who have at least one savings and one investment plan.

SELECT
  u.id AS owner_id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,

  -- Count of savings plans per customer
  (
    SELECT COUNT(*)
    FROM plans_plan sp
    WHERE sp.is_regular_savings = 1 AND sp.owner_id = u.id
  ) AS savings_count,

  -- Count of investment plans per customer
  (
    SELECT COUNT(*)
    FROM plans_plan ip
    WHERE ip.is_a_fund = 1 AND ip.owner_id = u.id
  ) AS investment_count,

  -- Total confirmed deposits (in naira), defaulting to 0 if none exist
  ROUND(
    COALESCE((
      SELECT SUM(s.confirmed_amount)
      FROM adashi_staging.savings_savingsaccount s
      WHERE s.owner_id = u.id
    ), 0) / 100, 2
  ) AS total_deposits

FROM users_customuser u

-- Ensure the user has both a savings and an investment plan
WHERE
  (SELECT COUNT(*) FROM plans_plan sp WHERE sp.is_regular_savings = 1 AND sp.owner_id = u.id) > 0
  AND
  (SELECT COUNT(*) FROM plans_plan ip WHERE ip.is_a_fund = 1 AND ip.owner_id = u.id) > 0

ORDER BY total_deposits DESC;
