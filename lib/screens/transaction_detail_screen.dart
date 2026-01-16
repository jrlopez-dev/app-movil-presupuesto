import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../models/presupuesto.dart';
import '../providers/presupuesto_provider.dart';
import '../utils/pdf_export.dart';
import '../utils/image_capture.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Presupuesto? p;
  final ScreenshotController _screenshotController = ScreenshotController();

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

  Future<void> _exportPdf() async {
    if (p == null) return;
    await PdfExport.exportPresupuestoToPdf(p!);
  }

  Future<void> _exportImage() async {
    if (p == null) return;
    // Capturar el widget que muestra el detalle
    final bytes = await _screenshotController.capture(pixelRatio: 2.0);
    if (bytes == null) return;
    final file = await ImageCapture.savePng(bytes, 'presupuesto_${p!.id}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imagen guardada: ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    if (p == null) return const Scaffold(body: Center(child: Text('No hay datos')));
    final f = NumberFormat.simpleCurrency(locale: 'en_US', name: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),
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
          child: Screenshot(
            controller: _screenshotController,
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
                        const SizedBox(height: 6),
                        Text('Nota: ${p!.nota}'),
                        const Divider(),
                        Text('Material: ${f.format(p!.material)}'),
                        Text('Pintura: ${f.format(p!.pintura)}'),
                        Text('Transporte: ${f.format(p!.transporte)}'),
                        Text('Mano de obra: ${f.format(p!.manoObra)}'),
                        const SizedBox(height: 8),
                        Text('Total: ${f.format(p!.total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Anticipo: ${p!.porcentajeAnticipo.toStringAsFixed(0)}% — ${f.format(p!.montoAnticipo)}'),
                        const SizedBox(height: 4),
                        Text('Monto restante: ${f.format(p!.total - p!.montoAnticipo)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('EDITAR'),
                  onPressed: () {
                    // Navegar al formulario principal con el presupuesto como argumento para editar
                    Navigator.pushNamed(context, '/create', arguments: p);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('EXPORTAR PDF'),
                  onPressed: _exportPdf,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('EXPORTAR IMAGEN'),
                  onPressed: _exportImage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
