import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// আপনার প্রজেক্টের কালার ফাইলটি এখানে ইম্পোর্ট করা হলো (ফোল্ডার পাথ আপনার প্রজেক্ট অনুযায়ী ঠিক করে নিতে পারেন)
import '../colors.dart'; 

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({Key? key}) : super(key: key);

  @override
  _PinLockScreenState createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  
  final String _savedPin = "1234"; // লোকাল বা ডাটাবেজ থেকে আসা পিন
  bool _isLoading = false;

  void _verifyAndUnlock() async {
    String enteredPin = _pinController.text.trim();

    if (enteredPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("দয়া করে ৪ সংখ্যার পিন কোড দিন।"),
          backgroundColor: AppColors.warningOrange, // আপনার কালার ফাইল থেকে
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (enteredPin == _savedPin) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? activeTripId = prefs.getString('active_trip_id');

      if (!mounted) return;

      if (activeTripId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RunningTripScreen(tripId: activeTripId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DriverDashboardScreen(),
          ),
        );
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ভুল পিন দিয়েছেন! আবার চেষ্টা করুন।"),
          backgroundColor: AppColors.errorRed, // আপনার কালার ফাইল থেকে
        ),
      );
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, // আপনার কালার ফাইলের ডার্ক ব্যাকগ্রাউন্ড
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // সিকিউরিটি আইকন
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 50, color: AppColors.primaryAccent),
              ),
              const SizedBox(height: 24),
              
              const Text(
                "নিরাপত্তা যাচাই",
                style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              const Text(
                "আপনার টোটো অ্যাপ সুরক্ষিত রাখতে ৪-সংখ্যার পিন কোড দিন",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 35),
              
              // ৪ ডিজিটের পাসওয়ার্ড বক্স
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textWhite, 
                    fontSize: 28, 
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "••••",
                    hintStyle: TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                    filled: true,
                    fillColor: AppColors.cardBackground, // আপনার কালার ফাইলের কার্ড ব্যাকগ্রাউন্ড
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // প্রবেশ করুন বাটন
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // আপনার কালার ফাইলের প্রাইমারি কালার
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _verifyAndUnlock,
                  child: _isLoading 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2),
                      )
                    : const Text(
                        "প্রবেশ করুন", 
                        style: TextStyle(fontSize: 16, color: AppColors.textWhite, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// ১. রানিং ট্রিপ স্ক্রিন
class RunningTripScreen extends StatelessWidget {
  final String tripId;
  const RunningTripScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app: AppBar(
        title: Text("রানিং ট্রিপ (ID: $tripId)"), 
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 70, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                "আপনার একটি রানিং ট্রিপ চলমান রয়েছে!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "অ্যাপ বন্ধ হয়ে যাওয়ায় আপনাকে স্বয়ংক্রিয়ভাবে সরাসরি এই স্ক্রিনে ফিরিয়ে আনা হয়েছে।",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('active_trip_id');

                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverDashboardScreen()),
                  );
                },
                icon: const Icon(Icons.check_circle, color: AppColors.textWhite),
                label: const Text("ট্রিপ শেষ করুন", style: TextStyle(color: AppColors.textWhite)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// ২. সাধারণ ড্যাশবোর্ড স্ক্রিন
class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color textWhite = Colors.white;
    return Scaffold(
      app: AppBar(
        title: const Text("ড্রাইভার ড্যাশবোর্ড"),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text(
          "স্বাগতম! আপনি এখন ড্যাশবোর্ডে আছেন।\nনতুন ট্রিপ শুরু করার জন্য প্রস্তুত।",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}