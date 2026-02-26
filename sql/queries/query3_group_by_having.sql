-- ============================================================
-- Query 3: GROUP BY with HAVING clause
-- Description: Find game categories where the average player 
--   rating is at least 8.0 and there have been at least 3 
--   ratings recorded. Shows which categories are most loved.
-- ============================================================

SELECT 
    c.name                        AS category_name,
    COUNT(DISTINCT g.game_id)     AS games_in_category,
    COUNT(sp.rating)              AS total_ratings,
    ROUND(AVG(sp.rating), 2)     AS avg_rating,
    MIN(sp.rating)                AS min_rating,
    MAX(sp.rating)                AS max_rating
FROM Category c
    INNER JOIN GameCategory gc ON c.category_id = gc.category_id
    INNER JOIN Game g          ON gc.game_id = g.game_id
    INNER JOIN PlaySession ps  ON g.game_id = ps.game_id
    INNER JOIN SessionPlayer sp ON ps.session_id = sp.session_id
WHERE sp.rating IS NOT NULL
GROUP BY c.category_id, c.name
HAVING AVG(sp.rating) >= 8.0 AND COUNT(sp.rating) >= 3
ORDER BY avg_rating DESC;

-- Expected: Categories like Cooperative and Adventure tend to 
-- score well because Gloomhaven and Arkham Horror are highly rated.
