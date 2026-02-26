-- ============================================================
-- Query 1: Three-Table Join
-- Description: List all games with their publisher name, 
--   country of origin, and average player rating from sessions.
--   Joins Game -> Publisher and Game -> PlaySession -> SessionPlayer.
-- ============================================================

SELECT 
    g.title          AS game_title,
    p.name           AS publisher,
    p.country        AS publisher_country,
    g.complexity_rating,
    COUNT(DISTINCT ps.session_id) AS times_played,
    ROUND(AVG(sp.rating), 1)     AS avg_rating,
    COUNT(sp.rating)              AS num_ratings
FROM Game g
    INNER JOIN Publisher p     ON g.publisher_id = p.publisher_id
    LEFT  JOIN PlaySession ps  ON g.game_id = ps.game_id
    LEFT  JOIN SessionPlayer sp ON ps.session_id = sp.session_id
GROUP BY g.game_id, g.title, p.name, p.country, g.complexity_rating
ORDER BY avg_rating DESC NULLS LAST;

-- Expected output: 15 rows, one per game.
-- Games with no sessions (e.g., Terraforming Mars) will show 
-- NULL avg_rating and 0 for times_played.
