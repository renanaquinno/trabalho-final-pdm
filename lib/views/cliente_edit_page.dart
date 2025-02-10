import 'package:flutter/material.dart';
import 'package:maps/models/cliente_model.dart';
import 'package:maps/services/database_service.dart';

class EditClientePage extends StatefulWidget {
  final Cliente cliente;

  const EditClientePage({Key? key, required this.cliente}) : super(key: key);

  @override
  _EditClientePageState createState() => _EditClientePageState();
}

class _EditClientePageState extends State<EditClientePage> {
  final ClienteService _databaseService = ClienteService.instance;

  late TextEditingController _nomeController;
  late TextEditingController _idadeController;
  late TextEditingController _estadoCivilController;
  String? _estadoCivil;

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers com os valores antigos do cliente
    _nomeController = TextEditingController(text: widget.cliente.nome);
    _idadeController =
        TextEditingController(text: widget.cliente.idade.toString());
    _estadoCivil = widget.cliente.estadoCivil;
    _estadoCivilController = TextEditingController(text: _estadoCivil);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _estadoCivilController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _idadeController,
              decoration: const InputDecoration(labelText: 'Idade'),
            ),
            DropdownButtonFormField<String>(
              value: _estadoCivil, // valor selecionado
              onChanged: (String? newValue) {
                setState(() {
                  _estadoCivil = newValue;
                  _estadoCivilController?.text = newValue ?? '';
                });
              },
              items: [
                DropdownMenuItem(value: 'solteiro', child: Text('Solteiro(a)')),
                DropdownMenuItem(value: 'casado', child: Text('Casado(a)')),
                DropdownMenuItem(
                    value: 'uniao_estavel', child: Text('União Estável')),
                DropdownMenuItem(
                    value: 'divorciado', child: Text('Divorciado(a)')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Estado Civil',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validação: se o nome estiver vazio, não prossegue
                if (_nomeController.text.trim().isEmpty) return;

                // Atualiza ou adiciona o cliente com os novos valores
                _databaseService.updateCliente(
                    widget.cliente.id,
                    _nomeController.text,
                    _idadeController.text,
                    _estadoCivilController.text);

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
