# 🎮 Guia Definitivo: Como Adicionar Capas ao PCSX2

Sempre que você adicionar uma nova ISO (novo jogo) na sua pasta `/media/jogos/PS2/ISOs/`, siga esse passo a passo exato para garantir que a capa apareça perfeitamente no PCSX2 sem bagunçar a sua organização!

---

### Passo 1: Descubra a "Serial" do Novo Jogo
1. Coloque o jogo novo na pasta de ISOs.
2. Abra o **PCSX2** uma vez para que ele reconheça o novo jogo (ou clique com o botão direito na lista e vá em "Atualizar/Refresh").
3. Abra o terminal e rode o nosso script auditor:
   ```bash
   bash /media/jogos/verificar_capas.sh
   ```
4. O script vai listar o seu jogo novo na seção **"1. FALHAS REAIS"**.
   > Exemplo que vai aparecer lá: `❌ [ SLUS-21782 ] - God of War II`
   Anote bem esse código entre colchetes (ex: `SLUS-21782`), pois é a identidade do jogo!

---

### Passo 2: Baixe e Salve a Imagem com o Nome Perfeito
1. Vá no Google Imagens e baixe a capa.
   > ⚠️ **Atenção ao WebP:** O PCSX2 odeia formato `.webp`. Baixe preferencialmente arquivos `.jpg` ou `.png`. Se baixar webp, use a ferramenta `convert` do seu terminal para transformá-lo em jpg!
2. Salve a imagem baixada dentro da sua pasta de capas:
   `/media/jogos/PS2/Capas/`
3. **Renomeie o arquivo estritamente para o padrão abaixo:**
   `Nome do Jogo [SERIAL].jpg`
   > ✅ **Exemplo Correto:** `God of War II [SLUS-21782].jpg`
   > ❌ **Exemplo Errado:** `god_of_war_capa.jpg`

---

### Passo 3: Faça o Elo de Ligação (Link Simbólico) no PCSX2
O PCSX2 nunca lê diretamente a sua pasta `Capas`. Precisamos criar um atalho que "engane" o emulador, mas sem tirar seu arquivo do lugar!

No terminal, rode o comando mágico de atalho (`ln -s = Link Simbólico`):
```bash
ln -s "/media/jogos/PS2/Capas/O Nome Perfeito Que Voce Deu [SERIAL].jpg" "/media/jogos/pcsx2-userdata/net.pcsx2.PCSX2/config/PCSX2/covers/SERIAL.jpg"
```
*(Lembre-se de não apagar as aspas do comando se o nome do jogo tiver espaços!)*

---

### Passo 4: A Prova dos 9 (Auditoria)
Para ter extrema certeza de que tudo deu certo, rode nosso script mais uma vez:
```bash
bash /media/jogos/verificar_capas.sh
```

- **Deu tudo certo?** Ele dirá "✅ Nenhuma falha real!" e "✅ Zero Falsos Positivos".
- **Apareceu em Falso Positivo?** Você errou o comando de atalho ou não colocou a Serial no nome da imagem original.
- **Apareceu em Falso Negativo?** Você esqueceu de fazer o comando do atalho de ligação (Passo 3) ou colocou a extensão errada.

Aproveite sua coleção de PS2 majestosamente organizada! 🕹️✨
