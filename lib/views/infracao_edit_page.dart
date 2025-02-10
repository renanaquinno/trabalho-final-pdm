import 'package:flutter/material.dart';
import 'package:maps/models/infracao_model.dart';
import 'package:maps/services/database_service.dart';

class EditInfracaoPage extends StatefulWidget {
  final InfracaoModel infracao;

  const EditInfracaoPage({Key? key, required this.infracao}) : super(key: key);

  @override
  _EditInfracaoPageState createState() => _EditInfracaoPageState();
}

class _EditInfracaoPageState extends State<EditInfracaoPage> {
  final InfracaoService _databaseService = InfracaoService.instance;

  late TextEditingController _descricaoController;
  late TextEditingController _naturezaController;
  late TextEditingController _localController;
  late TextEditingController _clienteController;

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers com os valores antigos do infracao
    _descricaoController =
        TextEditingController(text: widget.infracao.descricao);
    _naturezaController =
        TextEditingController(text: widget.infracao.natureza.toString());
    _localController = TextEditingController(text: widget.infracao.local);
    _clienteController =
        TextEditingController(text: widget.infracao.clienteId.toString());
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _naturezaController.dispose();
    _localController.dispose();
    _clienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Infracao'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descricao'),
            ),
            // TextField(
            //   controller: _naturezaController,
            //   decoration: const InputDecoration(labelText: 'Natureza'),
            // ),
            TextField(
              controller: _localController,
              decoration: const InputDecoration(labelText: 'Local'),
            ),
            // TextField(
            //   controller: _clienteController,
            //   decoration: const InputDecoration(labelText: 'Cliente'),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validação: se o marcar estiver vazio, não prossegue
                if (_descricaoController.text.trim().isEmpty) return;

                // Atualiza ou adiciona o infracao com os novos naturezaes
                _databaseService.updateInfracao(
                    widget.infracao.id,
                    _descricaoController.text,
                    _naturezaController.text,
                    _localController.text,
                    _clienteController.text);

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
