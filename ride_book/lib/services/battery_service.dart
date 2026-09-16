import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BatteryService {
  
  // ১. লিথিয়াম ব্যাটারি (ব্লুটুথ স্মার্ট BMS থেকে পার্সেন্টেজ ও ডেটা আনা)
  Future<Map<String, dynamic>> connectAndFetchLithiumBatteryData() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        return {"status": "ব্লুটুথ সাপোর্টেড নয়", "percentage": 0};
      }

      // ব্লুটুথ স্ক্যান শুরু
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      // সিমুলেটেড বা রিয়েল ব্লুটুথ ডিভাইস কানেকশন লজিক
      await for (var results in FlutterBluePlus.scanResults) {
        for (ScanResult r in results) {
          if (r.device.platformName.contains("BMS") || 
              r.device.platformName.contains("Battery") || 
              r.device.platformName.contains("Toto")) {
            
            FlutterBluePlus.stopScan();
            await r.device.connect();
            
            // সফল কানেকশনের পর ব্যাটারি থেকে পার্সেন্টেজ রিড করার কোড এখানে হবে
            return {
              "status": "স্মার্ট লিথিয়াম সংযুক্ত", 
              "percentage": 92 // উদাহরণস্বরূপ লাইভ ডেটা
            };
          }
        }
      }
      
      FlutterBluePlus.stopScan();
      return {"status": "ব্যাটারি ডিভাইস পাওয়া যায়নি", "percentage": 0};
    } catch (e) {
      return {"status": "কানেকশন এরর", "percentage": 0};
    }
  }

  // ২. নরমাল ব্যাটারি / পানির ওয়ালা ব্যাটারি (কন্ট্রোলারের ভোল্টেজ থেকে পার্সেন্টেজ ক্যালকুলেশন)
  int calculateNormalBatteryPercentage(double currentVoltage) {
    // সাধারণত একটি ৪৮ ভোল্টের (48V) টোটো ব্যাটারির ক্ষেত্রে:
    // ফুল চার্জ (100%) = প্রায় 52.0V - 54.0V
    // জিরো চার্জ (0%) = প্রায় 42.0V
    
    double maxVoltage = 52.0;
    double minVoltage = 42.0;

    if (currentVoltage >= maxVoltage) return 100;
    if (currentVoltage <= minVoltage) return 0;

    // ভোল্টেজ থেকে পার্সেন্টেজ হিসাব করার সূত্র
    double percentage = ((currentVoltage - minVoltage) / (maxVoltage - minVoltage)) * 100;
    return percentage.toInt();
  }
}