import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BreakdownScreen extends StatefulWidget {
  final String rideId;
  const BreakdownScreen({super.key, required this.rideId});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  bool _isSubmitting = false;

  // ফায়ারবেসে ব্রেকডাউন বা SOS রিপোর্ট পাঠানোর লজিক
  Future<void> _sendEmergencyBreakdown() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // ১. রানিং রাইডের স্ট্যাটাস আপডেট করা
      await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).update({
        'status': 'broken_down',
        'breakdownTime': FieldValue.serverTimestamp(),
        'breakdownDriverId': user?.uid ?? 'unknown_driver',
      });

      // ২. ইমার্জেন্সি পুল বা অ্যাডমিন অ্যালার্টে যুক্ত করা
      await FirebaseFirestore.instance.collection('emergency_breakdowns').add({
        'rideId': widget.rideId,
        'driverId': user?.uid ?? 'unknown_driver',
        'status': 'active_rescue_needed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚨 ব্রেকডাউন অ্যালার্ট সফলভাবে পাঠানো হয়েছে! মেকানিক ও অ্যাডমিনকে জানানো হচ্ছে।"),
          backgroundColor: Colors.redAccent,
        ),
      );

      Navigator.pop(context); // আগের স্ক্রিনে ফিরে যাওয়া
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ত্রুটি হয়েছে: $e"),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "ইমার্জেন্সি ব্রেকডাউন (SOS)",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "গাড়ি বা ব্যাটারিতে বড় কোনো সমস্যা হয়েছে?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "নিচের বাটনে প্রেস করলেই তৎক্ষণাৎ কন্ট্রোল রুম এবং কাছাকাছি মেকানিকদের কাছে আপনার লাইভ লোকেশন ও SOS অ্যালارت চলে যাবে।",
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _sendEmergencyBreakdown,
                icon: _isSubmitting
                    const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sos, size: 24),
                label: Text(
                  _isSubmitting ? "পাঠানো হচ্ছে..." : "জরুরি সাহায্য (SOS) পাঠান",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}