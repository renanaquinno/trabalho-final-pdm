class InfracaoModel {
  final int id;
  final String descricao;
  final int natureza;
  final String local;
  final int clienteId; // Adicionado o campo clienteId

  InfracaoModel({
    required this.id,
    required this.descricao,
    required this.natureza,
    required this.local,
    required this.clienteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'natureza': natureza,
      'local': local,
      'cliente_id': clienteId,
    };
  }

  factory InfracaoModel.fromMap(Map<String, dynamic> map) {
    return InfracaoModel(
      id: map['id'],
      descricao: map['descricao'],
      natureza: map['natureza'],
      local: map['local'],
      clienteId: map['cliente_id'],
    );
  }
}
