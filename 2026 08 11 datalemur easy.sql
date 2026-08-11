-- ============================================================
-- DataLemur SQL Practice — Easy Difficulty
-- Date solved: 2026-08-11
-- Dialect: MySQL (adjust LIMIT/date functions for Postgres if needed)
-- ============================================================

-- ------------------------------------------------------------
-- 1. Twitter — Histogram of Tweets
-- Table: tweets (tweet_id, user_id, msg, tweet_date)
-- Goal: For each tweet count bucket, how many users posted that many tweets?
-- ------------------------------------------------------------
SELECT tweet_count_per_user AS tweet_bucket,
       COUNT(user_id) AS num_users
FROM (
    SELECT user_id, COUNT(tweet_id) AS tweet_count_per_user
    FROM tweets
    GROUP BY user_id
) AS user_tweet_counts
GROUP BY tweet_count_per_user;


-- ------------------------------------------------------------
-- 2. LinkedIn — Data Science Skills
-- Table: candidates (candidate_id, skill)
-- Goal: Candidates who know SQL, Python AND Tableau (exactly these 3 rows / no extra)
-- ------------------------------------------------------------
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python', 'Tableau', 'SQL')
GROUP BY candidate_id
HAVING COUNT(DISTINCT skill) = 3;


-- ------------------------------------------------------------
-- 3. Facebook — Page With No Likes
-- Tables: pages (page_id, page_name), page_likes (user_id, page_id, liked_date)
-- Goal: Pages that have never been liked
-- ------------------------------------------------------------
SELECT p.page_id
FROM pages p
LEFT JOIN page_likes pl
    ON p.page_id = pl.page_id
WHERE pl.page_id IS NULL;


-- ------------------------------------------------------------
-- 4. Tesla — Unfinished Parts
-- Table: parts_assembly (step_id, part, assembly_step, finish_date)
-- Goal: Parts that were started but never finished
-- ------------------------------------------------------------
SELECT part
FROM parts_assembly
WHERE finish_date IS NULL;


-- ------------------------------------------------------------
-- 5. NY Times — Laptop vs. Mobile Viewership
-- Table: viewership (user_id, device_type, view_time)
-- Goal: Total laptop views vs total (mobile + tablet) views
-- ------------------------------------------------------------
SELECT
    SUM(CASE WHEN device_type = 'laptop' THEN 1 ELSE 0 END) AS laptop_views,
    SUM(CASE WHEN device_type IN ('tablet', 'phone') THEN 1 ELSE 0 END) AS mobile_views
FROM viewership;


-- ------------------------------------------------------------
-- 6. Facebook — Average Post Hiatus (Part 1)
-- Table: user_content (content_id, type, user_id, post_date)
-- Goal: For each user, the number of days between each of their consecutive posts
-- ------------------------------------------------------------
SELECT user_id,
       post_date,
       DATEDIFF(
           post_date,
           LAG(post_date) OVER (PARTITION BY user_id ORDER BY post_date)
       ) AS days_since_last_post
FROM user_content
WHERE type = 'post'
ORDER BY user_id, post_date;


-- ------------------------------------------------------------
-- 7. Microsoft — Teams Power Users
-- Table: messages (message_id, sender_id, receiver_id, content, sent_date)
-- Goal: Top 2 users by number of messages sent in Aug 2022 (example month)
-- ------------------------------------------------------------
SELECT sender_id,
       COUNT(message_id) AS message_count
FROM messages
WHERE sent_date BETWEEN '2022-08-01' AND '2022-08-31'
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;


-- ------------------------------------------------------------
-- 8. LinkedIn — Duplicate Job Listings
-- Table: job_listings (job_id, company_id, title, description)
-- Goal: Count how many companies have duplicate job listings
-- (same company_id + same description posted more than once)
-- ------------------------------------------------------------
SELECT COUNT(*) AS duplicate_companies
FROM (
    SELECT company_id, description
    FROM job_listings
    GROUP BY company_id, description
    HAVING COUNT(*) > 1
) AS dup;


-- ------------------------------------------------------------
-- 9. Robinhood — Cities With Completed Trades
-- Tables: trades (trade_id, user_id, status, quantity, ...), users (user_id, city, ...)
-- Goal: Cities with 5+ completed trades, ordered by number of trades desc, then city asc
-- ------------------------------------------------------------
SELECT u.city,
       COUNT(t.trade_id) AS total_orders
FROM trades t
JOIN users u
    ON t.user_id = u.user_id
WHERE t.status = 'Completed'
GROUP BY u.city
HAVING COUNT(t.trade_id) >= 5
ORDER BY total_orders DESC, u.city ASC;


-- ------------------------------------------------------------
-- 10. Amazon — Average Review Ratings
-- Table: amazon_reviews (review_id, user_id, product_id, stars, submit_date)
-- Goal: Average star rating per product, per month
-- ------------------------------------------------------------
SELECT product_id,
       EXTRACT(MONTH FROM submit_date) AS mth,
       ROUND(AVG(stars), 2) AS avg_stars
FROM amazon_reviews
GROUP BY product_id, EXTRACT(MONTH FROM submit_date)
ORDER BY product_id, mth;


-- ============================================================
-- Practice Log
-- ============================================================
-- | Date       | Source     | Question                          | Difficulty | Status |
-- |------------|------------|-----------------------------------|------------|--------|
-- | 2026-08-11 | DataLemur  | Histogram of Tweets                | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Data Science Skills                | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Page With No Likes                 | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Unfinished Parts                   | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Laptop vs. Mobile Viewership        | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Average Post Hiatus (Part 1)        | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Teams Power Users                  | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Duplicate Job Listings              | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Cities With Completed Trades        | Easy       | Done   |
-- | 2026-08-11 | DataLemur  | Average Review Ratings              | Easy       | Done   |
