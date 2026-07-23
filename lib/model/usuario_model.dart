import 'package:firebase_auth/firebase_auth.dart';

class UsuarioModel {
  final String uid;
  final String nome;
  final String email;

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
  });

  factory UsuarioModel.fromFirebase(User user) {
    return UsuarioModel(
      uid: user.uid,
      nome: user.displayName ?? '',
      email: user.email ?? '',
    );
  }






  
}