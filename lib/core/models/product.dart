import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String gender;
  final String season;
  final double baseBuyingPrice;
  final double baseSellingPrice;
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.gender,
    required this.season,
    required this.baseBuyingPrice,
    required this.baseSellingPrice,
    required this.isActive,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      gender: json['gender'] as String,
      season: json['season'] as String,
      baseBuyingPrice: (json['baseBuyingPrice'] as num).toDouble(),
      baseSellingPrice: (json['baseSellingPrice'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'brand': brand,
      'gender': gender,
      'season': season,
      'baseBuyingPrice': baseBuyingPrice,
      'baseSellingPrice': baseSellingPrice,
      'isActive': isActive,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    String? gender,
    String? season,
    double? baseBuyingPrice,
    double? baseSellingPrice,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      gender: gender ?? this.gender,
      season: season ?? this.season,
      baseBuyingPrice: baseBuyingPrice ?? this.baseBuyingPrice,
      baseSellingPrice: baseSellingPrice ?? this.baseSellingPrice,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
