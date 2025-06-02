# 🚀 Criar VM Ubuntu no VirtualBox com Docker Instalado

## 1. Baixar a ISO do Ubuntu Server
- Acesse: https://ubuntu.com/download/server
- Baixe a versão LTS (ex: `ubuntu-24.04.2-live-server-amd64.iso`)

## 2. Criar a VM no VirtualBox
1. Abra o **Oracle VM VirtualBox** e clique em **Novo**
2. Nome: `Ubuntu-Server`
3. Pasta: onde quiser salvar (ex: `D:\VM`)
4. Selecione a ISO baixada
5. Tipo: `Linux`, Versão: `Ubuntu (64-bit)`
6. Marque: **Pular Instalação Desassistida**
7. Clique em **Próximo**

## 3. Configurar Memória e CPU
- RAM: **2048 MB** ou mais
- CPUs: **2** (se possível)

## 4. Criar Disco Virtual
- Tipo: **VDI**
- Alocação: **Dinamicamente alocado**
- Tamanho: **20 GB** ou mais

## 5. Instalar o Ubuntu
1. Inicie a VM
2. Siga o processo padrão:
   - Idioma, teclado, rede automática (DHCP)
   - Use o disco inteiro
   - Crie usuário/senha
   - Marque **instalar OpenSSH Server**
   - Finalize e reinicie

## 6. Remover a ISO após instalação
1. Vá em **Configurações > Armazenamento**
2. Clique na ISO (`*.iso`)
3. Clique no **ícone de disco com X** para ejetar
4. Verifique se só o disco `.vdi` está listado
5. Clique em OK e inicie a VM novamente

## 7. Configurações recomendadas no VirtualBox

### Sistema
- Memória: 2048 MB+
- CPU: 2
- Desmarcar "Disquete" da ordem de boot
- Habilitar: VT-x/AMD-V, PAE/NX

### Monitor
- Memória de vídeo: 128 MB
- Aceleração 3D (opcional)

### Rede
- **Adaptador 1: habilitado**
- **Modo:** `Placa em modo Bridge`
- **Nome:** 
  - Se usa **cabo**: `Killer E2600 Gigabit Ethernet Controller`
  - Se usa **Wi-Fi**: `Intel(R) Wi-Fi 6 AX200 160MHz`

## 8. Atualizar o sistema após instalar

```bash
sudo apt update && sudo apt upgrade -y
```

## 9. Instalar Docker no Ubuntu Server

### Com Script:
https://docs.docker.com/engine/install/ubuntu/
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run
```

### Dependências:
```bash
sudo apt install ca-certificates curl gnupg -y
```

### Chave GPG do Docker:
```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \\
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```


### Adicionar repositório:
```bash
echo \\
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \\
  https://download.docker.com/linux/ubuntu \\
  $(lsb_release -cs) stable" | \\
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Instalar Docker:
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

### Ativar Docker:
```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### Usar Docker sem sudo:
```bash
sudo usermod -aG docker $USER
```

### Reinicie a VM:
```bash
sudo reboot
```

## 10. Testar o Docker
```bash
docker run hello-world
```

Se aparecer a mensagem de sucesso, o Docker está pronto pra uso.
