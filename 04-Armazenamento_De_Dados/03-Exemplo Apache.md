instalar httpd apache
docker pull httpd

criar pasta 
/data/apache-A

mapear pasta apra o container
caminho padrao /usr/local/apache2/htdocs/
docker run --name apache-A -d -p 80:80 --volume=/data/apache-A:/usr/local/apache2/htdocs httpd