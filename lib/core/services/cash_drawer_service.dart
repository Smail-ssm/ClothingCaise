import 'package:flutter/services.dart';

/// Service for controlling cash drawer via thermal printer
/// Uses platform channel to communicate with native Windows code
/// Cash drawer is typically connected to printer's cash drawer port (RJ11/RJ12)
class CashDrawerService {
  static const MethodChannel _channel = MethodChannel(
    'com.clothingshop/hardware',
  );

  /// Open the cash drawer
  /// Sends ESC/POS command through the printer to trigger the cash drawer
  Future<void> openDrawer() async {
    try {
      await _channel.invokeMethod('openCashDrawer');
      print('💰 Cash drawer opened successfully');
    } on PlatformException catch (e) {
      print('✗ Failed to open cash drawer: ${e.message}');
      throw Exception('Cash drawer error: ${e.message}');
    } catch (e) {
      print('✗ Unexpected error opening cash drawer: $e');
      throw Exception('Cash drawer error: $e');
    }
  }

  /// Check if cash drawer is available (checks if printer is available)
  /// The cash drawer is controlled through the printer
  Future<bool> isDrawerAvailable() async {
    try {
      final result = await _channel.invokeMethod('isPrinterAvailable', {
        'printerName': 'POS Printer',
      });
      return result as bool;
    } on PlatformException catch (e) {
      print('✗ Failed to check cash drawer: ${e.message}');
      return false;
    } catch (e) {
      print('✗ Unexpected error checking cash drawer: $e');
      return false;
    }
  }

  /// Test cash drawer (attempts to open it)
  Future<void> testDrawer() async {
    try {
      print('💰 Testing cash drawer...');
      await openDrawer();
      print('✓ Cash drawer test successful');
    } catch (e) {
      print('✗ Cash drawer test failed: $e');
      throw Exception('Cash drawer test failed: $e');
    }
  }
}
