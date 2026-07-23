import 'package:flutter/foundation.dart';
import '../model/usuario_model.dart';
import '../service/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _carregando = false;
  bool get carregando => _carregando;

  UsuarioModel? _usuario;
  UsuarioModel? get usuario => _usuario;

  Future<String?> entrar({
    required String email,
    required String senha,
  }) async {
    _setCarregando(true);
    final erro = await _authService.entrar(email: email, senha: senha);
    if (erro == null) _usuario = _authService.usuarioAtual();
    _setCarregando(false);
    return erro;
  }

  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _setCarregando(true);
    final erro = await _authService.cadastrar(
      nome: nome,
      email: email,
      senha: senha,
    );
    if (erro == null) _usuario = _authService.usuarioAtual();
    _setCarregando(false);
    return erro;
  }

  Future<void> sair() async {
    await _authService.sair();
    _usuario = null;
    notifyListeners();
  }

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }
}