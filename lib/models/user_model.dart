import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  int? id;
  String name;
  String email;
  String passwordHash;

  User(
      {this.id,
      required this.name,
      required this.email,
      required this.passwordHash});

  // Função para gerar hash da senha
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      passwordHash: map['passwordHash'],
    );
  }
}
