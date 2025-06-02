#!/bin/bash

# === ATUALIZA SISTEMA ===
echo "Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# === INSTALA PACOTES ÚTEIS ===
echo "Instalando pacotes básicos..."
sudo apt install -y htop git curl wget zip unzip net-tools vim nano neofetch

# === CONFIGURA .bashrc DO USUÁRIO ATUAL ===
echo "Personalizando .bashrc..."
BASHRC=~/.bashrc

# Ativa prompt colorido
if ! grep -q "force_color_prompt=yes" "$BASHRC"; then
  echo "force_color_prompt=yes" >> "$BASHRC"
fi

# Adiciona aliases e neofetch
cat << 'EOL' >> "$BASHRC"

# Aliases personalizados
alias ll='ls -lah --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Mostrar informações do sistema
neofetch
EOL

# === APLICA ALTERAÇÕES ===
echo "Aplicando .bashrc..."
source "$BASHRC"

# === CRIA USUÁRIO 'admin' ===
NOVO_USUARIO="admin"
echo "Criando usuário '$NOVO_USUARIO'..."
if ! id "$NOVO_USUARIO" &>/dev/null; then
  sudo useradd -m -s /bin/bash "$NOVO_USUARIO"
  echo "$NOVO_USUARIO:admin" | sudo chpasswd
  sudo usermod -aG sudo "$NOVO_USUARIO"
else
  echo "Usuário '$NOVO_USUARIO' já existe. Pulando criação."
fi

# === PERMISSÕES SUDO PARA 'admin' ===
echo "Configurando sudo sem senha para '$NOVO_USUARIO'..."
SUDOERS_LINE="$NOVO_USUARIO ALL=(ALL) NOPASSWD:ALL"
echo "$SUDOERS_LINE" | sudo tee /etc/sudoers.d/"$NOVO_USUARIO" > /dev/null
sudo chmod 0440 /etc/sudoers.d/"$NOVO_USUARIO"
sudo chmod 755 /etc/sudoers.d

# === DEFINE SENHA PARA ROOT ===
echo "Ativando root com senha 'root'..."
echo "root:root" | sudo chpasswd

# === CONFIGURA SSH ===
echo "Ajustando configurações de SSH..."
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "✅ Ambiente configurado com sucesso!"
