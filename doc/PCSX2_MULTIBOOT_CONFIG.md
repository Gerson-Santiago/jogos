# 🎮 PCSX2 — Guia de Configuração (Debian + Flatpak)

Este documento registra como o **PCSX2** está configurado com dados em `/mnt/jogos/` no **Debian 13 (Trixie)**, com o emulador instalado via Flatpak.

---

## 1. O Mistério das Capas Invisíveis (Flatpak vs Nativo)

O PCSX2 via Flatpak roda dentro de um **sandbox de segurança**. Isso cria um problema específico com capas:

- Quando a pasta `covers/` tem um **link simbólico** apontando para `/mnt/jogos/PS2/Capas/`, o PCSX2 tenta seguir esse caminho, bate no muro do sandbox e ignora o arquivo — a capa aparece genérica (azul).

**💡 A Solução: Hard Links**

Em vez de symlinks, as capas são criadas como **hard links** na pasta `covers/`. Um hard link é indistinguível de um arquivo real para o sistema operacional, portanto passa pela trava do sandbox sem problemas.

O script [`apply_covers_hardlinks.sh`](/mnt/jogos/apply_covers_hardlinks.sh) automatiza esse processo.

---

## 2. A Nomenclatura Perfeita: Capas vs Seriais

Para o emulador identificar automaticamente qual capa pertence a qual jogo:

1. **A Fonte da Verdade:** `/mnt/jogos/PS2/Capas/`
   Capas salvas com nomes humanos. Ex: `Nome do Jogo [SERIAL].jpg`.

2. **O Que o Emulador Exige:** `covers/`
   O PCSX2 lê apenas a **SERIAL** como nome de arquivo.
   A imagem deve se chamar exatamente `SLES-53702.jpg` — nada mais.

3. **Formatos Validados:**
   Use apenas `.jpg` autênticos. Arquivos `.webp` renomeados como `.jpg` não são reconhecidos corretamente pelo PCSX2 nem pelos scripts de auditoria.

---

## 3. Paths de Configuração

Todos os dados do PCSX2 estão centralizados em `/mnt/jogos/`:

| Dado | Caminho |
|---|---|
| ISOs | `/mnt/jogos/PS2/ISOs/` |
| Capas (fonte) | `/mnt/jogos/PS2/Capas/` |
| Texturas HD | `/mnt/jogos/PS2/Texturas/` |
| Userdata Flatpak | `/mnt/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/` |
| Memory Cards | `.../PCSX2/memcards/` |
| Saves States | `.../PCSX2/sstates/` |
| Cheats (PNACH) | `.../PCSX2/cheats/` |
| Texturas instaladas | `.../PCSX2/textures/` |

O Flatpak acessa `/mnt/jogos` via permissão configurada — verificar com Flatseal se necessário.

---

## 4. Scripts de Manutenção

| Script | Função |
|---|---|
| `apply_covers_hardlinks.sh` | Recria todas as capas como hardlinks em `covers/` |
| `_capas_verificar.sh` | Auditoria: falhas reais, falsos negativos e positivos |
| `_texturas_verificar.sh` | Diagnóstico completo do sistema de texturas HD |
| `_jogos_info.sh` | Tabela com Serial + CRC de todos os jogos |
| `launch_pcsx2.sh` | Launcher com correção de permissões antes de abrir |

---

**Fim de Documentação — atualizado em 2026-07-20**
