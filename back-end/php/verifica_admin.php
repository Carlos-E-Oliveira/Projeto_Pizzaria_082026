<?php

session_start();

if (
    !isset($_SESSION['user_id']) ||
    $_SESSION['tipo'] === 'cliente'
) {

    header("Location: ../../front-end/html/index.html");

    exit;
}