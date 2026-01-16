import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
                  ),
                  child: const Icon(Icons.insert_drive_file, size: 64, color: Colors.blueGrey),
                ),
                const SizedBox(height: 24),
                const Text('Presupuestos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Crea y gestiona presupuestos rápidamente', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_box),
                  label: const Text('Nuevo presupuesto'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:24, vertical:14)),
                  onPressed: () => Navigator.pushNamed(context, '/create'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Historial'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:24, vertical:14)),
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
