<?php
require 'conexao.php';

$nome  = $_POST['nome'] ?? '';
$email = $_POST['email'] ?? '';
$senha = $_POST['senha'] ?? '';

if (!$nome || !$email || !$senha) {
    echo "Campos incompletos.";
    exit;
}

$senhaHash = password_hash($senha, PASSWORD_DEFAULT);

$sql = $conn->prepare("INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)");
$sql->bind_param("sss", $nome, $email, $senhaHash);


if ($sql->execute()) {
    echo "OK";
} else {
    echo "Erro: " . $conn->error;
}
