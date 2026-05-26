<?php

session_start();

require 'conexao.php';

if (!isset($_POST['id'])) {
    exit("Pedido inválido.");
}

$id = intval($_POST['id']);

$sql = $conn->prepare("
    UPDATE pedido
    SET status = 'Cancelado'
    WHERE id = ?
    AND status != 'Enviado'
");

$sql->bind_param("i", $id);

if ($sql->execute()) {

    echo "OK";

} else {

    echo "Erro ao cancelar pedido.";

}