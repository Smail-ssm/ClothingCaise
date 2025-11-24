import 'package:flutter/services.dart';

/// Service for printing receipts on thermal printers (Windows only)
/// Uses platform channel to communicate with native Windows code
class PrintingService {
  static const MethodChannel _channel = MethodChannel(
    'com.clothingshop/hardware',
  );

  /// Print a sale receipt
  Future<void> printReceipt({
    required String saleId,
    required List<Map<String, dynamic>> items,
    required double total,
    required String paymentType,
    String printerName = 'POS Printer',
  }) async {
    try {
      // Format receipt content
      final StringBuffer content = StringBuffer();

      content.writeln('================================');
      content.writeln('   CLOTHING SHOP RECEIPT');
      content.writeln('================================');
      content.writeln('');
      content.writeln('Sale ID: $saleId');
      content.writeln('Date: ${DateTime.now().toString().substring(0, 19)}');
      content.writeln('');
      content.writeln('--------------------------------');
      content.writeln('ITEMS:');
      content.writeln('--------------------------------');

      for (final item in items) {
        final name = item['name'] ?? 'Unknown';
        final size = item['size'] ?? '';
        final color = item['color'] ?? '';
        final qty = item['quantity'] ?? 1;
        final price = item['unitPrice'] ?? 0.0;
        final lineTotal = item['totalLine'] ?? 0.0;

        content.writeln('$name ($size, $color)');
        content.writeln(
          '  $qty x \$${price.toStringAsFixed(2)} = \$${lineTotal.toStringAsFixed(2)}',
        );
        content.writeln('');
      }

      content.writeln('--------------------------------');
      content.writeln('TOTAL: \$${total.toStringAsFixed(2)}');
      content.writeln('Payment: $paymentType');
      content.writeln('--------------------------------');
      content.writeln('');
      content.writeln('Thank you for your purchase!');
      content.writeln('');
      content.writeln('================================');

      // Call platform method
      await _channel.invokeMethod('printReceipt', {
        'printerName': printerName,
        'content': content.toString(),
      });

      print('✓ Receipt printed successfully');
    } on PlatformException catch (e) {
      print('✗ Failed to print receipt: ${e.message}');
      throw Exception('Print failed: ${e.message}');
    } catch (e) {
      print('✗ Unexpected error during printing: $e');
      throw Exception('Print error: $e');
    }
  }

  /// Check if printer is available
  Future<bool> isPrinterAvailable({String printerName = 'POS Printer'}) async {
    try {
      final result = await _channel.invokeMethod('isPrinterAvailable', {
        'printerName': printerName,
      });
      return result as bool;
    } on PlatformException catch (e) {
      print('✗ Failed to check printer: ${e.message}');
      return false;
    } catch (e) {
      print('✗ Unexpected error checking printer: $e');
      return false;
    }
  }

  /// Test print
  Future<void> testPrint({String printerName = 'POS Printer'}) async {
    try {
      await _channel.invokeMethod('testPrint', {'printerName': printerName});
      print('✓ Test print sent successfully');
    } on PlatformException catch (e) {
      print('✗ Test print failed: ${e.message}');
      throw Exception('Test print failed: ${e.message}');
    } catch (e) {
      print('✗ Unexpected error during test print: $e');
      throw Exception('Test print error: $e');
    }
  }

  /// Get list of available printers (Windows only)
  /// Note: This requires additional Windows API implementation
  Future<List<String>> getAvailablePrinters() async {
    // This would require additional native implementation
    // For now, return common POS printer names
    return [
      'POS Printer',
      'Thermal Printer',
      'Receipt Printer',
      'EPSON TM-T88',
      'Star TSP100',
    ];
  }
}
