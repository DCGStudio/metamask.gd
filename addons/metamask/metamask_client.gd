@tool
extends Node
class_name MetaMaskClient

# Señales principales
signal accounts_changed(accounts: Array[String])
signal chain_changed(chain_id: String)
signals error_occurred(code: int, message: String)
signal connected()
signal disconnected()

# Configuración JavaScript
var _window: JavaScriptObject
var _ethereum: JavaScriptObject
var _js_callbacks: Dictionary = {}

func _enter_tree():
    # Inyectar código JS al cargar
    _inject_js_code()
    _setup_js_references()

# Inyecta el código JS necesario
func _inject_js_code():
    var js_code = """
        window.GodotMetaMask = {
            ethereum: null,
            
            init: function() {
                if (typeof window.ethereum !== 'undefined' && window.ethereum.isMetaMask) {
                    this.ethereum = window.ethereum;
                    return true;
                }
                return false;
            },
            
            request: async function(method, params) {
                try {
                    return await this.ethereum.request({ method, params });
                } catch (error) {
                    return { error: { code: error.code, message: error.message } };
                }
            }
        };
    """
    JavaScriptBridge.eval(js_code)

# Configura referencias a objetos JS
func _setup_js_references():
    _window = JavaScriptBridge.get_interface("window")
    _js_callbacks["accountsChanged"] = JavaScriptBridge.create_callback(_on_accounts_changed)
    _js_callbacks["chainChanged"] = JavaScriptBridge.create_callback(_on_chain_changed)

# Verifica si MetaMask está instalado
func is_available() -> bool:
    return JavaScriptBridge.eval("window.GodotMetaMask.init()", true)

# Solicita conexión de cuentas
func connect_accounts() -> void:
    var result = await _call_js_method("request", ["eth_requestAccounts", []])
    if result.has("error"):
        emit_signal("error_occurred", result.error.code, result.error.message)
    else:
        emit_signal("connected")

# Obtiene la cadena actual
func get_chain_id() -> String:
    return JavaScriptBridge.eval("window.GodotMetaMask.ethereum.chainId", true)

# Envía transacción ETH
func send_eth_transaction(from: String, to: String, value: String) -> Dictionary:
    var params = {
        from: from,
        to: to,
        value: "0x" + value.to_hex()
    }
    return await _call_js_method("request", ["eth_sendTransaction", [params]])

# Método genérico para llamadas JS
func _call_js_method(method: String, args: Array) -> Variant:
    var js_call = "window.GodotMetaMask.%s(%s)" % [method, _args_to_js(args)]
    return await JavaScriptBridge.eval(js_call, true)

# Convierte argumentos de GDScript a JS
func _args_to_js(args: Array) -> String:
    var str_args = []
    for arg in args:
        if arg is String:
            str_args.append('"%s"' % arg)
        else:
            str_args.append(JSON.stringify(arg))
    return ",".join(str_args)

# Manejo de eventos
func _on_accounts_changed(args: Array) -> void:
    var accounts = JSON.parse_string(args[0])
    emit_signal("accounts_changed", accounts)

func _on_chain_changed(args: Array) -> void:
    var chain_id = args[0]
    emit_signal("chain_changed", chain_id)