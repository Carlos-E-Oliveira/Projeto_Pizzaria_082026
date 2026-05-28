<?php

session_start();

require 'conexao.php';

if (!isset($_SESSION['user_id'])) {
    exit("Não autorizado.");
}

if (!isset($_POST['id'])) {
    exit("Pedido inválido.");
}

$id = intval($_POST['id']);
$user_id = $_SESSION['user_id'];

$sql = $conn->prepare("
    UPDATE pedido
    SET status = 'Cancelado'
    WHERE id = ?
    AND user_id = ?
    AND status != 'Enviado'
");

$sql->bind_param("ii", $id, $user_id);

if ($sql->execute()) {

    echo "OK";

} else {

    echo "Erro ao cancelar pedido.";

}