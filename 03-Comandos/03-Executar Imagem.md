Executar a imagem
docker run hello-world

Realizar execucao e programar tempo de execucao
docker run ubuntu sleep 10

Realizar a execucao do tempo e poder trabalhar equanto alocado
docker run -it ubuntu

deixar container em execucao ate o comando stop
docker run -dti ubuntu

entrar no container
docker exec -it adfad6cb8e53 /bin/bash