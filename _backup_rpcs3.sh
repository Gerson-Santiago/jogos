#!/bin/bash

echo "Fazendo backup da arquitetura Gold do RPCS3..."

# Definindo diretórios
BACKUP_DIR="/mnt/jogos/backups/rpcs3_configs"
RPCS3_CONF_DIR="$HOME/.config/rpcs3"

# Criando estrutura se não existir
mkdir -p "$BACKUP_DIR/input_configs/global"
mkdir -p "$BACKUP_DIR/GuiConfigs"

# Copiando os arquivos vitais
cp "$RPCS3_CONF_DIR/config.yml" "$BACKUP_DIR/"
cp "$RPCS3_CONF_DIR/games.yml" "$BACKUP_DIR/"
cp "$RPCS3_CONF_DIR/input_configs/global/Default.yml" "$BACKUP_DIR/input_configs/global/"
cp "$RPCS3_CONF_DIR/GuiConfigs/CurrentSettings.ini" "$BACKUP_DIR/GuiConfigs/"

echo "Arquivos copiados com sucesso! Fazendo commit no Git..."

cd /mnt/jogos || exit
git add "$BACKUP_DIR"
git commit -m "Auto-Backup: Atualizacao dos perfis Gold do RPCS3 (Controles e Configuracoes)"
git push

echo "Tudo salvo e versionado no GitHub!"
