import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/breakdown_screen.dart';
import 'screens/parts_catalog_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  String? driverId = prefs.getString('driver_id');

  runApp(TotoDriverApp(isLoggedIn: isLoggedIn, driverId: driverId));
}

class TotoDriverApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? driverId;

  const TotoDriverApp({super.key, required this.isLoggedIn, this.driverId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toto Driver Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: AppColors.darkBackground,
        fontFamily: 'Roboto',
      ),
      home: isLoggedIn 
          ? MainNavigationWrapper(driverId: driverId) 
          : const LoginScreen(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  final String? driverId;
  const MainNavigationWrapper({super.key, this.driverId});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(driverId: widget.driverId),
      const ProgressScreen(),
      const BreakdownScreen(),
      const PartsCatalogScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryAccent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'ড্যাশবোর্ড',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'প্রোগ্রেস',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'ব্রেকডাউন',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'পার্টস',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }
}