class AutomovelModel {
  final int id;
  final String marca;
  final String modelo;
  final String placa;
  final int fipe;
  final int proprietario;
  final int valorSeguro;

  AutomovelModel({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.placa,
    required this.fipe,
    required this.proprietario,
    required this.valorSeguro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'placa': placa,
      'fipe': fipe,
      'proprietario': proprietario,
      'valorSeguro': valorSeguro,
    };
  }
}
