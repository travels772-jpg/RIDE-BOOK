class WalletTransaction {
  final String transactionId; // UPI UTR Number
  final String driverId;
  final double amount;
  final String type; // 'CREDIT' বা 'DEBIT'
  final String status; // 'PENDING', 'SUCCESS', 'FAILED'
  final DateTime timestamp;

  WalletTransaction({
    required this.transactionId,
    required this.driverId,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'driverId': driverId,
      'amount': amount,
      'type': type,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      transactionId: map['transactionId'] ?? '',
      driverId: map['driverId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}