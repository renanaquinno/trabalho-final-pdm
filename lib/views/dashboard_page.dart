import 'package:flutter/material.dart';
import 'package:maps/views/automovel_page.dart';
import 'package:maps/views/infracao_page.dart';
import 'package:maps/views/maps_page.dart';
import 'package:maps/views/register_page.dart';
import 'cliente_page.dart'; // Importa a tela de contatos

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seguro Total"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Adicionando a imagem da logo no topo da tela
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              "assets/logo.png", // Caminho da imagem no projeto
              width: 120, // Ajuste do tamanho da logo
              height: 120,
            ),
          ),

          // Espaço para os botões do dashboard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardButton(
                      Icons.contact_page, "Clientes", context, ClientePage()),
                  _buildDashboardButton(Icons.directions_car, "Automoveis",
                      context, AutomovelPage()),
                  _buildDashboardButton(
                      Icons.list_alt, "Infrações", context, InfracaoPage()),
                  _buildDashboardButton(
                      Icons.map, "Locais de Multas", context, MapsPage()),
                  _buildDashboardButton(
                      Icons.exit_to_app, "Sair", context, LoginPage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(
      IconData icon, String label, BuildContext context, Widget? page) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
