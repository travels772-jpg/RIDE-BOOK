import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/trip_management_service.dart';
import '../colors.dart';
import 'breakdown_screen.dart';
import 'parts_catalog_screen.dart';
import 'profile_screen.dart';
import 'driver_emergency_alert_screen.dart'; // প্যাসেঞ্জার SOS অ্যালার্ট স্ক্রিন

class DashboardScreen extends StatefulWidget {
  final String? tripId;
  final String? driverId;

  const DashboardScreen({Key? key, this.tripId, this.driverId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TripManagementService _tripService = TripManagementService();
  GoogleMapController? _mapController;
  
  static const LatLng _initialPosition = LatLng(22.5726, 88.3639);
  bool _isLoading = false;

  final double _walletBalance = 1450.0;
  final double _todayEarnings = 650.0;
  final int _completedTripsCount = 10;
  final int _batteryPercentage = 88;

  @override
  void initState() {
    super.initState();
    _checkForIncomingPassengerSos(); // অ্যাপ চালুর সাথে সাথে প্যাসেঞ্জার SOS রিকোয়েস্ট চেক করার লজিক
  }

  // প্যাসেঞ্জার SOS দিয়েছে কিনা তা ব্যাকএন্ড থেকে চেক বা লিসেন করার ফাংশন
  void _checkForIncomingPassengerSos() {
    // এখানে ফায়ারবেস বা WebSocket লজিক থাকবে। 
    // টেস্ট বা ডেমোর জন্য কেউ SOS চাপা মাত্র ড্রাইভারের ফোনে এই পপ-আপ ট্রিগার হবে:
    /*
    bool isPassengerInDanger = true; // ব্যাকএন্ড সিগন্যাল
    if (isPassengerInDanger && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DriverEmergencyAlertScreen(
            passengerName: "বিপদগ্রস্ত প্যাসেঞ্জার",
            passengerPhone: "9876543210",
            emergencyLat: 22.5726,
            emergencyLng: 88.3639,
            liveVideoFeedUrl: "https://example.com/live-stream",
          ),
        ),
      );
    }
    */
  }

  // WhatsApp এ অটো মেসেজ পাঠানোর ফাংশন
  void _sendWhatsAppMessage(String phone, String message) async {
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // ১. ড্রাইভারের নিজস্ব SOS বা গাড়ি খারাপ হওয়ার কোড জেনারেট এবং WhatsApp মেসেজ
  void _onSosPressed() async {
    setState(() => _isLoading = true);
    try {
      String activeTripId = widget.tripId ?? "TRIP_DEMO_001";
      String handoverCode = await _tripService.triggerBreakdownAndGenerateCode(
        tripId: activeTripId,
        kmCovered: 5.5,
      );

      _sendWhatsAppMessage("919876543210", "জরুরি অ্যালার্ট! টোটো গাড়ি খারাপ হয়েছে (Driver SOS). হ্যান্ডওভার কোড: $handoverCode");

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            "ব্রেকডাউন ও SOS কোড জেনারেট হয়েছে", 
            style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "আপনার সিকিউর কোড: $handoverCode\nহোয়াটসঅ্যাপে নোটিফিকেশন পাঠিয়ে দেওয়া হয়েছে। অন্য ড্রাইভার এসে সাহায্য করবে।",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const BreakdownScreen()),
                );
              },
              child: const Text("ব্রেকডাউন স্ক্রিনে যান", style: TextStyle(color: AppColors.primaryAccent)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ত্রুটি: $e"), backgroundColor: AppColors.errorRed),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ২. ট্রিপ সফলভাবে শেষ করার ফাংশন ও WhatsApp মেসেজ
  void _completeTrip() async {
    setState(() => _isLoading = true);
    try {
      String activeTripId = widget.tripId ?? "TRIP_DEMO_001";
      await _tripService.completeTripWithAutoDeleteVideoProof(
        tripId: activeTripId,
        isAtTargetLocation: true,
        otpEntered: "1234",
        secretVideoUrl: "https://firebase_storage_link_dummy.mp4",
        finalLatitude: 22.5726,
        finalLongitude: 88.3639,
        isPaid: true,
      );

      _sendWhatsAppMessage("919876543210", "দাদা, আপনার ট্রিপ সফলভাবে শেষ হয়ে গেছে! আজকের আয় ওয়ালেটে যুক্ত হয়েছে।");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_trip_id');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ট্রিপ সফলভাবে সম্পন্ন হয়েছে ও WhatsApp এ মেসেজ গেছে!"), backgroundColor: AppColors.successGreen),
      );
      
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ত্রুটি: $e"), backgroundColor: AppColors.errorRed),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTripId = widget.tripId ?? "TRIP-01";
    if (displayTripId.length > 6) {
      displayTripId = displayTripId.substring(0, 6);
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      app: AppBar(
        title: Text("টোটো ড্রাইভার ড্যাশবোর্ড (ID: $displayTripId)"),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.textWhite),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ব্যাকগ্রাউন্ডে ফুল স্ক্রিন গুগল ম্যাপ
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // ওপরের স্ট্যাটাস ও ওয়ালেট প্যানেল
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Card(
                  color: AppColors.cardBackground.withOpacity(0.95),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.directions_car, color: AppColors.primaryAccent, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "গাড়ি রানিং ও লাইভ ট্র্যাকিং সক্রিয়", 
                              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "নিরাপদ", 
                            style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: AppColors.cardBackground.withOpacity(0.95),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ওয়ালেট ব্যালেন্স", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text("₹$_walletBalance", style: const TextStyle(color: AppColors.primaryAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                              const Text("মেইন ব্যালেন্স", style: TextStyle(color: AppColors.textWhite, fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Card(
                        color: AppColors.cardBackground.withOpacity(0.95),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("আজকের আয়", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text("₹$_todayEarnings", style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text("ট্রিপ: $_completedTripsCount টি", style: const TextStyle(color: AppColors.textWhite, fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Card(
                        color: AppColors.cardBackground.withOpacity(0.95),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ব্যাটারি হেলথ", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text("$_batteryPercentage%", style: const TextStyle(color: AppColors.primaryAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                              const Text("ভালো আছে", style: TextStyle(color: AppColors.textWhite, fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const PartsCatalogScreen()),
                    ),
                    icon: const Icon(Icons.build_rounded, color: AppColors.textWhite, size: 16),
                    label: const Text(
                      "টোটো পার্টস ও রিপেয়ারিং ক্যাটালগ দেখুন",
                      style: TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // নিচের কন্ট্রোল প্যানেল (ট্রিপ শেষ করা এবং ড্রাইভার SOS)
          Positioned(
            bottom: 25,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _completeTrip,
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.textWhite),
                    label: const Text(
                      "ট্রিপ সফলভাবে শেষ করুন (WhatsApp Alert)", 
                      style: TextStyle(fontSize: 14, color: AppColors.textWhite, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _onSosPressed,
                    icon: const Icon(Icons.warning_amber_rounded, color: AppColors.textWhite, size: 26),
                    label: const Text(
                      "গাড়ি খারাপ হয়েছে / SOS (অন্য টোটো ডাকুন)", 
                      style: TextStyle(fontSize: 15, color: AppColors.textWhite, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}