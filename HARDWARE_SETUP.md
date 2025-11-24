# Hardware Integration Guide - Windows POS Setup

This guide explains how to integrate thermal printers and cash drawers with your Clothing Caisse Manager application on Windows.

## 📦 What's Included

The application includes **native Windows integration** for:
- ✅ **Thermal Receipt Printers** (ESC/POS compatible)
- ✅ **Cash Drawers** (connected via printer)

## 🔧 Hardware Requirements

### 1. Thermal Printer
**Supported Protocols:**
- ESC/POS (most common, recommended)
- Compatible brands: Epson, Star, Citizen, Bixolon, etc.

**Recommended Models:**
- Epson TM-T88 series
- Star TSP100/TSP143
- Citizen CT-S310
- Bixolon SRP-350

**Connection Types:**
- ✅ USB (Recommended)
- ✅ Serial (RS-232)
- ✅ Network (Ethernet)
- ⚠️ Bluetooth (may have latency issues)

### 2. Cash Drawer
**Connection:**
- Must be connected to the printer's cash drawer port (RJ11/RJ12)
- Cannot be controlled directly; works through printer

**Compatible Drawers:**
- Any cash drawer with RJ11/RJ12 connector
- 12V or 24V drawers (check printer specifications)

## 🚀 Setup Instructions

### Step 1: Install Printer Driver

1. **Download Driver** from manufacturer's website:
   - Epson: https://epson.com/support
   - Star: https://www.starmicronics.com/support
   - Others: Check manufacturer website

2. **Install Driver** following manufacturer instructions

3. **Set Printer Name** to `POS Printer` (or customize in code)
   - Control Panel → Devices and Printers
   - Right-click printer → Printer Properties
   - Rename to `POS Printer`

### Step 2: Connect Hardware

#### USB Connection:
1. Connect printer to Windows PC via USB
2. Windows should auto-detect and install
3. Verify in "Devices and Printers"

#### Network Connection:
1. Connect printer to network (Ethernet)
2. Note the printer's IP address (print configuration)
3. Add Network Printer in Windows
4. Enter IP address when prompted

#### Cash Drawer:
1. Connect cash drawer to printer's cash drawer port
2. Usually located on the back of the printer
3. Plug in the RJ11/RJ12 cable
4. Cash drawer should click when printer sends command

### Step 3: Configure Printer Settings

