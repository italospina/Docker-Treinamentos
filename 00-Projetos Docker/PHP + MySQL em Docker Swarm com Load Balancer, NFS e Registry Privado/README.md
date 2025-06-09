# Projeto: App PHP + MySQL com Docker Swarm, NFS e HAProxy

Este projeto demonstra como construir uma aplicação PHP com MySQL, distribuída em 4 nós Docker Swarm, com volume compartilhado via NFS e balanceamento de carga usando HAProxy. Ao final, você terá:

* Uma **imagem PHP personalizada com mysqli** publicada em Registry privado.
* Um **serviço MySQL** rodando em container isolado.
* Um **volume compartilhado via NFS** entre todos os nós.
* Um **serviço PHP com 15 réplicas** balanceadas entre os nós.
* Um **HAProxy** distribuindo as requisições para os containers PHP.

---

## 🚀 Etapas Detalhadas

### 1. Configuração do Docker Swarm

**No node01:**

```bash
docker swarm init --advertise-addr 192.168.56.11
```

**Nos outros nós:**

```bash
docker swarm join --token <TOKEN> 192.168.56.11:2377
```

### 2. Registry Docker Privado (no node01)

```bash
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

**Em todos os nós, crie `/etc/docker/daemon.json`:**

```json
{
  "insecure-registries" : ["192.168.56.11:5000"]
}
```

Reinicie o Docker:

```bash
systemctl restart docker
```

### 3. Criação da imagem PHP personalizada

**Dockerfile:**

```Dockerfile
FROM php:8.2-apache
RUN docker-php-ext-install mysqli
COPY . /var/www/html
```

**Build e envio para o Registry:**

```bash
docker build -t php-mysqli .
docker tag php-mysqli 192.168.56.11:5000/php-mysqli
docker push 192.168.56.11:5000/php-mysqli
```

### 4. Volume Compartilhado

```bash
docker volume create app
```

**Nos outros nós:**

```bash
mkdir -p /var/lib/docker/volumes/app/_data
```

### 5. NFS Server e Montagem

**No node01:**

```bash
apt install -y nfs-kernel-server
mkdir -p /var/lib/docker/volumes/app/_data
nano /etc/exports
```

Adicione:

```
/var/lib/docker/volumes/app/_data *(rw,sync,no_subtree_check,no_root_squash)
```

Depois:

```bash
exportfs -a
systemctl restart nfs-kernel-server
```

**Nos outros nós:**

```bash
apt install -y nfs-common
mkdir -p /var/lib/docker/volumes/app/_data
mount 192.168.56.11:/var/lib/docker/volumes/app/_data /var/lib/docker/volumes/app/_data
```

### 6. Banco de Dados MySQL

```bash
docker volume create data
docker run -e MYSQL_ROOT_PASSWORD=senha123 \
  -e MYSQL_DATABASE=meubanco \
  --name mysql-A -d -p 3306:3306 \
  --mount source=data,target=/var/lib/mysql \
  mysql:9.3
```

### 7. `docker-compose.yml`

```yaml
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

  haproxy:
    image: haproxy:latest
    ports:
      - "80:80"
    volumes:
      - /home/vagrant/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
    networks:
      - app_net
    deploy:
      placement:
        constraints: [node.hostname == node01]

volumes:
  phpdata:
    driver_opts:
      type: "nfs"
      o: "addr=192.168.56.11,rw"
      device: ":/var/lib/docker/volumes/app/_data"

networks:
  app_net:
    driver: overlay
```

### 8. `haproxy.cfg`

```haproxy
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
    server-template phpservice 15 phpservice:80 check
```

### 9. Deploy do Stack

```bash
docker stack deploy -c docker-compose.yml phpstack
```

---

## 📚 index.php de Exemplo

Coloque dentro de `/var/lib/docker/volumes/app/_data/index.php`:

```php
<?php
$host = '192.168.56.11';
$user = 'root';
$pass = 'senha123';
$db   = 'meubanco';
$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) die("Erro: " . $conn->connect_error);
$res = $conn->query("SELECT * FROM dados");
echo "<table border='1'><tr><th>id</th><th>data1</th><th>data2</th><th>hostname</th><th>ip</th></tr>";
while ($row = $res->fetch_assoc()) {
    echo "<tr><td>{$row['id']}</td><td>{$row['data1']}</td><td>{$row['data2']}</td><td>{$row['hostname']}</td><td>{$row['ip']}</td></tr>";
}
echo "</table>";
$conn->close();
?>
```

---

## 🔧 Comandos úteis

```bash
docker stack rm phpstack
docker service ls
docker service ps phpstack_phpservice
docker volume ls
docker container ls -a
docker logs <container>
```

---

## 💬 Contato

Criado por **Ítalo Spina**. Para dúvidas ou melhorias, entre em contato.

Tecnologias: Docker, PHP, NFS, HAProxy, MySQL

Bom desenvolvimento! 🚀
