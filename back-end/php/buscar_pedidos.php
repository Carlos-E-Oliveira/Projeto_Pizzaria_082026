<?php
require_once 'conexao.php';

$query = "SELECT * FROM pedido ORDER BY data_pedido DESC";
$result = $conn->query($query);

$pedidos = [];
while ($row = $result->fetch_assoc()) {
    $pedidos[] = $row;
}

echo json_encode($pedidos);
?>