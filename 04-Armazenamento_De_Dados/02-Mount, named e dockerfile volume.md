# ✅ 1. --mount (modo moderno)
docker run -d \
  --name meu_container \
  --mount type=bind,source="$(pwd)"/dados,target=/app/dados \
  nginx

# Isso monta a pasta local ./dados dentro do container em /app/dados

# ✅ 2. --volume (modo antigo, mas ainda válido)
docker run -d \
  --name meu_container \
  -v "$(pwd)"/dados:/app/dados \
  nginx

# Mesmo efeito que --mount, mas com sintaxe mais curta

# ✅ 3. Com Dockerfile usando VOLUME

# Dockerfile
FROM ubuntu
RUN mkdir /app/logs
VOLUME ["/app/logs"]
CMD ["bash"]

# Build da imagem
docker build -t meu_ubuntu .

# Rodar com volume anônimo (automático)
docker run -it meu_ubuntu

# Rodar com bind manual
docker run -it -v $(pwd)/logs:/app/logs meu_ubuntu
