#!/bin/bash

# Diretórios e arquivos
CACHE_FILE="/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/cache/gamelist.cache"
COVERS_DIR="/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/covers"
CAPAS_DIR="/media/jogos/PS2/Capas"

echo "============================================================"
echo "🎮 Auditoria Profunda de Capas do PCSX2"
echo "============================================================"
echo ""

if [ ! -f "$CACHE_FILE" ]; then
    echo "Erro: Arquivo gamelist.cache não encontrado em:"
    echo "$CACHE_FILE"
    exit 1
fi

declare -a REPORT_FALTANTE
declare -a REPORT_FALSO_NEGATIVO
declare -a REPORT_FALSO_POSITIVO

# Extrai os dados do cache usando strings e awk
while IFS='|' read -r serial nome_jogo; do
    capa_existe=0
    capa_oficial=""
    
    # 1. Checa se o atalho do formato .jpg ou .png válido existe e pode ser acessado
    for ext in "jpg" "png"; do
        if [ -r "$COVERS_DIR/$serial.$ext" ]; then
            capa_existe=1
            capa_oficial="$COVERS_DIR/$serial.$ext"
            break
        fi
    done
    
    if [ "$capa_existe" -eq 1 ]; then
        # ----------------------------------------------------
        # VERIFICAR FALSOS POSITIVOS (Ligação suspeita)
        # ----------------------------------------------------
        if [ -L "$capa_oficial" ]; then
            target=$(readlink "$capa_oficial")
            target_name=$(basename "$target")
            
            # Se o nome original do arquivo não conter a serial, sinalizamos como suspeito!
            if [[ "$target_name" != *"$serial"* ]]; then
                REPORT_FALSO_POSITIVO+=("⚠️  [ $serial ] $nome_jogo -> Cuidado com atalho para: $target_name")
            fi
        fi
    else
        # ----------------------------------------------------
        # VERIFICAR FALSOS NEGATIVOS (Arquivo ignorado/desvinculado)
        # ----------------------------------------------------
        achou_perdida=0
        perdidas=""
        # Busca qualquer imagem cujo nome contenha ao menos a serial na pasta real
        for img in "$CAPAS_DIR"/*"$serial"*; do
            if [ -e "$img" ]; then
                achou_perdida=1
                perdidas+="$(basename "$img") | "
            fi
        done
        
        if [ "$achou_perdida" -eq 1 ]; then
            REPORT_FALSO_NEGATIVO+=("🔎 [ $serial ] $nome_jogo -> Não apareceu no PCSX2, mas encontrei na pasta: $perdidas")
        else
            REPORT_FALTANTE+=("❌ [ $serial ] $nome_jogo")
        fi
    fi

done < <(strings "$CACHE_FILE" | awk '
/^\/media\/jogos\/PS2\/ISOs\// {
    path = $0
    # Pegar linha do serial
    getline
    raw_serial = $0
    # Identifica o padrão de serial do PS2 ex: SLES-55373
    match(raw_serial, /[A-Z]{4}-[0-9]{5}/)
    if (RSTART > 0) {
        serial = substr(raw_serial, RSTART, RLENGTH)
        # Pegar linha do nome
        getline
        name = $0
        print serial "|" name
    }
}')

# ----------- RESULTADOS -----------

echo "🔽 1. FALHAS REAIS (Faltando e não encontrei nada na pasta Capas):"
if [ ${#REPORT_FALTANTE[@]} -eq 0 ]; then
    echo "   ✅ Nenhuma falha real detetactada."
else
    for item in "${REPORT_FALTANTE[@]}"; do echo "   $item"; done
fi
echo ""

echo "🔽 2. FALSOS NEGATIVOS (A imagem existe na pasta 'Capas', mas o PCSX2 não está usando):"
if [ ${#REPORT_FALSO_NEGATIVO[@]} -eq 0 ]; then
    echo "   ✅ Nenhum arquivo desvinculado detectado."
else
    for item in "${REPORT_FALSO_NEGATIVO[@]}"; do echo "   $item"; done
    echo "   DICA: Formatos como .webp, nomes com falta de permissão ou atalhos esquecidos geram falsos negativos."
fi
echo ""

echo "🔽 3. FALSOS POSITIVOS / AVISOS (O atalho existe no PCSX2, mas aponta para um nome de arquivo diferente do jogo):"
if [ ${#REPORT_FALSO_POSITIVO[@]} -eq 0 ]; then
    echo "   ✅ Zero Falsos Positivos! Suas imagens são 100% fieis às suas Seriais!"
else
    for item in "${REPORT_FALSO_POSITIVO[@]}"; do echo "   $item"; done
    echo "   DICA: Falsos positivos geram o bug visual (como a capa do Resident Evil com a imagem errada)."
fi
echo ""

echo "============================================================"
echo "Auditoria Mestra finalizada. Regra: Nenhuma imagem apagada."
echo "============================================================"
