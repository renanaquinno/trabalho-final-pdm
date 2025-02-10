import 'package:flutter/material.dart';
import 'package:maps/models/automovel_model.dart';
import 'package:maps/services/database_service.dart';

class EditAutomovelPage extends StatefulWidget {
  final AutomovelModel automovel;

  const EditAutomovelPage({Key? key, required this.automovel})
      : super(key: key);

  @override
  _EditAutomovelPageState createState() => _EditAutomovelPageState();
}

class _EditAutomovelPageState extends State<EditAutomovelPage> {
  final AutomovelService _databaseService = AutomovelService.instance;

  late TextEditingController _marcarController;
  late TextEditingController _modeloController;
  late TextEditingController _placaController;
  late TextEditingController _fipeController;
  late TextEditingController _proprietarioController;
  late TextEditingController _valorSeguroController;

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers com os valores antigos do automovel
    _marcarController = TextEditingController(text: widget.automovel.marca);
    _modeloController = TextEditingController(text: widget.automovel.modelo);
    _placaController = TextEditingController(text: widget.automovel.placa);
    _fipeController =
        TextEditingController(text: widget.automovel.fipe.toString());
    _proprietarioController =
        TextEditingController(text: widget.automovel.proprietario.toString());
    _valorSeguroController =
        TextEditingController(text: widget.automovel.valorSeguro.toString());
  }

  @override
  void dispose() {
    _marcarController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _fipeController.dispose();
    _proprietarioController.dispose();
    _valorSeguroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Automovel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _marcarController,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            TextField(
              controller: _modeloController,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            TextField(
              controller: _placaController,
              decoration: const InputDecoration(labelText: 'Placa'),
            ),
            TextField(
              controller: _fipeController,
              decoration: const InputDecoration(labelText: 'FIPE'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validação: se o marcar estiver vazio, não prossegue
                if (_marcarController.text.trim().isEmpty) return;

                // Atualiza ou adiciona o automovel com os novos valores
                _databaseService.updateAutomovel(
                    widget.automovel.id,
                    _marcarController.text,
                    _modeloController.text,
                    _placaController.text,
                    _fipeController.text,
                    _proprietarioController.text,
                    _valorSeguroController.text);

                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
