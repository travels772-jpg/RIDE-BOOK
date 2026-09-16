import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ফায়ারবেস থেকে লাইভ ব্যানার ডেটা স্ট্রিম আনার মেথড
  Stream<DocumentSnapshot> getBannerStream() {
    return _firestore.collection('settings').doc('admin_banner').snapshots();
  }
}

// ড্যাশবোর্ডে ব্যানার দেখানোর রিইউজেবল উইজেট
class AdminBannerWidget extends StatelessWidget {
  const AdminBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminBannerService bannerService = AdminBannerService();

    return StreamBuilder<DocumentSnapshot>(
      stream: bannerService.getBannerStream(),
      builder: (context, snapshot) {
        // ডিফল্ট বা ফলব্যাক ব্যানার ইমেজ ও টাইটেল
        String bannerUrl = "https://images.unsplash.com/photo-1579546929518-9e396f3cc809";
        String bannerTitle = "টোটো সার্ভিস ও ড্রাইভার আপডেট";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          bannerUrl = data['imageUrl'] ?? bannerUrl;
          bannerTitle = data['title'] ?? bannerTitle;
        }

        return Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(bannerUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              bannerTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}