import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/presupuesto.dart';
import '../providers/presupuesto_provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Presupuesto? p;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null && arg is Presupuesto) {
      p = arg;
    }
  }

  void _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Desea eliminar este presupuesto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true && p != null && p!.id != null) {
      await Provider.of<PresupuestoProvider>(context, listen: false).delete(p!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (p == null) return const Scaffold(body: Center(child: Text('No hay datos')));
    final f = NumberFormat.simpleCurrency(locale: 'es_ES');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del presupuesto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p!.proyecto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Cliente: ${p!.cliente}'),
                      Text('Fecha: ${DateFormat.yMMMMd('es').format(p!.fecha)}'),
                      const Divider(),
                      Text('Material: ${f.format(p!.material)}'),
                      Text('Pintura: ${f.format(p!.pintura)}'),
                      Text('Transporte: ${f.format(p!.transporte)}'),
                      Text('Mano de obra: ${f.format(p!.manoObra)}'),
                      const SizedBox(height: 8),
                      Text('Total: ${f.format(p!.total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Anticipo: ${p!.porcentajeAnticipo.toStringAsFixed(0)}% — ${f.format(p!.montoAnticipo)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('EDITAR'),
                onPressed: () {
                  // TODO: implementar edición
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edición pendiente')));
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('EXPORTAR PDF'),
                onPressed: () {
                  // TODO: implementar exportar
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportar PDF (pendiente)')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
