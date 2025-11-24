# Flutter + Firebase Clothing Stock & Caisse Manager  
### **Complete Specification (Cursor AI Prompt)**

This Markdown file contains the **full specification** used to generate the complete Flutter + Firebase application inside .  
It includes all required collections, models, screens, architecture rules, and logic.

---

## 1. Project Overview

Build a production-ready Flutter application for a **clothing shop stock management + caisse system**.

Platforms:
- Android  
- Web  
- **Windows Desktop** (important for ticket printer + cash drawer)

Backend:
- Firebase Auth  
- Cloud Firestore  

Tech Stack:
- Flutter 3.13+
- Riverpod (preferred)
- GoRouter
- Null-safety

---

## 2. Core Features

### A. Authentication
- Login screen  
- Firebase Auth (email + password)
- `users` collection stores:
  - `name`
  - `role: admin | cashier`
  - `createdAt: Timestamp`

---

## 3. Clothing Product Structure

Clothing requires variants (size + color).

### A. Product Model (General)
Stored in `products` collection.

Fields:
- `name`
- `category`
- `brand`
- `gender`
- `season`
- `baseBuyingPrice`
- `baseSellingPrice`
- `isActive`
- `createdAt`
- `updatedAt`

### B. Product Variants (Size + Color)
Stored in **flat collection**: `productVariants`.

Fields:
- `productId`
- `productName`
- `size` (XS, S, M, L, XL, XXL…)
- `color`
- `barcode`
- `buyingPrice`
- `sellingPrice`
- `currentStock`
- `minStock`
- `isActive`
- `createdAt`
- `updatedAt`

---

## 4. Stock Movements

Collection: `stockMovements`

Fields:
- `variantId`
- `productId`
- `quantity`
- `direction: IN | OUT`
- `reason: PURCHASE | SALE | ADJUSTMENT | WASTE`
- `relatedSaleId`
- `userId`
- `createdAt`

Rules:
- Update `currentStock` when creating a stock movement
- No negative stock allowed

---

## 5. Sales (POS)

Collection: `sales`

Fields:
- `date`
- `totalAmount`
- `paymentType: CASH | CARD | OTHER`
- `userId`
- `cashSessionId`
- `lines`: list of:
  - variantId
  - productId
  - productName
  - size
  - color
  - quantity
  - unitPrice
  - totalLine

Sale Logic:
- Deduct stock per line  
- Create stockMovement (OUT, SALE)  
- If paymentType = CASH → update caisse session  

---

## 6. Caisse (Cash Drawer) System

Collection: `cashSessions`

Fields:
- `userId`
- `status: OPEN | CLOSED`
- `openingCash`
- `totalCashSales`
- `manualCashIn`
- `manualCashOut`
- `expectedClosingCash`
- `countedClosingCash`
- `difference`
- `openedAt`
- `closedAt`

Calculations:
```
expectedClosingCash = openingCash + totalCashSales + manualCashIn - manualCashOut
difference = countedClosingCash - expectedClosingCash
```

---

## 7. Screens to Build

### Auth
- Login Screen

### Home
- Cards showing:
  - number of products  
  - number of low-stock variants  
  - expected closing cash (if session open)

### Products
- List products  
- Add/edit product  
- Deactivate product  

### Variants
- List all variants  
- Add/edit variant  
- Initial stock  

### Stock
- Stock In  
- Stock Out  

### Sales (POS)
- Search products or scan barcode  
- Add to cart  
- Select payment type  
- Confirm sale  

### Caisse
- Open session  
- Cash in / Cash out  
- Close session  

---

## 8. Windows Hardware Integration (prepare)
Create:

- `PrintingService`  
- `CashDrawerService`  

Implement mock logic for now.  
Later, implement Windows-specific platform channels.

---

## 9. Folder Structure (Required)

```
lib/
  main.dart
  core/
    models/
    services/
    repositories/
    utils/
  features/
    auth/
    products/
    variants/
    stock/
    sales/
    cash/
    home/
  common/
    widgets/
    theme/
    routing/
```

---

## 10. Requirements for Cursor Generation

Cursor must generate:

- All model classes with `fromJson/toJson`
- Firestore repositories
- Riverpod providers
- Screens + routing
- CRUD UI
- POS UI
- Caisse UI
- Project-wide error handling
- Windows-friendly architecture for hardware integration

All features must be **functional**, not mockups.

---

# END OF FILE
