<?php
require 'conexao.php';
session_start();

$email = $_POST['email'] ?? '';
$senha = $_POST['senha'] ?? '';

$sql = $conn->prepare("SELECT id, senha, nome, email FROM usuarios WHERE email = ?");
$sql->bind_param("s", $email);
$sql->execute();

$result = $sql->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();

    if (password_verify($senha, $user['senha'])) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_nome'] = $user['nome'];
        $_SESSION['user_email'] = $user['email'];
        echo "OK";
    } else {
        echo "SENHA_INVALIDA";
    }
} else {
    echo "LOGIN_INEXISTENTE";
}
