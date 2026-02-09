import 'package:flutter/services.dart';

/// Formatea un input numérico en tiempo real como moneda:
/// - Separador de miles con coma: 555,550.00
/// - 2 decimales fijos (cuando hay parte decimal)
/// - Permite escribir solo dígitos y un separador decimal (.)
///
/// Internamente trabaja con '.' como separador decimal.
class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter({this.decimalDigits = 2});

  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;

    if (raw.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Normalizar: permitir ',' como decimal solo si NO hay '.', pero aquí lo tratamos como separador de miles.
    // Para evitar ambigüedad, convertimos ',' a nada y dejamos '.' como único decimal.
    // Si el usuario teclea ',', lo ignoramos como miles.
    String cleaned = raw.replaceAll(',', '');

    // Permitir solo dígitos y '.'
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9\.]'), '');

    // Si hay más de un punto, dejamos el primero
    final firstDot = cleaned.indexOf('.');
    if (firstDot != -1) {
      final before = cleaned.substring(0, firstDot);
      final after = cleaned.substring(firstDot + 1).replaceAll('.', '');
      cleaned = '$before.$after';
    }

    // Limitar decimales
    if (firstDot != -1) {
      final parts = cleaned.split('.');
      final dec = parts.length > 1 ? parts[1] : '';
      if (dec.length > decimalDigits) {
        cleaned = '${parts[0]}.${dec.substring(0, decimalDigits)}';
      }
    }

    // Separar entero y decimal
    final parts = cleaned.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    // Formatear miles en la parte entera
    final formattedInt = _formatThousands(intPart);

    final formatted = decPart == null ? formattedInt : '$formattedInt.$decPart';

    // Mantener el cursor lo más al final posible
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatThousands(String digits) {
    if (digits.isEmpty) return '';

    // Evitar ceros a la izquierda excesivos, pero permitir "0"
    String d = digits.replaceFirst(RegExp(r'^0+(?!$)'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      final indexFromEnd = d.length - i;
      buffer.write(d[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
