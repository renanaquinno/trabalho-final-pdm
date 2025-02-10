import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps/models/infracao_model.dart';
import 'package:maps/services/database_service.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? mapController;
  final ClienteService _databaseService = ClienteService.instance;
  final InfracaoService _InfracaodatabaseService = InfracaoService.instance;
  final ClienteService _clienteDatabaseService = ClienteService.instance;

  String? _maps_nome = null;
  String? _maps_latitude = null;
  String? _maps_longitude = null;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-5.095424, -42.8146688),
    zoom: 14.4746,
  );

  Set<Marker> _marcadores = {};

  //final LatLng _center = const LatLng(-5.1022707, -42.9531379);

  @override
  void initState() {
    super.initState();
    _carregarMarcadores();
    _localizacaoAtual();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _localizacaoAtual() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Serviço de localização está desativado.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permissão de localização negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          'Permissão de localização foi negada permanentemente. Não podemos solicitar.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print('Localização: ${position.toString()}');
  }

  void _carregarMarcadores() async {
    try {
      // Obter as infrações do banco de dados
      List<InfracaoModel> infracoes =
          await _InfracaodatabaseService.getInfracao();

      Set<Marker> marcadoresLocal = {};

      // Lista de futuros de nomes de clientes
      List<Future<void>> futures = [];

      for (var infracao in infracoes) {
        String coordenadas = infracao.local;
        String _nomeCliente = 'Desconhecido'; // Valor default

        // Adicionando a chamada assíncrona para buscar o nome do cliente
        futures.add(Future.delayed(Duration.zero, () async {
          try {
            _nomeCliente = await _clienteDatabaseService
                    .getNomeCliente(infracao.clienteId) ??
                'Desconhecido';
          } catch (e) {
            _nomeCliente = 'Erro ao carregar';
          }
        }));

        // Separando a string de coordenadas
        List<String> partes =
            coordenadas.split(',').map((e) => e.trim()).toList();
        String latitude = partes[0];
        String longitude = partes[1];

        // Criando o marcador
        Marker marcador = Marker(
          markerId: MarkerId(infracao.descricao),
          position: LatLng(double.parse(latitude), double.parse(longitude)),
          infoWindow: InfoWindow(
            title: infracao.descricao,
            snippet: "Lat: ${latitude}, Lon: ${longitude}",
          ),
          onTap: () async {
            // Buscar mais detalhes do cliente, por exemplo
            String? nomeCliente = await _clienteDatabaseService
                .getNomeCliente(infracao.clienteId);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(infracao.descricao),
                  content: Text('Cliente: $nomeCliente'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Fechar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );

        marcadoresLocal.add(marcador);
      }

      // Esperando todas as futuras chamadas de _getNomeCliente
      await Future.wait(futures);

      // Atualizando o estado após carregar os marcadores
      setState(() {
        _marcadores = marcadoresLocal;
      });
    } catch (e) {
      print("Erro ao carregar marcadores: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('App de Contatos'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-5.095424, -42.8146688),
          zoom: 10,
        ),
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        mapType: MapType.normal,
        markers: _marcadores,
      ),
    );
  }
}
