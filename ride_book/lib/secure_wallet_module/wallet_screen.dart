import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  
  final String myBusinessUpiId = "your_business_upi@ybl";
  final String merchantName = "Toto Ride";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ড্রাইভার ওয়ালেট'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ফায়ারবেস থেকে লাইভ ব্যালেন্স স্ট্রিম বিল্ডার
            StreamBuilder<double>(
              stream: _walletService.getWalletBalanceStream(),
              builder: (context, snapshot) {
                double balance = snapshot.data ?? 0.0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ওয়ালেট ব্যালেন্স (লাইভ)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text(
                        '₹ ${balance.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // অ্যাড মানি এবং উইথড্র বাটন
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddMoneyOptions(context),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text('অ্যাড মানি', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawDialog(context),
                    icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                    label: const Text('উইথড্র', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMoneyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ওয়ালেটে টাকা অ্যাড করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.phone_android, color: Theme.of(context).primaryColor, size: 30),
                title: const Text('ফোনপে / পেটিএম অ্যাপ দিয়ে পেমেন্ট'),
                subtitle: const Text('অ্যাপ খুলে নিজের পিন দিয়ে ডাইরেক্ট অ্যাড করুন'),
                onTap: () {
                  Navigator.pop(context);
                  _showDirectUpiAppDialog(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.qr_code_scanner, color: Theme.of(context).primaryColor, size: 30),
                title: const Text('কিউআর কোড স্ক্যান করুন'),
                subtitle: const Text('স্ক্যান করে টাকা পাঠালে ওয়ালেটে অটো অ্যাড হবে'),
                onTap: () {
                  Navigator.pop(context);
                  _showQrCodeDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDirectUpiAppDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('টাকার পরিমাণ লিখুন'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'পরিমাণ লিখুন (যেমন: ₹100)', prefixIcon: Icon(Icons.currency_rupee)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              double amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                Navigator.pop(context);
                bool success = await _walletService.addMoneyToWallet(amount);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('₹$amount সফলভাবে ওয়ালেটে যোগ হয়েছে!')),
                  );
                }
              }
            },
            child: const Text('পেমেন্ট করুন'),
          ),
        ],
      ),
    );
  }

  void _showQrCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('স্ক্যান করে টাকা পাঠান'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'এই কিউআর কোডে স্ক্যান করে পেমেন্ট করলে আপনার ওয়ালেটে টাকা জমা হয়ে যাবে।', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 12, color: Colors.grey)
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 180,
              width: 180,
              child: QrImageView(
                data: "upi://pay?pa=$myBusinessUpiId&pn=${Uri.encodeComponent(merchantName)}&cu=INR",
                size: 180,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন')),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final TextEditingController withdrawController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ওয়ালেট থেকে টাকা তুলুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('আপনার ব্যাংক বা ফোনপে নম্বরে টাকা পাঠিয়ে দেওয়া হবে।', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: withdrawController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'উইথড্র করার পরিমাণ লিখুন', prefixIcon: Icon(Icons.currency_rupee)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              double amount = double.tryParse(withdrawController.text) ?? 0.0;
              if (amount > 0) {
                Navigator.pop(context);
                var result = await _walletService.withdrawMoney(amount);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              }
            },
            child: const Text('কনফার্ম করুন'),
          ),
        ],
      ),
    );
  }
}