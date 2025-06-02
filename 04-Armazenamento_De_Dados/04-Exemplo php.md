instalar
docker pull php:7.4-apache

criar pasta
mkdir /data/php-A

mapear pasta apra o container
caminho padrao: /usr/local/apache2/htdocs/

docker run --name php-A -d -p 8080:80 --volume=/data/php-A:/var/www/html php:7.4-apache