import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class TripManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ১. নতুন ট্রিপ শুরু করা (ড্রাইভার ও প্যাসেঞ্জারের প্রোফাইল তথ্যসহ)
  Future<String> startTrip({
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String passengerName,
    required String passengerPhone,
    required String startLocation,
    required String destination,
    required bool isPersonal,
    required int totalSeats,
    required double totalDistanceKm,
    required double totalFare,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('trips').add({
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'startLocation': startLocation,
        'destination': destination,
        'isPersonal': isPersonal,
        'totalSeats': totalSeats,
        'availableSeats': totalSeats,
        'totalDistanceKm': totalDistanceKm,
        'totalFare': totalFare,
        'gpsTimeline': [],
        'status': 'ongoing',
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception("ট্রিপ শুরু করতে সমস্যা হয়েছে: $e");
    }
  }

  // ২. শেয়ারিং ট্রিপে নতুন প্যাসেঞ্জার অ্যাড করা
  Future<void> addPassengerToSharingTrip({
    required String tripId,
    required String passengerName,
    required String passengerPhone,
    required String pickupPoint,
    required String dropPoint,
    required int seatsNeeded,
  }) async {
    DocumentReference tripRef = _firestore.collection('trips').doc(tripId);
    
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(tripRef);
      if (!snapshot.exists) throw Exception("ট্রিপটি পাওয়া যায়নি!");

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data['isPersonal'] ?? false) {
        throw Exception("এটি পার্সোনাল বুকিং! নতুন যাত্রী তোলা যাবে না।");
      }

      int availableSeats = data['availableSeats'] ?? 0;
      if (availableSeats < seatsNeeded) throw Exception("গাড়িতে পর্যাপ্ত ফাঁকা সিট নেই!");

      List passengers = List.from(data['passengers'] ?? []);
      passengers.add({
        'name': passengerName,
        'phone': passengerPhone,
        'pickup': pickupPoint,
        'drop': dropPoint,
        'seats': seatsNeeded,
      });

      transaction.update(tripRef, {
        'availableSeats': availableSeats - seatsNeeded,
        'passengers': passengers,
      });
    });
  }

  // ৩. গাড়ি খারাপ হলে SOS এবং ৪-সংখ্যার হ্যান্ডওভার কোড জেনারেট করা
  Future<String> triggerBreakdownAndGenerateCode({
    required String tripId,
    required double kmCovered, 
  }) async {
    try {
      String handoverCode = (1000 + Random().nextInt(9000)).toString();

      await _firestore.collection('trips').doc(tripId).update({
        'status': 'broken_down',
        'completedKm': kmCovered,
        'handoverCode': handoverCode,
      });

      await _firestore.collection('breakdown_alerts').add({
        'tripId': tripId,
        'completedKm': kmCovered,
        'handoverCode': handoverCode,
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return handoverCode;
    } catch (e) {
      throw Exception("ব্রেকডাউন অ্যালার্ট পাঠাতে সমস্যা হয়েছে: $e");
    }
  }

  // ৪. নতুন ড্রাইভার কোড দিয়ে ট্রিপ টেকওভার করা (লেজার হিসাবসহ)
  Future<bool> verifyCodeAndTakeoverTrip({
    required String tripId,
    required String enteredCode,
    required String newDriverId,
    required String newDriverName,
    required String newDriverPhone,
  }) async {
    DocumentReference tripRef = _firestore.collection('trips').doc(tripId);

    return await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(tripRef);
      if (!snapshot.exists) return false;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      String actualCode = data['handoverCode'] ?? '';

      if (actualCode == enteredCode) {
        double totalDist = (data['totalDistanceKm'] ?? 10.0).toDouble();
        double totalFare = (data['totalFare'] ?? 100.0).toDouble();
        double kmCovered = (data['completedKm'] ?? 0.0).toDouble();

        double ratePerKm = totalFare / totalDist;
        double firstDriverEarnings = kmCovered * ratePerKm;
        double remainingFare = totalFare - firstDriverEarnings;

        transaction.update(tripRef, {
          'driverId': newDriverId,
          'driverName': newDriverName,
          'driverPhone': newDriverPhone,
          'status': 'handed_over',
          'firstDriverEarnings': firstDriverEarnings,
          'remainingFareForNewDriver': remainingFare,
          'handoverVerified': true,
        });

        return true;
      }
      return false;
    });
  }

  // ৫. ব্যাকগ্রাউন্ডে প্রতি ১ মিনিট পর পর জিপিএস ও টাইমস্ট্যাম্প আপডেট করা (প্যাসেঞ্জারের ফোন অফ থাকলেও কাজ করবে)
  Future<void> updateGpsTimeline({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      DocumentReference tripRef = _firestore.collection('trips').doc(tripId);
      
      await tripRef.update({
        'gpsTimeline': FieldValue.arrayUnion([
          {
            'lat': latitude,
            'lng': longitude,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ])
      });
    } catch (e) {
      // ব্যাকগ্রাউন্ড লকিং ফেইল যেন না করে
    }
  }

  // ৬. ট্রিপ শেষ করার সময় OTP, পেমেন্ট এবং ৩ দিন মেয়াদের সিক্রেট ভিডিও প্রুফ সেভ করা
  Future<void> completeTripWithAutoDeleteVideoProof({
    required String tripId,
    required bool isAtTargetLocation,
    String? otpEntered,
    required String secretVideoUrl, // ব্যাকগ্রাউন্ডে রেকর্ড হওয়া ভিডিও ফাইল লিংক
    required double finalLatitude,
    required double finalLongitude,
    required bool isPaid,
  }) async {
    DocumentReference tripRef = _firestore.collection('trips').doc(tripId);

    // ঠিক ৩ দিন পরের ডেট ও টাইম হিসাব (অটো-ডিলিট বা এক্সপায়ারি সময়ের জন্য)
    DateTime expiryDate = DateTime.now().add(const Duration(days: 3));

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(tripRef);
      if (!snapshot.exists) throw Exception("ট্রিপটি পাওয়া যায়নি!");

      transaction.update(tripRef, {
        'status': isPaid ? 'completed' : 'payment_dispute',
        'paymentStatus': isPaid ? 'paid' : 'unpaid_dispute',
        'verificationMethod': isAtTargetLocation && otpEntered != null ? 'OTP_Verified' : 'Manual_Closed',
        'otpUsed': otpEntered ?? '',
        'finalDropLocation': {
          'lat': finalLatitude,
          'lng': finalLongitude,
          'dropTime': DateTime.now().toIso8601String(),
        },
        'secretVideoProofUrl': secretVideoUrl, // ভিডিও প্রুফ লিংক
        'videoExpiryTime': expiryDate.toIso8601String(), // ৩ দিন পর ভিডিও এক্সপায়ার হবে
        'tripClosedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}