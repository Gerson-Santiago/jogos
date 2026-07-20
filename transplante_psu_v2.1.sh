#!/usr/bin/env bash
# =============================================================================
# PROTOCOLO DE TRANSPLANTE PSU v2.1 — Shadow of the Colossus (PAL Recovery)
# Incidente: SOTC-53326-C12 | CRC: 0F0C4A9C
# Autor: Antigravity AI Engineering Suite
# Data: 2026-04-04
# =============================================================================
# USO: bash transplante_psu_v2.1.sh
# REQUISITO: mymcplusplus instalado em /tmp/mymc-env/
# =============================================================================

set -euo pipefail

# --- CONFIGURAÇÃO DE PATHS ---
LAB_DIR="/mnt/jogos/lab"
LOG_DIR="/mnt/jogos/doc/debugMemoryCard12-13"
SOURCE_MC="${LAB_DIR}/final_test.ps2"
TARGET_MC="/mnt/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/memcards/Mcd002.ps2"
BACKUP_DIR="/mnt/jogos/pcsx2-userdata/BACKUP_SOTC_20260404_095412/memcards"
PNACH_FILE="/mnt/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/cheats/SCES-53326_0F0C4A9C.pnach"
MYMC="/tmp/mymc-env/bin/python3 -m mymcplusplus"

NTSC_DIR="BASCUS-97472nico"
PAL_DIR="BESCES-53326nico"
PSU_NTSC="${LAB_DIR}/${NTSC_DIR}.psu"
PSU_PAL="${LAB_DIR}/${PAL_DIR}.psu"

# --- HASHES DE REFERÊNCIA (MD5 extraídos em sessão anterior) ---
MD5_MCD001_REF="a59ea74e996438a65c1a6696feced542"
MD5_MCD002_REF="914e26ce1e2661e14d39d87310d3cdd3"

# --- CONFIGURAÇÃO DE LOG (stdout e stderr separados e timestampados) ---
mkdir -p "${LOG_DIR}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_STDOUT="${LOG_DIR}/transplante_v2_${TIMESTAMP}.log"
LOG_STDERR="${LOG_DIR}/transplante_v2_${TIMESTAMP}_errors.log"

# Redirecionar: stdout -> tee (terminal + log), stderr -> arquivo separado
exec > >(tee -a "${LOG_STDOUT}") 2>"${LOG_STDERR}"

# Função de separador visual
sep() { echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }

# Função de validação de hash MD5
check_md5() {
    local file="$1"
    local expected="$2"
    local label="$3"
    local actual
    actual=$(md5sum "$file" | awk '{print $1}')
    if [[ "$actual" == "$expected" ]]; then
        echo "  [OK] ${label}: ${actual}"
    else
        echo "  [WARN] ${label} — Hash divergente!"
        echo "         Esperado: ${expected}"
        echo "         Atual:    ${actual}"
    fi
}

# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  TRANSPLANTE PSU v2.1 — SOTC PAL Recovery           ║"
echo "║  $(date)                     ║"
echo "╚══════════════════════════════════════════════════════╝"

# =============================================================================
sep
echo "[FASE 1/6] AUDITORIA PRÉ-OPERAÇÃO"
sep

echo ""
echo ">> 1.1 Verificando integridade do backup de referência..."
check_md5 "${BACKUP_DIR}/Mcd001.ps2" "${MD5_MCD001_REF}" "Mcd001 (backup)"
check_md5 "${BACKUP_DIR}/Mcd002.ps2" "${MD5_MCD002_REF}" "Mcd002 (backup)"

echo ""
echo ">> 1.2 Conteúdo atual do PNACH de cheats:"
echo "   Path: ${PNACH_FILE}"
echo "   -------"
cat "${PNACH_FILE}" | sed 's/^/   /'
echo "   -------"

