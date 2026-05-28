<?php

session_start();
$user_id = $_SESSION['user_id'];

require 'conexao.php';

$nome = $_POST['nome'] ?? '';
$endereco = $_POST['endereco'] ?? '';
$cidade = $_POST['cidade'] ?? '';
$cep = $_POST['cep'] ?? '';
$formaPagamento = $_POST['formaPagamento'] ?? '';
$pedido = $_POST['pedido'] ?? '';
$total = $_POST['total'] ?? '';

if (
    empty($nome) ||
    empty($endereco) ||
    empty($cidade) ||
    empty($cep) ||
    empty($formaPagamento) ||
    empty($pedido) ||
    empty($total)
) {
    echo "Campos incompletos.";
    exit;
}

$sql = $conn->prepare("
    INSERT INTO pedido
    (
        user_id,
        nome,
        endereco,
        cidade,
        cep,
        forma_pagamento,
        pedido,
        total,
        status
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
");

$status = "Em preparo";

$sql->bind_param(
    "issssssds",
    $user_id,
    $nome,
    $endereco,
    $cidade,
    $cep,
    $formaPagamento,
    $pedido,
    $total,
    $status
);

if ($sql->execute()) {

    echo "OK";

} else {

    echo "Erro ao salvar pedido: " . $conn->error;

}

$sql->close();
$conn->close();