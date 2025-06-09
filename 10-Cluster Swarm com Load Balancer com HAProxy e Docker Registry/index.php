<?php
// Ativar exibição de erros
ini_set("display_errors", 1);
header('Content-Type: text/html; charset=iso-8859-1');

// Exibir versão do PHP
echo 'Versao Atual do PHP: ' . phpversion() . '<br>';

// Dados da conexão
$servername = "192.168.56.11";
$username = "root";
$password = "senha123";
$database = "meubanco";

// Criar conexão com MySQL usando mysqli
$link = new mysqli($servername, $username, $password, $database);

// Verificar conexão
if (mysqli_connect_errno()) {
    printf("Connect failed: %s\n", mysqli_connect_error());
    exit();
}

// Gerar dados aleatórios
$valor_rand1 = rand(1, 999);
$valor_rand2 = strtoupper(substr(bin2hex(random_bytes(4)), 1));
$host_name = gethostname();
$host_ip = $_SERVER['REMOTE_ADDR'];

// Inserir no banco
$query = "INSERT INTO dados (id, data1, data2, hostname, ip) 
          VALUES ('$valor_rand1', '$valor_rand2', '$valor_rand2', '$host_name', '$host_ip')";

if ($link->query($query) === TRUE) {
    echo "Novo registro inserido com sucesso.<br>";
} else {
    echo "Erro ao inserir: " . $link->error . "<br>";
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Exemplo PHP</title>
</head>
<body>
    <p>Este é um exemplo de integração entre PHP e MySQL.</p>
</body>
</html>