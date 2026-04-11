# 📊 Relatório de Auditoria: ISOs vs Seriais vs Capas

Este relatório detalha a saúde da sua biblioteca de jogos no PCSX2, cruzando os nomes dos arquivos ISO com as Seriais extraídas e as Capas disponíveis.

## 1. Mapeamento ISO -> Serial -> Capa
Para que o PCSX2 mostre a capa, ele precisa que o arquivo dentro da pasta `covers/` tenha o nome da **Serial** (ex: `SLUS-20946.jpg`). 

| ISO do Jogo | Serial Reconhecida | Status da Capa | Arquivo de Origem em /Capas/ |
|:--- |:--- |:--- |:--- |
| Castlevania - Curse of Darkness | **SLES-53755** | ✅ OK | `Castlevania - Curse of Darkness [SLES-53755].jpg` |
| Castlevania - Lament of Innocence | **SLES-52118** | ✅ OK | `Castlevania - Lament of Innocence [SLES-52118].jpg` |
| Crash Nitro Kart | **SLES-51511** | ✅ OK | `Crash Nitro Kart [SLES-51511].jpg` |
| FIFA Street 1 | **SLES-53064** | ✅ OK | `FIFA Street 1 [SLES-53064].jpg` |
| FIFA Street 2 | **SLES-53797** | ✅ OK | `FIFA Street 2 [SLES-53797].jpg` |
| Final Fantasy X | **SCES-50494** | ✅ OK | `Final Fantasy X [SCES-50494].jpg` |
| God of War 1 | **SCUS-97399** | ✅ OK | `God of War 1 [SCUS-97399].jpg` |
| God of War 2 | **SCES-54206** | ✅ OK | `God of War 2 [SCES-54206].jpg` |
| Grand Theft Auto - San Andreas | **SLUS-20946** | ✅ OK | `Grand Theft Auto - San Andreas [SLUS-20946].jpg` |
| Gran Turismo 4 | **SCUS-97328** | ✅ OK | `Gran Turismo 4 [SCUS-97328].jpg` |
| Guitar Hero II | **SLES-54442** | ✅ OK | `Guitar Hero II [SLES-54442].jpg` |
| Metal Slug Anthology | **SLES-54677** | ✅ OK | `Metal Slug Anthology [SLES-54677].jpg` |
| Need for Speed - Most Wanted | **SLES-53857** | ✅ OK | `Need for Speed - Most Wanted [Black Edition] [SLES-53857].jpg` |
| Need for Speed - Underground 2 | **SLUS-21065** | ✅ OK | `Need for Speed - Underground 2 [SLUS-21065].jpg` |
| Prince of Persia - The Sands of Time | **SLUS-20743** | ✅ OK | `Prince of Persia - The Sands of Time [SLUS-20743].jpg` |
| Resident Evil 4 | **SLES-53702** | ✅ OK | `Resident Evil 4 [SLES-53702].jpg` |
| Shadow of the Colossus | **SCES-53326** | ✅ OK | `Shadow of the Colossus [SCES-53326].jpg` |
| Sonic Unleashed | **SLES-55380** | ✅ OK | `Sonic Unleashed [SLES-55380].jpg` |
| The King Of Fighters 10 in 1 | **PSTG-06042** | ✅ OK | `The King Of Fighters 10 in 1 [PSTG-06042].jpg` |
| The King of Fighters Collection | **SLES-55373** | ✅ OK | `The King of Fighters Collection - The Orochi Saga [SLES-55373].jpg` |
| Tony Hawk's Project 8 | **SLES-54389** | ✅ OK | `Tony Hawk's Project 8 [SLES-54389].jpg` |

---

## 2. Arquivos "Órfãos" ou sem Serial (Atenção!)

Como você observou, existem alguns arquivos na pasta `Capas/` que não seguem o padrão `[SERIAL]` ou são duplicatas manuais. O sistema **não consegue usar esses arquivos automaticamente**, a menos que você os renomeie.

### ⚠️ Arquivos Identificados sem Serial:
1.  `250px-Final_Fantasy_X_FrontBox.jpg`: Provavelmente uma miniatura de download. O sistema está usando `Final Fantasy X [SCES-50494].jpg` em vez desta.
2.  `250px-Gt4.jpg`: Miniatura do Gran Turismo 4. O sistema está usando a versão com Serial.
3.  `the-king-of-fighters-10-en-1.jpg`: Versão antiga. A versão com `[PSTG-06042]` é a que está vinculada.
4.  `Captura de tela de 2026-03-17 01-04-34.png`: Arquivo de sistema/captura que não pertence à biblioteca de capas.
5.  `D_NQ_NP_990243-MLB84167639445_042025-O.jpg`: Nome genérico de download (Mercado Livre/Internet).

### 💡 Recomendação:
Mantenha os arquivos que têm o `[SERIAL]` para garantir que o emulador (e meus scripts de sincronia) funcionem sempre. Os outros podem ser movidos para uma pasta de `/backup/` se você quiser limpar a visualização da pasta, mas conforme sua regra, **não os apague**.

---
*Relatório gerado em 29/03/2026*
