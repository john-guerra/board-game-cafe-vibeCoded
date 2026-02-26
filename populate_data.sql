-- ============================================================
-- Board Game Cafe Database
-- Test Data Population Script
-- ============================================================
-- Run with: sqlite3 boardgame_cafe.db < populate_data.sql
-- ============================================================

PRAGMA foreign_keys = ON;

-- ============================================================
-- Publishers (8 records)
-- ============================================================
INSERT INTO Publisher (name, country, website, founded_year) VALUES
    ('Stonemaier Games',    'USA',        'https://stonemaiergames.com',     2012),
    ('Cephalofair Games',   'USA',        'https://cephalofair.com',         2015),
    ('Czech Games Edition', 'Czech Republic', 'https://czechgames.com',      2007),
    ('Repos Production',    'Belgium',    'https://rprod.com',               2004),
    ('Days of Wonder',      'USA',        'https://daysofwonder.com',        2002),
    ('Z-Man Games',         'Canada',     'https://zmangames.com',           1999),
    ('Ravensburger',        'Germany',    'https://ravensburger.com',        1883),
    ('Fantasy Flight Games','USA',        'https://fantasyflightgames.com',  1995);

-- ============================================================
-- Categories (8 records)
-- ============================================================
INSERT INTO Category (name, description) VALUES
    ('Strategy',      'Games emphasizing strategic planning and decision-making'),
    ('Cooperative',   'Players work together against the game'),
    ('Party',         'Light games for large groups and social gatherings'),
    ('Deck-Building', 'Players construct decks of cards during gameplay'),
    ('Worker Placement', 'Players assign limited workers to actions on the board'),
    ('Adventure',     'Games featuring exploration, quests, and narrative'),
    ('Family',        'Accessible games suitable for all ages'),
    ('Engine-Building', 'Players build systems that generate increasing returns');

-- ============================================================
-- Games (15 records)
-- ============================================================
INSERT INTO Game (title, min_players, max_players, play_time_minutes, complexity_rating, year_published, copies_owned, is_available, publisher_id) VALUES
    ('Wingspan',               1, 5, 70,  2.5, 2019, 3, 1, 1),
    ('Scythe',                 1, 5, 115, 3.4, 2016, 2, 1, 1),
    ('Gloomhaven',             1, 4, 120, 3.9, 2017, 1, 1, 2),
    ('Codenames',              2, 8, 15,  1.3, 2015, 4, 1, 3),
    ('7 Wonders',              2, 7, 30,  2.3, 2010, 2, 1, 4),
    ('Ticket to Ride',         2, 5, 45,  1.8, 2004, 3, 1, 5),
    ('Pandemic',               2, 4, 45,  2.4, 2008, 2, 1, 6),
    ('Catan',                  3, 4, 90,  2.3, 1995, 3, 1, 7),
    ('Viticulture',            1, 6, 90,  2.9, 2013, 2, 1, 1),
    ('Terraforming Mars',      1, 5, 120, 3.2, 2016, 2, 0, 8),
    ('Azul',                   2, 4, 30,  1.8, 2017, 3, 1, 5),
    ('Everdell',               1, 4, 80,  2.8, 2018, 2, 1, 1),
    ('Dixit',                  3, 8, 30,  1.2, 2008, 2, 1, 4),
    ('Arkham Horror LCG',      1, 2, 120, 3.5, 2016, 1, 1, 8),
    ('Splendor',               2, 4, 30,  1.8, 2014, 3, 1, 5);

