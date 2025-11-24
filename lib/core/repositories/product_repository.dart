import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Product.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get product by ID
  Future<Product?> getProduct(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Product.fromJson(doc.data()!, doc.id);
  }

  // Create product
  Future<String> createProduct(Product product) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(product.toJson());
    return docRef.id;
  }

  // Update product
  Future<void> updateProduct(String id, Product product) async {
    await _firestore.collection(_collection).doc(id).update(product.toJson());
  }

  // Deactivate product (Logical Delete)
  Future<void> deactivateProduct(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  // Archive product
  Future<void> archiveProduct(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isArchived': true,
      'updatedAt': Timestamp.now(),
    });
  }

  // Get products count
  Future<int> getProductsCount() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
