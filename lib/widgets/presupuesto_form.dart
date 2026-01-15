import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../models/presupuesto.dart';
import '../providers/presupuesto_provider.dart';
import '../utils/pdf_export.dart';
import '../utils/image_capture.dart';

class PresupuestoForm extends StatefulWidget {
  final Presupuesto? presupuesto;
  const PresupuestoForm({super.key, this.presupuesto});

  @override
  State<PresupuestoForm> createState() => _PresupuestoFormState();
}

class _PresupuestoFormState extends State<PresupuestoForm> {
  final _formKey = GlobalKey<FormState>();
  final _proyectoCtrl = TextEditingController();
  final _clienteCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  final _materialCtrl = TextEditingController(text: '0');
  final _pinturaCtrl = TextEditingController(text: '0');
  final _transporteCtrl = TextEditingController(text: '0');
  final _manoCtrl = TextEditingController(text: '0');

  double _porcentaje = 0.0;

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    if (widget.presupuesto != null) {
      final p = widget.presupuesto!;
      _proyectoCtrl.text = p.proyecto;
      _clienteCtrl.text = p.cliente;
      _fecha = p.fecha;
      _materialCtrl.text = p.material.toStringAsFixed(2);
      _pinturaCtrl.text = p.pintura.toStringAsFixed(2);
      _transporteCtrl.text = p.transporte.toStringAsFixed(2);
      _manoCtrl.text = p.manoObra.toStringAsFixed(2);
      _porcentaje = p.porcentajeAnticipo;
    }
  }

  double _parse(String v) {
    final cleaned = v.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get _total {
    return _parse(_materialCtrl.text) +
        _parse(_pinturaCtrl.text) +
        _parse(_transporteCtrl.text) +
        _parse(_manoCtrl.text);
  }

  double get _montoAnticipo => (_total * _porcentaje) / 100.0;
  double get _montoRestante => (_total - _montoAnticipo);

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = Presupuesto(
      id: widget.presupuesto?.id,
      proyecto: _proyectoCtrl.text.trim(),
      cliente: _clienteCtrl.text.trim(),
      fecha: _fecha,
      material: _parse(_materialCtrl.text),
      pintura: _parse(_pinturaCtrl.text),
      transporte: _parse(_transporteCtrl.text),
      manoObra: _parse(_manoCtrl.text),
      total: _total,
      porcentajeAnticipo: _porcentaje,
      montoAnticipo: _montoAnticipo,
    );

    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    if (widget.presupuesto == null) {
      await provider.add(p);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Presupuesto guardado')));
    } else {
      await provider.update(p);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Presupuesto actualizado')));
    }

    // Limpiar formulario si era nuevo
    if (widget.presupuesto == null) {
      _formKey.currentState!.reset();
      _proyectoCtrl.clear();
      _clienteCtrl.clear();
      _materialCtrl.text = '0';
      _pinturaCtrl.text = '0';
      _transporteCtrl.text = '0';
      _manoCtrl.text = '0';
      setState(() {
        _porcentaje = 0;
        _fecha = DateTime.now();
      });
    }
  }

  Future<void> _exportPdf() async {
    final p = Presupuesto(
      id: widget.presupuesto?.id,
      proyecto: _proyectoCtrl.text.trim(),
      cliente: _clienteCtrl.text.trim(),
      fecha: _fecha,
      material: _parse(_materialCtrl.text),
      pintura: _parse(_pinturaCtrl.text),
      transporte: _parse(_transporteCtrl.text),
      manoObra: _parse(_manoCtrl.text),
      total: _total,
      porcentajeAnticipo: _porcentaje,
      montoAnticipo: _montoAnticipo,
    );
    await PdfExport.exportPresupuestoToPdf(p);
  }

  Future<void> _exportImage() async {
    final bytes = await _screenshotController.capture(pixelRatio: 2.0);
    if (bytes == null) return;
    final file = await ImageCapture.savePng(bytes, 'presupuesto_${widget.presupuesto?.id ?? DateTime.now().millisecondsSinceEpoch}');
    // TODO: compartir con share_plus si se desea
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imagen guardada: ${file.path}')));
  }

  @override
  void dispose() {
    _proyectoCtrl.dispose();
    _clienteCtrl.dispose();
    _materialCtrl.dispose();
    _pinturaCtrl.dispose();
    _transporteCtrl.dispose();
    _manoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.simpleCurrency(locale: 'en_US', name: '\$', decimalDigits: 2);

    return Screenshot(
      controller: _screenshotController,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _proyectoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del proyecto',
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _clienteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Fecha: ${DateFormat.yMMMMd('es').format(_fecha)}'),
                        ),
                        TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Seleccionar'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Desglose de montos', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _moneyField('Monto de material', _materialCtrl, Icons.build),
                    const SizedBox(height: 8),
                    _moneyField('Monto de pintura', _pinturaCtrl, Icons.format_paint),
                    const SizedBox(height: 8),
                    _moneyField('Monto de transporte', _transporteCtrl, Icons.local_shipping),
                    const SizedBox(height: 8),
                    _moneyField('Monto de mano de obra', _manoCtrl, Icons.handyman),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.blueGrey[50],
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Total: ${f.format(_total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Anticipo:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _porcentaje,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: '${_porcentaje.toStringAsFixed(0)}%',
                            onChanged: (v) => setState(() => _porcentaje = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${_porcentaje.toStringAsFixed(0)}%')
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Monto anticipo: ${f.format(_montoAnticipo)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Monto restante: ${f.format(_montoRestante)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(widget.presupuesto == null ? 'GUARDAR' : 'ACTUALIZAR'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _save,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _exportPdf,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('IMAGEN'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _exportImage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moneyField(String label, TextEditingController ctrl, IconData icon) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: '\$ ',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requerido';
        final n = double.tryParse(v.replaceAll(',', ''));
        if (n == null) return 'Número inválido';
        if (n < 0) return 'No puede ser negativo';
        return null;
      },
      onChanged: (v) => setState(() {}),
    );
  }
}