-- ============================================================
-- GameCategory (25+ mappings)
-- ============================================================
INSERT INTO GameCategory (game_id, category_id) VALUES
    (1,  1), (1,  8), (1,  7),          -- Wingspan: Strategy, Engine-Building, Family
    (2,  1), (2,  5), (2,  8),          -- Scythe: Strategy, Worker Placement, Engine-Building
    (3,  1), (3,  2), (3,  6),          -- Gloomhaven: Strategy, Cooperative, Adventure
    (4,  3), (4,  7),                   -- Codenames: Party, Family
    (5,  1), (5,  4),                   -- 7 Wonders: Strategy, Deck-Building
    (6,  7), (6,  1),                   -- Ticket to Ride: Family, Strategy
    (7,  2), (7,  1),                   -- Pandemic: Cooperative, Strategy
    (8,  1), (8,  7),                   -- Catan: Strategy, Family
    (9,  5), (9,  1),                   -- Viticulture: Worker Placement, Strategy
    (10, 1), (10, 8),                   -- Terraforming Mars: Strategy, Engine-Building
    (11, 1), (11, 7),                   -- Azul: Strategy, Family
    (12, 5), (12, 8),                   -- Everdell: Worker Placement, Engine-Building
    (13, 3), (13, 7),                   -- Dixit: Party, Family
    (14, 2), (14, 6), (14, 4),         -- Arkham Horror: Cooperative, Adventure, Deck-Building
    (15, 1), (15, 7), (15, 8);         -- Splendor: Strategy, Family, Engine-Building

-- ============================================================
-- Members (12 records)
-- ============================================================
INSERT INTO Member (first_name, last_name, email, phone, join_date) VALUES
    ('Alice',   'Chen',      'alice.chen@email.com',      '555-0101', '2024-01-15'),
    ('Bob',     'Martinez',  'bob.martinez@email.com',    '555-0102', '2024-02-20'),
    ('Carol',   'Johnson',   'carol.j@email.com',         '555-0103', '2024-01-08'),
    ('David',   'Kim',       'david.kim@email.com',       '555-0104', '2024-03-12'),
    ('Eva',     'Petrov',    'eva.petrov@email.com',      '555-0105', '2024-04-01'),
    ('Frank',   'O''Brien',  'frank.obrien@email.com',    '555-0106', '2024-02-14'),
    ('Grace',   'Tanaka',    'grace.tanaka@email.com',    '555-0107', '2024-05-22'),
    ('Henry',   'Williams',  'henry.w@email.com',         '555-0108', '2024-01-30'),
    ('Iris',    'Novak',     'iris.novak@email.com',      '555-0109', '2024-06-15'),
    ('Jake',    'Patel',     'jake.patel@email.com',      '555-0110', '2024-03-05'),
    ('Karen',   'Schmidt',   'karen.schmidt@email.com',   '555-0111', '2024-07-01'),
    ('Leo',     'Reeves',    'leo.reeves@email.com',      '555-0112', '2024-08-19');

-- ============================================================
-- PlaySessions (20 records)
-- ============================================================
INSERT INTO PlaySession (game_id, session_date, duration_minutes, table_number) VALUES
    (1,  '2024-09-01 14:00:00', 75,  1),
    (7,  '2024-09-01 15:00:00', 50,  2),
    (4,  '2024-09-02 18:00:00', 20,  3),
    (8,  '2024-09-03 13:00:00', 95,  1),
    (6,  '2024-09-05 16:00:00', 40,  2),
    (3,  '2024-09-06 10:00:00', 150, 1),
    (1,  '2024-09-07 14:00:00', 65,  3),
    (2,  '2024-09-08 11:00:00', 120, 1),
    (11, '2024-09-08 15:00:00', 35,  2),
    (4,  '2024-09-10 19:00:00', 25,  3),
    (12, '2024-09-12 14:00:00', 85,  1),
    (5,  '2024-09-13 17:00:00', 35,  2),
    (9,  '2024-09-14 12:00:00', 100, 1),
    (7,  '2024-09-15 14:00:00', 45,  2),
    (13, '2024-09-16 19:00:00', 30,  3),
    (1,  '2024-09-18 14:00:00', 70,  1),
    (15, '2024-09-19 16:00:00', 30,  2),
    (14, '2024-09-20 10:00:00', 130, 1),
    (6,  '2024-09-21 15:00:00', 50,  3),
    (8,  '2024-09-22 13:00:00', 85,  2);

