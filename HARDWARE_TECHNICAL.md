# Windows Hardware Integration - Technical Reference

## Architecture Overview

The hardware integration uses Flutter's platform channel mechanism to communicate between Dart code and native Windows C++ code.

```
┌─────────────────────────────────────────────────┐
│           Flutter/Dart Layer                    │
├─────────────────────────────────────────────────┤
│  PrintingService.dart                           │
│  CashDrawerService.dart                         │
└──────────────────┬──────────────────────────────┘
                   │ MethodChannel
                   │ 'com.clothingshop/hardware'
┌──────────────────▼──────────────────────────────┐
│         Native Windows Layer (C++)              │
├─────────────────────────────────────────────────┤
│  hardware_plugin.cpp                            │
│  ├─ OpenPrinter()                               │
│  ├─ PrintReceipt()                              │
│  ├─ PrintRawData()                              │
│  ├─ OpenCashDrawer()                            │
│  └─ GenerateReceiptData() (ESC/POS)             │
└──────────────────┬──────────────────────────────┘
                   │ Windows API
┌──────────────────▼──────────────────────────────┐
│           Windows Print Spooler                 │
├─────────────────────────────────────────────────┤
│  winspool.lib                                   │
│  ├─ OpenPrinter()                               │
│  ├─ StartDocPrinter()                           │
│  ├─ WritePrinter()                              │
│  └─ ClosePrinter()                              │
└──────────────────┬──────────────────────────────┘
                   │ USB/Serial/Network
┌──────────────────▼──────────────────────────────┐
│          Physical Hardware                      │
├─────────────────────────────────────────────────┤
│  Thermal Printer ──RJ11/RJ12──► Cash Drawer    │
└─────────────────────────────────────────────────┘
```

## Files Structure

```
windows/runner/
├── hardware_plugin.h          # Plugin header (interface)
├── hardware_plugin.cpp        # Plugin implementation
├── flutter_window.h           # Flutter window header
├── flutter_window.cpp         # Flutter window (plugin registration)
├── main.cpp                   # App entry point
└── CMakeLists.txt            # Build configuration (needs update)

lib/core/services/
├── printing_service.dart      # Dart printing service
└── cash_drawer_service.dart   # Dart cash drawer service
```

## Method Channel API

### Channel Name
```
com.clothingshop/hardware
```

### Methods

#### 1. printReceipt
**Purpose**: Print a formatted receipt

**Arguments**:
```dart
{
  'printerName': String,  // Default: 'POS Printer'
  'content': String       // Receipt text to print
}
```

**Returns**: `bool` (success)

**Throws**: `PlatformException`

---

#### 2. openCashDrawer
**Purpose**: Open the cash drawer via printer

**Arguments**: None

**Returns**: `bool` (success)

**Throws**: `PlatformException`

---

#### 3. isPrinterAvailable
**Purpose**: Check if printer is accessible

**Arguments**:
```dart
{
  'printerName': String  // Optional, default: 'POS Printer'
}
```

**Returns**: `bool` (available)

---

#### 4. testPrint
**Purpose**: Send a test print job

**Arguments**:
```dart
{
  'printerName': String  // Optional, default: 'POS Printer'
}
```

**Returns**: `bool` (success)

**Throws**: `PlatformException`

## ESC/POS Command Reference

### Common Commands

| Command | Hex | Function |
|---------|-----|----------|
| ESC @ | 1B 40 | Initialize printer |
| LF | 0A | Line feed |
| CR | 0D | Carriage return |
| ESC a n | 1B 61 n | Alignment (0=left, 1=center, 2=right) |
| GS ! n | 1D 21 n | Character size |
| GS V m | 1D 56 m | Cut paper |
| ESC p m t1 t2 | 1B 70 m t1 t2 | Open cash drawer |

### Character Size (GS ! n)

```
n = height | width

Examples:
0x00 = Normal
0x10 = Double height
0x20 = Double width  
0x30 = Double height + width
```

### Cash Drawer Command Detail

```cpp
ESC p m t1 t2
  │  │ │  │
  │  │ │  └─ OFF time (units of 2ms)
  │  │ └──── ON time (units of 2ms)  
  │  └─────── Pin number (0 or 1)
  └────────── Command

Example: Open drawer for 100ms
ESC p 0 50 50
= 1B 70 00 32 32
```

## Implementation Details

### C++ Plugin

**Key Functions**:

```cpp
// Open Windows printer
bool OpenPrinter(const std::string& printer_name);

// Print text content (converts to ESC/POS)
bool PrintReceipt(const std::string& content);

// Print raw ESC/POS bytes
bool PrintRawData(const std::vector<uint8_t>& data);

// Generate ESC/POS from text
std::vector<uint8_t> GenerateReceiptData(const std::string& content);

// Get cash drawer command bytes
std::vector<uint8_t> GetCashDrawerCommand();
```

**Windows APIs Used**:
- `OpenPrinterW()` - Open printer handle
- `StartDocPrinterW()` - Begin print job
- `StartPagePrinter()` - Begin page
- `WritePrinter()` - Send data to printer
- `EndPagePrinter()` - End page
- `EndDocPrinter()` - End print job
- `ClosePrinter()` -Close printer handle

### Dart Services

