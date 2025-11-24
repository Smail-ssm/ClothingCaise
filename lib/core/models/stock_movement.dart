import 'package:cloud_firestore/cloud_firestore.dart';

class StockMovement {
  final String id;
  final String variantId;
  final String productId;
  final int quantity;
  final MovementDirection direction;
  final MovementReason reason;
  final String? relatedSaleId;
  final String userId;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.quantity,
    required this.direction,
    required this.reason,
    this.relatedSaleId,
    required this.userId,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json, String id) {
    return StockMovement(
      id: id,
      variantId: json['variantId'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      direction: MovementDirection.values.firstWhere(
        (e) => e.toString().split('.').last == json['direction'],
      ),
      reason: MovementReason.values.firstWhere(
        (e) => e.toString().split('.').last == json['reason'],
      ),
      relatedSaleId: json['relatedSaleId'] as String?,
      userId: json['userId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantId': variantId,
      'productId': productId,
      'quantity': quantity,
      'direction': direction.toString().split('.').last,
      'reason': reason.toString().split('.').last,
      'relatedSaleId': relatedSaleId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum MovementDirection { IN, OUT }

enum MovementReason { PURCHASE, SALE, ADJUSTMENT, WASTE }
