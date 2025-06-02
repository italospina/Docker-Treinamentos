Criar destino
docker exec Ubuntu-A mkdir /destino

Ver destino
docker exec Ubuntu-A ls -la

1-Enviar arquivo para container 
docker cp nome_do_arquivo.txt Ubuntu-A:/destino

2-Enviar varios arquivos
Instalar zip
apt install -y zip

Zipar tudo
zip meuzip.zip *.txt

3-do container para servidor
docker cp Ubuntu-A:/destino/meuzip.zip zipcopia.zip