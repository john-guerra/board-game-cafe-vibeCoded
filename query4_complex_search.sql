-- ============================================================
-- Query 4: Complex Search Criterion
-- Description: Find games suitable for a "date night" - games
--   that support exactly 2 players, take less than 60 minutes,
--   are currently available, have a complexity rating between
--   1.5 and 3.0 (not too simple, not too hard), AND belong to
--   either the Strategy or Cooperative category.
--   Uses AND, OR, BETWEEN, IN, and comparison operators.
-- ============================================================

SELECT DISTINCT
    g.title,
    g.min_players || '-' || g.max_players AS player_range,
    g.play_time_minutes,
    g.complexity_rating,
    g.copies_owned,
    GROUP_CONCAT(DISTINCT c.name) AS categories
FROM Game g
    INNER JOIN GameCategory gc ON g.game_id = gc.game_id
    INNER JOIN Category c      ON gc.category_id = c.category_id
WHERE g.min_players <= 2
  AND g.max_players >= 2
  AND g.play_time_minutes < 60
  AND g.is_available = 1
  AND g.complexity_rating BETWEEN 1.5 AND 3.0
  AND g.game_id IN (
      SELECT gc2.game_id 
      FROM GameCategory gc2 
          INNER JOIN Category c2 ON gc2.category_id = c2.category_id
      WHERE c2.name IN ('Strategy', 'Cooperative')
  )
GROUP BY g.game_id
ORDER BY g.complexity_rating ASC;

-- This query uses: AND (5 conditions), BETWEEN, IN (with subquery),
-- comparison operators (<, <=, >=, =), and GROUP_CONCAT for display.
