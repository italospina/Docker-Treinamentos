# Docker-Treinamentos

Este repositório contém uma série de experimentos e aplicações práticas relacionados à conteinerização com Docker, utilizando também ferramentas como Docker Compose, Docker Swarm, HAProxy, Vagrant, NFS e PHP + MySQL em ambientes distribuídos.

Foi desenvolvido durante e após a formação **Docker Fundamentals** da DIO, com o objetivo de consolidar conceitos fundamentais e avançados de infraestrutura com containers.

---

## 📂 Estrutura do Repositório

```
Docker-Treinamentos/
├── 01_HelloDocker/              # Primeiro container com imagem hello-world
├── 02_Container_MySQL/         # Subindo MySQL com Docker CLI
├── 03_Container_PHP/           # PHP 8.2 com Apache em container
├── 04_DockerCompose_PHP_MySQL/ # Aplicativo PHP + MySQL com Docker Compose
├── 05_ClusterSwarm_HAProxy/    # Cluster com Docker Swarm, HAProxy e NFS
└── README.md                   # Este documento
```

---

## 🚀 Conteúdo dos Diretórios

### 01\_HelloDocker

* Primeiro teste com Docker rodando o container `hello-world`.
* Objetivo: verificar funcionamento da instalação e entender ciclo de vida de um container.

### 02\_Container\_MySQL

* Subida de container **MySQL 9.3** via `docker run`.
* Volume persistente criado com `docker volume create`.
* Acesso via CLI e exploração de variáveis de ambiente (`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`).

### 03\_Container\_PHP

* Criação de um container com **PHP 8.2 + Apache**.
* Uso de `Dockerfile` para customizar a imagem com a extensão `mysqli`.
* Exposição da porta 80 e montagem de arquivos PHP locais.

### 04\_DockerCompose\_PHP\_MySQL

* Estrutura completa com **Docker Compose**:

  * PHP + Apache
  * MySQL
  * Adminer (GUI web para banco)
* Aplicativo PHP conecta ao banco e renderiza informações HTML.
* Criação de banco/tabela, inserção condicional e exibição de dados.
* Uso de rede interna, volumes nomeados e dependências entre serviços.

### 05\_ClusterSwarm\_HAProxy

* Projeto mais completo:

  * Criação de **cluster Docker Swarm com 4 nós (via Vagrant)**
  * Uso de **Registry privado** para armazenar imagem PHP personalizada
  * Volume compartilhado com **NFS Server**
  * **15 réplicas PHP** balanceadas por **HAProxy**
  * **MySQL** isolado e acessado pelas réplicas
* HAProxy configurado com `server-template` para auto-distribuição
* Acesso web expõe uma aplicação PHP real conectada ao banco

---

## ⚛️ Tecnologias Utilizadas

* **Docker** (CLI, Dockerfile, images, volumes, networks)
* **Docker Compose** (orquestração de ambientes locais)
* **Docker Swarm** (cluster, escalabilidade, deploy de stacks)
* **HAProxy** (load balancing entre containers)
* **NFS** (volume compartilhado entre os nós)
* **MySQL** (banco de dados relacional)
* **PHP + Apache** (servidor de aplicação)
* **Vagrant** (provisionamento de múltiplos VMs Ubuntu para testes distribuídos)
* **Adminer** (interface de gerenciamento de banco)

---

## 📅 Como Rodar (exemplo do Compose)

```bash
cd 04_DockerCompose_PHP_MySQL
docker-compose up -d --build
```

Acesse em: `http://localhost:8080`

---

## 🔧 Comandos de Referência

```bash
docker build -t nome-imagem .
docker run -d -p 80:80 nome-imagem
docker volume create nome-volume
docker network create nome-rede
docker-compose up -d

docker swarm init
docker service create --replicas 3 nome-imagem
docker stack deploy -c docker-compose.yml nomestack
```

---

## 💬 Contato

Criado por **Ítalo Spina**. Para dúvidas ou sugestões, entre em contato via [GitHub](https://github.com/italospina).

---

⭐ Se você achou útile este repositório, considere deixar uma estrela! ⭐
