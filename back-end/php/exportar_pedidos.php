<?php

require 'conexao.php';

header('Content-Type: text/csv; charset=utf-8');

header(
    'Content-Disposition: attachment; filename=pedidos.csv'
);

$output = fopen('php://output', 'w');

fputcsv($output, [
    'ID',
    'Cliente',
    'Endereco',
    'Cidade',
    'CEP',
    'Pagamento',
    'Pedido',
    'Total',
    'Status',
    'Data'
], ';');

$sql = "
    SELECT
        id,
        nome,
        endereco,
        cidade,
        cep,
        forma_pagamento,
        pedido,
        total,
        status,
        data_pedido
    FROM pedido
    ORDER BY data_pedido DESC
";

$result = $conn->query($sql);

while ($row = $result->fetch_assoc()) {

    fputcsv($output, [
        $row['id'],
        $row['nome'],
        $row['endereco'],
        $row['cidade'],
        $row['cep'],
        $row['forma_pagamento'],
        $row['pedido'],
        $row['total'],
        $row['status'],
        $row['data_pedido']
    ], ';');

}

fclose($output);

exit;