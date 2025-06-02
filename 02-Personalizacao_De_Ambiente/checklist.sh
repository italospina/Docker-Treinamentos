#!/bin/bash

echo "=== ✅ VERIFICAÇÃO DO AMBIENTE ==="

# Verifica pacotes
echo -e "\n🔍 Verificando pacotes instalados..."
for pkg in htop git curl wget zip unzip net-tools vim nano neofetch; do
  dpkg -s "$pkg" &> /dev/null && echo "[OK] $pkg" || echo "[ERRO] $pkg não encontrado"
done

# Verifica usuário admin
echo -e "\n👤 Verificando usuário 'admin'..."
id admin &> /dev/null && echo "[OK] Usuário 'admin' existe" || echo "[ERRO] Usuário 'admin' não existe"

# Verifica sudo sem senha
echo -e "\n🔐 Verificando sudo sem senha para 'admin'..."
sudo -lU admin 2>/dev/null | grep -q "NOPASSWD: ALL" && echo "[OK] Sudo sem senha configurado" || echo "[ERRO] Sudo sem senha NÃO configurado"

# Verifica arquivo sudoers.d/admin
echo -e "\n📝 Verificando arquivo /etc/sudoers.d/admin..."
if [ -f /etc/sudoers.d/admin ]; then
  echo "[OK] Arquivo encontrado"
  PERM=$(stat -c %a /etc/sudoers.d/admin)
  [[ "$PERM" == "440" ]] && echo "[OK] Permissão correta (0440)" || echo "[ERRO] Permissão incorreta: $PERM"
else
  echo "[ERRO] Arquivo não existe"
fi

# Verifica shell e cores
echo -e "\n🎨 Verificando prompt colorido e shell..."
grep -q "force_color_prompt=yes" /home/admin/.bashrc && echo "[OK] Cores ativadas no .bashrc" || echo "[ERRO] Cores NÃO ativadas"
grep -q "alias ls='ls --color=auto'" /home/admin/.bashrc && echo "[OK] Alias colorido configurado" || echo "[ERRO] Alias 'ls' não configurado"

# Verifica shell padrão do admin
shell=$(getent passwd admin | cut -d: -f7)
[[ "$shell" == "/bin/bash" ]] && echo "[OK] Shell padrão do admin é bash" || echo "[ERRO] Shell padrão é $shell"

# Verifica SSH configs
echo -e "\n📡 Verificando configuração do SSH..."
grep -q "^PermitRootLogin no" /etc/ssh/sshd_config && echo "[OK] Root login via SSH desativado" || echo "[ERRO] Root login ainda ativo"
grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config && echo "[OK] PasswordAuthentication está ativado" || echo "[ERRO] PasswordAuthentication desativado"

echo -e "\n✅ Verificação concluída."
