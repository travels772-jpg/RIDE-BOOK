import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../services/trip_management_service.dart';

class MapScreen extends StatefulWidget {
  final String tripId; // ফায়ারস্টোর থেকে আসা একটিভ ট্রিপ আইডি
  final String driverId;

  const MapScreen({super.key, required this.tripId, required this.driverId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TripManagementService _tripService = TripManagementService();

  // উদাহরণস্বরূপ স্টেট (যা রিয়েল টাইমে ফায়ারস্টোর বা ট্রিপ থেকে আসবে)
  bool isPersonal = false; // পার্সোনাল নাকি শেয়ারিং
  int totalSeats = 5;
  int availableSeats = 3; // বর্তমানে ফাঁকা সিট
  List passengersList = [
    {'name': 'রহিম সাহেব', 'pickup': 'স্টেশন মোড়', 'drop': 'হাসপাতাল রোড', 'seats': 2}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          isPersonal ? "🔒 পার্সোনাল রাইড (রিজার্ভড)" : "🛺 শেয়ারিং রাইড মোড",
          style: TextStyle(
            color: isPersonal ? Colors.orangeAccent : AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ১. ব্যাকগ্রাউন্ড ম্যাপ প্লেসহোল্ডার
          Container(
            color: const Color(0xFF111827),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_rounded,
                    size: 70,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "লাইভ জিপিএস রুট ও প্যাসেঞ্জার ট্র্যাকিং চলছে...",
                    style: TextStyle(color: AppColors.textWhite, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // ২. ওপরের সিট ও বুকিং স্ট্যাটাস কার্ড
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPersonal ? Colors.orangeAccent : AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPersonal ? "স্ট্যাটাস: পার্সোনাল বুকিং" : "স্ট্যাটাস: শেয়ারিং অন",
                        style: TextStyle(
                          color: isPersonal ? Colors.orangeAccent : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: availableSeats > 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "ফাঁকা সিট: $availableSeats / $totalSeats টি",
                          style: TextStyle(
                            color: availableSeats > 0 ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 16),
                  
                  // বর্তমান যাত্রীদের লিস্ট
                  const Text(
                    "বর্তমান যাত্রীরা:",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  passengersList.isEmpty
                      ? const Text("কোনো যাত্রী নেই (গাড়ি ফাঁকা)", style: TextStyle(color: Colors.white70, fontSize: 13))
                      : Column(
                          children: passengersList.map((p) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("• ${p['name']} (${p['seats']} সিট)", style: const TextStyle(color: AppColors.textWhite, fontSize: 13)),
                                  Text("${p['pickup']} ➔ ${p['drop']}", style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),

          // ৩. নিচের কন্ট্রোল প্যানেল (শেয়ারিং প্যাসেঞ্জার বা পার্সোনাল রুলস হ্যান্ডেল করার জন্য)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPersonal 
                        ? "পার্সোনাল রাইড চলছে: রাস্তায় নতুন প্যাসেঞ্জার তোলার অনুমতি নেই।" 
                        : "রাস্তা থেকে নতুন প্যাসেঞ্জার তুলতে নিচের বাটনে চাপ দিন:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isPersonal ? Colors.orangeAccent : AppColors.textGrey, 
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // যদি শেয়ারিং মোড হয় তবেই নতুন যাত্রী তোলার বাটন কাজ করবে
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPersonal ? Colors.grey : AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isPersonal 
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("এটি পার্সোনাল রাইড! নতুন প্যাসেঞ্জার তোলা যাবে না।")),
                                  );
                                }
                              : () {
                                  // শেয়ারিং মোডে নতুন প্যাসেঞ্জার এড করার ডায়লগ বা লজিক
                                  setState(() {
                                    if (availableSeats > 0) {
                                      availableSeats--;
                                      passengersList.add({
                                        'name': 'নতুন যাত্রী',
                                        'pickup': 'মাঝপথ',
                                        'drop': 'গন্তব্য',
                                        'seats': 1
                                      });
                                    }
                                  });
                                },
                          icon: const Icon(Icons.person_add_alt_1),
                          label: Text(isPersonal ? "পার্সোনাল মোড (লকড)" : "রাস্তা থেকে যাত্রী তুলুন"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}