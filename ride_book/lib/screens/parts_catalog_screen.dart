import 'package:flutter/material.dart';
import 'secure_wallet_module/wallet_screen.dart';
import 'history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/parts_catalog_screen.dart';

class UniqueDriverDashboard extends StatefulWidget {
  const UniqueDriverDashboard({super.key});

  @override
  State<UniqueDriverDashboard> createState() => _UniqueDriverDashboardState();
}

class _UniqueDriverDashboardState extends State<UniqueDriverDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeContent(),
    const WalletScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'ড্যাশবোর্ড',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'ওয়ালেট',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'হিস্ট্রি',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // হেডার
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'স্বাগতম, ড্রাইভার',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'সোনু মন্ডল',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  icon: const CircleAvatar(
                    backgroundColor: Color(0xFF38BDF8),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ইনকাম কার্ড
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'আজকের মোট ইনকাম',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₹ 1,450.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.trending_up, color: Colors.white, size: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'কুইক সার্ভিসেস',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            // পার্টস ও প্রাইস লিস্ট কার্ড (ড্যাশবোর্ড থেকে সরাসরি দেখার জন্য)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PartsCatalogScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.build_circle_rounded, color: Color(0xFF38BDF8), size: 36),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'টোটো পার্টস ও প্রাইস লিস্ট',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'সকল যন্ত্রাংশের দাম ও ছবি দেখুন',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ওয়ালেট এবং হিস্ট্রি বাটন
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFF38BDF8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WalletScreen()),
                      );
                    },
                    icon: const Icon(Icons.wallet),
                    label: const Text('ওয়ালেট'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFF38BDF8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('হিস্ট্রি'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}