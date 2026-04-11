# Inventário de Hardware e Sistema — TUF Gaming (antigravity)

Este documento registra a configuração base do sistema e o roteiro de upgrades para garantir a melhor performance em emulação e jogos.

## 💻 Especificações Atuais

### Processador (CPU)
*   **Modelo**: AMD Ryzen 5 7600 (Zen 4 / AM5)
*   **Núcleos**: 6 Cores / 12 Threads
*   **Velocidade**: 3.8 GHz (Base) → 5.1 GHz (Boost)
*   **Status**: Estável, refrigeração adequada para emulação via iGPU.

### Placa-Mãe
*   **Modelo**: ASUS TUF Gaming B650M-E WIFI
*   **Chipset**: AMD B650 (Suporte PCIe 5.0)
*   **BIOS**: AMI 3827 (Atualizada em Junho/2026)

### Memória RAM
*   **Configuração**: 16GB (2x 8GB) DDR5 Kingston Fury Beast
*   **Perfil EXPO**: ATIVO @ 6000 MT/s (C30)
*   **Status**: Alta performance garantida para Zen 4.

### Armazenamento
1.  **NVMe (Principal)**: WD Green SN3000 500GB (PCIe 4.0) — Windows 11 / Swap 8GB.
2.  **HDD (Secundário/Jogos)**: WDC WD5000LPCX-2 500GB laptop.
    *   **⚠️ ATENÇÃO**: Conectado via **USB 3.0**. Considere migração para SATA interno para reduzir latência de carregamento.

---

## 🎮 Gráficos (GPU)

### GPU Atual (iGPU)
*   **Modelo**: AMD Radeon Raphael (Integrada)
*   **Capacidade**: 2 Compute Units (CUs).
*   **Limitante**: Recomendado uso de resolução 720p ou inferior para títulos pesados (Batman Arkham City).

### 🚀 GPU Pendente (Upgrade Futuro)
*   **Modelo**: Gigabyte RX 9060 XT Gaming OC 16G
*   **SKU**: `GV-R9060XTGAMING OC-16GD`
*   **Arquitetura**: RDNA 4 / Navi 48 (PCIe 5.0)
*   **VRAM**: 16GB GDDR6

#### 🛠️ Comandos de Pós-Instalação:

Ao instalar a RX 9060 XT, execute os seguintes comandos para garantir a ativação correta dos drivers:

```bash
# 1. Instalar Kernel 6.19+ (necessário para Navi 48)
sudo apt install -t trixie-backports linux-image-amd64 linux-headers-amd64

# 2. Verificar o carregamento do módulo
lspci | grep -i "9060\|navi 48"
lsmod | grep amdgpu
cat /sys/class/drm/card1/device/vendor

# 3. Validar logs do driver DRM
dmesg | grep -i "amdgpu\|drm" | tail -20
```

---

## 🛠️ Software e Kernel
*   **Distro**: Debian GNU/Linux 13.4 (Trixie)
*   **Kernel Atual**: 6.12.x-amd64
*   **Mesa**: 25.3.x (Drivers de vídeo)
