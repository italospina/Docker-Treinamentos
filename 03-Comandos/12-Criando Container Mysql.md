instalar
docker pull mysql

liberar portas e setar variaveis de ambiente
docker run -e MYSQL_ROOT_PASSWORD=senha123 --name mysql-A -d -p 3306:3306 mysql

entrar no container
docker exec -it mysql-A bash

chamar o comando mysql
mysql -u root -p --protocol=tcp

criar banco
CREATE DATABASE TESTE;

ver bancos
show databases;

ver ip
ip a

ver ip de container
docker inspect

instalar mysql client
apt -y install mysql-client

chamar mysql
mysql -u root -p --protocol=tcp