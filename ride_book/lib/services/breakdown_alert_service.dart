import 'package:cloud_firestore/cloud_firestore.dart';

class BreakdownAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ১. গাড়ি খারাপ হলে ইমার্জেন্সি অ্যালার্ট ব্রডকাস্ট করা
  Future<void> sendBreakdownAlert({
    required String driverId,
    required String driverName,
    required String locationDetails,
  }) async {
    try {
      await _firestore.collection('breakdown_alerts').add({
        'driverId': driverId,
        'driverName': driverName,
        'location': locationDetails,
        'status': 'active', // active, resolved
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("ইমার্জেন্সি অ্যালার্ট পাঠাতে সমস্যা হয়েছে: $e");
    }
  }

  // ২. আশেপাশের ড্রাইভারদের জন্য লাইভ অ্যালার্ট স্ট্রিম
  Stream<QuerySnapshot> getActiveBreakdownAlerts() {
    return _firestore
        .collection('breakdown_alerts')
        .where('status', '==', 'active')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}