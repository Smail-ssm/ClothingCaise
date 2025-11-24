import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/validators.dart';

class CashSessionScreen extends ConsumerStatefulWidget {
  const CashSessionScreen({super.key});

  @override
  ConsumerState<CashSessionScreen> createState() => _CashSessionScreenState();
}

class _CashSessionScreenState extends ConsumerState<CashSessionScreen> {
  final _openingCashController = TextEditingController();
  final _cashInController = TextEditingController();
  final _cashOutController = TextEditingController();
  final _countedCashController = TextEditingController();

  Future<void> _openSession() async {
    final openingCash = double.tryParse(_openingCashController.text);
    if (openingCash == null || openingCash < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) throw Exception('User not found');

      await ref
          .read(cashSessionRepositoryProvider)
          .openSession(currentUser.id, openingCash);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cash session opened')));
        _openingCashController.clear();
        ref.invalidate(activeCashSessionProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addCashIn(String sessionId) async {
    final amount = double.tryParse(_cashInController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      await ref
          .read(cashSessionRepositoryProvider)
          .addCashIn(sessionId, amount);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cash in recorded')));
        _cashInController.clear();
        ref.invalidate(activeCashSessionProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addCashOut(String sessionId) async {
    final amount = double.tryParse(_cashOutController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      await ref
          .read(cashSessionRepositoryProvider)
          .addCashOut(sessionId, amount);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cash out recorded')));
        _cashOutController.clear();
        ref.invalidate(activeCashSessionProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _closeSession(String sessionId) async {
    final countedCash = double.tryParse(_countedCashController.text);
    if (countedCash == null || countedCash < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the counted cash amount')),
      );
      return;
    }

    try {
      await ref
          .read(cashSessionRepositoryProvider)
          .closeSession(sessionId, countedCash);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cash session closed')));
        _countedCashController.clear();
        ref.invalidate(activeCashSessionProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeCashSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cash Session')),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return _buildOpenSessionUI();
          }
          return _buildActiveSessionUI(session);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildOpenSessionUI() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.point_of_sale,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'No Active Session',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Open a new cash session to start selling',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _openingCashController,
                decoration: const InputDecoration(
                  labelText: 'Opening Cash Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openSession,
                  child: const Text('Open Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSessionUI(dynamic session) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Session',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Opening Cash',
                    FormatUtils.formatCurrency(session.openingCash),
                  ),
                  _buildInfoRow(
                    'Cash Sales',
                    FormatUtils.formatCurrency(session.totalCashSales),
                  ),
                  _buildInfoRow(
                    'Manual Cash In',
                    FormatUtils.formatCurrency(session.manualCashIn),
                  ),
                  _buildInfoRow(
                    'Manual Cash Out',
                    FormatUtils.formatCurrency(session.manualCashOut),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Expected Closing Cash',
                    FormatUtils.formatCurrency(session.expectedClosingCash),
                    isHighlighted: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Manual Adjustments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cashInController,
                    decoration: const InputDecoration(
                      labelText: 'Cash In Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _addCashIn(session.id),
                    child: const Text('Add Cash In'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cashOutController,
                    decoration: const InputDecoration(
                      labelText: 'Cash Out Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _addCashOut(session.id),
                    child: const Text('Add Cash Out'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Close Session',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _countedCashController,
                    decoration: const InputDecoration(
                      labelText: 'Counted Cash Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _closeSession(session.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Close Session'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
              fontSize: isHighlighted ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _openingCashController.dispose();
    _cashInController.dispose();
    _cashOutController.dispose();
    _countedCashController.dispose();
    super.dispose();
  }
}
