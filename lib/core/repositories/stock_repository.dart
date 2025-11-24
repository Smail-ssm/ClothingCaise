import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_movement.dart';

class StockRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'stockMovements';

  // Create stock movement and update variant stock
  Future<String> createMovement(StockMovement movement) async {
    // Use transaction to ensure atomicity
    return await _firestore.runTransaction((transaction) async {
      // Get current variant
      final variantDoc = await transaction.get(
        _firestore.collection('productVariants').doc(movement.variantId),
      );

      if (!variantDoc.exists) {
        throw Exception('Variant not found');
      }

      final currentStock = variantDoc.data()!['currentStock'] as int;
      int newStock;

      if (movement.direction == MovementDirection.IN) {
        newStock = currentStock + movement.quantity;
      } else {
        newStock = currentStock - movement.quantity;
        if (newStock < 0) {
          throw Exception('Insufficient stock');
        }
      }

      // Create movement record
      final movementRef = _firestore.collection(_collection).doc();
      transaction.set(movementRef, movement.toJson());

      // Update variant stock
      transaction.update(
        _firestore.collection('productVariants').doc(movement.variantId),
        {'currentStock': newStock, 'updatedAt': Timestamp.now()},
      );

      return movementRef.id;
    });
  }

  // Get movements by variant
  Stream<List<StockMovement>> getMovementsByVariant(String variantId) {
    return _firestore
        .collection(_collection)
        .where('variantId', isEqualTo: variantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StockMovement.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get all movements
  Stream<List<StockMovement>> getMovements({int limit = 100}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StockMovement.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}
