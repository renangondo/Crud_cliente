import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cliente.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'clientes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clientes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            telefone TEXT NOT NULL,
            cep TEXT NOT NULL,
            rua TEXT,
            bairro TEXT,
            cidade TEXT,
            estado TEXT
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> inserir(Cliente c) async {
    final db = await database;
    return db.insert('clientes', c.toMap()..remove('id'));
  }

  // READ
  Future<List<Cliente>> listar() async {
    final db = await database;
    final rows = await db.query('clientes', orderBy: 'nome');
    return rows.map(Cliente.fromMap).toList();
  }

  // UPDATE
  Future<int> atualizar(Cliente c) async {
    final db = await database;
    return db.update('clientes', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  // DELETE
  Future<int> excluir(int id) async {
    final db = await database;
    return db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }
}