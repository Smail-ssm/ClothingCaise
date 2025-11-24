import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cash_session.dart';

class CashSessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cashSessions';

  // Get active session for user
  Future<CashSession?> getActiveSession(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'OPEN')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CashSession.fromJson(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  // Open new session
  Future<String> openSession(String userId, double openingCash) async {
    // Check if there's already an open session
    final existingSession = await getActiveSession(userId);
    if (existingSession != null) {
      throw Exception('A cash session is already open');
    }

    final session = CashSession(
      id: '',
      userId: userId,
      status: SessionStatus.OPEN,
      openingCash: openingCash,
      totalCashSales: 0,
      manualCashIn: 0,
      manualCashOut: 0,
      expectedClosingCash: openingCash,
      openedAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection(_collection)
        .add(session.toJson());
    return docRef.id;
  }

  // Add manual cash in
  Future<void> addCashIn(String sessionId, double amount) async {
    final doc = await _firestore.collection(_collection).doc(sessionId).get();
    if (!doc.exists) throw Exception('Session not found');

    final session = CashSession.fromJson(doc.data()!, doc.id);
    final newManualCashIn = session.manualCashIn + amount;
    final newExpected = session.calculateExpectedClosing() + amount;

    await _firestore.collection(_collection).doc(sessionId).update({
      'manualCashIn': newManualCashIn,
      'expectedClosingCash': newExpected,
    });
  }

  // Add manual cash out
  Future<void> addCashOut(String sessionId, double amount) async {
    final doc = await _firestore.collection(_collection).doc(sessionId).get();
    if (!doc.exists) throw Exception('Session not found');

    final session = CashSession.fromJson(doc.data()!, doc.id);
    final newManualCashOut = session.manualCashOut + amount;
    final newExpected = session.calculateExpectedClosing() - amount;

    await _firestore.collection(_collection).doc(sessionId).update({
      'manualCashOut': newManualCashOut,
      'expectedClosingCash': newExpected,
    });
  }

  // Close session
  Future<void> closeSession(String sessionId, double countedCash) async {
    final doc = await _firestore.collection(_collection).doc(sessionId).get();
    if (!doc.exists) throw Exception('Session not found');

    final session = CashSession.fromJson(doc.data()!, doc.id);
    final difference = session.calculateDifference(countedCash);

    await _firestore.collection(_collection).doc(sessionId).update({
      'status': 'CLOSED',
      'countedClosingCash': countedCash,
      'difference': difference,
      'closedAt': Timestamp.now(),
    });
  }

  // Get sessions by user
  Stream<List<CashSession>> getSessionsByUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('openedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CashSession.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get all sessions
  Stream<List<CashSession>> getAllSessions({int limit = 50}) {
    return _firestore
        .collection(_collection)
        .orderBy('openedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CashSession.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get session by ID
  Future<CashSession?> getSession(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return CashSession.fromJson(doc.data()!, doc.id);
  }

  Stream<CashSession?> watchSession(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CashSession.fromJson(doc.data()!, doc.id);
    });
  }
}
