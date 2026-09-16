import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // বর্তমান লগইন করা ইউজারের আইডি নেওয়া
  String get _currentDriverId => _auth.currentUser?.uid ?? 'test_driver_id';

  // ফায়ারবেস থেকে লাইভ ব্যালেন্স স্ট্রিম (রিয়েল-টাইম সিঙ্ক)
  Stream<double> getWalletBalanceStream() {
    return _firestore
        .collection('drivers')
        .doc(_currentDriverId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('walletBalance')) {
        return (snapshot.data()!['walletBalance'] ?? 0.0).toDouble();
      }
      return 0.0; // ডিফল্ট ব্যালেন্স শূন্য
    });
  }

  // ফায়ারবেসে সিকিউরড উপায়ে টাকা যোগ করা
  Future<bool> addMoneyToWallet(double amount) async {
    try {
      if (amount <= 0) return false;

      // অ্যাটমিক ট্রানজেকশন যাতে ডাটাবেজে কোনো গড়মিল না হয়
      bool isSuccess = await _firestore.runTransaction((transaction) async {
        DocumentReference driverRef = _firestore.collection('drivers').doc(_currentDriverId);
        DocumentSnapshot snapshot = await transaction.get(driverRef);

        double currentBalance = 0.0;
        if (snapshot.exists && snapshot.data() != null) {
          currentBalance = ((snapshot.data() as Map<String, dynamic>)['walletBalance'] ?? 0.0).toDouble();
        }

        double newBalance = currentBalance + amount;

        // ব্যালেন্স আপডেট এবং ট্রানজেকশন রেকর্ড সেভ
        transaction.set(driverRef, {'walletBalance': newBalance}, SetOptions(merge: true));
        
        DocumentReference txnRef = _firestore.collection('wallet_transactions').doc();
        transaction.set(txnRef, {
          'driverId': _currentDriverId,
          'amount': amount,
          'type': 'CREDIT',
          'timestamp': DateTime.now().toIso8601String(),
        });

        return true;
      });

      return isSuccess;
    } catch (e) {
      debugPrint("Firebase Add Money Error: $e");
      return false;
    }
  }

  // ফায়ারবেস সিকিউরড উইথড্র লজিক (যাতে ব্যালেন্সের বেশি কেউ তুলতে না পারে)
  Future<Map<String, dynamic>> withdrawMoney(double amount) async {
    try {
      if (amount <= 0) return {'success': false, 'message': 'সঠিক পরিমাণ লিখুন'};

      Map<String, dynamic> result = await _firestore.runTransaction((transaction) async {
        DocumentReference driverRef = _firestore.collection('drivers').doc(_currentDriverId);
        DocumentSnapshot snapshot = await transaction.get(driverRef);

        double currentBalance = 0.0;
        if (snapshot.exists && snapshot.data() != null) {
          currentBalance = ((snapshot.data() as Map<String, dynamic>)['walletBalance'] ?? 0.0).toDouble();
        }

        // ফাঁকফোকর বন্ধ: ওয়ালেটে পর্যাপ্ত টাকা না থাকলে উইথড্র ব্লক হবে
        if (currentBalance < amount) {
          return {'success': false, 'message': 'পর্যাপ্ত ওয়ালেট ব্যালেন্স নেই!'};
        }

        double newBalance = currentBalance - amount;
        transaction.set(driverRef, {'walletBalance': newBalance}, SetOptions(merge: true));

        DocumentReference payoutRef = _firestore.collection('wallet_payouts').doc();
        transaction.set(payoutRef, {
          'driverId': _currentDriverId,
          'amount': amount,
          'type': 'DEBIT_WITHDRAW',
          'timestamp': DateTime.now().toIso8601String(),
        });

        return {'success': true, 'message': '₹$amount সফলভাবে উইথড্র করা হয়েছে!'};
      });

      return result;
    } catch (e) {
      debugPrint("Firebase Withdraw Error: $e");
      return {'success': false, 'message': 'সার্ভার ত্রুটি: $e'};
    }
  }
}