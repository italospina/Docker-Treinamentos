<?php
header("Content-Type: text/html; charset=UTF-8");

// ===============================
// Parâmetros de conexão (serviço 'db')
// ===============================
$host = 'db';
$user = 'root';
$pass = 'senha123';
$db   = 'testdb';

// Tenta conectar ao MySQL (host 'db' dentro da rede do Compose)
$mysqli = new mysqli($host, $user, $pass, $db);
if ($mysqli->connect_errno) {
    die("Falha na conexão: " . $mysqli->connect_error);
}

// Cria tabela 'clientes' se não existir
$mysqli->query("
    CREATE TABLE IF NOT EXISTS clientes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(100),
        cidade VARCHAR(100)
    ) ENGINE=InnoDB
");

// Insere um registro de exemplo (caso não exista)
$mysqli->query("
    INSERT INTO clientes (nome, cidade)
    SELECT 'Fulano', 'São Paulo'
    WHERE NOT EXISTS (
      SELECT 1 FROM clientes WHERE nome='Fulano' AND cidade='São Paulo'
    )
");

// Busca todos os clientes
$result = $mysqli->query("SELECT * FROM clientes");
?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>App PHP + MySQL</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Lista de Clientes</h1>
    <table>
        <tr>
            <th>ID</th>
            <th>Nome</th>
            <th>Cidade</th>
        </tr>
        <?php while ($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?= $row['id'] ?></td>
                <td><?= htmlspecialchars($row['nome'], ENT_QUOTES, 'UTF-8') ?></td>
                <td><?= htmlspecialchars($row['cidade'], ENT_QUOTES, 'UTF-8') ?></td>
            </tr>
        <?php endwhile; ?>
    </table>
</body>
</html>
<?php
$mysqli->close();
?>