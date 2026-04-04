#!/usr/bin/env python3
"""
═════════════════════════════════════════════════════════════════════════════
PROTOCOLO DE TRANSPLANTE PSU v3.0 — Shadow of the Colossus (PAL Recovery)
═════════════════════════════════════════════════════════════════════════════
Incidente: SOTC-53326-C12 (Colossus 12 Bug)
Data: 04/04/2026
Engenheiro: Antigravity AI

OBJETIVO:
  Transplante cirúrgico de save NTSC (BASCUS-97472nico) para PAL (BESCES-53326nico)
  via PSU patching + importação no Memory Card Slot 2.

REQUISITOS:
  - mymcplusplus >= 0.5.0
  - Python 3.7+

USO:
  python3 transplante_sotc_v3.py
═════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
import hashlib
import shutil
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Optional, Tuple

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURAÇÃO
# ─────────────────────────────────────────────────────────────────────────────

CONFIG = {
    "LAB_DIR": "/media/jogos/lab",
    "LOG_DIR": "/media/jogos/doc/debugMemoryCard12-13",
    "SOURCE_MC": "/media/jogos/lab/final_test.ps2",
    "TARGET_MC": "/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/memcards/Mcd002.ps2",
    "BACKUP_DIR": "/media/jogos/pcsx2-userdata/BACKUP_SOTC_20260404_095412/memcards",
    "PNACH_FILE": "/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/cheats/SCES-53326_0F0C4A9C.pnach",
    "NTSC_ID": "BASCUS-97472nico",
    "PAL_ID": "BESCES-53326nico",
    "MD5_MCD001_REF": "a59ea74e996438a65c1a6696feced542",
    "MD5_MCD002_REF": "914e26ce1e2661e14d39d87310d3cdd3",
}

# ─────────────────────────────────────────────────────────────────────────────
# LOGGER (cores para terminal)
# ─────────────────────────────────────────────────────────────────────────────

class Logger:
    """Logger com cores ANSI para terminal."""
    
    RESET = "\033[0m"
    BOLD = "\033[1m"
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    CYAN = "\033[96m"
    
    def __init__(self, log_file: Optional[str] = None):
        self.log_file = log_file
        if log_file:
            Path(log_file).parent.mkdir(parents=True, exist_ok=True)
    
    def _write(self, msg: str) -> None:
        """Escreve em stdout e arquivo de log."""
        print(msg)
        if self.log_file:
            with open(self.log_file, "a") as f:
                # Remove códigos ANSI ao escrever no arquivo
                clean_msg = self._strip_ansi(msg)
                f.write(clean_msg + "\n")
    
    @staticmethod
    def _strip_ansi(text: str) -> str:
        """Remove códigos de cor ANSI."""
        import re
        return re.sub(r"\033\[[0-9;]*m", "", text)
    
    def header(self, title: str) -> None:
        msg = f"\n{self.BOLD}{self.CYAN}{'═' * 78}\n{title}\n{'═' * 78}{self.RESET}"
        self._write(msg)
    
    def section(self, title: str) -> None:
        msg = f"\n{self.BOLD}{self.BLUE}[{title}]{self.RESET}"
        self._write(msg)
    
    def ok(self, msg: str) -> None:
        self._write(f"{self.GREEN}✓ {msg}{self.RESET}")
    
    def warn(self, msg: str) -> None:
        self._write(f"{self.YELLOW}⚠ {msg}{self.RESET}")
    
    def error(self, msg: str) -> None:
        self._write(f"{self.RED}✗ {msg}{self.RESET}")
    
    def info(self, msg: str) -> None:
        self._write(f"{self.CYAN}ℹ {msg}{self.RESET}")
    
    def plain(self, msg: str) -> None:
        self._write(msg)

# ─────────────────────────────────────────────────────────────────────────────
# UTILITÁRIOS
# ─────────────────────────────────────────────────────────────────────────────

def get_md5(filepath: str) -> str:
    """Calcula MD5 de um arquivo."""
    md5_hash = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            md5_hash.update(chunk)
    return md5_hash.hexdigest()

def run_mymc(cmd: list) -> Tuple[int, str, str]:
    """Executa comando mymc e retorna (return_code, stdout, stderr)."""
    try:
        result = subprocess.run(
            ["python3", "-m", "mymcplusplus"] + cmd,
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.returncode, result.stdout, result.stderr
    except FileNotFoundError:
        return 127, "", "mymcplusplus não encontrado"
    except subprocess.TimeoutExpired:
        return 124, "", "Timeout na execução"

def validate_path(path: str, must_exist: bool = True) -> bool:
    """Valida se um caminho existe."""
    exists = os.path.exists(path)
    if must_exist and not exists:
        return False
    return True

# ─────────────────────────────────────────────────────────────────────────────
# FASES DO TRANSPLANTE
# ─────────────────────────────────────────────────────────────────────────────

class TransplanteSOTC:
    """Orquestrador do protocolo de transplante PSU."""
    
    def __init__(self, logger: Logger):
        self.logger = logger
        self.config = CONFIG
        self.psu_ntsc = f"{self.config['LAB_DIR']}/{self.config['NTSC_ID']}.psu"
        self.psu_pal = f"{self.config['LAB_DIR']}/{self.config['PAL_ID']}.psu"
    
    def run(self) -> bool:
        """Executa todo o protocolo."""
        try:
            self.logger.header(
                "PROTOCOLO DE TRANSPLANTE PSU v3.0\n"
                f"Shadow of the Colossus PAL Recovery — {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            )
            
            # Fases
            if not self._fase_auditoria():
                return False
            if not self._fase_limpeza():
                return False
            if not self._fase_export_psu():
                return False
            if not self._fase_patch_psu():
                return False
            if not self._fase_import_psu():
                return False
            if not self._fase_validacao():
                return False
            
            self.logger.section("PROTOCOLO CONCLUÍDO COM SUCESSO")
            self.logger.ok("Seu save está pronto no Slot 2!")
            self.logger.info("Próximas ações:")
            self.logger.plain(
                f"\n  1. No PCSX2: BIOS > Desmarque 'Fast Boot'\n"
                f"  2. Carregue Shadow of the Colossus (ISO)\n"
                f"  3. Carregue o save do SLOT 2\n"
                f"  4. Colossus 12 (Cenobite) deve aparecer no radar da espada\n\n"
            )
            return True
        
        except Exception as e:
            self.logger.error(f"Erro crítico: {e}")
            return False
    
    def _fase_auditoria(self) -> bool:
        """FASE 1: Auditoria pré-operação."""
        self.logger.section("FASE 1/6: AUDITORIA PRÉ-OPERAÇÃO")
        
        # 1.1: Verificar backup
        self.logger.plain("\n>> 1.1 Verificando backups de referência...")
        mcd001_backup = f"{self.config['BACKUP_DIR']}/Mcd001.ps2"
        mcd002_backup = f"{self.config['BACKUP_DIR']}/Mcd002.ps2"
        
        if not validate_path(mcd001_backup):
            self.logger.warn(f"Backup Mcd001 não encontrado: {mcd001_backup}")
        else:
            md5 = get_md5(mcd001_backup)
            self.logger.ok(f"Mcd001 (backup): {md5}")
        
        if not validate_path(mcd002_backup):
            self.logger.warn(f"Backup Mcd002 não encontrado: {mcd002_backup}")
        else:
            md5 = get_md5(mcd002_backup)
            self.logger.ok(f"Mcd002 (backup): {md5}")
        
        # 1.2: Verificar Memory Card de origem
        self.logger.plain("\n>> 1.2 Memory Card de origem (final_test.ps2):")
        if not validate_path(self.config['SOURCE_MC']):
            self.logger.error(f"Arquivo não encontrado: {self.config['SOURCE_MC']}")
            return False
        
        rc, out, err = run_mymc([self.config['SOURCE_MC'], 'dir'])
        if rc == 0:
            self.logger.plain(out)
            self.logger.ok(f"Memory Card legível")
        else:
            self.logger.error(f"Falha ao ler Memory Card: {err}")
            return False
        
        # 1.3: Verificar Memory Card de destino
        self.logger.plain("\n>> 1.3 Memory Card de destino (Slot 2):")
        if not validate_path(self.config['TARGET_MC']):
            self.logger.warn(f"Card não existe yet: {self.config['TARGET_MC']} — será criado")
        else:
            self.logger.ok(f"Card existe: {self.config['TARGET_MC']}")
        
        # 1.4: Verificar PNACH
        self.logger.plain("\n>> 1.4 Arquivo PNACH para cheats:")
        if not validate_path(self.config['PNACH_FILE']):
            self.logger.warn(f"PNACH não encontrado: {self.config['PNACH_FILE']}")
        else:
            self.logger.ok(f"PNACH encontrado")
        
        return True
    
    def _fase_limpeza(self) -> bool:
        """FASE 2: Limpeza de arquivos residuais."""
        self.logger.section("FASE 2/6: LIMPEZA DO AMBIENTE")
        
        self.logger.plain(f"\n>> Removendo PSUs residuais de {self.config['LAB_DIR']}/...")
        
        removed = []
        for pattern in [self.psu_ntsc, self.psu_pal, 
                        f"{self.config['LAB_DIR']}/MASTER_*.psu",
                        f"{self.config['LAB_DIR']}/save_*.psu"]:
            if os.path.exists(pattern):
                try:
                    os.remove(pattern)
                    removed.append(pattern)
                    self.logger.ok(f"Removido: {pattern}")
                except Exception as e:
                    self.logger.warn(f"Falha ao remover {pattern}: {e}")
        
        if not removed:
            self.logger.ok("Nenhum arquivo residual encontrado")
        
        return True
    
    def _fase_export_psu(self) -> bool:
        """FASE 3: Exportar save NTSC em formato PSU."""
        self.logger.section("FASE 3/6: EXPORT PSU ECC-SAFE (NTSC)")
        
        self.logger.plain(f"\n>> Exportando '{self.config['NTSC_ID']}' para PSU...")
        self.logger.plain(f"   Origem: {self.config['SOURCE_MC']}")
        self.logger.plain(f"   Destino: {self.psu_ntsc}")
        
        # mymcplusplus export gera o arquivo no CWD com o nome interno
        os.chdir(self.config['LAB_DIR'])
        rc, out, err = run_mymc([self.config['SOURCE_MC'], 'export', self.config['NTSC_ID']])
        
        if rc != 0:
            self.logger.error(f"Falha na exportação: {err}")
            return False
        
        # Verificar se o arquivo foi criado
        if not os.path.exists(self.psu_ntsc):
            self.logger.error(f"PSU não foi gerado: {self.psu_ntsc}")
            return False
        
        filesize = os.path.getsize(self.psu_ntsc) / 1024
        md5 = get_md5(self.psu_ntsc)
        
        self.logger.ok(f"PSU gerado com sucesso")
        self.logger.plain(f"   Tamanho: {filesize:.1f} KB")
        self.logger.plain(f"   MD5: {md5}")
        
        return True
    
    def _fase_patch_psu(self) -> bool:
        """FASE 4: Patchear PSU — renomear NTSC ID para PAL ID."""
        self.logger.section("FASE 4/6: PATCH DE HEADER PSU (NTSC → PAL)")
        
        self.logger.plain(f"\n>> Renomeando ID interno...")
        self.logger.plain(f"   De: {self.config['NTSC_ID']}")
        self.logger.plain(f"   Para: {self.config['PAL_ID']}")
        self.logger.plain(f"   Comprimento: {len(self.config['NTSC_ID'])} → {len(self.config['PAL_ID'])}")
        
        if len(self.config['NTSC_ID']) != len(self.config['PAL_ID']):
            self.logger.error("Comprimentos divergentes! Abortando patch.")
            return False
        
        # Ler PSU original
        with open(self.psu_ntsc, 'rb') as f:
            data = f.read()
        
        ntsc_bytes = self.config['NTSC_ID'].encode('ascii')
        pal_bytes = self.config['PAL_ID'].encode('ascii')
        
        # Contar ocorrências
        count = data.count(ntsc_bytes)
        self.logger.plain(f"\n   Ocorrências de '{self.config['NTSC_ID']}': {count}")
        
        if count == 0:
            self.logger.error("ID NTSC não encontrado no PSU! Arquivo pode estar corrompido.")
            return False
        
        # Patchear
        patched = data.replace(ntsc_bytes, pal_bytes)
        
        # Verificar se eliminou todas
        remaining = patched.count(ntsc_bytes)
        if remaining > 0:
            self.logger.warn(f"{remaining} ocorrências residuais de NTSC após patch")
        else:
            self.logger.ok(f"Nenhuma ocorrência residual — patch limpo")
        
        # Escrever PSU patcheado
        with open(self.psu_pal, 'wb') as f:
            f.write(patched)
        
        md5_pal = hashlib.md5(patched).hexdigest()
        filesize = os.path.getsize(self.psu_pal) / 1024
        
        self.logger.ok(f"PSU PAL gerado")
        self.logger.plain(f"   Arquivo: {self.psu_pal}")
        self.logger.plain(f"   Tamanho: {filesize:.1f} KB")
        self.logger.plain(f"   MD5: {md5_pal}")
        
        return True
    
    def _fase_import_psu(self) -> bool:
        """FASE 5: Importar PSU patcheado no Memory Card Slot 2."""
        self.logger.section("FASE 5/6: IMPORT NO MEMORY CARD 2 (SLOT 2)")
        
        # Deletar save antigo do Slot 2 (se existir)
        self.logger.plain(f"\n>> Removendo save antigo do Slot 2...")
        rc, out, err = run_mymc([self.config['TARGET_MC'], 'dir'])
        
        if rc == 0 and self.config['PAL_ID'] in out:
            self.logger.plain(f"   Encontrado '{self.config['PAL_ID']}' — removendo...")
            rc_del, _, err_del = run_mymc([self.config['TARGET_MC'], 'delete', self.config['PAL_ID']])
            if rc_del == 0:
                self.logger.ok(f"Save antigo removido")
            else:
                self.logger.warn(f"Falha ao remover: {err_del}")
        else:
            self.logger.ok(f"Nenhum save antigo encontrado")
        
        # Importar PSU patcheado
        self.logger.plain(f"\n>> Importando '{self.config['PAL_ID']}' no Slot 2...")
        os.chdir(self.config['LAB_DIR'])
        rc, out, err = run_mymc([self.config['TARGET_MC'], 'import', self.psu_pal])
        
        if rc != 0:
            self.logger.error(f"Falha na importação: {err}")
            return False
        
        self.logger.ok(f"Import concluído")
        return True
    
    def _fase_validacao(self) -> bool:
        """FASE 6: Validação pós-transplante."""
        self.logger.section("FASE 6/6: VALIDAÇÃO PÓS-TRANSPLANTE")
        
        # 6.1: Listar save no Slot 2
        self.logger.plain(f"\n>> 6.1 Inventário do Memory Card Slot 2:")
        rc, out, err = run_mymc([self.config['TARGET_MC'], 'dir'])
        
        if rc != 0:
            self.logger.error(f"Falha ao ler Card: {err}")
            return False
        
        self.logger.plain(out)
        
        # 6.2: Verificar se save PAL está presente
        if self.config['PAL_ID'] in out:
            self.logger.ok(f"Save '{self.config['PAL_ID']}' confirmado no Slot 2!")
        else:
            self.logger.warn(f"Save PAL não encontrado — verificar manualmente")
            return False
        
        # 6.3: Hash do Card
        self.logger.plain(f"\n>> 6.2 MD5 do Memory Card Slot 2:")
        md5_card = get_md5(self.config['TARGET_MC'])
        self.logger.plain(f"   {md5_card}")
        
        return True

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

def main():
    """Função principal."""
    # Setup logger
    log_file = f"{CONFIG['LOG_DIR']}/transplante_v3_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    logger = Logger(log_file)
    
    # Executar protocolo
    transplante = TransplanteSOTC(logger)
    success = transplante.run()
    
    if success:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
