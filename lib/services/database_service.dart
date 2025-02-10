import 'package:maps/models/automovel_model.dart';
import 'package:maps/models/infracao_model.dart';
import 'package:maps/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cliente_model.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath =
        join(databaseDirPath, "app_database.db"); // Banco único

    return await openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {
      await _createTables(db);
    });
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL
          )
        ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        idade int,
        estadoCivil TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS automovel (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        placa TEXT NOT NULL,
        fipe INTEGER,
        valorSeguro INTEGER,
        cliente INTEGER,
        FOREIGN KEY (cliente) REFERENCES cliente(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS infracao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao TEXT NOT NULL,
        natureza INTEGER,
        local TEXT NOT NULL,
        cliente INTEGER,
        FOREIGN KEY (cliente) REFERENCES cliente(id) ON DELETE CASCADE
      )
    ''');
  }
}

// --------------------- CLIENTE SERVICE ---------------------
class ClienteService {
  static final ClienteService instance = ClienteService._constructor();
  final DatabaseService _databaseService = DatabaseService.instance;

  ClienteService._constructor();

  final String _tableName = "cliente";
  final String _idColumn = "id";
  final String _nomeColumn = "nome";
  final String _idadeColumn = "idade";
  final String _estadoCivilColumn = "estadoCivil";

  Future<void> addCliente(String nome, int idade, String estadoCivil) async {
    final db = await _databaseService.database;
    await db.insert(
      _tableName,
      {
        _nomeColumn: nome,
        _idadeColumn: idade,
        _estadoCivilColumn: estadoCivil,
      },
    );
  }

  Future<List<Cliente>> getCliente() async {
    final db = await _databaseService.database;
    final data = await db.query(_tableName);

    return data
        .map((e) => Cliente(
              id: e[_idColumn] as int,
              nome: e[_nomeColumn] as String,
              idade: e[_idadeColumn] as int,
              estadoCivil: e[_estadoCivilColumn] as String,
            ))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.query('cliente');
    return result;
  }

  Future<String?> getNomeCliente(int clienteId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'cliente',
      columns: ['nome'],
      where: 'id = ?',
      whereArgs: [clienteId],
    );

    if (result.isNotEmpty) {
      return result.first['nome'] as String;
    }
    return null;
  }

  Future<void> deleteCliente(int id) async {
    final db = await _databaseService.database;
    await db.delete(_tableName, where: '$_idColumn = ?', whereArgs: [id]);
  }

  Future<void> updateCliente(
      int id, String nome, String idade, String estadoCivil) async {
    final db = await _databaseService.database;
    await db.update(
      _tableName,
      {
        _nomeColumn: nome,
        _idadeColumn: idade,
        _estadoCivilColumn: estadoCivil,
      },
      where: '$_idColumn = ?',
      whereArgs: [id],
    );
  }
}

// --------------------- AUTOMOVEL SERVICE ---------------------
class AutomovelService {
  static final AutomovelService instance = AutomovelService._constructor();
  final DatabaseService _databaseService = DatabaseService.instance;
  final InfracaoService _InfracaodatabaseService = InfracaoService.instance;

  AutomovelService._constructor();

  final String _tableName = "automovel";
  final String _idColumn = "id";
  final String _marcaColumn = "marca";
  final String _modeloColumn = "modelo";
  final String _placaColumn = "placa";
  final String _fipeColumn = "fipe";
  final String _proprietarioColumn = "cliente";
  final String _valorSeguroColumn = "valorSeguro";

  Future<void> addAutomovel(String marca, String modelo, String placa, int fipe,
      int cliente, int valorSeguro) async {
    final db = await _databaseService.database;
    await db.insert(
      _tableName,
      {
        _marcaColumn: marca,
        _modeloColumn: modelo,
        _placaColumn: placa,
        _fipeColumn: fipe,
        _proprietarioColumn: cliente,
        _valorSeguroColumn: valorSeguro,
      },
    );

    await _InfracaodatabaseService.atualizarSeguroPorCliente(cliente, 0);
  }

  Future<List<AutomovelModel>> getAutomovel() async {
    final db = await _databaseService.database;
    final data = await db.query(_tableName);

    return data
        .map((e) => AutomovelModel(
              id: e[_idColumn] as int,
              marca: e[_marcaColumn] as String,
              modelo: e[_modeloColumn] as String,
              placa: e[_placaColumn] as String,
              fipe: e[_fipeColumn] as int,
              proprietario: e[_proprietarioColumn] as int,
              valorSeguro: e[_valorSeguroColumn] as int,
            ))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAutomoveis() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.query('automovel');
    return result;
  }

  Future<void> deleteAutomovel(int id) async {
    final db = await _databaseService.database;
    await db.delete(_tableName, where: '$_idColumn = ?', whereArgs: [id]);
  }

  Future<void> updateAutomovel(
      int id,
      String marca,
      String modelo,
      String placa,
      String fipe,
      String proprietario,
      String valorSeguro) async {
    final db = await _databaseService.database;
    await db.update(
      _tableName,
      {
        _marcaColumn: marca,
        _modeloColumn: modelo,
        _placaColumn: placa,
        _fipeColumn: fipe,
        _proprietarioColumn: proprietario,
        _valorSeguroColumn: valorSeguro,
      },
      where: '$_idColumn = ?',
      whereArgs: [id],
    );
  }
}

// --------------------- INFRACAO SERVICE ---------------------
class InfracaoService {
  static final InfracaoService instance = InfracaoService._constructor();
  final DatabaseService _databaseService = DatabaseService.instance;

  InfracaoService._constructor();

  final String _tableName = "infracao";
  final String _idColumn = "id";
  final String _descricaoColumn = "descricao";
  final String _naturezaColumn = "natureza";
  final String _localColumn = "local";
  final String _clienteColumn = "cliente";

  Future<void> addInfracao(
      String descricao, int natureza, String local, int cliente) async {
    final db = await _databaseService.database;
    await db.insert(
      _tableName,
      {
        _descricaoColumn: descricao,
        _naturezaColumn: natureza,
        _localColumn: local,
        _clienteColumn: cliente,
      },
    );
    // Após cadastrar, recalcula o valor do seguro
    await atualizarSeguroPorCliente(cliente, natureza);
  }

  Future<List<InfracaoModel>> getInfracao() async {
    final db = await _databaseService.database;
    final data = await db.query(_tableName);

    return data
        .map((e) => InfracaoModel(
              id: e[_idColumn] as int,
              descricao: e[_descricaoColumn] as String,
              natureza: e[_naturezaColumn] as int,
              local: e[_localColumn] as String,
              clienteId: e[_clienteColumn] as int,
            ))
        .toList();
  }

  Future<List<InfracaoModel>> getInfracaoPorCliente(int id) async {
    final db = await _databaseService.database;

    final data = await db.query(
      _tableName,
      where: '$_clienteColumn = ?', // Filtra pelo ID do cliente
      whereArgs: [id], // Passa o argumento para evitar SQL Injection
    );

    return data
        .map((e) => InfracaoModel(
              id: e[_idColumn] as int,
              descricao: e[_descricaoColumn] as String,
              natureza: e[_naturezaColumn] as int,
              local: e[_localColumn] as String,
              clienteId:
                  e[_clienteColumn] as int, // Cliente é um inteiro, não String
            ))
        .toList();
  }

  Future<void> deleteInfracao(int id) async {
    final db = await _databaseService.database;
    await db.delete(_tableName, where: '$_idColumn = ?', whereArgs: [id]);
  }

  Future<void> updateInfracao(int id, String descricao, String natureza,
      String local, String cliente) async {
    final db = await _databaseService.database;
    await db.update(
      _tableName,
      {
        _descricaoColumn: descricao,
        _naturezaColumn: natureza,
        _localColumn: local,
        _clienteColumn: cliente,
      },
      where: '$_idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<void> atualizarSeguroPorCliente(int clienteId, int tipo) async {
    final db = await _databaseService.database;
    double estadoCivilValor;
    double idadeValor;
    double novoValorSeguro = 0;
    double valorBaseSeguro = 0;
    double infracaoValor = 1;

    // Busca todos os automóveis do cliente
    final automoveis = await db.query(
      'automovel',
      columns: ['id', 'fipe', 'valorSeguro'],
      where: 'cliente = ?',
      whereArgs: [clienteId],
    );

    switch (tipo) {
      case 1:
        infracaoValor = 1.01;
        break;
      case 2:
        infracaoValor = 1.02;
        break;
      case 3:
        infracaoValor = 1.03;
        break;
      case 4:
        infracaoValor = 1.04;
        break;
      case 5:
        infracaoValor = 1.05;
        break;
      default:
        final cliente = await db.query(
          'cliente',
          columns: ['estadoCivil', 'idade'],
          where: 'id = ?',
          whereArgs: [clienteId],
        );

        if (cliente.isNotEmpty) {
          final clienteData = cliente.first;

          switch (clienteData['estadoCivil'].toString()) {
            case 'solteiro':
              estadoCivilValor = 0.15;
              break;
            case 'casado':
              estadoCivilValor = 0.1;
              break;
            case 'uniao_estavel':
              estadoCivilValor = 0.5;
              break;
            case 'divorciado':
              estadoCivilValor = 0.10;
              break;
            default:
              estadoCivilValor = 0.1;
          }

          if (clienteData['idade'] as int <= 25) {
            idadeValor = 0.20;
          } else if (clienteData['idade'] as int <= 30) {
            idadeValor = 0.15;
          } else if (clienteData['idade'] as int <= 40) {
            idadeValor = 0.10;
          } else if (clienteData['idade'] as int <= 50) {
            idadeValor = 0.05;
          } else {
            idadeValor = 0.03;
          }
        } else {
          estadoCivilValor = 0.1;
          idadeValor = 0.03;
        }
        valorBaseSeguro = 1000.0 * (idadeValor + estadoCivilValor);
    }

    // Atualiza o valor do seguro para todos os automóveis do cliente
    for (var automovel in automoveis) {
      if (automovel['valorSeguro'] == 1) {
        novoValorSeguro =
            ((automovel['fipe'] as num).toDouble() * 0.03) + valorBaseSeguro;
      } else {
        novoValorSeguro =
            (automovel['valorSeguro'] as num).toDouble() * infracaoValor;
      }

      await db.update(
        'automovel',
        {'ValorSeguro': novoValorSeguro},
        where: 'id = ?',
        whereArgs: [automovel['id']],
      );
    }
  }
}

// --------------------- USER SERVICE ---------------------
class UserService {
  static final UserService instance = UserService._constructor();
  final DatabaseService _databaseService = DatabaseService.instance;

  UserService._constructor();

  Future<void> addUser(String name, String email, String passwordHash) async {
    final db = await _databaseService.database;
    await db.insert('users', {
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
    });
  }

  Future<int> insertUser(User user) async {
    final db = await _databaseService.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}
