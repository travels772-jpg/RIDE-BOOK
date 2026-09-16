import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// আপনার প্রজেক্টের কনস্ট্যান্ট ফাইল পাথ অনুযায়ী এটি প্রয়োজনমতো ঠিক করে নেবেন:
// import 'constants.dart'; 

class UniqueDriverDashboard extends StatefulWidget {
  const UniqueDriverDashboard({Key? key}) : super(key: key);

  @override
  _UniqueDriverDashboardState createState() => _UniqueDriverDashboardState();
}

class _UniqueDriverDashboardState extends State<UniqueDriverDashboard> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // আপনার প্রজেক্টের কনস্ট্যান্ট ব্যাকগ্রাউন্ড কালার
      backgroundColor: Colors.black, // এখানে আপনার প্রজেক্টের AppColors.backgroundColor দিতে পারেন
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ১. কাস্টম অ্যাপ বার / হেডার অংশ (নাম ও প্রোফাইল)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "স্বাগতম,",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "সোনু মন্ডল", // আপনার নাম বা ড্রাইভার নাম
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ২. অ্যাডমিন কন্ট্রোলড ডায়নামিক ব্যানার (ঈদ, পূজো বা স্পেশাল নোটিশের ছবি)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('settings').doc('admin_banner').snapshots(),
                builder: (context, snapshot) {
                  // ডিফল্ট একটি সুন্দর ফেস্টিভ বা স্টাইলিশ ব্যানার ইমেজ
                  String bannerUrl = "https://images.unsplash.com/photo-1579546929518-9e396f3cc809"; 
                  String bannerTitle = "শুভ টোটো সার্ভিস!";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    bannerUrl = data['imageUrl'] ?? bannerUrl;
                    bannerTitle = data['title'] ?? bannerTitle;
                  }

                  return Container(
                    width: double.infinity,
                    height: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // ৩. ফায়ারবেস থেকে লাইভ ব্যালেন্স ও ওয়ালেট কার্ড
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(currentUser?.uid ?? 'test_driver_id')
                    .snapshots(),
                builder: (context, snapshot) {
                  double balance = 0.0;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    balance = (data['balance'] ?? 0.0).toDouble();
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B), // কার্ডের নিজস্ব প্রিমিয়াম কালার
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "বর্তমান ওয়ালেট ব্যালেন্স",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹ ${balance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // টাকা যোগ করার অপশন
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Add Money clicked")),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("টাকা যোগ"),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ৪. কুইক সার্ভিসেস বা শর্টকাট বাটনস
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "কুইক সার্ভিসেস",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeatureCard(Icons.directions_car, "আমার রাইড"),
                    _buildFeatureCard(Icons.build, "গাড়ি মেরামত"),
                    _buildFeatureCard(Icons.history, "হিস্ট্রি"),
                    _buildFeatureCard(Icons.support_agent, "হেল্পলাইন"),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ছোট ফিচার কার্ড উইজেট বানানোর মেথড
  Widget _buildFeatureCard(IconData icon, String title) {
    return Container(
      width: 85,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}