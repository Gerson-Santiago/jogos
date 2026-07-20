#!/bin/bash
# PCSX2 Gold Standard Launcher
# Garante permissões de escrita e abre o emulador via Flatpak

# Caminho para os dados (ajuste se necessário)
DATA_PATH="/mnt/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/"

echo "--- Iniciando PCSX2 Gold Standard ---"

# Ajusta permissões do usuário atual de forma recursiva nas pastas críticas
echo "Ajustando permissões em $DATA_PATH..."
find "$DATA_PATH" -type d -exec chmod 755 {} +
find "$DATA_PATH" -type f -exec chmod 644 {} +

# Garante que as pastas de saves (se convertidas para folder) tenham escrita
if [ -d "$DATA_PATH/memcards" ]; then
    find "$DATA_PATH/memcards" -type d -exec chmod 755 {} +
    find "$DATA_PATH/memcards" -type f -not -name ".gitkeep" -exec chmod 664 {} +
fi

echo "Abrindo PCSX2 via Flatpak..."
flatpak run net.pcsx2.PCSX2
