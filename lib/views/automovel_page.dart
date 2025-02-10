import 'package:flutter/material.dart';
import 'package:maps/models/automovel_model.dart';
import 'package:maps/services/database_service.dart';
import 'package:maps/views/automovel_edit_page.dart';

class AutomovelPage extends StatefulWidget {
  const AutomovelPage({super.key});

  @override
  State<AutomovelPage> createState() => _AutomovelPageState();
}

class _AutomovelPageState extends State<AutomovelPage> {
  final AutomovelService _databaseService = AutomovelService.instance;
  final ClienteService _clienteDatabaseService = ClienteService.instance;
  final InfracaoService _infracaoDatabaseService = InfracaoService.instance;

  String? _marca = null;
  String? _modelo = null;
  String? _placa = null;
  int? _fipe = null;
  int? _proprietario;
  int? _valorSeguro;

  List<Map<String, dynamic>> _clientes = [];

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

  Future<void> _calcularValorSeguro(cliente) async {
    final infracao =
        await _infracaoDatabaseService.getInfracaoPorCliente(cliente);
    setState(() {
      //_valorSeguro = infracao;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Automovels"),
        backgroundColor: Colors.green,
      ),
      body: _automovelList(),
      floatingActionButton: _addAutomovelButton(),
    );
  }

  Widget _addAutomovelButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Adicionar Automovel'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _marca = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Marca',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _modelo = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Modelo',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _placa = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Placa',
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _fipe = int.tryParse(value) ?? 0;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Digite o valor FIPE',
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: _proprietario,
                  onChanged: (int? newValue) {
                    setState(() {
                      _proprietario = newValue;
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
                    labelText: 'Proprietario',
                  ),
                ),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (_placa == null || _placa == "") return;
                    _databaseService.addAutomovel(_marca!, _modelo!, _placa!,
                        _fipe!, _proprietario!, _valorSeguro ?? 1);
                    setState(() {
                      _marca = null;
                      _modelo = null;
                      _placa = null;
                      _fipe = null;
                      _proprietario = null;
                      _valorSeguro = null;
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

  Widget _automovelList() {
    return FutureBuilder(
      future: _databaseService.getAutomovel(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            AutomovelModel automovel = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      automovel.placa,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditAutomovelPage(automovel: automovel),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                subtitle: Text(
                  automovel.modelo,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                leading: const Icon(Icons.car_rental, color: Colors.blue),
                children: [
                  ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("💸 FIPE: ${automovel.fipe.toString()}"),
                        Text("🚘 Marca: ${automovel.marca}"),
                        FutureBuilder<String?>(
                          future: _clienteDatabaseService
                              .getNomeCliente(automovel.proprietario),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                        Text("🔐 Valor Seguro: ${automovel.valorSeguro}"),
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