echo ""
echo ">> 1.3 Inventário de arquivos .psu residuais no LAB:"
ls -lah "${LAB_DIR}"/*.psu 2>/dev/null && echo "   [WARN] Arquivos residuais encontrados — serão removidos na Fase 2." \
    || echo "   [OK] Nenhum .psu residual."

echo ""
echo ">> 1.4 Estado atual do Memory Card de destino (Slot 2):"
${MYMC} "${TARGET_MC}" dir || echo "   [INFO] Memory Card vazio ou sem saves legíveis."

echo ""
echo ">> 1.5 Verificando Memory Card de origem (final_test.ps2):"
${MYMC} "${SOURCE_MC}" dir

# =============================================================================
sep
echo "[FASE 2/6] LIMPEZA DO AMBIENTE DE TRABALHO"
sep

echo ""
echo ">> Removendo todos os arquivos .psu do LAB para evitar 'File exists'..."
# Remove explicitamente os nomes que o mymcplusplus pode gerar no CWD
rm -fv "${LAB_DIR}/${NTSC_DIR}.psu" \
        "${LAB_DIR}/${PAL_DIR}.psu" \
        "${LAB_DIR}/MASTER_NTSC.psu" \
        "${LAB_DIR}/MASTER_NTSC_SAVE.psu" \
        "${LAB_DIR}/save_original_ntsc.psu" \
        "${LAB_DIR}/clean_transplant/${NTSC_DIR}.psu" 2>/dev/null \
    || echo "   [OK] Nenhum arquivo a remover."

echo "   LAB limpo."

# =============================================================================
sep
echo "[FASE 3/6] EXPORT PSU ECC-SAFE (NTSC)"
sep

echo ""
echo ">> Exportando save NTSC de '${SOURCE_MC}'..."
echo "   NOTA: mymcplusplus ignora o 3º argumento como nome de arquivo."
echo "         O output real será: ${PSU_NTSC} (CWD + nome interno do save)"

# Mudar para LAB_DIR para controlar o CWD de output
cd "${LAB_DIR}"
${MYMC} "${SOURCE_MC}" export "${NTSC_DIR}"

# Verificar se o arquivo foi gerado corretamente
if [[ -f "${PSU_NTSC}" ]]; then
    echo "   [OK] PSU gerado com sucesso."
    ls -lah "${PSU_NTSC}"
    MD5_PSU_NTSC=$(md5sum "${PSU_NTSC}" | awk '{print $1}')
    echo "   MD5 (PSU NTSC original): ${MD5_PSU_NTSC}"
else
    echo "   [ERRO FATAL] Arquivo PSU não encontrado após export."
    echo "                Abortando. Verifique o Memory Card de origem."
    exit 1
fi

# =============================================================================
sep
echo "[FASE 4/6] PATCH DE HEADER PSU — NTSC -> PAL"
sep

echo ""
echo ">> Renomeando diretório interno: '${NTSC_DIR}' -> '${PAL_DIR}'..."
echo "   Comprimento NTSC: ${#NTSC_DIR} | Comprimento PAL: ${#PAL_DIR}"
echo "   [Comprimentos iguais — substituição byte-a-byte segura, sem padding necessário]"

python3 - <<PYEOF
import shutil, hashlib, sys

src = "${PSU_NTSC}"
dst = "${PSU_PAL}"
ntsc = b"${NTSC_DIR}"
pal  = b"${PAL_DIR}"

# Validação de comprimento antes de qualquer operação
if len(ntsc) != len(pal):
    print(f"  [ERRO] Comprimentos divergentes: {len(ntsc)} vs {len(pal)}. Abortando.")
    sys.exit(1)

# Copiar o PSU original preservando metadados
shutil.copy2(src, dst)

with open(dst, "rb") as f:
    data = f.read()

# Contar e reportar ocorrências antes do patch
count = data.count(ntsc)
print(f"  Ocorrências de '{ntsc.decode()}' no PSU: {count}")

if count == 0:
    print("  [ERRO] String NTSC não encontrada no PSU. Arquivo pode estar corrompido.")
    sys.exit(1)

# Substituição (todos os blocos: dir entry, file entries, icon.sys refs)
patched = data.replace(ntsc, pal)

with open(dst, "wb") as f:
    f.write(patched)

md5_result = hashlib.md5(patched).hexdigest()
print(f"  [OK] PSU PAL gerado: {dst}")
print(f"  MD5 (PSU PAL patched): {md5_result}")

# Verificação de sanidade: confirmar que o NTSC id não existe mais
remaining = patched.count(ntsc)
if remaining > 0:
    print(f"  [WARN] Ainda existem {remaining} ocorrências residuais do ID NTSC.")
else:
    print(f"  [OK] Nenhuma ocorrência NTSC residual. Patch limpo.")
PYEOF

echo ""
echo ">> Verificação pós-patch:"
ls -lah "${PSU_PAL}"

# =============================================================================
sep
echo "[FASE 5/6] IMPORT NO MEMORY CARD 2 (PAL)"
sep

echo ""
echo ">> Estado do Slot 2 antes do import:"
${MYMC} "${TARGET_MC}" dir || echo "   [INFO] Vazio."

echo ""
echo ">> Importando '${PSU_PAL}' -> '${TARGET_MC}'..."
${MYMC} "${TARGET_MC}" import "${PSU_PAL}"

echo "   [OK] Import concluído."

# =============================================================================
sep
echo "[FASE 6/6] VALIDAÇÃO PÓS-TRANSPLANTE"
sep

echo ""
echo ">> 6.1 Inventário do Memory Card 2 pós-transplante:"
${MYMC} "${TARGET_MC}" dir

echo ""
echo ">> 6.2 Hash MD5 do Slot 2 (registrar para auditoria futura):"
md5sum "${TARGET_MC}"

echo ""
echo ">> 6.3 Verificando se o save PAL está presente:"
if ${MYMC} "${TARGET_MC}" dir 2>/dev/null | grep -q "${PAL_DIR}"; then
    echo "   [OK] Diretório '${PAL_DIR}' confirmado no Slot 2."
else
    echo "   [WARN] Diretório PAL não localizado. Verificar manualmente."
fi

echo ""
echo ">> 6.4 Lembrete pós-operação crítico:"
echo "   ┌─────────────────────────────────────────────────────┐"
echo "   │  PNACH 'always-on' (modo 1) ativo para C13.        │"
echo "   │  Após vencer o Colossus 13 e SALVAR no save point, │"
echo "   │  REMOVA ou comente a linha patch= do arquivo:      │"
echo "   │  ${PNACH_FILE}"
echo "   │  Caso contrário o radar trava em C13 para os       │"
echo "   │  Colossos 14, 15 e 16.                             │"
echo "   └─────────────────────────────────────────────────────┘"

# =============================================================================
sep
echo "PROTOCOLO v2.1 CONCLUÍDO — $(date)"
echo "Log stdout: ${LOG_STDOUT}"
echo "Log stderr: ${LOG_STDERR}"
sep
echo ""