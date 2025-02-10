import 'package:flutter/material.dart';
import 'package:maps/models/cliente_model.dart';
import 'package:maps/services/database_service.dart';
import 'package:maps/views/cliente_edit_page.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final ClienteService _databaseService = ClienteService.instance;
  String? _nome = null;
  int? _idade = null;
  String? _estadoCivil = null;

  Map<String, String> estadoCivilLabels = {
    'solteiro': 'Solteiro(a)',
    'casado': 'Casado(a)',
    'uniao_estavel': 'União Estável',
    'divorciado': 'Divorciado(a)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Clientes"),
        backgroundColor: Colors.blue,
      ),
      body: _clienteList(),
      floatingActionButton: _addClienteButton(),
    );
  }

  Widget _addClienteButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Adicionar Cliente'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _nome = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nome',
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _idade = int.tryParse(value) ?? 0;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Idade',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _estadoCivil,
                  onChanged: (String? newValue) {
                    setState(() {
                      _estadoCivil = newValue!;
                    });
                  },
                  items: const [
                    {'value': 'solteiro', 'label': 'Solteiro(a)'},
                    {'value': 'casado', 'label': 'Casado(a)'},
                    {'value': 'uniao_estavel', 'label': 'União Estável'},
                    {'value': 'divorciado', 'label': 'Divorciado(a)'},
                  ].map((estado) {
                    return DropdownMenuItem<String>(
                      value: estado['value'], // Valor interno
                      child: Text(estado['label']!), // Texto exibido ao usuário
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Estado Civil',
                  ),
                ),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (_nome == null || _nome == "") return;
                    _databaseService.addCliente(_nome!, _idade!, _estadoCivil!);
                    setState(() {
                      _nome = null;
                      _idade = null;
                      _estadoCivil = null;
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

  Widget _clienteList() {
    return FutureBuilder<List<Cliente>>(
      future: _databaseService.getCliente(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erro ao carregar clientes"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Nenhum cliente encontrado"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Cliente cliente = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cliente.nome,
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
                                EditClientePage(cliente: cliente),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                leading: const Icon(Icons.person, color: Colors.blue),
                children: [
                  ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🎂 Idade: ${cliente.idade} anos"),
                        Text(
                            "💍 Estado Civil: ${estadoCivilLabels[cliente.estadoCivil] ?? 'Desconhecido'}"),
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
