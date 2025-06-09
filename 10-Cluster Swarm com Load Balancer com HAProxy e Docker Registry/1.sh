#2. Configuração do Docker Swarm
#No node01:
docker swarm init --advertise-addr 192.168.56.11

#Nos outros nós (node02, node03, node04), copie e execute o comando de join exibido após o swarm init, algo como:
docker swarm join --token <TOKEN> 192.168.56.11:2377

#3. Criação do Docker Registry Privado (no node01)
docker run -d -p 5000:5000 --restart=always --name registry registry:2

#Crie o arquivo /etc/docker/daemon.json em todos os nós:
{
  "insecure-registries" : ["192.168.56.11:5000"]
}

#Reinicie o Docker:
systemctl restart docker

#4. Criação da Imagem PHP com mysqli (no node01)
#Crie um Dockerfile:

FROM php:8.2-apache
RUN docker-php-ext-install mysqli
COPY . /var/www/html

#Compile e envie ao registry:
docker build -t php-mysqli .
docker tag php-mysqli 192.168.56.11:5000/php-mysqli
docker push 192.168.56.11:5000/php-mysqli

#5. Criação do Volume Compartilhado (no node01)
docker volume create app

# Crie o diretório de dados nos outros nós:
mkdir -p /var/lib/docker/volumes/app/_data


#6. NFS Server
#Instalação do NFS Server (no node01)
apt-get install nfs-server -y

# Instalação do NFS Client (nos outros nós)
apt update
apt install -y nfs-common

#editar o arquivo de configuracao onde vamos replicar
nano /etc/exports

/var/lib/docker/volumes/app/_data *(rw,sync,subtree_check)

#para exportar
exportfs -ar

#instalar o servico nas outras maquina
apt-get install nfs-common -y

#ver se tem acesso
showmount -e 192.168.56.11

#precisa montar isso nos outros nós no mesmo caminho (ip da maquina principal)
mount 192.168.56.11:/var/lib/docker/volumes/app/_data /var/lib/docker/volumes/app/_data

#agora todos os nos estao replicados

#5. Volume Compartilhado com NFS
#No node01:
apt install -y nfs-kernel-server
mkdir -p /srv/nfs/phpdata
chown nobody:nogroup /srv/nfs/phpdata
echo "/srv/nfs/phpdata *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
exportfs -a && systemctl restart nfs-kernel-server

#Nos outros nós:
mkdir -p /mnt/phpdata
mount 192.168.56.11:/srv/nfs/phpdata /mnt/phpdata

#Se quiser montar via Docker, use:
type: volume
driver_opts:
  type: "nfs"
  o: "addr=192.168.56.11,rw"
  device: ":/srv/nfs/phpdata"

#6. Banco de Dados MySQL (em qualquer nó)
docker volume create data
docker run -e MYSQL_ROOT_PASSWORD=senha123 -e MYSQL_DATABASE=meubanco --name mysql-A -d -p 3306:3306 --mount source=data,target=/var/lib/mysql mysql:9.3

#7. Deploy do Serviço com Swarm
#Crie o docker-compose.yml:
version: "3.9"

services:
  phpservice:
    image: 192.168.56.11:5000/php-mysqli
    deploy:
      replicas: 15
      placement:
        constraints: [node.role == worker]
    volumes:
      - type: volume
        source: phpdata
        target: /var/www/html
        volume:
          nocopy: true
    networks:
      - app_net

volumes:
  phpdata:
    driver_opts:
      type: "nfs"
      o: "addr=192.168.56.11,rw"
      device: ":/srv/nfs/phpdata"

networks:
  app_net:
    driver: overlay


#Suba com:
docker stack deploy -c docker-compose.yml phpstack

#8. HAProxy (no node01)
#Exemplo básico de configuração (haproxy.cfg):
#nano /home/vagrant/haproxy.cfg

global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http_front
    bind *:80
    default_backend php_back

backend php_back
    balance roundrobin
    server-template phpservice 15 phpstack_phpservice:80 check



#Rode com:
docker run -d --name haproxy \
  -p 80:80 \
  -v /home/vagrant/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
  --network phpstack_app_net \
  haproxy:latest
