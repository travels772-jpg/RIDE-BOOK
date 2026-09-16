class TripModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String passengerName;
  final String passengerPhone;
  final String startLocation;
  final String destination;
  final bool isPersonal;
  final int totalSeats;
  final int availableSeats;
  final double totalDistanceKm;
  final double totalFare;
  final String status;
  final String paymentStatus;
  final List<dynamic> gpsTimeline;
  final String? handoverCode;
  final String? secretVideoProofUrl;
  final String? videoExpiryTime;

  TripModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.passengerName,
    required this.passengerPhone,
    required this.startLocation,
    required this.destination,
    required this.isPersonal,
    required this.totalSeats,
    required this.availableSeats,
    required this.totalDistanceKm,
    required this.totalFare,
    required this.status,
    required this.paymentStatus,
    required this.gpsTimeline,
    this.handoverCode,
    this.secretVideoProofUrl,
    this.videoExpiryTime,
  });

  // ফায়ারবেস থেকে ডেটা রিড করার জন্য
  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    return TripModel(
      id: id,
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      passengerName: map['passengerName'] ?? '',
      passengerPhone: map['passengerPhone'] ?? '',
      startLocation: map['startLocation'] ?? '',
      destination: map['destination'] ?? '',
      isPersonal: map['isPersonal'] ?? true,
      totalSeats: map['totalSeats'] ?? 1,
      availableSeats: map['availableSeats'] ?? 1,
      totalDistanceKm: (map['totalDistanceKm'] ?? 0.0).toDouble(),
      totalFare: (map['totalFare'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'ongoing',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      gpsTimeline: map['gpsTimeline'] ?? [],
      handoverCode: map['handoverCode'],
      secretVideoProofUrl: map['secretVideoProofUrl'],
      videoExpiryTime: map['videoExpiryTime'],
    );
  }
}