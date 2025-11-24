import 'dart:io';

/// Platform detection utilities for the application
class PlatformUtils {
  /// Check if running on Windows
  static bool get isWindows => Platform.isWindows;

  /// Check if running on mobile (Android or iOS)
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Check if running on desktop (Windows, macOS, Linux)
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// Check if device is a POS terminal (Windows)
  /// On Windows, we automatically limit to POS features only
  static bool get isPOSTerminal => false; // Forced for testing

  /// Get platform name for display
  static String get platformName {
    if (Platform.isWindows) return 'Windows POS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
