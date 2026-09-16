import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black, // আপনার অ্যাপের ব্যাকগ্রাউন্ড কালার
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "লেনদেন ও রাইড হিস্ট্রি",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallet_transactions')
            .where('driverId', isEqualTo: currentUser?.uid ?? 'test_driver_id')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "কোনো ট্রানজেকশন হিস্ট্রি পাওয়া যায়নি।",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var txn = docs[index].data() as Map<String, dynamic>;
              String title = txn['title'] ?? 'রাইড পেমেন্ট';
              double amount = (txn['amount'] ?? 0.0).toDouble();
              bool isCredit = txn['type'] == 'credit';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isCredit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    child: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isCredit ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "সফল লেনদেন",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: Text(
                    "${isCredit ? '+' : '-'} ₹$amount",
                    style: TextStyle(
                      color: isCredit ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}