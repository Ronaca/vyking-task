
-- Create database
CREATE DATABASE IF NOT EXISTS vyking;

-- Switch to the vyking database
USE vyking;

-- Create player table
CREATE TABLE players (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    balance DECIMAL(10,2) DEFAULT 0
);

-- Create player_bets table (stores bets placed by players in a tournament)
CREATE TABLE tournaments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    prize_pool DECIMAL(10,2) NOT NULL,
    start_date DATETIME,
    end_date DATETIME
);

-- Create player_bets table (stores bets placed by players in a tournament)
CREATE TABLE player_bets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    tournament_id INT,
    amount DECIMAL(10,2) NOT NULL,
    date DATETIME,
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (tournament_id) REFERENCES tournaments(id)
);


-- Index for player_bets.tournament_id to speed up JOINs with tournaments table
CREATE INDEX idx_tournament_id ON player_bets(tournament_id);


-- Add some dummy data

-- Insert tournaments
INSERT INTO tournaments (name, prize_pool, start_date, end_date) VALUES
    ('Winter Showdown', 5000.00, '2024-01-01 10:00:00', '2024-01-10 22:00:00'),
    ('Spring Championship', 7500.00, '2024-04-01 10:00:00', '2024-04-10 22:00:00'),
    ('Summer Tournament', 7500.00, '2024-07-01 10:00:00', '2024-07-10 22:00:00');

-- Insert players
INSERT INTO players (name, email, balance) VALUES
    ('Alice Johnson', 'alice@example.com', 100.00),
    ('Bob Smith', 'bob@example.com', 200.00),
    ('Charlie Brown', 'charlie@example.com', 150.00),
    ('David Wilson', 'david@example.com', 300.00),
    ('Emma Davis', 'emma@example.com', 120.00),
    ('Frank Thomas', 'frank@example.com', 250.00),
    ('Grace Hall', 'grace@example.com', 180.00),
    ('Henry Allen', 'henry@example.com', 90.00),
    ('Isla White', 'isla@example.com', 170.00),
    ('Jack Harris', 'jack@example.com', 220.00),
    ('Katie Moore', 'katie@example.com', 140.00),
    ('Leo Young', 'leo@example.com', 275.00),
    ('Mia Scott', 'mia@example.com', 160.00),
    ('Noah Green', 'noah@example.com', 210.00),
    ('Olivia Adams', 'olivia@example.com', 195.00),
    ('Paul Baker', 'paul@example.com', 230.00),
    ('Quinn Nelson', 'quinn@example.com', 130.00),
    ('Ryan Carter', 'ryan@example.com', 190.00),
    ('Sophia Perez', 'sophia@example.com', 165.00),
    ('Tommy Reed', 'tommy@example.com', 280.00);

-- Insert player bets
INSERT INTO player_bets (player_id, tournament_id, amount, date) VALUES
    (1, 1, 50.00, '2024-01-01 10:00:00'),
    (1, 2, 60.00, '2024-02-02 10:00:00'),
    (1, 3, 75.00, '2024-03-02 11:00:00'),

    (2, 1, 200.00, '2024-01-02 12:30:00'),
    (2, 3, 80.00, '2024-03-03 12:30:00'),

    (3, 2, 150.00, '2024-02-03 13:45:00'),
    (3, 3, 150.00, '2024-03-04 13:45:00'),

    (4, 1, 250.00, '2024-01-03 11:15:00'),
    (4, 2, 180.00, '2024-02-04 15:00:00'),

    (5, 3, 300.00, '2024-03-05 14:10:00'),

    (6, 1, 95.00, '2024-01-06 15:25:00'),
    (6, 2, 115.00, '2024-02-06 16:00:00'),

    (7, 2, 110.00, '2024-02-07 16:40:00'),
    (7, 3, 220.00, '2024-03-07 17:20:00'),

    (8, 1, 130.00, '2024-01-08 17:55:00'),
    (8, 3, 140.00, '2024-03-08 18:10:00'),

    (9, 3, 275.00, '2024-03-09 18:30:00'),

    (10, 2, 190.00, '2024-02-10 19:45:00'),
    (10, 3, 210.00, '2024-03-10 20:00:00'),

    (11, 1, 140.00, '2024-01-11 20:10:00'),
    (11, 2, 155.00, '2024-02-11 21:00:00'),

    (12, 3, 210.00, '2024-03-12 21:25:00'),

    (13, 2, 125.00, '2024-02-13 22:40:00'),
    (13, 3, 160.00, '2024-03-13 23:30:00'),

    (14, 1, 175.00, '2024-01-14 23:55:00'),
    (14, 3, 185.00, '2024-03-14 09:00:00'),

    (15, 2, 260.00, '2024-02-15 09:20:00'),
    (15, 3, 290.00, '2024-03-15 10:10:00'),

    (16, 3, 300.00, '2024-03-16 10:35:00'),

    (17, 1, 225.00, '2024-01-17 11:50:00'),
    (17, 2, 235.00, '2024-02-17 12:40:00'),

    (18, 3, 280.00, '2024-03-18 12:05:00'),
    (18, 1, 195.00, '2024-01-18 13:10:00'),

    (19, 2, 190.00, '2024-02-19 13:20:00'),
    (19, 3, 170.00, '2024-03-19 14:00:00'),

    (20, 1, 240.00, '2024-01-20 14:35:00'),
    (20, 2, 250.00, '2024-02-20 15:30:00'),
    (20, 3, 260.00, '2024-03-20 16:20:00');


