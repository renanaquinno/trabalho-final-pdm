import 'package:flutter/material.dart';
import 'package:maps/controllers/user_controller.dart';
import 'package:maps/views/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserController _controller = UserController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = "";

  void _login() async {
    bool success = await _controller.login(
        _emailController.text, _passwordController.text);
    setState(() {
      if (success) {
        // Redirecionar para a tela principal (HomePage)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        // Mostrar mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciais inválidas')),
        );
      }
    });
  }

  void _register() async {
    await _controller.addUser(
        "Usuário", _emailController.text, _passwordController.text);
    setState(() {
      _message = "Usuário registrado com sucesso!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Image.asset(
                "assets/logo.png",
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                    backgroundColor: Colors.blue),
                child: const Text("Login"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _register(),
                child: const Text("Registrar"),
              ),
              Text(_message, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
