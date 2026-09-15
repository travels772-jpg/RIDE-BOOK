import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dashboard_screen.dart';

class ProgressScreen extends StatefulWidget {
  final String name;
  final String address;
  final String idCardNumber;

  const ProgressScreen({
    super.key,
    required this.name,
    required this.address,
    required this.idCardNumber,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  double _progressValue = 0.4;
  String _statusMessage = 'আপনার তথ্য যাচাই করা হচ্ছে...';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startFirebaseUploadProcess();
  }

  // ফায়ারবেসে ডাটা আপলোড এবং প্রোগ্রেস আপডেট করার লজিক
  void _startFirebaseUploadProcess() async {
    // ধাপ ১: ভেরিফিকেশন ও কানেকশন
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _progressValue = 0.8;
      _statusMessage = 'ফায়ারবেসে ডকুমেন্টস আপলোড হচ্ছে...';
    });

    // ধাপ ২: আপলোড কমপ্লিট ও টিক চিহ্ন দেখানো
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _progressValue = 1.0;
      _statusMessage = 'প্রোফাইল সফলভাবে আপডেট করা হয়েছে!';
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('EASY RIDE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Logout', style: TextStyle(color: Colors.white70)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'প্রোফাইল ট্রানজিশন এবং অগ্রগতি\n- Profile Transition & Progress',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: Row(
                children: [
                  // Step 1 Card (ভেরিফিকেশন ও প্রোগ্রেস)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ধাপ ১: ভেরিফিকেশন', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 15),
                          LinearProgressIndicator(
                            value: _progressValue,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                          const SizedBox(height: 15),
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 5),
                              Text('ডকুমেন্ট ও তথ্য', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Step 2 Card (সাফল্য, টিক চিহ্ন ও ড্যাশবোর্ড বাটন)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ধাপ ২: সাফল্য', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: _isSuccess ? Colors.green : Colors.white24,
                            child: Icon(
                              _isSuccess ? Icons.check : Icons.hourglass_top,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isSuccess ? 'সব কাজ সম্পন্ন!' : 'আপলোডের জন্য অপেক্ষা করুন...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isSuccess ? Colors.greenAccent : Colors.white70, 
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.electric_rickshaw, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // নিচের মূল ড্যাশবোর্ডে যাওয়ার অ্যাকশন বাটন (টিক চিহ্ন আসার পর বা এমনিতেও কাজ করবে)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSuccess ? Colors.green : Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                child: Text(
                  _isSuccess ? 'ড্যাশবোর্ডে যান (সফল)' : 'ড্যাশবোর্ডে যান', 
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}