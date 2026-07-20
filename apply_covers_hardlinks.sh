#!/bin/bash

CAPAS_DIR="/mnt/jogos/PS2/Capas"
COVERS_DIR="$HOME/.var/app/net.pcsx2.PCSX2/config/PCSX2/covers"

echo "🧹 1. Limpando atalhos simbólicos que não funcionam no Flatpak..."
# Remove todos os arquivos .jpg/.png que são LIGAÇÕES SIMBÓLICAS (-type l) ou arquivos em covers/
find "$COVERS_DIR" -maxdepth 1 \( -name "*.jpg" -o -name "*.png" \) -exec rm -f {} \;

echo "🌎 2. Baixando e verificando a capa do GTA San Andreas (SLUS-20946)..."
GTA_PATH="$CAPAS_DIR/Grand Theft Auto - San Andreas [SLUS-20946].jpg"
if [ ! -f "$GTA_PATH" ]; then
    wget -qO "$GTA_PATH" "https://upload.wikimedia.org/wikipedia/en/c/c4/GTASABOX.jpg"
    if [ $? -eq 0 ]; then
        echo "✅ Capa do GTA San Andreas salva com sucesso na pasta Capas!"
    else
        echo "❌ Falha ao tentar baixar a capa oficial. Tente baixar manualmente depois."
    fi
else
    echo "✅ Capa do GTA San Andreas já existe."
fi

echo "🔗 3. Recriando todas as capas como HARD LINKS (Arquivos Reais Mágicos)..."
for FULL_IMG in "$CAPAS_DIR"/*.jpg "$CAPAS_DIR"/*.png; do
    # Verifica se o arquivo e nome são válidos e tem a formatação Nome [SERIAL].jpg
    if [[ -f "$FULL_IMG" ]]; then
        NOME_ARQUIVO=$(basename "$FULL_IMG")
        
        # Puxa o serial que está contido nos colchetes Ex: SLUS-12345
        if [[ "$NOME_ARQUIVO" =~ \[([A-Z0-9]{4}-[0-9]{5})\]\.(jpg|png)$ ]]; then
            SERIAL="${BASH_REMATCH[1]}"
            EXTENSAO="${BASH_REMATCH[2]}"
            
            # Cria o comando do Hard Link que fará o arquivo se materializar em covers/
            DESTINO="$COVERS_DIR/$SERIAL.$EXTENSAO"
            
            # ln (sem o -s) cria o hardlink (ele passará pela trava do sandbox do Zorin!)
            ln -f "$FULL_IMG" "$DESTINO" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "   -> Clonado ($SERIAL) via Hardlink"
            fi
        fi
    fi
done

echo "🎉 Tudo pronto! Abra seu PCSX2 do Zorin OS e veja as capas surgirem magicamente!"
