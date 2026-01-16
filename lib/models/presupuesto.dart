class Presupuesto {
  int? id;
  String proyecto;
  String cliente;
  String nota;
  DateTime fecha;
  double material;
  double pintura;
  double transporte;
  double manoObra;
  double total;
  double porcentajeAnticipo;
  double montoAnticipo;

  Presupuesto({
    this.id,
    required this.proyecto,
    required this.cliente,
    required this.nota,
    required this.fecha,
    required this.material,
    required this.pintura,
    required this.transporte,
    required this.manoObra,
    required this.total,
    required this.porcentajeAnticipo,
    required this.montoAnticipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'proyecto': proyecto,
      'cliente': cliente,
      'nota': nota,
      'fecha': fecha.millisecondsSinceEpoch,
      'material': material,
      'pintura': pintura,
      'transporte': transporte,
      'mano_obra': manoObra,
      'total': total,
      'porcentaje_anticipo': porcentajeAnticipo,
      'monto_anticipo': montoAnticipo,
    };
  }

  factory Presupuesto.fromMap(Map<String, dynamic> map) {
    return Presupuesto(
      id: map['id'] as int?,
      proyecto: map['proyecto'] as String,
      cliente: map['cliente'] as String,
      nota: (map['nota'] as String?) ?? '',
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha'] as int),
      material: (map['material'] as num).toDouble(),
      pintura: (map['pintura'] as num).toDouble(),
      transporte: (map['transporte'] as num).toDouble(),
      manoObra: (map['mano_obra'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      porcentajeAnticipo: (map['porcentaje_anticipo'] as num).toDouble(),
      montoAnticipo: (map['monto_anticipo'] as num).toDouble(),
    );
  }
}
