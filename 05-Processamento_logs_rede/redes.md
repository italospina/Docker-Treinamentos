listar conexoes de rede
docker network ls

ver quais constainer estao adicionados a essa rede
docker network inspect bridge

instalar o ping
apt-get install -y iputils-ping

testar ping
ping 172.17.0.5

1- isolar 2 containers
criar rede
docker network create minha-rede

verificar as duas redes com o inspect

entrar em um container
