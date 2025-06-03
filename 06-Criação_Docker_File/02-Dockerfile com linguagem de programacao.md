1 - baixar imagem da linguagem
docker pull python

2- criar um diretorio
mkdir python

3-criar um app pequeno
nano app.py
print("Hello from Docker!")

4-criar o dockerfile
FROM python

WORKDIR /usr/src/app

COPY app.py /usr/src/app

CMD [ "python", "/usr/src/app/app.py" ]

5 - gerar a imagem
docker build -t app-python:1.0 .

6- rodar a imagem
docker run -ti --name runapp1 app-python:1.0