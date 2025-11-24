# 🖨️ Hardware Integration - Clothing Caisse Manager

This guide explains how to integrate hardware peripherals (Printers, Cash Drawers, Scanners) with the application, specifically for the **Windows** platform.

## 🔫 Barcode Scanners

Barcode scanners act as keyboard inputs.

### Setup
1.  Connect your USB barcode scanner to the computer.
2.  Ensure it is configured to send an "Enter" key (Carriage Return) after scanning.
    -   Most scanners do this by default.
    -   Refer to your scanner's manual if needed.

### Usage
-   **POS Screen**: Click on the search field (or ensure focus is on the window) and scan an item. It will automatically be added to the cart.
-   **Stock Screen**: Scan an item to search for it.
-   **Variant Screen**: Scan a barcode to assign it to a new variant.

---

## 🧾 Thermal Receipt Printer

The application is designed to work with ESC/POS compatible thermal printers (e.g., Epson TM-T20, generic 80mm printers).

### Current Implementation
The current version uses a **Mock Service** (`PrintingService`) for development. It logs print actions to the console instead of sending them to a physical device.

### Enabling Physical Printing (Windows)

To enable real printing, you need to implement the Windows Platform Channel in `windows/runner/`.

1.  **Dependency**: We recommend using the `esc_pos_printer` and `flutter_pos_printer_platform` packages.
2.  **Service Update**: Modify `lib/core/services/printing_service.dart` to use the real printer driver.

#### Planned Architecture
```dart
// lib/core/services/printing_service.dart
Future<void> printReceipt(Sale sale) async {
  if (Platform.isWindows) {
    // Send ESC/POS commands via Platform Channel or Driver
  }
}
```

---

## 💵 Cash Drawer

Cash drawers connect via the Thermal Printer (RJ11/RJ12 cable). The printer sends a pulse signal to open the drawer.

### How it Works
1.  App sends "Print" command (or specific "Open Drawer" command) to the printer.
2.  Printer receives command.
3.  Printer sends 24V pulse to the Cash Drawer.
4.  Drawer opens.

### Implementation
The `CashDrawerService` currently mocks this action.

To implement:
1.  Send the ESC/POS command `[27, 112, 0, 25, 250]` (standard kick command) to the printer.
2.  This should be done whenever a **Cash Sale** is completed or the **Open Session** button is clicked.

---

## 🖥️ Windows POS Mode

The application automatically detects when it is running on Windows and enables POS-specific features:
-   Direct printing support (future).
-   Keyboard shortcuts (future).
-   Optimized layout for touch screens.