1. Open **Devices and Printers**
2. Right-click `POS Printer` → **Printing Preferences**
3. Configure:
   - Paper Size: Usually 80mm (3 1/8")
   - Print Quality: Standard  
   - Speed: Normal/Fast
4. Click **Apply** and **OK**

### Step 4: Test Hardware

In the app:
```dart
// Test printer
final printingService = PrintingService();
await printingService.testPrint();

// Test cash drawer
final drawerService = CashDrawerService();
await drawerService.testDrawer();
```

Or use the built-in test buttons in the Settings screen.

## 🔌 ESC/POS Commands Reference

The app uses standard ESC/POS commands:

### Printer Commands
```
Initialize: ESC @
Line feed: LF (0x0A)
Cut paper: GS V 66 0
Character size: GS ! n
```

### Cash Drawer Command
```
Open drawer: ESC p m t1 t2
- ESC = 0x1B
- p = 0x70
- m = pin number (0 or 1)
- t1 = ON time (50ms)
- t2 = OFF time (50ms)
```

## 🎯 Customization

### Change Printer Name

If your printer has a different name:

**Option 1: Rename Windows Printer**
- Recommended for simplicity
- Set name to `POS Printer`

**Option 2: Update Code**
```dart
// In printing_service.dart and cash_drawer_service.dart
final String defaultPrinterName = 'Your Printer Name';
```

### Adjust Paper Width

For different paper widths (58mm, 80mm, etc.):
- The text formatting automatically adjusts
- For advanced layout, modify `GenerateReceiptData()` in `hardware_plugin.cpp`

### Custom Receipt Format

Edit `printReceipt()` in `lib/core/services/printing_service.dart`:
```dart
content.writeln('Your Store Name');
content.writeln('123 Main St');
content.writeln('Tel: (555) 123-4567');
// ... customize as needed
```

## 🐛 Troubleshooting

### Printer Not Found
**Error:** `PRINTER_NOT_FOUND`

**Solutions:**
1. Check printer name matches exactly
2. Verify printer is online (not paused)
3. Check USB/Network connection
4. Restart printer
5. Reinstall driver

### Print Job Stuck
**Symptoms:** Nothing prints, or partial prints

**Solutions:**
1. Clear print queue: Control Panel → Devices and Printers
2. Right-click printer → "See what's printing"
3. Document → Cancel All Documents
4. Restart Print Spooler service:
   ```powershell
   net stop spooler
   net start spooler
   ```

### Cash Drawer Won't Open
**Error:** `DRAWER_FAILED`

**Solutions:**
1. Check RJ11/RJ12 cable connection
2. Verify drawer is plugged into power
3. Test printer is working first
4. Check drawer voltage matches printer (12V vs 24V)
5. Try different cash drawer port (some printers have 2)

### Permission Errors
**Error:** Access denied

**Solutions:**
1. Run app as Administrator (right-click → Run as administrator)
2. Check printer permissions: Properties → Security tab
3. Add your user account with full control

## 📱 Platform-Specific Notes

### Windows 10/11
- ✅ Fully supported
- USB drivers usually auto-install
- Network printers need manual setup

### Windows 7/8
- ✅ Supported but requires manual driver installation
- May need to disable driver signature enforcement

### Other Platforms
- **Android**: Would require different implementation (Android POS SDK)
- **iOS**: Not applicable (POS hardware not supported)
- **Web**: Cannot access hardware directly
- **macOS**: Would work but requires different USB/serial implementation

## 🔐 Security Considerations

1. **Printer Access**: Limit who can access the printer in Windows settings
2. **Network Printers**: Use secure network, consider VPN for remote locations
3. **Cash Drawer**: Physical security is most important

## 📊 Performance Tips

1. **Print Speed**: Use "Fast" mode in printer preferences
2. **Paper Roll**: Use high-quality thermal paper
3. **Maintenance**: Clean print head monthly
4. **Network**: Use wired Ethernet, not WiFi, for reliability

## 🛠 Advanced: Direct Serial/USB Communication

For advanced users who need direct serial communication:

1. Update `hardware_plugin.cpp` to use Windows Serial API
2. Add COM port detection
3. Implement raw serial I/O

This is already implemented in the platform channel, but you can customize it further.

## 📞 Support

### Printer Support
- Check manufacturer's website for documentation
- Most printers include command reference manuals
- ESC/POS command reference: https://reference.epson-biz.com/modules/ref_escpos/

### App Support
- Check logs in console for detailed error messages
- Enable debug mode for verbose output
- Test with simple text file first (Notepad → Print)

## ✅ Quick Checklist

Before reporting issues:
- [ ] Printer appears in "Devices and Printers"
- [ ] Printer status is "Ready" (not offline/paused)
- [ ] Test page prints successfully from Windows
- [ ] Printer name matches code configuration
- [ ] Cash drawer cable is securely connected
- [ ] App has printer access permissions
- [ ] Printer driver is up to date

## 🎓 Resources

- **ESC/POS Commands**: https://reference.epson-biz.com/modules/ref_escpos/
- **Flutter Platform Channels**: https://docs.flutter.dev/platform-integration/platform-channels
- **Windows Printing API**: https://docs.microsoft.com/en-us/windows/win32/printdocs/printing-and-print-spooler

---

## Example: Complete Workflow

```dart
// 1. Check hardware availability
final printing = PrintingService();
final drawer = CashDrawerService();

if (await printing.isPrinterAvailable()) {
  print('✓ Printer ready');
} else {
  print('✗ Printer not available');
  return;
}

// 2. Process sale
final sale = await createSale(...);

// 3. Open cash drawer (for cash payments)
if (paymentType == PaymentType.CASH) {
  await drawer.openDrawer();
}

// 4. Print receipt
await printing.printReceipt(
  saleId: sale.id,
  items: sale.lines.map((line) => {
    'name': line.productName,
    'size': line.size,
    'color': line.color,
    'quantity': line.quantity,
    'unitPrice': line.unitPrice,
    'totalLine': line.totalLine,
  }).toList(),
  total: sale.totalAmount,
  paymentType: paymentType.toString(),
);

print('✓ Sale completed successfully');
```
