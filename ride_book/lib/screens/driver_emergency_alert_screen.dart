Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DriverEmergencyAlertScreen(
      passengerName: "রাহুল মন্ডল", // প্যাসেঞ্জারের নাম
      passengerPhone: "9876543210", // প্যাসেঞ্জারের ফোন নম্বর
      emergencyLat: 22.5726,       // প্যাসেঞ্জারের লাইভ ল্যাটিটিউড
      emergencyLng: 88.3639,       // প্যাসেঞ্জারের লাইভ লংটিটিউড
      liveVideoFeedUrl: "https://example.com/live-stream", // লাইভ ভিডিও ফিড লিংক
    ),
  ),
);