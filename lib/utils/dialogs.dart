import 'package:flutter/material.dart';

/// Utilidades comunes para diálogos consistentes en toda la app.
class AppDialogs {
  static Future<void> ok(
    BuildContext context, {
    String title = 'Información',
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    String title = 'Confirmar',
    required String message,
    String cancelText = 'Cancelar',
    String okText = 'Aceptar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(okText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
