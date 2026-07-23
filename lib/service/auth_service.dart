import 'package:firebase_auth/firebase_auth.dart';
import '../model/usuario_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await credencial.user?.updateDisplayName(nome);
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este email já está cadastrado.';
        case 'invalid-email':
          return 'Email inválido.';
        case 'weak-password':
          return 'A senha precisa ter pelo menos 6 caracteres.';
        default:
          return 'Erro ao cadastrar. Tente novamente.';
      }
    }
  }

  Future<String?> entrar({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          return 'Email ou senha incorretos.';
        default:
          return 'Erro ao entrar. Tente novamente.';
      }
    }
  }

  UsuarioModel? usuarioAtual() {
    final user = _auth.currentUser;
    return user == null ? null : UsuarioModel.fromFirebase(user);
  }

  Future<void> sair() => _auth.signOut();
}