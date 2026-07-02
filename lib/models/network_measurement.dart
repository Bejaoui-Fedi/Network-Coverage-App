class NetworkMeasurement {
  final int id;
  final String deviceId;
  final DateTime dateHeure;
  final double latitude;
  final double longitude;
  final String operateur;
  final String typeReseau;
  final int? rssi;
  final int? rsrp;
  final int? rsrq;
  final double? snr;
  final int? latence;
  final double? downloadSpeed;
  final double? uploadSpeed;
  final double? gpsSpeed;
  final String? cellId;
  final String? pci;
  final String? band;
  final DateTime createdAt;

  NetworkMeasurement({
    required this.id,
    required this.deviceId,
    required this.dateHeure,
    required this.latitude,
    required this.longitude,
    required this.operateur,
    required this.typeReseau,
    this.rssi,
    this.rsrp,
    this.rsrq,
    this.snr,
    this.latence,
    this.downloadSpeed,
    this.uploadSpeed,
    this.gpsSpeed,
    this.cellId,
    this.pci,
    this.band,
    required this.createdAt,
  });

  factory NetworkMeasurement.fromJson(Map<String, dynamic> json) {
    return NetworkMeasurement(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      deviceId: json['device_id']?.toString() ?? '',
      dateHeure: DateTime.parse(json['date_heure'] as String),
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      operateur: json['operateur']?.toString() ?? '',
      typeReseau: json['type_reseau']?.toString() ?? '',
      rssi: json['rssi'] != null ? num.tryParse(json['rssi'].toString())?.toInt() : null,
      rsrp: json['rsrp'] != null ? num.tryParse(json['rsrp'].toString())?.toInt() : null,
      rsrq: json['rsrq'] != null ? num.tryParse(json['rsrq'].toString())?.toInt() : null,
      snr: json['snr'] != null ? double.tryParse(json['snr'].toString()) : null,
      latence: json['latence'] != null ? num.tryParse(json['latence'].toString())?.toInt() : null,
      downloadSpeed: json['download_speed'] != null ? double.tryParse(json['download_speed'].toString()) : null,
      uploadSpeed: json['upload_speed'] != null ? double.tryParse(json['upload_speed'].toString()) : null,
      gpsSpeed: json['gps_speed'] != null ? double.tryParse(json['gps_speed'].toString()) : null,
      cellId: json['cell_id']?.toString(),
      pci: json['pci']?.toString(),
      band: json['band']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'date_heure': dateHeure.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'operateur': operateur,
      'type_reseau': typeReseau,
      'rssi': rssi,
      'rsrp': rsrp,
      'rsrq': rsrq,
      'snr': snr,
      'latence': latence,
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'gps_speed': gpsSpeed,
      'cell_id': cellId,
      'pci': pci,
      'band': band,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
