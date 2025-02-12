<?php
require_once __DIR__ . '/config/db.php';

try {
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    $query = "
        SELECT id, name, balance, 
               RANK() OVER (ORDER BY balance DESC) AS ranking
        FROM players
    ";

    $stmt = $pdo->query($query);
    $rankings = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($rankings);

} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>