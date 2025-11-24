import 'package:cloud_firestore/cloud_firestore.dart';

class CashSession {
  final String id;
  final String userId;
  final SessionStatus status;
  final double openingCash;
  final double totalCashSales;
  final double manualCashIn;
  final double manualCashOut;
  final double expectedClosingCash;
  final double? countedClosingCash;
  final double? difference;
  final DateTime openedAt;
  final DateTime? closedAt;

  CashSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.openingCash,
    required this.totalCashSales,
    required this.manualCashIn,
    required this.manualCashOut,
    required this.expectedClosingCash,
    this.countedClosingCash,
    this.difference,
    required this.openedAt,
    this.closedAt,
  });

  factory CashSession.fromJson(Map<String, dynamic> json, String id) {
    return CashSession(
      id: id,
      userId: json['userId'] as String,
      status: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      openingCash: (json['openingCash'] as num).toDouble(),
      totalCashSales: (json['totalCashSales'] as num?)?.toDouble() ?? 0.0,
      manualCashIn: (json['manualCashIn'] as num?)?.toDouble() ?? 0.0,
      manualCashOut: (json['manualCashOut'] as num?)?.toDouble() ?? 0.0,
      expectedClosingCash:
          (json['expectedClosingCash'] as num?)?.toDouble() ?? 0.0,
      countedClosingCash: (json['countedClosingCash'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      openedAt: (json['openedAt'] as Timestamp).toDate(),
      closedAt: json['closedAt'] != null
          ? (json['closedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status.toString().split('.').last,
      'openingCash': openingCash,
      'totalCashSales': totalCashSales,
      'manualCashIn': manualCashIn,
      'manualCashOut': manualCashOut,
      'expectedClosingCash': expectedClosingCash,
      'countedClosingCash': countedClosingCash,
      'difference': difference,
      'openedAt': Timestamp.fromDate(openedAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
    };
  }

  CashSession copyWith({
    String? id,
    String? userId,
    SessionStatus? status,
    double? openingCash,
    double? totalCashSales,
    double? manualCashIn,
    double? manualCashOut,
    double? expectedClosingCash,
    double? countedClosingCash,
    double? difference,
    DateTime? openedAt,
    DateTime? closedAt,
  }) {
    return CashSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      openingCash: openingCash ?? this.openingCash,
      totalCashSales: totalCashSales ?? this.totalCashSales,
      manualCashIn: manualCashIn ?? this.manualCashIn,
      manualCashOut: manualCashOut ?? this.manualCashOut,
      expectedClosingCash: expectedClosingCash ?? this.expectedClosingCash,
      countedClosingCash: countedClosingCash ?? this.countedClosingCash,
      difference: difference ?? this.difference,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  // Calculate expected closing cash dynamically
  double calculateExpectedClosing() {
    return openingCash + totalCashSales + manualCashIn - manualCashOut;
  }

  // Calculate difference between counted and expected
  double calculateDifference(double counted) {
    return counted - calculateExpectedClosing();
  }
}

enum SessionStatus { OPEN, CLOSED }
