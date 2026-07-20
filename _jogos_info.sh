#!/bin/bash

# ==============================================================================
# SCRIPT DE INFORMAÇÕES DE JOGOS (PS2) - PARA BUSCA DE TEXTURAS
# ==============================================================================

# Cores para o terminal
AMARELO='\033[1;33m'
VERDE='\033[0;32m'
AZUL='\033[0;34m'
CIANO='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Caminhos importantes
DIRETORIO_ISOS="/mnt/jogos/PS2/ISOs"
CACHE_PCSX2="/mnt/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/cache/gamelist.cache"
LOG_PCSX2="/mnt/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/logs/emulog.txt"

clear
echo -e "${AZUL}==============================================================================${RESET}"
echo -e "${CIANO}                 LISTA DE JOGOS E INFORMAÇÕES PARA TEXTURAS                  ${RESET}"
echo -e "${AZUL}==============================================================================${RESET}"
echo ""

# Cabeçalho da Tabela
printf "${AMARELO}%-35s | %-12s | %-12s | %-30s${RESET}\n" "ARQUIVO" "SERIAL ID" "CRC (LOG)" "DESCRIÇÃO / NOME LIMPO"
echo "----------------------------------------------------------------------------------------------------------------"

# Itera sobre os arquivos de jogos
ls -1 "$DIRETORIO_ISOS" | grep -Ei "\.(iso|chd|gz|cso)$" | while read -r ARQUIVO; do
    
    # 1. Tentar extrair o SERIAL do nome do arquivo (procurando o padrão [SXXX-XXXXX])
    SERIAL=$(echo "$ARQUIVO" | grep -oP "[A-Z]{4}-[0-9]{5}" | head -n 1)
    
    # Se não encontrar no nome, buscar no cache do PCSX2 (usando strings para ver o binário)
    if [ -z "$SERIAL" ]; then
        # Busca o trecho que contém o nome do arquivo no cache (usa -F para tratar como string literal)
        SERIAL=$(strings "$CACHE_PCSX2" | grep -F -A 3 "$ARQUIVO" | grep -oP "[A-Z]{4}-[0-9]{5}" | head -n 1)
    fi

    # Se ainda for vazio, e for ISO, tentar via 7z
    if [ -z "$SERIAL" ] && [[ "$ARQUIVO" == *.iso ]]; then
        SERIAL_RAW=$(7z l "$DIRETORIO_ISOS/$ARQUIVO" 2>/dev/null | grep -oP "[A-Z]{4}_[0-9]{3}\.[0-9]{2}" | head -n 1)
        if [ -n "$SERIAL_RAW" ]; then
            SERIAL=$(echo "$SERIAL_RAW" | sed 's/_/-/' | sed 's/\.//')
        fi
    fi

    # 2. Buscar o NOME REAL no cache (se o serial foi achado)
    NOME_REAL="---"
    if [ -n "$SERIAL" ] && [ -f "$CACHE_PCSX2" ]; then
        # Tenta pegar a linha que descreve o jogo no cache
        # Usamos -F no grep -v para evitar erros com colchetes nos nomes
        NOME_REAL=$(strings "$CACHE_PCSX2" | grep -F -A 5 "$ARQUIVO" | grep -F -v "$ARQUIVO" | grep -v "/" | grep -v "$SERIAL" | head -n 1)
    fi

    # 3. Buscar o CRC (se o jogo foi rodado e está no log)
    # No log o formato costuma ser Game CRC = 0x... ou apenas CRC: ...
    # Procuramos especificamente por 8 caracteres hexadecimais após "Game CRC =" ou "CRC: "
    CRC=$(grep -i "Serial: $SERIAL" -A 2 "$LOG_PCSX2" 2>/dev/null | grep -oP "CRC: [A-F0-9]{8}" | awk '{print $2}' | tail -n 1)
    
    if [ -z "$CRC" ]; then
        # Segunda tentativa: busca por "Game CRC = 0xXXXXXXXX" ou "Game CRC = XXXXXXXX"
        CRC=$(grep -i "Game CRC =" "$LOG_PCSX2" 2>/dev/null | grep -oP "Game CRC = (0x)?\K[A-F0-9]{8}" | tail -n 1)
    fi
    if [ -z "$CRC" ]; then CRC="[n/a]"; fi

    # Truncar o nome do arquivo para caber na tabela se necessário
    ARQ_TABLE="${ARQUIVO:0:32}"
    if [ "${#ARQUIVO}" -gt 32 ]; then ARQ_TABLE="${ARQ_TABLE}..."; fi

    # Formatação de saída (cor verde se encontrou serial, amarelo se não)
    if [ -n "$SERIAL" ]; then
        printf "${RESET}%-35s | ${VERDE}%-12s${RESET} | ${MAGENTA}%-12s${RESET} | %-30s\n" "$ARQ_TABLE" "$SERIAL" "$CRC" "$NOME_REAL"
    else
        printf "${RESET}%-35s | ${AMARELO}%-12s${RESET} | ${MAGENTA}%-12s${RESET} | %-30s\n" "$ARQ_TABLE" "MISTÉRIO" "$CRC" "---"
    fi

done

echo ""
echo -e "${AZUL}==============================================================================${RESET}"
echo -e "${AMARELO}DICA:${RESET} Pesquise no Google: ${CIANO} \"[SERIAL-ID] texture pack pcsx2\"${RESET}"
echo -e "Exemplo: ${CIANO} \"SLUS-21065 texture pack pcsx2\"${RESET}"
echo -e "${AZUL}==============================================================================${RESET}"
