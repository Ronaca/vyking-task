
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

