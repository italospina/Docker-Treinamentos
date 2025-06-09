# Projeto: App PHP + MySQL com Docker Compose
Este projeto demonstra como executar uma aplicação PHP (com MySQL) e um container Adminer usando Docker Compose. Ao final, você terá:  
- Um container **MySQL 9.3** com banco de dados `testdb`.  
- Um container **PHP 8.3 + Apache** que conecta ao MySQL e exibe uma lista de clientes.  
- Um container **Adminer** para gerenciar o banco via interface web.
## 📂 Estrutura de Diretórios
```
/data/compose/projeto-html-DIO/
├── docker-compose.yml
├── Dockerfile
└── html/
    ├── index.php
    └── style.css
```
- **docker-compose.yml** … define os serviços (`db`, `web`, `adminer`).  
- **Dockerfile** … habilita a extensão `mysqli` no PHP/Apache.  
- **html/**  
  - **index.php** … aplicação PHP que conecta no MySQL, cria tabela/registro e exibe dados.  
  - **style.css** … estilos CSS para a tabela de clientes.
## 🚀 Conteúdo dos Arquivos
### 1. `docker-compose.yml`
```yaml
version: "3.8"
services:
  db:
    image: mysql:9.3
    environment:
      MYSQL_ROOT_PASSWORD: "senha123"
      MYSQL_DATABASE: "testdb"
    ports:
      - "3306:3306"
    volumes:
      - /data/mysql-compose:/var/lib/mysql
  web:
    build: .
    depends_on:
      - db
    ports:
      - "8080:80"
    volumes:
      - ./html:/var/www/html
  adminer:
    image: adminer
    depends_on:
      - db
    ports:
      - "8081:8080"
```
- **db**  
  - Imagem: `mysql:9.3`  
  - Variáveis de ambiente:  
    - `MYSQL_ROOT_PASSWORD=senha123`  
    - `MYSQL_DATABASE=testdb`  
  - Porta mapeada: `3306:3306`  
  - Volume (bind-mount) para persistência: `/data/mysql-compose:/var/lib/mysql`  
- **web**  
  - Build local via Dockerfile (instala extensão `mysqli`).  
  - Depende de `db` (inicia o MySQL antes).  
  - Porta mapeada: `8080:80`  
  - Volume (bind-mount) que expõe a pasta `html/` em `/var/www/html`.  
- **adminer**  
  - Imagem oficial `adminer`  
  - Depende de `db`  
  - Porta mapeada: `8081:8080` (interface Adminer disponível em `http://<IP>:8081`)
### 2. `Dockerfile`
```dockerfile
# /data/compose/projeto-html-DIO/Dockerfile
FROM php:8.3.21-apache
# Instala extensão mysqli para conectar ao MySQL
RUN docker-php-ext-install mysqli
```
- Base: `php:8.3.21-apache` (PHP 8.3 + Apache).  
- O comando `docker-php-ext-install mysqli` habilita a extensão `mysqli` no PHP.
### 3. `html/index.php`
```php
<?php
header("Content-Type: text/html; charset=UTF-8");
// ▶︎ Parâmetros de conexão (serviço 'db')
$host = 'db';
$user = 'root';
$pass = 'senha123';
$db   = 'testdb';
// Tenta conectar ao MySQL (hostname “db”)
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
// Insere registro de exemplo (caso não exista)
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
```
- Conecta a `db` (hostname do MySQL no Compose).  
- Cria a tabela `clientes` se não existir.  
- Insere o registro “Fulano – São Paulo” apenas uma vez.  
- Exibe todos os registros em uma tabela HTML.
### 4. `html/style.css`
```css
body {
  font-family: Arial, sans-serif;
  background-color: #f4f4f4;
  margin: 20px;
}
h1 {
  color: #333;
}
table {
  width: 50%;
  border-collapse: collapse;
  margin-top: 10px;
}
th, td {
  border: 1px solid #999;
  padding: 8px;
  text-align: left;
}
th {
  background-color: #555;
  color: #fff;
}
```
- Define estilo básico para a página e tabela de clientes.  
- Arquivo referenciado em `<link rel="stylesheet" href="style.css">`.
## 📌 Como Rodar
1. **Clone o repositório (se aplicável)**  
   ```bash
   git clone <URL_DO_REPOSITÓRIO>
   cd projeto-html-DIO
   ```
2. **Acesse a pasta do projeto**  
   ```bash
   cd /data/compose/projeto-html-DIO
   ```
3. **Ajuste permissões da pasta `html/`**  
   ```bash
   sudo chown -R 33:33 ./html
   sudo chmod -R 755 ./html
   ```  
   O Apache (usuário `www-data`, UID 33) precisa de permissão para ler arquivos PHP/CSS.
4. **Encerre containers/volumes antigos (opcional, mas recomendado no primeiro uso)**  
   ```bash
   docker-compose down -v
   ```  
   O `-v` remove volumes nomeados. Se estiver usando bind-mount em `/data/mysql-compose`, certifique-se de que este diretório esteja vazio antes de subir novamente.
5. **Suba e construa os containers**  
   ```bash
   docker-compose up -d --build
   ```  
   - Vai buildar a imagem PHP/Apache (via Dockerfile) instalando `mysqli`.  
   - Criar o container MySQL, que gera o banco `testdb` na primeira vez.  
   - Criar o container Adminer.
6. **Aguarde 15–20 segundos**  
   O MySQL precisa de alguns segundos para terminar a inicialização e criar o banco `testdb`.  
   Para acompanhar a inicialização, use:  
   ```bash
   docker-compose logs db | tail -n 10
   ```  
   Procure por algo como:  
   ```
   [Entrypoint]: Creating database testdb
   ```
7. **Acesse no navegador**  
   - **Aplicação PHP/Apache:**  
     ```
     http://<IP_DO_SERVIDOR>:8080
     ```  
   - **Interface Adminer (para gerenciar o MySQL):**  
     ```
     http://<IP_DO_SERVIDOR>:8081
     ```  
   - **Credenciais:**  
     - Sistema: MySQL  
     - Servidor: db  
     - Usuário: root  
     - Senha: senha123  
     - Banco: testdb
## 🛠️ Troubleshooting
### Unknown database “testdb”
- **Causa:** `/data/mysql-compose` continha dados antigos.  
- **Solução – Opção A (limpar bind-mount):**  
  ```bash
  docker-compose down -v
  sudo rm -rf /data/mysql-compose/*
  docker-compose up -d --build
  ```
- **Solução – Opção B (usar named volume):**  
  Edite `docker-compose.yml` substituindo o bind-mount por named volume:  
  ```yaml
  db:
    image: mysql:9.3
    environment:
      MYSQL_ROOT_PASSWORD: "senha123"
      MYSQL_DATABASE: "testdb"
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
  volumes:
    db_data:
  ```  
  Em seguida:  
  ```bash
  docker-compose down -v
  docker-compose up -d --build
  ```
### Class “mysqli” not found
- **Causa:** extensão `mysqli` não instalada no PHP.  
- **Solução:** verifique se o `Dockerfile` contém:  
  ```dockerfile
  FROM php:8.3.21-apache
  RUN docker-php-ext-install mysqli
  ```  
  Depois:  
  ```bash
  docker-compose up -d --build
  ```
### php_network_getaddresses: getaddrinfo for db failed
- **Causa:** container `web` não está na mesma rede do `db`.  
- **Solução:** remova qualquer seção `networks:` do `docker-compose.yml`, deixando o Compose criar a rede padrão.  
  ```bash
  docker-compose down -v
  docker-compose up -d --build
  ```  
  Aguarde o MySQL iniciar (15 segundos) e recarregue a página.
### 403 Forbidden ao acessar `index.php`
- **Causa:** permissões incorretas na pasta `html/`.  
- **Solução:**  
  ```bash
  sudo chown -R 33:33 /data/compose/projeto-html-DIO/html
  sudo chmod -R 755 /data/compose/projeto-html-DIO/html
  docker-compose restart web
  ```
## 📄 Comandos Úteis
- **Parar e remover containers + volumes nomeados:**  
  ```bash
  docker-compose down -v
  ```
- **Limpar imagens não usadas:**  
  ```bash
  docker image prune -a -f
  ```
- **Limpar volumes órfãos:**  
  ```bash
  docker volume prune -f
  ```
- **Verificar logs de um serviço:**  
  ```bash
  docker-compose logs <serviço> | tail -n 20
  ```  
  Ex.:  
  ```bash
  docker-compose logs db | tail -n 20
  docker-compose logs web | tail -n 20
  ```
## 📬 Contato e Agradecimentos
Criado por **Ítalo Spina**. Se precisar de ajuda ou quiser sugerir melhorias, entre em contato!  
Imagens oficiais utilizadas:  
- PHP/Apache: `php:8.3.21-apache`  
- MySQL: `mysql:9.3`  
- Adminer: `adminer`  
Sinta-se à vontade para estilizar, adicionar JavaScript ou expandir a aplicação conforme seus conhecimentos em HTML, CSS e JavaScript.  
Bom desenvolvimento! 🚀
