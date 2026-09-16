import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/trip_management_service.dart';
import '../services/battery_service.dart';
import '../colors.dart';
import 'breakdown_screen.dart';
import 'parts_catalog_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? tripId;
  final String? driverId;

  const DashboardScreen({Key? key, this.tripId, this.driverId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TripManagementService _tripService = TripManagementService();
  final BatteryService _batteryService = BatteryService();
  
  GoogleMapController? _mapController;
  static const LatLng _initialPosition = LatLng(22.5726, 88.3639);
  bool _isLoading = false;

  final double _walletBalance = 1450.0;
  final double _todayEarnings = 650.0;
  final int _completedTripsCount = 10;
  
  int _batteryPercentage = 88;
  String _batteryStatusText = "ট্যাপ করে কানেক্ট করুন";
  bool _isBatteryConnecting = false;
  String _batteryType = "lithium";

  @override
  void initState() {
    super.initState();
    _loadSavedBatteryPreference();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _loadSavedBatteryPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _batteryType = prefs.getString('battery_type') ?? "lithium";
        _batteryStatusText = _batteryType == "lithium" ? "লিথিয়াম (ব্লুটুথ)" : "নরমাল (কন্ট্রোলার)";
      });
    } catch (e) {
      debugPrint("Error loading battery preference: $e");
    }
  }

  void _showBatteryTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text("আপনার টোটোর ব্যাটারি সিলেক্ট করুন", style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bluetooth, color: AppColors.primaryAccent),
              title: const Text("স্মার্ট লিথিয়াম ব্যাটারি (ব্লুটুথ BMS)", style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
              onTap: () async {
                Navigator.pop(dialogContext);
                await _saveBatteryType("lithium");
                _connectLithiumBattery();
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.electric_car, color: AppColors.successGreen),
              title: const Text("নরমাল ব্যাটারি (কন্ট্রোলার সিগন্যাল)", style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
              onTap: () async {
                Navigator.pop(dialogContext);
                await _saveBatteryType("normal");
                _fetchNormalControllerBattery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBatteryType(String type) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('battery_type', type);
      if (mounted) setState(() => _batteryType = type);
    } catch (e) {
      debugPrint("Error saving battery type: $e");
    }
  }

  void _connectLithiumBattery() async {
    setState(() {
      _isBatteryConnecting = true;
      _batteryStatusText = "ব্লুটুথ অন হচ্ছে...";
    });

    try {
      var result = await _batteryService.connectAndFetchLithiumBatteryData();
      if (!mounted) return;
      setState(() {
        _batteryStatusText = result["status"] ?? "সংযুক্ত";
        if (result["percentage"] != null && result["percentage"] > 0) {
          _batteryPercentage = result["percentage"];
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _batteryStatusText = "কানেকশন ফেলড");
    } finally {
      if (mounted) setState(() => _isBatteryConnecting = false);
    }
  }

  void _fetchNormalControllerBattery() {
    setState(() => _batteryStatusText = "কন্ট্রোলার সিগন্যাল রিড হচ্ছে...");
    try {
      double mockControllerVoltage = 48.5; 
      int calculatedPercentage = _batteryService.calculateNormalBatteryPercentage(mockControllerVoltage);

      if (!mounted) return;
      setState(() {
        _batteryPercentage = calculatedPercentage;
        _batteryStatusText = "নরমাল (কন্ট্রোলার 48V)";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _batteryStatusText = "রিডিং এরর");
    }
  }

  void _sendWhatsAppMessage(String phone, String message) async {
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("WhatsApp launch error: $e");
    }
  }

  void _onSosPressed() async {
    setState(() => _isLoading = true);
    try {
      String activeTripId = widget.tripId ?? "TRIP_DEMO_001";
      String handoverCode = await _tripService.triggerBreakdownAndGenerateCode(
        tripId: activeTripId,
        kmCovered: 5.5,
      );
      _sendWhatsAppMessage("919876543210", "জরুরি অ্যালার্ট! টোটো গাড়ি খারাপ হয়েছে (Driver SOS). কোড: $handoverCode");

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text("ব্রেকডাউন ও SOS কোড জেনারেট হয়েছে", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
          content: Text("সিকিউর কোড: $handoverCode\nহোয়াটসঅ্যাপে নোটিফিকেশন পাঠানো হয়েছে।", style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BreakdownScreen()));
              },
              child: const Text("ব্রেকডাউন স্ক্রিনে যান", style: TextStyle(color: AppColors.primaryAccent)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ত্রুটি: $e"), backgroundColor: AppColors.errorRed));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      _sendWhatsAppMessage("919876543210", "দাদা, আপনার ট্রিপ সফলভাবে শেষ হয়ে গেছে! আয় ওয়ালেটে যুক্ত হয়েছে।");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ট্রিপ সফল হয়েছে ও WhatsApp এ মেসেজ গেছে!"), backgroundColor: AppColors.successGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ত্রুটি: $e"), backgroundColor: AppColors.errorRed));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logoutDriver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayTripId = widget.tripId ?? "TRIP-01";
    if (displayTripId.length > 6) displayTripId = displayTripId.substring(0, 6);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        app: AppBar(
          title: Text("টোটো ড্রাইভার ড্যাশবোর্ড (ID: $displayTripId)"),
          backgroundColor: AppColors.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: AppColors.textWhite),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.errorRed),
              onPressed: _logoutDriver,
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(target: _initialPosition, zoom: 14.0),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) => _mapController = controller,
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  Card(
                    color: AppColors.cardBackground.withOpacity(0.95),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.directions_car, color: AppColors.primaryAccent, size: 24),
                              SizedBox(width: 8),
                              Text("গাড়ি রানিং ও লাইভ ট্র্যাকিং সক্রিয়", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                            child: const Text("নিরাপদ", style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 12)),
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
                        child: InkWell(
                          onTap: _showBatteryTypeSelectionDialog,
                          child: Card(
                            color: AppColors.cardBackground.withOpacity(0.95),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_batteryType == "lithium" ? "লিথিয়াম ব্যাটারি" : "নরমাল ব্যাটারি", style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                                      Icon(_batteryType == "lithium" ? Icons.bluetooth : Icons.electric_car, color: AppColors.primaryAccent, size: 12),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text("$_batteryPercentage%", style: const TextStyle(color: AppColors.primaryAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(_isBatteryConnecting ? "কানেক্ট হচ্ছে..." : _batteryStatusText, style: const TextStyle(color: AppColors.textWhite, fontSize: 7), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PartsCatalogScreen())),
                      icon: const Icon(Icons.build_rounded, color: AppColors.textWhite, size: 16),
                      label: const Text("টোটো পার্টস ও রিপেয়ারিং ক্যাটালগ দেখুন", style: TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _isLoading ? null : _completeTrip,
                      icon: const Icon(Icons.check_circle_outline, color: AppColors.textWhite),
                      label: const Text("ট্রিপ সফলভাবে শেষ করুন (WhatsApp Alert)", style: TextStyle(fontSize: 14, color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _isLoading ? null : _onSosPressed,
                      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.textWhite, size: 26),
                      label: const Text("গাড়ি খারাপ হয়েছে / SOS (অন্য টোটো ডাকুন)", style: TextStyle(fontSize: 15, color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}