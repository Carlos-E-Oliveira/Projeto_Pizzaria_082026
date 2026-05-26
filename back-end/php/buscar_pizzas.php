<?php
$host = "localhost";
$user = "root";
$password = "";
$dbname   = "pizzaria";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Buscar todas as pizzas
    $stmt = $pdo->query("SELECT * FROM pizzas");
    $pizzas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($pizzas);
} catch (PDOException $e) {
    echo json_encode(["sucesso" => false, "erro" => $e->getMessage()]);
}
?>
