import 'package:cloud_firestore/cloud_firestore.dart';

class PartsPricingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ফায়ারবেস থেকে সমস্ত পার্টসের লাইভ স্ট্রিম আনা
  Stream<QuerySnapshot> getPartsStream() {
    return _firestore.collection('toto_parts').orderBy('name').snapshots();
  }

  // অ্যাডমিন বা মেকানিক কর্তৃক নতুন পার্টস যুক্ত করার মেথড (ছবি, নাম ও দামসহ)
  Future<void> addPart({
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    try {
      await _firestore.collection('toto_parts').add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding part: $e");
    }
  }
}