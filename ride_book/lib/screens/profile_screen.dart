import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import 'progress_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  
  File? _profileImage;
  File? _aadhaarImage;
  File? _vehicleImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idCardController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  // ক্যামেরা ওপেন করে ছবি তোলার ফাংশন
  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (type == 'profile') {
            _profileImage = File(image.path);
          } else if (type == 'aadhaar') {
            _aadhaarImage = File(image.path);
          } else if (type == 'vehicle') {
            _vehicleImage = File(image.path);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📸 ছবি সফলভাবে ক্যাপচার এবং সেভ করা হয়েছে!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ক্যামেরা ওপেন করতে সমস্যা হয়েছে!')),
      );
    }
  }

  void _submitAndGoToProgress() {
    String idCardText = _idCardController.text.trim().replaceAll(' ', '');
    
    if (_nameController.text.trim().isEmpty || 
        _phoneController.text.trim().isEmpty || 
        _vehicleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ দয়া করে নাম, মোবাইল নম্বর এবং গাড়ীর নাম্বার পূরণ করুন!')),
      );
      return;
    }

    if (idCardText.isNotEmpty && idCardText.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ সঠিক ১২ ডিজিটের নম্বর প্রদান করুন!')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressScreen(
          name: _nameController.text.trim(),
          address: _phoneController.text.trim(),
          idCardNumber: _idCardController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Driver Dashboard & Profile',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Logout', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // প্রোফাইল ফটো সেকশন ও ক্যামেরা বাটন
                  Center(
                    child: Column(
                      children: [
                        const Text('প্রোফাইল ফটো *', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage('profile'),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 38,
                                backgroundColor: Colors.white24,
                                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                                child: _profileImage == null
                                    ? const Icon(Icons.person, size: 45, color: Colors.white)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Colors.cyanAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          onPressed: () => _pickImage('profile'),
                          icon: const Icon(Icons.camera_alt, size: 14, color: Colors.cyanAccent),
                          label: const Text('ক্যামেরায় তুলে সেভ করুন', style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // নাম ইনপুট
                  _buildFieldLabel('নাম *'),
                  _buildTextField(_nameController, 'আপনার পুরো নাম লিখুন', Icons.person),
                  const SizedBox(height: 12),

                  // মোবাইল নম্বর ইনপুট
                  _buildFieldLabel('মোবাইল নম্বর *'),
                  _buildTextField(_phoneController, 'আপনার মোবাইল নম্বর', Icons.phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),

                  // ইমেল আইডি ইনপুট
                  _buildFieldLabel('ইমেল আইডি'),
                  _buildTextField(_emailController, 'আপনার ইমেল ঠিকানা', Icons.email),
                  const SizedBox(height: 12),

                  // আইডি কার্ড ফিল্ড
                  _buildFieldLabel('আইডি কার্ড নম্বর'),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _idCardController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.badge, color: Colors.cyanAccent, size: 20),
                      hintText: '১২৩৪ ৫৬৭৮ ৯১০১',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3))),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // আইডি কার্ডের ছবি তোলার বাটন
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.cyanAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _pickImage('aadhaar'),
                    icon: Icon(Icons.camera_alt, color: _aadhaarImage != null ? Colors.greenAccent : Colors.cyanAccent, size: 18),
                    label: Text(
                      _aadhaarImage != null ? 'আইডি কার্ডের ছবি সেভ হয়েছে ✓' : 'আইডি কার্ডের ছবি তুলে সেভ করুন',
                      style: TextStyle(color: _aadhaarImage != null ? Colors.greenAccent : Colors.cyanAccent, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // গাড়ির নাম্বার ইনপুট
                  _buildFieldLabel('গাড়ীর নাম্বার *'),
                  _buildTextField(_vehicleController, 'আপনার গাড়ীর নাম্বার', Icons.electric_rickshaw),
                  const SizedBox(height: 8),
                  
                  // গাড়ির ছবি তোলার বাটন
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.cyanAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _pickImage('vehicle'),
                    icon: Icon(Icons.camera_alt, color: _vehicleImage != null ? Colors.greenAccent : Colors.cyanAccent, size: 18),
                    label: Text(
                      _vehicleImage != null ? 'গাড়ির ছবি সেভ হয়েছে ✓' : 'গাড়ির ছবি তুলে সেভ করুন',
                      style: TextStyle(color: _vehicleImage != null ? Colors.greenAccent : Colors.cyanAccent, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // সংরক্ষণ করুন বাটন
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      onPressed: _isUploading ? null : _submitAndGoToProgress,
                      child: _isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : const Text(
                              'সংরক্ষণ করুন - Save Changes',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3))),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}