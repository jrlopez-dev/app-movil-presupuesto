import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/presupuesto.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('presupuestos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE presupuestos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      proyecto TEXT NOT NULL,
      cliente TEXT NOT NULL,
      fecha INTEGER NOT NULL,
      material REAL NOT NULL,
      pintura REAL NOT NULL,
      transporte REAL NOT NULL,
      mano_obra REAL NOT NULL,
      total REAL NOT NULL,
      porcentaje_anticipo REAL NOT NULL,
      monto_anticipo REAL NOT NULL
    )
    ''');
  }

  Future<int> insertPresupuesto(Presupuesto p) async {
    final db = await database;
    return await db.insert('presupuestos', p.toMap());
  }

  Future<int> updatePresupuesto(Presupuesto p) async {
    final db = await database;
    return await db.update('presupuestos', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deletePresupuesto(int id) async {
    final db = await database;
    return await db.delete('presupuestos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Presupuesto>> getAllPresupuestos() async {
    final db = await database;
    final maps = await db.query('presupuestos', orderBy: 'fecha DESC');
    return maps.map((m) => Presupuesto.fromMap(m)).toList();
  }

  Future<Presupuesto?> getPresupuestoById(int id) async {
    final db = await database;
    final maps = await db.query('presupuestos', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Presupuesto.fromMap(maps.first);
    return null;
  }
}
