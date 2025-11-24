import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariant {
  final String id;
  final String productId;
  final String productName;
  final String size;
  final String color;
  final String? barcode;
  final double buyingPrice;
  final double sellingPrice;
  final int currentStock;
  final int minStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.productName,
    required this.size,
    required this.color,
    this.barcode,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json, String id) {
    return ProductVariant(
      id: id,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      size: json['size'] as String,
      color: json['color'] as String,
      barcode: json['barcode'] as String?,
      buyingPrice: (json['buyingPrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      currentStock: json['currentStock'] as int? ?? 0,
      minStock: json['minStock'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'size': size,
      'color': color,
      'barcode': barcode,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'minStock': minStock,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProductVariant copyWith({
    String? id,
    String? productId,
    String? productName,
    String? size,
    String? color,
    String? barcode,
    double? buyingPrice,
    double? sellingPrice,
    int? currentStock,
    int? minStock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      size: size ?? this.size,
      color: color ?? this.color,
      barcode: barcode ?? this.barcode,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => currentStock <= minStock;
}
