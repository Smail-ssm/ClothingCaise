# 📘 User Guide - Clothing Caisse Manager

This guide explains how to use the Clothing Caisse Manager application for your daily shop operations.

## 🔑 1. Authentication

### Login
1. Launch the application.
2. Enter your **Email** and **Password**.
3. Click **Login**.

> **Note**: If you don't have an account, ask your administrator to create one for you.

---

## 🏠 2. Dashboard (Home)

The dashboard gives you a quick overview of your shop's status:

- **Total Products**: Number of unique product styles.
- **Low Stock**: Number of items that are running low (below minimum stock).
- **Expected Cash**: The amount of cash that should be in the drawer (if a session is open).

**Quick Actions**:
- **New Sale**: Jump directly to the POS screen.
- **Add Product**: Go to the product creation screen.

---

## 👕 3. Product Management

### Creating a Product
1. Go to **Products** in the side menu.
2. Click the **+ Add Product** button.
3. Fill in the details:
   - **Name**: e.g., "Summer T-Shirt"
   - **Category**: e.g., "T-Shirts"
   - **Brand**: e.g., "Nike"
   - **Gender**: Men, Women, or Unisex
   - **Season**: Summer, Winter, etc.
   - **Base Prices**: Default buying and selling prices.
4. Click **Save**.

### Managing Variants (Sizes & Colors)
A "Product" is the general style. "Variants" are the specific items (e.g., Red XL, Blue M).

1. Go to **Variants**.
2. Click **+ Add Variant**.
3. Select the **Product** (e.g., "Summer T-Shirt").
4. Enter:
   - **Size**: e.g., "XL"
   - **Color**: e.g., "Red"
   - **Barcode**: Scan or type the barcode.
   - **Stock**: Initial quantity.
   - **Min Stock**: Alert level (e.g., 5).
5. Click **Save**.

> **Tip**: You can print barcode labels for your variants from this screen (Windows only).

---

## 📦 4. Stock Management

Use this to add new inventory or remove damaged items.

1. Go to **Stock**.
2. **Scan Barcode** or search for a product.
3. Select **Movement Type**:
   - **IN**: Adding stock (Purchase, Return).
   - **OUT**: Removing stock (Damaged, Theft, Correction).
4. Enter the **Quantity**.
5. Click **Confirm**.

> **Note**: Sales automatically reduce stock. You don't need to do this manually for sales.

---

## 💰 5. Point of Sale (POS)

This is where you process customer sales.

### Making a Sale
1. Go to **Sales (POS)**.
2. **Scan Items**: Use your barcode scanner or search by name.
3. **Adjust Cart**:
   - Change quantity with `+` and `-`.
   - Remove items with the trash icon.
4. **Select Payment**:
   - **Cash**: Requires an open Cash Session.
   - **Card**: External card terminal.
   - **Other**: Gift cards, etc.
5. Click **Complete Sale**.

### Receipt
- If on Windows with a printer, the receipt will print automatically.
- A digital record is saved in the system.

---

## 💵 6. Cash Session (Caisse)

Manage your cash drawer securely.

### Opening a Session
1. Go to **Cash Session**.
2. Count the cash currently in the drawer.
3. Enter the amount in **Opening Cash**.
4. Click **Open Session**.

### During the Day
- All **Cash Sales** are automatically added to the "Expected Cash".
- **Manual Cash In**: Use this if you add change/coins to the drawer.
- **Manual Cash Out**: Use this for petty cash expenses (e.g., buying lunch, paying for cleaning).

### Closing a Session
1. Click **Close Session**.
2. **Count your actual cash** in the drawer.
3. Enter the **Counted Cash**.
4. The system will calculate the **Difference** (Expected vs. Counted).
   - **Green**: Perfect match.
   - **Red**: Missing cash or extra cash.
5. Click **Confirm Close**.

---

## ⚠️ Common Questions

**Q: Can I sell an item with 0 stock?**
A: No, the system prevents selling items that are out of stock to ensure inventory accuracy.

**Q: How do I handle returns?**
A: Currently, use the **Stock** screen to add the item back (IN - Adjustment) and refund the customer manually.

**Q: I forgot my password.**
A: Ask the administrator to reset it for you.