-- Create stored procedure to distribute prizes based on tournament ID
DELIMITER $$

CREATE PROCEDURE distribute_prizes(IN tour_id INT)
BEGIN
-- Declare variables
DECLARE total_prize DECIMAL(10,2);
DECLARE prize1 DECIMAL(10,2);
DECLARE prize2 DECIMAL(10,2);
DECLARE prize3 DECIMAL(10,2);

DECLARE total_prize_first_rank DECIMAL(10,2) DEFAULT 0;
DECLARE total_players_first_rank INT DEFAULT 0;
DECLARE total_prize_second_rank DECIMAL(10,2) DEFAULT 0;
DECLARE total_players_second_rank INT DEFAULT 0;
DECLARE total_prize_third_rank DECIMAL(10,2) DEFAULT 0;
DECLARE total_players_third_rank INT DEFAULT 0;

-- Get the total prize pool for the tournament
SELECT prize_pool INTO total_prize FROM tournaments WHERE id = tour_id;

-- Assign prize amounts
SET prize1 = total_prize * 0.50;
SET prize2 = total_prize * 0.30;
SET prize3 = total_prize * 0.20;

-- Create temporary table to store rankings and row numbers
CREATE TEMPORARY TABLE temp_ranking (
    player_id INT PRIMARY KEY,
    ranking INT,
    row_number INT -- Added row_number column
);

-- Insert ranking data
INSERT INTO temp_ranking (player_id, ranking, row_number)
SELECT player_id, ranking,
       ROW_NUMBER() OVER (ORDER BY ranking ASC) AS row_number
FROM (
         SELECT player_id,
                RANK() OVER (ORDER BY SUM(amount) DESC) AS ranking
         FROM player_bets
         WHERE tournament_id = tour_id
         GROUP BY player_id
     ) ranked_players
WHERE ranking <= 3
ORDER BY ranking ASC;

-- Count the players per rank
SELECT
    SUM(CASE WHEN ranking = 1 THEN 1 ELSE 0 END) AS total_players_first_rank,
    SUM(CASE WHEN ranking = 2 THEN 1 ELSE 0 END) AS total_players_second_rank,
    SUM(CASE WHEN ranking = 3 THEN 1 ELSE 0 END) AS total_players_third_rank
INTO total_players_first_rank, total_players_second_rank, total_players_third_rank
FROM temp_ranking;

-- Calculate total prize per rank
SELECT
    SUM(CASE
            WHEN ranking = 1 AND row_number = 1 THEN prize1
            WHEN ranking = 1 AND row_number = 2 THEN prize2
            WHEN ranking = 1 AND row_number = 3 THEN prize3
            ELSE 0
        END),

    SUM(CASE
            WHEN ranking = 2 AND row_number = 2 THEN prize2
            WHEN ranking = 2 AND row_number = 3 THEN prize3
            ELSE 0
        END),

    SUM(CASE
            WHEN ranking = 3 AND row_number = 3 THEN prize3
            ELSE 0
        END)
INTO total_prize_first_rank, total_prize_second_rank, total_prize_third_rank
FROM temp_ranking;

-- Update balances
UPDATE players
    JOIN temp_ranking ON players.id = temp_ranking.player_id
    SET players.balance = players.balance +
        CASE
        WHEN temp_ranking.ranking = 1 THEN IF(total_players_first_rank > 0, total_prize_first_rank / total_players_first_rank, 0)
        WHEN temp_ranking.ranking = 2 THEN IF(total_players_second_rank > 0, total_prize_second_rank / total_players_second_rank, 0)
        WHEN temp_ranking.ranking = 3 THEN IF(total_players_third_rank > 0, total_prize_third_rank / total_players_third_rank, 0)
        ELSE 0
END
WHERE temp_ranking.player_id IS NOT NULL;

-- Cleanup
DROP TEMPORARY TABLE temp_ranking;

END$$

DELIMITER ;

