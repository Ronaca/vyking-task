# Vyking Tournament Prize Distribution

This project implements a system for distributing tournament prizes to players based on their rankings. 
It tracks the players, their bets on tournaments, and calculates how prize money is allocated based on amount of bets placed by each player.

## Requirements

- **Minimum PHP version**: 5.3.0 (Recommended PHP 7.4+) with PDO extension enabled.
- **Minimum MySQL version**: 8.0
- **A web server** (e.g., Apache or Nginx) with PHP support.

## Setup Instructions

### 1. **Install Dependencies**
Ensure you have PHP installed, along with the **PDO extension** for MySQL (it should be enabled by default in most PHP installations).

### 2. **Database Setup**
Create a MySQL database and import the schema from the `db.sql` file.

```sh
mysql -u USERNAME -p < db.sql
```
The schema includes the following tables:
- **players**: Stores player information
- **tournaments**: Stores tournament information
- **player_bets**: Stores player bets on tournaments

The schema also includes a stored procedure `distribute_prizes()` that calculates the prize distribution based on player rankings and updates player balances accordingly.

Dummy data can be inserted into the tables using the `dummy.sql` file.

```sh
mysql -u USERNAME -p < dummy.sql
```

### 3. **Tournament Prize Distribution API (PHP)**

This section explains how to use the distribute_prizes.php and get_rankings.php scripts, which handle prize distribution and player rankings in a tournament.

### 3.1. **Scripts**

### 3.1.1 **distribute_prizes.php**
Calls the MySQL stored procedure distribute_prizes()
Distributes the prize pool among the top-ranked players
Updates player balances accordingly

### 3.1.2 **get_rankings.php**
Retrieves the ranking of players based on their account balance

### 3.2. **How to Use**

### 3.2.1 **distribute_prizes.php**  

```bash
  POST /distribute_prizes.php
```
Request Parameters:
- tournament_id: The ID of the tournament to distribute prizes for

Example Request:
```sh
curl -X POST -d "tournament_id=1" http://localhost/distribute_prizes.php
```

### 3.2.2 **get_rankings.php**  

```bash
  GET /get_rankings.php
```

Example Request:
```sh
curl http://localhost/get_rankings.php
```