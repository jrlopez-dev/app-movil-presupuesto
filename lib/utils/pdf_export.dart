import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

import '../models/presupuesto.dart';

class PdfExport {
  static Future<void> exportPresupuestoToPdf(Presupuesto p) async {
    final doc = pw.Document();
    final f = NumberFormat.simpleCurrency(locale: 'es_ES');
    doc.addPage(
      pw.Page(
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Presupuesto', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Proyecto: ${p.proyecto}'),
              pw.Text('Cliente: ${p.cliente}'),
              pw.Text('Fecha: ${DateFormat.yMMMMd('es').format(p.fecha)}'),
              pw.SizedBox(height: 12),
              pw.Text('Desglose:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text('Material: ${f.format(p.material)}'),
              pw.Text('Pintura: ${f.format(p.pintura)}'),
              pw.Text('Transporte: ${f.format(p.transporte)}'),
              pw.Text('Mano de obra: ${f.format(p.manoObra)}'),
              pw.Divider(),
              pw.Text('Total: ${f.format(p.total)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text('Anticipo: ${p.porcentajeAnticipo.toStringAsFixed(0)}% - ${f.format(p.montoAnticipo)}'),
            ],
          ),
        ),
      ),
    );

    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/presupuesto_${p.id ?? DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);

    // Abrir preview/compartir
    await Printing.sharePdf(bytes: bytes, filename: file.path.split('/').last);
  }
}
