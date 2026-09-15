import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ড্যাশবোর্ড (Dashboard)'),
        backgroundColor: AppColors.yellowColor,
        foregroundColor: Colors.black,
        actions: [
          // লগআউট বাটন, যাতে প্রয়োজনে আবার লগইন পেজে ফিরে যাওয়া যায়
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            tooltip: 'লগআউট',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'স্বাগতম ড্যাশবোর্ডে!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'এটি একটি সাধারণ ড্যাশবোর্ড। পরবর্তীতে আপনার প্রয়োজন অনুযায়ী এখানে টোটো বুকিং, ড্রাইভার স্ট্যাটাস বা অন্যান্য ফিচারগুলো যোগ করে বড় করে নিতে পারবেন।',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // ডেমো কার্ড বা সেকশন
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildDashboardCard('টোটো বুকিং', Icons.directions_car, Colors.orange),
                  _buildDashboardCard('প্রোফাইল', Icons.person, Colors.blue),
                  _buildDashboardCard('হিস্ট্রি', Icons.history, Colors.green),
                  _buildDashboardCard('সেটিংস', Icons.settings, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ড্যাশবোর্ডের ছোট কার্ড তৈরির হেল্পার মেথড
  Widget _buildDashboardCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}