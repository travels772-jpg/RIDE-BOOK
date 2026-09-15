import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isDriverSelected = true; 
  String selectedGender = 'BOYS'; 
  bool _isLoading = false;
  
  final TextEditingController _phoneController = TextEditingController();
  
  // ৪ ঘরের ওটিপি কন্ট্রোলার এবং ফোকাস নোড
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // ওটিপি পাঠানোর ফাংশন
  void _sendFirebaseOtp() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দয়া করে সঠিক ১০ ডিজিটের মোবাইল নম্বর দিন!')),
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ওটিপি পাঠানো হয়েছে! (৪ ঘরের সঠিক ওটিপি দিন)')),
    );
  }

  // **নিখুঁত লক এবং নেভিগেশন ভ্যালিডেশন ফাংশন**
  void _verifyOtpAndProceed(bool isNewUser) {
    // ১. ফোন নম্বর চেক
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ লক করা আছে: প্রথমে সঠিক ১০ ডিজিটের মোবাইল নম্বর দিন!')),
      );
      return;
    }

    // ২. ৪ ঘরের ওটিপি চেক
    String enteredOtp = _otpControllers.map((e) => e.text).join();
    if (enteredOtp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ লক করা আছে: ৪ ঘরের সম্পূর্ণ ওটিপি (OTP) না দিলে এন্ট্রি নেওয়া হবে না!')),
      );
      return;
    }

    // ৩. সঠিক পেজে নেভিগেশন (New Login -> Profile, Old Login -> Dashboard)
    if (isNewUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.yellowColor,
              AppColors.redColor,
              AppColors.greenColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.yellowColor.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // অ্যাপ টাইটেল ও লোগো
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car, color: AppColors.yellowColor, size: 28),
                        const SizedBox(width: 10),
                        const Text(
                          'WELCOME TO TOTO BOOKING',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'এন্টার ইওর ডিটেইলস টু স্টার্ট ইওর জার্নি',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 18),

                    // Driver / Booking টগল সুইচ
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isDriverSelected = true),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDriverSelected ? AppColors.redColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Text(
                                  'Driver',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isDriverSelected = false),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !isDriverSelected ? AppColors.yellowColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Booking',
                                  style: TextStyle(
                                    color: !isDriverSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // OTP ভেরিফিকেশন লেবেল
                    const Text(
                      'OTP ভেরিফিকেশন (প্রোফাইল টাইপ)',
                      style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),

                    // জেন্ডার সিলেকশন ছবি ও বাটন
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGenderButton('GIRLS', 'https://cdn-icons-png.flaticon.com/512/2922/2922561.png'),
                        _buildGenderButton('BOYS', 'https://cdn-icons-png.flaticon.com/512/2922/2922510.png'),
                        _buildGenderButton('OTHER', 'https://cdn-icons-png.flaticon.com/512/4140/4140048.png'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // মোবাইল নম্বর ইনপুট ফিল্ড
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'মোবাইল নাম্বার (১০ ডিজিট)',
                        labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Send OTP বাটন
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendFirebaseOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Send OTP (ওটিপি পাঠান)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ৪ ঘরের অটো-ফোকাস ওটিপি বক্স
                    const Text(
                      'Enter the OTP sent to your phone (৪ ঘরের ওটিপি দিন)',
                      style: TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) => SizedBox(
                        width: 50,
                        height: 48,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              _otpFocusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _otpFocusNodes[index - 1].requestFocus();
                            }
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 16),

                    // নিউ এবং ওল্ড ইউজার অপশন
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // New Login -> প্রোফাইল পেজে যাবে
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _verifyOtpAndProceed(true),
                            icon: const Icon(Icons.person_add, color: AppColors.greenColor, size: 18),
                            label: const Text(
                              'New Login',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.greenColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Old Login -> ড্যাশবোর্ড পেজে যাবে
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _verifyOtpAndProceed(false),
                            icon: const Icon(Icons.login, color: Colors.black, size: 18),
                            label: const Text(
                              'Old Login',
                              style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.yellowColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // জেন্ডার বাটন উইজেট
  Widget _buildGenderButton(String title, String imageUrl) {
    bool isSelected = selectedGender == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = title),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.yellowColor : Colors.transparent, width: 1.5),
          ),
          child: Column(
            children: [
              Image.network(
                imageUrl,
                height: 26,
                width: 26,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}