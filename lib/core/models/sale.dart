import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final DateTime date;
  final double totalAmount;
  final PaymentType paymentType;
  final String userId;
  final String? cashSessionId;
  final List<SaleLine> lines;

  Sale({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentType,
    required this.userId,
    this.cashSessionId,
    required this.lines,
  });

  factory Sale.fromJson(Map<String, dynamic> json, String id) {
    return Sale(
      id: id,
      date: (json['date'] as Timestamp).toDate(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentType: PaymentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentType'],
      ),
      userId: json['userId'] as String,
      cashSessionId: json['cashSessionId'] as String?,
      lines: (json['lines'] as List)
          .map((line) => SaleLine.fromJson(line as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'totalAmount': totalAmount,
      'paymentType': paymentType.toString().split('.').last,
      'userId': userId,
      'cashSessionId': cashSessionId,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}

class SaleLine {
  final String variantId;
  final String productId;
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;
  final double totalLine;

  SaleLine({
    required this.variantId,
    required this.productId,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
    required this.totalLine,
  });

  factory SaleLine.fromJson(Map<String, dynamic> json) {
    return SaleLine(
      variantId: json['variantId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      size: json['size'] as String,
      color: json['color'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalLine: (json['totalLine'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantId': variantId,
      'productId': productId,
      'productName': productName,
      'size': size,
      'color': color,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalLine': totalLine,
    };
  }
}

enum PaymentType { CASH, CARD, OTHER }
