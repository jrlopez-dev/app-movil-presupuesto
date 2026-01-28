import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/presupuesto_provider.dart';
import '../models/presupuesto.dart';
import '../widgets/presupuesto_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Presupuesto? editing;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    provider.loadAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg != null && arg is Presupuesto) {
      editing = arg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),
        title: const Text('Crear / Editar Presupuesto'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'history') Navigator.pushNamed(context, '/history');
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'history', child: ListTile(leading: Icon(Icons.history), title: Text('Historial'))),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PresupuestoForm(presupuesto: editing),
            ],
          ),
        ),
      ),
    );
  }
}