**PrintingService**:
```dart
class PrintingService {
  static const MethodChannel _channel = 
      MethodChannel('com.clothingshop/hardware');
  
  Future<void> printReceipt({...}) async {
    // Format content
    // Call platform method
    await _channel.invokeMethod('printReceipt', {...});
  }
}
```

## Extending the Implementation

### Add Barcode Printing

1. Update `GenerateReceiptData()` in C++:
```cpp
// Add to GenerateReceiptData()
// Code 128 barcode
data.push_back(GS);     // 0x1D
data.push_back('k');    // k
data.push_back(73);     // Code 128
data.push_back(12);     // Length
// Add barcode data bytes
```

2. Update Dart service:
```dart
Future<void> printBarcodeReceipt({
  required String barcode,
  ...
}) async {
  // Add barcode to content
}
```

### Add Logo Printing

1. Convert logo to monochrome bitmap
2. Use ESC * command for raster graphics
3. Send bitmap data

```cpp
// Example: Print logo
data.push_back(ESC);
data.push_back('*');
data.push_back(mode);
data.push_back(width_low);
data.push_back(width_high);
// Add bitmap data
```

### Support Multiple Printers

1. Modify Dart service:
```dart
Future<void> printReceipt({
  required String printerName,  // Make required
  ...
}) async {
  await _channel.invokeMethod('printReceipt', {
    'printerName': printerName,
    ...
  });
}
```

2. Store printer preferences
3. Let user select printer in settings

## Build Configuration

### CMakeLists.txt

Add to `windows/runner/CMakeLists.txt`:

```cmake
target_sources(${BINARY_NAME} PRIVATE
  # ... existing files ...
  "hardware_plugin.cpp"
  "hardware_plugin.h"
)

# Link Windows print library
target_link_libraries(${BINARY_NAME} PRIVATE
  winspool
)
```

## Error Handling

### C++ Side

```cpp
if (!OpenPrinter(printer_name)) {
  result->Error(
    "PRINTER_NOT_FOUND",
    "Could not open printer: " + printer_name
  );
  return;
}
```

### Dart Side

```dart
try {
  await _channel.invokeMethod('printReceipt', {...});
} on PlatformException catch (e) {
  if (e.code == 'PRINTER_NOT_FOUND') {
    // Handle printer not found
  } else if (e.code == 'PRINT_FAILED') {
    // Handle print failure
  }
}
```

## Testing

### Unit Test (Dart)

```dart
void main() {
  test('PrintingService formats receipt correctly', () async {
    final service = PrintingService();
    // Mock platform channel
    // Test receipt formatting
  });
}
```

### Integration Test

```dart
void main() {
  integrationTest('Prints actual receipt', () async {
    final service = PrintingService();
    await service.testPrint();
    // Verify receipt printed
  });
}
```

## Performance

### Typical timings:
- Open printer: <50ms
- Send ESC/POS data: <100ms
- Physical printing: 1-3 seconds
- Cash drawer open: <200ms

### Optimization tips:
1. Keep printer handle open during session
2. Batch multiple receipts if possible
3. Use "Fast" print mode
4. Minimize text, maximize ESC/POS commands

## Security

1. **Validate input**: Sanitize receipt content
2. **Limit access**: Check user permissions before printing
3. **Audit logging**: Log all print and drawer operations
4. **Error handling**: Don't expose system details in errors

## Debugging

### Enable verbose logging in C++:

```cpp
#define DEBUG_PRINTING

#ifdef DEBUG_PRINTING
  OutputDebugStringA(("Printer: " + message + "\n").c_str());
#endif
```

### View logs in Visual Studio Output window

### Dart logging:

```dart
print('✓ Success message');
print('✗ Error message');
print('ℹ Info message');
```

## Common Issues

### Issue: "Access Denied"
**Cause**: Insufficient permissions
**Solution**: Run as Administrator or change printer permissions

### Issue: "Printer Offline"
**Cause**: Printer not ready
**Solution**: Check printer status, cables, power

### Issue: "Invalid Handle"
**Cause**: Printer closed prematurely
**Solution**: Check OpenPrinter/ClosePrinter pairing

### Issue: "Cash drawer doesn't open"
**Cause**: Wrong ESC/POS command or cable
**Solution**: Verify cable, try different pin number (0 vs 1)

## References

- [Windows Print Spooler API](https://docs.microsoft.com/en-us/windows/win32/printdocs/printing-and-print-spooler)
- [ESC/POS Command Reference](https://reference.epson-biz.com/modules/ref_escpos/)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)

---

## Example: Complete Custom Receipt

```cpp
std::vector<uint8_t> GenerateCustomReceipt() {
  std::vector<uint8_t> data;
  
  // Initialize
  data.push_back(0x1B); data.push_back(0x40);
  
  // Center align
  data.push_back(0x1B); data.push_back(0x61); data.push_back(0x01);
  
  // Large text
  data.push_back(0x1D); data.push_back(0x21); data.push_back(0x30);
  
  // Add title
  std::string title = "MY STORE\n";
  data.insert(data.end(), title.begin(), title.end());
  
  // Normal text
  data.push_back(0x1D); data.push_back(0x21); data.push_back(0x00);
  
  // Left align
  data.push_back(0x1B); data.push_back(0x61); data.push_back(0x00);
  
  // Add content...
  
  // Cut paper
  data.push_back(0x1D); data.push_back(0x56); data.push_back(66); data.push_back(0);
  
  return data;
}
```
