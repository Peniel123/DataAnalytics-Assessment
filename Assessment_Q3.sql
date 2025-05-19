-- Assessment Question 3
-- Objective: Identify users with active savings or investment plans who have been inactive (i.e., have not made a transaction) for over 365 days.
--
-- Approach:
-- 1. Use a CTE `recent_transactions` to get the most recent transaction date per customer from the savings table.
-- 2. Use another CTE `active_plans` to filter only active plans (regular savings or investments) and label their type.
-- 3. Join both datasets to find users with either:
--      - No transaction record at all (NULL last_transaction_date), or
--      - A last transaction over 365 days ago.
-- 4. Compute inactivity duration using DATEDIFF.
--
-- This method separates logic into reusable, readable units and was found to perform efficiently on real data.

WITH recent_transactions AS (
    SELECT 
        owner_id, 
        -- Get the latest (most recent) transaction date for each user.
        -- This helps us determine how long ago they last interacted with their savings plan.
        MAX(transaction_date) AS last_transaction_date
    FROM adashi_staging.savings_savingsaccount
    GROUP BY owner_id
),

active_plans AS (
    SELECT 
        id AS plan_id, 
        owner_id,
        -- Use CASE to classify each plan type:
        -- If the plan is marked as a regular savings plan, label it as 'Savings'.
        -- If the plan is marked as a fund, label it as 'Investment'.
        -- This makes the results easier to interpret in plain English.
        CASE 
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
        END AS type
    FROM plans_plan
    -- We are only interested in plans that are currently active:
    -- either regular savings plans or investment funds.
    WHERE is_regular_savings = 1 OR is_a_fund = 1
)

SELECT 
    ap.plan_id,
    ap.owner_id,
    ap.type,
    rt.last_transaction_date,
    -- Calculate the number of days since the last transaction.
    -- If the user never transacted, this value will be NULL and filtered below.
    DATEDIFF(CURDATE(), rt.last_transaction_date) AS inactivity_days
FROM active_plans ap
-- Join each plan with its owner's most recent transaction (if any).
LEFT JOIN recent_transactions rt 
    ON ap.owner_id = rt.owner_id
WHERE 
    -- Include users who have NEVER made a transaction
    rt.last_transaction_date IS NULL 
    -- Or users who haven't transacted in over 365 days
    OR DATEDIFF(CURDATE(), rt.last_transaction_date) > 365
ORDER BY inactivity_days DESC;
