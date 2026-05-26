<?php
session_start();

require '../../back-end/php/conexao.php';

if (!isset($_SESSION['user_id'])) {
    header("Location: login.html");
    exit;
}

$nome = $_SESSION['user_nome'];
$email = $_SESSION['user_email'];

$sqlPedidos = $conn->prepare("
    SELECT *
    FROM pedido
    WHERE nome = ?
    ORDER BY id DESC
");

$sqlPedidos->bind_param("s", $nome);
$sqlPedidos->execute();

$resultPedidos = $sqlPedidos->get_result();
?>

<!DOCTYPE html>
<html lang="pt-BR">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Status do Pedido</title>
        <link rel="stylesheet" href="../css/perfil.css" />
        <link rel="stylesheet" href="../css/style.css" />
        <link rel="shortcut icon" href="../img/logo.png" type="image/x-icon" />
        <link
            href="https://fonts.googleapis.com/css2?family=Fjalla+One&display=swap"
            rel="stylesheet"
        />
        <link
            href="https://fonts.googleapis.com/css2?family=Viga&display=swap"
            rel="stylesheet"
        />
    </head>

    <body>
        <header>
            <nav>
                <div class="container">
                    <a href="#" class="logo">
                        <img src="../img/logo.png" alt="Logo" />
                    </a>
                    <div class="menu-toggle" id="mobile-menu">
                        <span class="bar1"></span>
                        <span class="bar2"></span>
                        <span class="bar3"></span>
                    </div>
                    <div class="nav-links">
                        <a href="index.html" class="button">Home</a>
                        <a href="cardapio.html" class="button">Cardápio</a>
                        <a href="carrinho.html" class="button">Carrinho</a>
                        <a href="sobre.html" class="button">Sobre Nós</a>
                        <a href="perfil.php" class="button">Perfil</a>
                    </div>
                </div>
            </nav>
        </header>
        <div class="perfil-container">
            <aside class="menu-lateral">
                <button onclick="mostrarSecao('dados')">MEUS DADOS</button>
                <button onclick="mostrarSecao('pedidos')">MEUS PEDIDOS</button>
                <button onclick="sair()">SAIR</button>
            </aside>

            <main class="conteudo">
                <section id="dados" class="secao ativa">
                    <h2>Seus Dados</h2>
                    <p><strong>Nome: </strong><span id="nome"><?php echo htmlspecialchars($nome); ?></span></p>
                    <p><strong>Email: </strong><span id="email"><?php echo htmlspecialchars($email); ?></span></p>
                </section>

                <section id="pedidos" class="secao">

                    <h2>Histórico de Pedidos</h2>

                    <?php if ($resultPedidos->num_rows > 0): ?>

                        <?php while ($pedido = $resultPedidos->fetch_assoc()): ?>

                            <div class="pedido">

                                <p>
                                    <strong><?= htmlspecialchars($pedido['pedido']) ?></strong>
                                    <br>

                                    #<?= $pedido['id'] ?>
                                    <br>

                                    <?= htmlspecialchars($pedido['nome']) ?>
                                    <br>

                                    <?= htmlspecialchars($pedido['endereco']) ?>
                                    ,
                                    <?= htmlspecialchars($pedido['cidade']) ?>

                                    <br>

                                    CEP:
                                    <?= htmlspecialchars($pedido['cep']) ?>

                                    <br>

                                    Forma de pagamento:
                                    <?= htmlspecialchars($pedido['forma_pagamento']) ?>

                                    <br>

                                    Valor:
                                    R$ <?= number_format($pedido['total'], 2, ',', '.') ?>

                                    <br>

                                    Status:
                                    <strong class="status <?= strtolower(str_replace(' ', '-', $pedido['status'])) ?>">
                                        <?= htmlspecialchars($pedido['status']) ?>
                                    </strong>

                                    <br>

                                    Data:
                                    <?= date('d/m/Y H:i', strtotime($pedido['data_pedido'])) ?>
                                </p>

                                <?php if ($pedido['status'] !== 'Enviado' && $pedido['status'] !== 'Cancelado'): ?>

                                    <button
                                        class="cancelar"
                                        onclick="cancelarPedido(<?= $pedido['id'] ?>)"
                                    >
                                        CANCELAR PEDIDO
                                    </button>

                                <?php endif; ?>

                            </div>

                        <?php endwhile; ?>

                    <?php else: ?>

                        <p>Você ainda não realizou pedidos.</p>

                    <?php endif; ?>

                </section>
            </main>
        </div>

        <footer>
            <script src="../../back-end/js/mobile-menu.js"></script>
            <script src="../../back-end/js/sessao.js"></script>
        </footer>
    </body>
</html>
