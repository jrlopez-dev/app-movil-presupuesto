import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/presupuesto_provider.dart';
import '../models/presupuesto.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PresupuestoProvider>(context, listen: false).loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PresupuestoProvider>(context);
    final f = NumberFormat.simpleCurrency(locale: 'en_US', name: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de presupuestos'),
      ),
      body: SafeArea(
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.items.isEmpty
                ? const Center(child: Text('No hay presupuestos'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final p = provider.items[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(p.proyecto),
                          subtitle: Text('${p.cliente} • ${DateFormat.yMMMd('es').format(p.fecha)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(f.format(p.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Restante: ${f.format(p.total - p.montoAnticipo)}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: p),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
