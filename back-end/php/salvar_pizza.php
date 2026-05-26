<?php
$host = "localhost";
$user = "root";
$password = "";
$dbname   = "pizzaria";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Receber dados do formulário
    $nome = $_POST['nome'];
    $descricao = $_POST['descricao'];
    $precoP = $_POST['precoP'];
    $precoM = $_POST['precoM'];
    $precoG = $_POST['precoG'];
    
    // Lidar com a imagem
    if ($_FILES['imagem']['error'] == UPLOAD_ERR_OK) {
        $extensao = pathinfo($_FILES['imagem']['name'], PATHINFO_EXTENSION);
        $nomeUnico = uniqid('pizza_' . date('Ymd_His_')) . '.' . $extensao;
        $imagemURL = 'uploads/' . $nomeUnico;
        $imagemFisica = dirname(__DIR__) . '/../front-end/uploads/' . $nomeUnico;
        move_uploaded_file($_FILES['imagem']['tmp_name'], $imagemFisica);
    } else {
        throw new Exception('Erro ao fazer upload da imagem');
    }

    // Inserir no banco de dados
    $stmt = $pdo->prepare("INSERT INTO pizzas (nome, descricao, precoP, precoM, precoG, imagem) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$nome, $descricao, $precoP, $precoM, $precoG, $imagemURL]);

    echo json_encode(['sucesso' => true]);

} catch (PDOException $e) {
    echo json_encode(['erro' => $e->getMessage()]);
} catch (Exception $e) {
    echo json_encode(['erro' => $e->getMessage()]);
}
?>
