<?php
$dsn = 'mysql:host=localhost;dbname=vyking';
$user = 'root';
$password = '';

try {
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['tournament_id'])) {
        $tournamentId = (int) $_POST['tournament_id'];

        // Call the stored procedure
        $stmt = $pdo->prepare("CALL distribute_prizes(:tournamentId)");
        $stmt->bindParam(':tournamentId', $tournamentId, PDO::PARAM_INT);
        $stmt->execute();

        echo json_encode(['message' => 'Prizes distributed successfully']);
    } else {
        echo json_encode(['error' => 'Invalid request']);
    }
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
