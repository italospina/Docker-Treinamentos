verificar informacoes do container
docker inspect mysql-A

criar 2 pastas na raiz
mkdir /data
mkdir /data/mysql-A

vamos recriar tudo novamente, mas com caminho do /data dentro do host e definindo container
docker run -e MYSQL_ROOT_PASSWORD=senha123 --name mysql-A -d -p 3306:3306 --volume=/data/mysql-A:/var/lib/mysql mysql

agora todos os dados, por mais que o container seja excluido, podem ser recuperados em outro momento

exemplo.

