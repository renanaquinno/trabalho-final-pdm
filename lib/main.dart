import 'package:flutter/material.dart';
import 'package:maps/views/register_page.dart';
import 'views/dashboard_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await resetDatabase();
  runApp(const MyApp());
}

Future<void> resetDatabase() async {
  final databaseDirPath = await getDatabasesPath();
  final databasePath = join(databaseDirPath, "app_database.db");

  print("🔴 Apagando banco de dados...");
  await deleteDatabase(databasePath);
  print("✅ Banco de dados apagado com sucesso!");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage()
        // return MaterialApp(debugShowCheckedModeBanner: false, home: DashboardPage()
        );
  }
}
