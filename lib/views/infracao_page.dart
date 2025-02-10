import 'package:flutter/material.dart';
import 'package:maps/models/automovel_model.dart';
import 'package:maps/models/infracao_model.dart';
import 'package:maps/services/database_service.dart';
import 'package:maps/views/automovel_edit_page.dart';
import 'package:maps/views/infracao_edit_page.dart';

class InfracaoPage extends StatefulWidget {
  const InfracaoPage({super.key});

  @override
  State<InfracaoPage> createState() => _InfracaoPageState();
}

class _InfracaoPageState extends State<InfracaoPage> {
  final InfracaoService _databaseService = InfracaoService.instance;
  final ClienteService _clienteDatabaseService = ClienteService.instance;
  String? _descricao = null;
  int? _natureza = null;
  String? _local = null;
  int? _cliente;

  List<Map<String, dynamic>> _clientes = [];
  Map<int, String> naturezaLabels = {
    1: 'Leve',
    2: 'Média',
    3: 'Grave',
    4: 'Gravíssima',
  };

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await _clienteDatabaseService.getClientes();
    setState(() {
      _clientes = clientes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Infrações"),
        backgroundColor: Colors.red,
      ),
      body: _infracaoList(),
      floatingActionButton: _addInfracaoButton(),
    );
  }

  Widget _addInfracaoButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Adicionar Infracao'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _descricao = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Descrição', // Título do campo
                    hintText:
                        'Ex: Transitar em Alta Velocidade', // Texto de exemplo (placeholder)
                    border: OutlineInputBorder(),
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: _natureza,
                  onChanged: (int? newValue) {
                    setState(() {
                      _natureza = newValue!;
                    });
                  },
                  items: const [
                    {'value': 1, 'label': 'Leve'},
                    {'value': 2, 'label': 'Média'},
                    {'value': 3, 'label': 'Grave'},
                    {'value': 4, 'label': 'Gravíssima'},
                  ].map((estado) {
                    return DropdownMenuItem<int>(
                      value: estado['value'] as int, // Garantindo que seja int
                      child: Text(estado['label']!
                          as String), // Texto exibido ao usuário
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Natureza',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _local = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Coordenadas do Local',
                    hintText: '-4.554, -44.541',
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: _cliente,
                  onChanged: (int? newValue) {
                    setState(() {
                      _cliente = newValue;
                    });
                  },
                  items: _clientes.map((clientes) {
                    return DropdownMenuItem<int>(
                      value: clientes['id'], // Value = ID do cliente
                      child: Text(clientes['nome']), // Label = Nome do cliente
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Cliente',
                  ),
                ),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (_descricao == null || _descricao == "") return;
                    _databaseService.addInfracao(
                        _descricao!, _natureza!, _local!, _cliente!);
                    setState(() {
                      _descricao = null;
                      _natureza = null;
                      _local = null;
                      _cliente = null;
                    });
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    "Salvar",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      },
      child: const Icon(
        Icons.add,
      ),
    );
  }

  Widget _infracaoList() {
    return FutureBuilder(
      future: _databaseService.getInfracao(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            InfracaoModel infracao = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      infracao.descricao,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditInfracaoPage(infracao: infracao),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                subtitle: FutureBuilder<String?>(
                  future: _clienteDatabaseService
                      .getNomeCliente(infracao.clienteId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Carregando...");
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Text("Cliente não encontrado",
                          style: TextStyle(color: Colors.red));
                    } else {
                      return Text("👤 Cliente: ${snapshot.data}",
                          style: TextStyle(color: Colors.grey[700]));
                    }
                  },
                ),
                leading: const Icon(Icons.assignment, color: Colors.blue),
                children: [
                  ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "❗ Natureza: ${naturezaLabels[infracao.natureza] ?? 'Desconhecido'}"),
                        Text("📍 Local: ${infracao.local}"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
