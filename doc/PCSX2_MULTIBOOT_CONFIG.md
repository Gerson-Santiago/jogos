# 🎮 PCSX2 Configuração Multiboot (Guia de Sobrevivência)

Este documento foi criado para registrar como o **PCSX2** funciona dividindo o mesmo pendrive/HD (`/media/jogos/`) entre o seu **Zorin OS** e o seu **Debian**. 

Muitas vezes, configurações idênticas apresentarão comportamentos opostos entre os sistemas por causa do método de instalação ou bloqueios de segurança invisíveis.

---

## 1. O Mistério das Capas Invisíveis (Flatpak vs Nativo)

Você percebeu que imagens que funcionavam ou eram atestadas pelo arquivo auditor (o `_capas_verificar.sh`) simplesmente apareciam genéricas (azuis) dentro da tela inicial do emulador no Zorin. O motivo principal para isso acontecer reside no **método de leitura de atalhos**:

### Zorin OS (Sandboxed via Flatpak)
No Zorin, o aplicativo do PCSX2 vem pelo **FlatHub (Flatpak)**. Sistemas Flatpak são "prisões de segurança". 
- Quando você dá acesso para ler a pasta de jogos (`/media/jogos/PS2/ISOs/`), ele tem a chave dessa porta;
- Porém, quando a pasta `covers` cria um "Link Simbólico" (`Lnk`) misterioso que aponta para outra sub-pasta (`/media/jogos/PS2/Capas/`), o PCSX2 tentará seguir esse caminho, baterá num muro invisível do Sandboxing e ignorará o arquivo fingindo que a capa não existe!

### Debian (Nativo .deb / AppImage)
Muitas vezes, em sistemas instalados de forma tradicional (Nativa), o emulador tem permissões universais de leitura dentro do sistema.
- Se o link simbólico na pasta de `covers` aponta para `/media/jogos/PS2/Capas/...`, o emulador consegue "pular" da sua pasta interna para a sub-pasta real sem sofrer bloqueio nenhum do Debian.

**💡 A Solução Magistral: Hard Links (O Bypass Hacker) 💡**
Para que **ambos** os sistemas leiam as capas impecavelmente sem ter que forçar comandos chatos no Flatpak:
Em vez de criarmos "Atalhos Simbólicos", criamos **Hard Links**! Um Hard Link convence o Sistema Operacional de que o arquivo "clonado" na pasta `covers` DO PCSX2 é 100% verdadeiro (e não um atalho de mapa). Mas magicamente os dois arquivos pesam exatamente a mesma quantidade em disco! Como ele é um arquivo "real", o Zorin Flatpak o lê sem piscar.

---

## 2. A Nomenclatura Perfeita: Capas vs Seriais

Para o emulador identificar automaticamente qual capa pertence a qual jogo, existe uma estrutura engessada.

1. **A Fonte da Verdade:** `/media/jogos/PS2/Capas/`
   Aqui estão suas capas salvas com nomes humanos. Ex: `Nome do Jogo [SERIAL].jpg`.
   
2. **O Que o Emulador Exige:** `covers/`
   O PCSX2 nunca lerá o nome do jogo. Apenas e unicamente a **SERIAL**.
   Portanto, a imagem lá dentro deve se chamar exatamente `SLUS-21782.jpg`, nada de nomes extras.

3. **Formatos Validados:** 
   Baixe apenas `.jpg` autênticos. Muitas imagens da nova internet se chamam `.jpg`, mas dentro do código fonte delas são arquivos `.webp`. O script auditor e verificador do PCSX2 não conseguirá injetar as texturas/capas se elas não forem legítimas.

---

## 3. Arquitetando texturas e Saves em Conjunto (Debian + Zorin)

Como você é mestre em dual-boot e montagem de partição (já que sua `/media/jogos` está rodando), para garantir que um jogo que você avançou no Zorin continue do mesmo lugar no Debian:

**A Raiz do Salve Compartilhado:**
Você precisa garantir que **os dois** instaladores do PCSX2 apontem *todas* as configurações de interface do programa (memcards, sstates, texturas e snaphots) para exatamente a mesma pasta.

1. No PCSX2, vá em **Configurações > Pastas**.
2. Aponte a pasta de `Memory Cards` em AMBOS os PCs para:
   `/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/memcards/`
3. Faça a exata mesma coisa para os `Savestates`, os `Cheats` e primariamente a sua aba `Textures`.
4. Assim, o PCSX2, independente do lado que der o boot, será só um robô vazio que buscará a "memória e o cérebro" diretamente dessa pasta raiz!

**Cuidado de Segurança:** NUNCA apague ou retire a partição `/media/jogos` abruptamente com o emulador rodando ou com um Save-State acontecendo, caso contrário ele corromperá a alma do save nos dois sistemas.

---
**Fim de Documentação de Sistema**