-- ============================================================
-- SessionPlayer (48 records with ratings and comments)
-- ============================================================
INSERT INTO SessionPlayer (session_id, member_id, rating, comment) VALUES
    -- Session 1: Wingspan (Alice, Bob, Carol)
    (1,  1, 9,  'Beautiful game, love the bird engine'),
    (1,  2, 8,  'Great artwork'),
    (1,  3, 7,  'Bit long but enjoyable'),
    -- Session 2: Pandemic (David, Eva)
    (2,  4, 8,  'Exciting cooperative play'),
    (2,  5, 9,  'We saved the world!'),
    -- Session 3: Codenames (Alice, Bob, Frank, Grace, Henry)
    (3,  1, 7,  'Fun party game'),
    (3,  2, 8,  NULL),
    (3,  6, 9,  'Hilarious clues'),
    (3,  7, 8,  'Great for groups'),
    (3,  8, 7,  NULL),
    -- Session 4: Catan (Carol, David, Frank)
    (4,  3, 6,  'Too much luck with the dice'),
    (4,  4, 8,  'Classic for a reason'),
    (4,  6, 7,  NULL),
    -- Session 5: Ticket to Ride (Alice, Eva)
    (5,  1, 9,  'Relaxing and strategic'),
    (5,  5, 8,  'Love the route planning'),
    -- Session 6: Gloomhaven (Bob, Carol, David, Henry)
    (6,  2, 10, 'Best gaming experience ever'),
    (6,  3, 9,  'Incredibly immersive'),
    (6,  4, 8,  'Complex but rewarding'),
    (6,  8, 9,  'Want to play again ASAP'),
    -- Session 7: Wingspan (Grace, Iris)
    (7,  7, 8,  'Loved the engine building'),
    (7,  9, 7,  'First time, will play again'),
    -- Session 8: Scythe (Alice, Frank, Jake)
    (8,  1, 8,  'Amazing strategy depth'),
    (8,  6, 7,  'A bit overwhelming at first'),
    (8, 10, 9,  'Fantastic mechanisms'),
    -- Session 9: Azul (Eva, Karen)
    (9,  5, 9,  'Beautiful tiles'),
    (9, 11, 8,  'Simple yet deep'),
    -- Session 10: Codenames (Bob, Grace, Leo, Henry)
    (10, 2, 8,  'Even better second time'),
    (10, 7, 7,  NULL),
    (10,12, 9,  'My new favorite party game'),
    (10, 8, 8,  'Always a hit'),
    -- Session 11: Everdell (Carol, David)
    (11, 3, 9,  'Adorable and strategic'),
    (11, 4, 8,  'Great worker placement'),
    -- Session 12: 7 Wonders (Alice, Bob, Frank, Eva)
    (12, 1, 7,  'Quick and fun'),
    (12, 2, 8,  'Good for larger groups'),
    (12, 6, 7,  NULL),
    (12, 5, 8,  'Nice drafting mechanic'),
    -- Session 13: Viticulture (Grace, Jake, Karen)
    (13, 7, 9,  'Love the wine theme'),
    (13,10, 8,  'Excellent worker placement'),
    (13,11, 9,  'Top 3 for me'),
    -- Session 14: Pandemic (Alice, Iris)
    (14, 1, 8,  'Close call, barely won'),
    (14, 9, 7,  'Stressful but fun'),
    -- Session 15: Dixit (Bob, Carol, David, Eva, Frank, Grace)
    (15, 2, 7,  'Creative and silly'),
    (15, 3, 8,  'Great imagination game'),
    (15, 4, 6,  'Not really my style'),
    (15, 5, 8,  NULL),
    (15, 6, 7,  NULL),
    (15, 7, 9,  'Beautiful illustrations'),
    -- Session 16: Wingspan (Henry, Leo)
    (16, 8, 9,  'Addicted to this game'),
    (16,12, 8,  'Really enjoyable'),
    -- Session 17: Splendor (Alice, Jake)
    (17, 1, 8,  'Quick gem-collecting fun'),
    (17,10, 7,  'Good filler game'),
    -- Session 18: Arkham Horror LCG (Bob, Carol)
    (18, 2, 9,  'Incredible narrative'),
    (18, 3, 10, 'Best card game I have played'),
    -- Session 19: Ticket to Ride (Karen, Leo, Iris)
    (19,11, 8,  'Easy to learn'),
    (19,12, 7,  'Solid game night choice'),
    (19, 9, 8,  'Love blocking routes'),
    -- Session 20: Catan (Alice, David, Eva)
    (20, 1, 7,  'Always enjoy Catan'),
    (20, 4, 6,  'Dice were not kind to me'),
    (20, 5, 7,  NULL);
