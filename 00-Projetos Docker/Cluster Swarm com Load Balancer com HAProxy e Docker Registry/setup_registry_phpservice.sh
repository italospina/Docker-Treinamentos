#!/bin/bash

# IP do node01 (onde o registry será exposto)
REGISTRY_IP="192.168.56.11"
NODES=("192.168.56.11" "192.168.56.12" "192.168.56.13" "192.168.56.14")
IMAGE_NAME="php:8.3-apache-mysqli"
FULL_IMAGE="$REGISTRY_IP:5000/$IMAGE_NAME"
DOCKERFILE_PATH="/apache-php-mysql"

echo "🚀 Subindo Registry privado no $REGISTRY_IP..."
docker service create \
  --name registry \
  --publish published=5000,target=5000 \
  --constraint 'node.hostname == node01' \
  --mount type=volume,source=registry_data,target=/var/lib/registry \
  registry:2

sleep 5

echo "🔧 Configurando Docker em todos os nós para aceitar o registry inseguro..."
for NODE in "${NODES[@]}"; do
  ssh root@$NODE "mkdir -p /etc/docker && echo '{ \"insecure-registries\": [\"$REGISTRY_IP:5000\"] }' > /etc/docker/daemon.json"
  ssh root@$NODE "systemctl restart docker"
done

echo "🧱 Buildando imagem no node01..."
docker build -t $FULL_IMAGE $DOCKERFILE_PATH

echo "📤 Enviando imagem para o registry..."
docker push $FULL_IMAGE

echo "📦 Subindo serviço phpservice no Swarm..."
docker service create \
  --name phpservice \
  --replicas 15 \
  --mount type=volume,source=app,target=/var/www/html \
  $FULL_IMAGE

echo "✅ Finalizado. Acesse http://$REGISTRY_IP para testar a aplicação."
