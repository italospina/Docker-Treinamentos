1 - Criar diretorio debian-apache
mkdir debian-apache
cd debian-apache
mkdir site

2-criar uma imagem de site rapido

index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Site Exemplo</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Bem-vindo ao Meu Site</h1>
    </header>
    <main>
        <p>Este é um site de exemplo feito para testes locais.</p>
    </main>
    <footer>
        <p>&copy; 2025 Exemplo</p>
    </footer>
</body>
</html>

style.css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background-color: #f2f2f2;
    color: #333;
}

header {
    background-color: #004488;
    color: white;
    padding: 20px;
    text-align: center;
}

main {
    padding: 20px;
}

footer {
    background-color: #ddd;
    text-align: center;
    padding: 10px;
}

3-criar um tar com os documentos da pasta
tar -czf site.tar ./

4-criar dockerfile na pasta anterior
FROM debian

# Instala o Apache
RUN apt-get update && apt-get install -y apache2 && apt-get clean

# Variáveis de ambiente corretas
ENV APACHE_LOCK_DIR=/var/lock \
    APACHE_PID_FILE=/var/run/apache2.pid \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2

# Adiciona os arquivos do site
ADD site.tar /var/www/html

# Corrige o LABEL (sem espaços ao redor do "=")
LABEL description="Apache webserver 1.0"

# Define volume e porta
VOLUME /var/www/html
EXPOSE 80

# Corrige o caminho e fecha a string corretamente
ENTRYPOINT ["/usr/sbin/apachectl"]
CMD ["-D", "FOREGROUND"]

5-gerar imagem
docker image build -t debian-apache:1.0 .

6-subir imagem
docker run -ti -p 80:80 --name meuapache debian-apache:1.0