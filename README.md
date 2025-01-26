# Godot MetaMask Addon 🦊⚡

**Integra MetaMask en tu juego Godot y habilita transacciones blockchain directamente desde el navegador.**

[![Godot 4.3+](https://img.shields.io/badge/Godot-4.3%2B-%23478cbf)](https://godotengine.org)
[![Licencia MIT](https://img.shields.io/badge/Licencia-MIT-green)](LICENSE)

Un addon para Godot Engine que permite interactuar con wallets Web3 (como MetaMask) de forma sencilla y profesional. Ideal para juegos Play-to-Earn, NFTs, y aplicaciones descentralizadas (dApps).

---

## 🚀 Características Principales

- **Conexión de Wallet**  
  Solicita acceso a cuentas de MetaMask con un solo comando.
  
- **Manejo de Eventos en Tiempo Real**  
  Detecta cambios en cuentas, cadenas blockchain y desconexiones.

- **Operaciones Blockchain**  
  - Envío de ETH/ERC-20  
  - Consulta de balances  
  - Cambio de red (Chain Switching)  
  - Firmas de mensajes EIP-712

- **Compatibilidad Web**  
  Optimizado para exportaciones HTML5 con WebAssembly.

---

## 📦 Instalación

1. Descarga el [último release](https://github.com/DCGStudio/metamask.gd/releases) o clona el repositorio.
2. Copia la carpeta `addons/metamask` a tu proyecto Godot.
3. Activa el plugin en:  
   `Proyecto → Ajustes del Proyecto → Plugins`.

---

## 🎮 Uso Básico

```gdscript
extends Node

@onready var metamask = $MetaMaskClient

func _ready():
    if metamask.is_available():
        await metamask.connect_accounts()
        print("Cuenta conectada:", metamask.selected_account)
    else:
        OS.alert("¡Instala MetaMask!")

# Enviar 0.1 ETH
func send_transaction():
    var tx_result = await metamask.send_eth(
        metamask.selected_account,
        "0xDestino...", 
        0.1
    )
    print("Transacción enviada:", tx_result.hash)
```

```gdscript
extends Node

@onready var metamask = $MetaMaskClient

func _ready():
    if metamask.is_available():
        metamask.connect_accounts()
        metamask.accounts_changed.connect(_on_accounts)
        metamask.chain_changed.connect(_on_chain)
    else:
        show_error("¡Instala MetaMask!")

func _on_accounts(accounts: Array[String]):
    print("Cuentas conectadas:", accounts)

func _on_chain(chain_id: String):
    print("Cadena actual:", chain_id)

func send_eth():
    var result = await metamask.send_eth_transaction(
        "0xTuDireccion",
        "0xDestino",
        "1000000000000000000"  # 1 ETH en wei
    )
    if result.has("error"):
        print("Error:", result.error)
    else:
        print("TX Hash:", result)
```


---

## 🌐 Requisitos

- Godot Engine 4.3 o superior
- Exportación a HTML5/Web
- MetaMask instalado en el navegador
- **HTTPS** (Requerido para producción)

---

## 🛠 Roadmap

- [ ] Soporte para WalletConnect
- [ ] Integración con Smart Contracts (ABI)
- [ ] Ejemplos avanzados (NFTs, Staking)
- [ ] Traducciones (EN/ES/FR)

---

## 🤝 Contribuir

¡Aportes son bienvenidos! Sigue estos pasos:
1. Haz un Fork del repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Haz Commit de tus cambios (`git commit -m 'Añade X funcionalidad'`)
4. Haz Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

Distribuido bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

