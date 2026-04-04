#!/bin/bash

# Cores para o output
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m'

# Caminhos importantes
INI_FILE="/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/inis/PCSX2.ini"
DIR_TEXTURAS_DISPONIVEIS="/media/jogos/PS2/Texturas"
DIR_TEXTURAS_PCSX2="/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/textures"

echo -e "${AZUL}============================================${NC}"
echo -e "${AZUL}      VERIFICADOR DE TEXTURAS - PCSX2       ${NC}"
echo -e "${AZUL}============================================${NC}"
echo ""

# 1. VERIFICAR SE AS TEXTURAS ESTÃO ATIVAS NO PCSX2
echo -e "1. Status das Texturas no PCSX2:"
if [ -f "$INI_FILE" ]; then
    # Busca pela linha LoadTextureReplacements ignorando maiúsculas/minúsculas
    STATUS_ATIVO=$(grep -i "^LoadTextureReplacements \?=" "$INI_FILE" | awk -F'=' '{print $2}' | tr -d ' ')
    
    if [ "$STATUS_ATIVO" == "true" ]; then
        echo -e "   [ ${VERDE}ATIVAS${NC} ] (LoadTextureReplacements = true)"
    else
        echo -e "   [ ${VERMELHO}INATIVAS${NC} ] (LoadTextureReplacements = false ou não configurado)"
    fi
else
    echo -e "   [ ${VERMELHO}ERRO${NC} ] Arquivo PCSX2.ini não encontrado em $INI_FILE"
fi
echo ""

# 2. VERIFICAR TEXTURAS DISPONÍVEIS NA PASTA DE DOWNLOAD
echo -e "2. Pacotes de Texturas Disponíveis em $DIR_TEXTURAS_DISPONIVEIS:"
if [ -d "$DIR_TEXTURAS_DISPONIVEIS" ]; then
    # Conta subdiretórios ou arquivos .rar/.zip
    PACOTES=$(find "$DIR_TEXTURAS_DISPONIVEIS" -mindepth 1 -maxdepth 1 -type d | wc -l)
    
    if [ "$PACOTES" -gt 0 ]; then
        echo -e "   Encontrado(s) ${VERDE}$PACOTES${NC} pacote(s):"
        # Lista as pastas
        find "$DIR_TEXTURAS_DISPONIVEIS" -mindepth 1 -maxdepth 1 -type d | while read PACOTE; do
            NOME_PACOTE=$(basename "$PACOTE")
            echo -e "   - ${AMARELO}$NOME_PACOTE${NC}"
        done
    else
        echo -e "   ${AMARELO}Nenhum pacote de textura encontrado (pastas isoladas).${NC}"
    fi
else
    echo -e "   [ ${VERMELHO}ERRO${NC} ] Diretório não existe."
fi
echo ""

# 3. VERIFICAR TEXTURAS INSTALADAS (ATIVAS/RECONHECIDAS POR SERIAL) NO PCSX2
echo -e "3. Texturas instaladas (pastas de jogos) no PCSX2:"
if [ -d "$DIR_TEXTURAS_PCSX2" ]; then
    INSTALADAS=$(find "$DIR_TEXTURAS_PCSX2" -mindepth 1 -maxdepth 1 -type d | wc -l)
    
    if [ "$INSTALADAS" -gt 0 ]; then
        echo -e "   Encontrada(s) textura(s) para ${VERDE}$INSTALADAS${NC} jogo(s):"
        find "$DIR_TEXTURAS_PCSX2" -mindepth 1 -maxdepth 1 -type d | while read JOGO; do
            SERIAL=$(basename "$JOGO")
            
            # Verifica se tem a pasta 'replacements' e alguns arquivos lá dentro
            if [ -d "$JOGO/replacements" ]; then
                QTD_ARQ=$(find "$JOGO/replacements" -type f | wc -l)
                if [ "$QTD_ARQ" -gt 0 ]; then
                    echo -e "   - ${VERDE}$SERIAL${NC} (${QTD_ARQ} arquivos de textura)"
                else
                    echo -e "   - ${AMARELO}$SERIAL${NC} (pasta 'replacements' existe, mas está VAZIA)"
                fi
            else
                echo -e "   - ${AMARELO}$SERIAL${NC} (pasta criada, mas SEM a subpasta 'replacements')"
            fi
        done
    else
        echo -e "   ${AMARELO}Nenhuma textura de jogo instalada no momento.${NC}"
    fi
else
    echo -e "   [ ${VERMELHO}ERRO${NC} ] Diretório não existe ($DIR_TEXTURAS_PCSX2)."
fi

echo ""

# 4. VERIFICAÇÃO DE EXECUÇÃO REAL (LOG DO EMULADOR)
echo -e "4. Verificação Prática no Emulador (Log de Execução):"
LOG_FILE="/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/logs/emulog.txt"
if [ -f "$LOG_FILE" ]; then
    # Busca no log se o emulador registrou algum evento de textura
    LOG_TEXTURA=$(grep -iE "replacement texture|custom textures" "$LOG_FILE" | tail -n 1)
    if [ -n "$LOG_TEXTURA" ]; then
        echo -e "   [ ${VERDE}ATIVIDADE COMPROVADA${NC} ] O PCSX2 injetou/leu texturas customizadas na última sessão!"
        echo -e "   Último evento no log: ${AMARELO}$LOG_TEXTURA${NC}"
        echo -e "   => Isso é a ${VERDE}PROVA REAL${NC} de que as texturas estão no lugar certo e sendo puxadas para a tela."
    else
        echo -e "   [ ${AMARELO}SEM PROVAS AINDA${NC} ] Nenhum registro de uso de texturas (ou falhas) no log desta sessão."
        echo -e "   => Jogue no Modo Hardware (se sumiu, aperte F9 até voltar ao normal) e rode este script de novo."
    fi
else
    echo -e "   [ ${VERMELHO}NÃO AVALIADO${NC} ] Log não encontrado."
fi

echo ""
echo -e "${AZUL}============================================${NC}"
