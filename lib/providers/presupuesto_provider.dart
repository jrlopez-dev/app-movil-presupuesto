import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/presupuesto.dart';

class PresupuestoProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<Presupuesto> _items = [];
  bool _loading = false;

  List<Presupuesto> get items => _items;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _items = await _db.getAllPresupuestos();
    _loading = false;
    notifyListeners();
  }

  Future<int> add(Presupuesto p) async {
    final id = await _db.insertPresupuesto(p);
    await loadAll();
    return id;
  }

  Future<void> update(Presupuesto p) async {
    if (p.id == null) return;
    await _db.updatePresupuesto(p);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _db.deletePresupuesto(id);
    await loadAll();
  }
}
