import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/presupuesto.dart';
import '../providers/presupuesto_provider.dart';

class PresupuestoForm extends StatefulWidget {
  const PresupuestoForm({super.key});

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

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _fecha = d);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = Presupuesto(
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
    await provider.add(p);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Presupuesto guardado')),
    );

    // Limpiar formulario
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
    final f = NumberFormat.currency(locale: 'es_ES', symbol: '', decimalDigits: 2);

    return Form(
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
                  label: const Text('GUARDAR'),
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
                  label: const Text('GENERAR PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    // TODO: llamar a función de export PDF
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generar PDF (implementación pendiente)')));
                  },
                ),
              ),
            ],
          ),
        ],
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
