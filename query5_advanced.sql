-- ============================================================
-- Query 5: Advanced Query Mechanisms
-- Uses: RCTE (Recursive CTE for member engagement tiers),
--   PARTITION BY (rank games within each publisher),
--   and CASE/WHEN (classify games by complexity).
-- ============================================================

-- Part A: Window function with PARTITION BY
-- Rank each game by average rating within its publisher,
-- and classify complexity using CASE/WHEN.
-- ============================================================

SELECT 
    p.name AS publisher,
    g.title,
    ROUND(avg_data.avg_rating, 1) AS avg_rating,
    avg_data.play_count,
    RANK() OVER (
        PARTITION BY p.publisher_id 
        ORDER BY avg_data.avg_rating DESC
    ) AS rank_within_publisher,
    CASE
        WHEN g.complexity_rating <= 1.5 THEN 'Light'
        WHEN g.complexity_rating <= 2.5 THEN 'Medium-Light'
        WHEN g.complexity_rating <= 3.5 THEN 'Medium-Heavy'
        WHEN g.complexity_rating <= 5.0 THEN 'Heavy'
        ELSE 'Unrated'
    END AS weight_class
FROM Game g
    INNER JOIN Publisher p ON g.publisher_id = p.publisher_id
    LEFT JOIN (
        SELECT 
            ps.game_id,
            AVG(sp.rating) AS avg_rating,
            COUNT(DISTINCT ps.session_id) AS play_count
        FROM PlaySession ps
            INNER JOIN SessionPlayer sp ON ps.session_id = sp.session_id
        WHERE sp.rating IS NOT NULL
        GROUP BY ps.game_id
    ) avg_data ON g.game_id = avg_data.game_id
ORDER BY p.name, rank_within_publisher;

-- ============================================================
-- Part B: Recursive CTE
-- Generate engagement tiers for members based on session count,
-- using a recursive CTE to define tier thresholds.
-- ============================================================

WITH RECURSIVE TierThresholds(tier_name, min_sessions, max_sessions) AS (
    -- Base case: first tier
    VALUES ('Bronze', 0, 2)
    UNION ALL
    -- Recursive cases
    SELECT 
        CASE 
            WHEN tier_name = 'Bronze' THEN 'Silver'
            WHEN tier_name = 'Silver' THEN 'Gold'
            WHEN tier_name = 'Gold'   THEN 'Platinum'
        END,
        max_sessions + 1,
        CASE
            WHEN tier_name = 'Bronze' THEN 5
            WHEN tier_name = 'Silver' THEN 8
            WHEN tier_name = 'Gold'   THEN 999
        END
    FROM TierThresholds
    WHERE tier_name != 'Platinum'
),
MemberActivity AS (
    SELECT 
        m.member_id,
        m.first_name || ' ' || m.last_name AS member_name,
        COUNT(sp.session_id) AS session_count,
        ROUND(AVG(sp.rating), 1) AS avg_rating_given
    FROM Member m
        LEFT JOIN SessionPlayer sp ON m.member_id = sp.member_id
    GROUP BY m.member_id, member_name
)
SELECT 
    ma.member_name,
    ma.session_count,
    ma.avg_rating_given,
    tt.tier_name AS engagement_tier
FROM MemberActivity ma
    INNER JOIN TierThresholds tt 
        ON ma.session_count >= tt.min_sessions 
       AND ma.session_count <= tt.max_sessions
ORDER BY ma.session_count DESC, ma.member_name;

-- Expected: Members are classified into Bronze (0-2 sessions),
-- Silver (3-5), Gold (6-8), Platinum (9+) tiers.
