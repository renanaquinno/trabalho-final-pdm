class Cliente {
  final int id;
  final String nome;
  final int idade;
  final String estadoCivil;

  Cliente({
    required this.id,
    required this.nome,
    required this.idade,
    required this.estadoCivil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'idade': idade,
      'estadoCivil': estadoCivil,
    };
  }
}
