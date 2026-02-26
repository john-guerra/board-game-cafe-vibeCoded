-- ============================================================
-- Query 2: Subquery
-- Description: Find members who have played at least one game
--   whose complexity rating is above the overall average 
--   complexity of all games in the library. Uses a subquery
--   in the WHERE clause.
-- ============================================================

SELECT DISTINCT
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    m.join_date
FROM Member m
    INNER JOIN SessionPlayer sp ON m.member_id = sp.member_id
    INNER JOIN PlaySession ps   ON sp.session_id = ps.session_id
    INNER JOIN Game g           ON ps.game_id = g.game_id
WHERE g.complexity_rating > (
    SELECT AVG(complexity_rating) 
    FROM Game 
    WHERE complexity_rating IS NOT NULL
)
ORDER BY m.last_name, m.first_name;

-- The subquery computes the average complexity across all games.
-- Expected: Members who have played games like Gloomhaven (3.9),
-- Scythe (3.4), Terraforming Mars (3.2), Arkham Horror (3.5), etc.
