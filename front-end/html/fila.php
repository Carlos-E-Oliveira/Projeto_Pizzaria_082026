<?php require '../../back-end/php/verifica_admin.php'; ?>

<!doctype html>
<html lang="pt-br">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gerenciamento de Pedidos</title>
    <link rel="stylesheet" href="../css/admin.css" />
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
            <a href="gerenciamento.php" class="button">Produtos</a>
            <a href="fila.php" class="button">Fila</a>
          </div>
        </div>
      </nav>
    </header>

    <section class="resumo">
      <div>
        <strong>Pedidos do dia</strong>
        <p id="total-dia">0</p>
      </div>
      <div>
        <strong>Concluídos</strong>
        <p id="concluidos">0</p>
      </div>
      <div>
        <strong>Saiu para entrega</strong>
        <p id="entrega">0</p>
      </div>
      <div>
        <strong>Em preparo</strong>
        <p id="preparo">0</p>
      </div>
      <div>
        <strong>Cancelados</strong>
        <p id="cancelados">0</p>
      </div>
       <div class="acoes-topo">
        <button onclick="exportarCSV()" class="btn-exportar">
            EXPORTAR CSV
        </button>
    </div>
    </section>

    <section class="pedidos">
      <table>
        <thead>
          <tr>
            <th>Pedido</th>
            <th>Cliente</th>
            <th>Status</th>
            <th>Valor</th>
            <th>Hora</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody id="lista-pedidos"></tbody>
      </table>
    </section>

    <script src="../../back-end/js/fila.js"></script>
    <div id="notificacao">Status atualizado com sucesso!</div>
  </body>
</html>
