ver estatisticas de uso dos containers
docker stats php-A

como ja existe temos que atualizar
docker update php-A -m 128M --memory-swap 128M --cpus 0.2

CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O    PIDS
3a02eff2fadd   php-A     0.00%     9.352MiB / 3.731GiB   0.24%     2.96kB / 23.5kB   0B / 4.1kB   7

CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT   MEM %     NET I/O           BLOCK I/O    PIDS
3a02eff2fadd   php-A     0.00%     9.352MiB / 128MiB   7.31%     2.96kB / 23.5kB   0B / 4.1kB   7

criar ja com memoria deifinida
docker run --name ubuntu-TESTE -dti -m 128M --cpus 0.2 ubuntu

instalar um app para superlotar a memoria da maquina
apt -y install stress

usar

root@f8ad04a17e25:/# stress --cpu 1 --vm-bytes 50m --vm 1 --vm-bytes 50m^C
