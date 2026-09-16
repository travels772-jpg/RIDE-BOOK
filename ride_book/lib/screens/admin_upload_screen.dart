import 'package:flutter/material.dart';
import '../services/parts_pricing_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final PartsPricingService _partsService = PartsPricingService();
  bool _isLoading = false;

  // পার্টস ও দাম ফায়ারবেসে সেভ করার ফাংশন
  void _uploadPart() async {
    if (_nameController.text.isEmpty || 
        _priceController.text.isEmpty || 
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("দয়া করে পার্টসের নাম, দাম এবং ছবির লিংক দিন!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      double price = double.parse(_priceController.text);
      
      // সার্ভিস কল করে ফায়ারবেসে ডাটা পাঠানো
      await _partsService.addPart(
        name: _nameController.text.trim(),
        price: price,
        imageUrl: _imageUrlController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("সফলভাবে পার্টস ও দাম ডাটাবেজে সেভ করা হয়েছে!"),
          backgroundColor: Colors.green,
        ),
      );
      
      // ইনপুট ফিল্ডগুলো পরিষ্কার করা
      _nameController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ত্রুটি হয়েছে: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "অ্যাডমিন: পার্টস ও দাম আপলোড",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              "নতুন যন্ত্রাংশ বা পার্টস যুক্ত করুন",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "এখানে দেওয়া নাম ও দাম সরাসরি ড্রাইভার অ্যাপের ক্যাটালগে লাইভ আপডেট হয়ে যাবে।",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 25),

            // পার্টসের নাম ইনপুট
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "পার্টসের নাম (যেমন: টোটো কন্ট্রোলার বক্স)",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // পার্টসের দাম ইনপুট
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "দাম (টাকায়, যেমন: 1200)",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ছবির লিংক বা ইউআরএল ইনপুট
            TextField(
              controller: _imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "ছবির লিংক (Image URL)",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // সেভ বাটন
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _uploadPart,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "ডাটাবেজে সেভ করুন",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}