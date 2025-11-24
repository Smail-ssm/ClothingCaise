import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';
import '../models/stock_movement.dart';

class SaleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sales';

  // Create sale with stock movements
  Future<String> createSale(Sale sale, String userId) async {
    return await _firestore.runTransaction((transaction) async {
      // Create sale record
      final saleRef = _firestore.collection(_collection).doc();
      transaction.set(saleRef, sale.toJson());

      // Create stock movements for each line
      for (final line in sale.lines) {
        final movement = StockMovement(
          id: '',
          variantId: line.variantId,
          productId: line.productId,
          quantity: line.quantity,
          direction: MovementDirection.OUT,
          reason: MovementReason.SALE,
          relatedSaleId: saleRef.id,
          userId: userId,
          createdAt: DateTime.now(),
        );

        // Get current variant
        final variantDoc = await transaction.get(
          _firestore.collection('productVariants').doc(line.variantId),
        );

        if (!variantDoc.exists) {
          throw Exception('Variant ${line.variantId} not found');
        }

        final currentStock = variantDoc.data()!['currentStock'] as int;
        final newStock = currentStock - line.quantity;

        if (newStock < 0) {
          throw Exception(
            'Insufficient stock for ${line.productName} (${line.size}, ${line.color})',
          );
        }

        // Create movement record
        final movementRef = _firestore.collection('stockMovements').doc();
        transaction.set(movementRef, movement.toJson());

        // Update variant stock
        transaction.update(
          _firestore.collection('productVariants').doc(line.variantId),
          {'currentStock': newStock, 'updatedAt': Timestamp.now()},
        );
      }

      // Update cash session if payment is CASH
      if (sale.paymentType == PaymentType.CASH && sale.cashSessionId != null) {
        final sessionDoc = await transaction.get(
          _firestore.collection('cashSessions').doc(sale.cashSessionId),
        );

        if (sessionDoc.exists) {
          final sessionData = sessionDoc.data()!;
          final currentTotal =
              (sessionData['totalCashSales'] as num?)?.toDouble() ?? 0.0;
          final openingCash = (sessionData['openingCash'] as num).toDouble();
          final manualCashIn =
              (sessionData['manualCashIn'] as num?)?.toDouble() ?? 0.0;
          final manualCashOut =
              (sessionData['manualCashOut'] as num?)?.toDouble() ?? 0.0;

          final newTotalCashSales = currentTotal + sale.totalAmount;
          final newExpectedClosing =
              openingCash + newTotalCashSales + manualCashIn - manualCashOut;

          transaction.update(
            _firestore.collection('cashSessions').doc(sale.cashSessionId),
            {
              'totalCashSales': newTotalCashSales,
              'expectedClosingCash': newExpectedClosing,
            },
          );
        }
      }

      return saleRef.id;
    });
  }

  // Get sales
  Stream<List<Sale>> getSales({int limit = 100}) {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Sale.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get sales by date range
  Stream<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) {
    return _firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Sale.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get sales by cash session
  Stream<List<Sale>> getSalesBySession(String sessionId) {
    return _firestore
        .collection(_collection)
        .where('cashSessionId', isEqualTo: sessionId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Sale.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}
