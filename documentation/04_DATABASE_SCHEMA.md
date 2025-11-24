# 🗄️ Database Schema - Clothing Caisse Manager

The application uses **Cloud Firestore** (NoSQL) for data storage.

## 🔒 Security Rules

Access is controlled by `role` ("admin" or "cashier").
-   **Admins**: Full read/write access.
-   **Cashiers**: Read access, limited write access (Sales, Cash Sessions).

---

## 📂 Collections

### 1. `users`
Stores user profiles and roles.

| Field | Type | Description |
| :--- | :--- | :--- |
| `uid` | String | Document ID (matches Auth UID) |
| `name` | String | Display name |
| `email` | String | User email |
| `role` | String | `admin` or `cashier` |
| `createdAt` | Timestamp | Account creation date |

### 2. `products`
Stores general product information (style).

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `name` | String | Product name |
| `category` | String | e.g., "T-Shirts" |
| `brand` | String | e.g., "Nike" |
| `gender` | String | `Men`, `Women`, `Unisex` |
| `season` | String | `Summer`, `Winter`, etc. |
| `baseBuyingPrice` | Number | Default cost |
| `baseSellingPrice` | Number | Default price |
| `isActive` | Boolean | Soft delete flag |

### 3. `productVariants`
Stores specific SKUs (Size/Color combinations).

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `productId` | String | Reference to parent Product |
| `productName` | String | Denormalized name |
| `size` | String | e.g., "XL" |
| `color` | String | e.g., "Red" |
| `barcode` | String | Unique barcode |
| `currentStock` | Number | Current inventory level |
| `minStock` | Number | Low stock alert threshold |
| `buyingPrice` | Number | Specific cost |
| `sellingPrice` | Number | Specific price |

### 4. `stockMovements`
Tracks history of inventory changes.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `variantId` | String | Reference to Variant |
| `quantity` | Number | Amount changed |
| `direction` | String | `IN` or `OUT` |
| `reason` | String | `PURCHASE`, `SALE`, `ADJUSTMENT`, `WASTE` |
| `userId` | String | Who made the change |
| `createdAt` | Timestamp | When it happened |

### 5. `sales`
Stores completed sales transactions.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `date` | Timestamp | Transaction time |
| `totalAmount` | Number | Final total |
| `paymentType` | String | `CASH`, `CARD`, `OTHER` |
| `userId` | String | Cashier ID |
| `cashSessionId` | String | Reference to Cash Session |
| `lines` | Array | List of items sold (snapshot) |

### 6. `cashSessions`
Tracks cash drawer shifts.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `userId` | String | Cashier ID |
| `status` | String | `OPEN` or `CLOSED` |
| `openedAt` | Timestamp | Start time |
| `closedAt` | Timestamp | End time |
| `openingCash` | Number | Starting amount |
| `totalCashSales` | Number | Accumulated cash sales |
| `manualCashIn` | Number | Manual additions |
| `manualCashOut` | Number | Manual withdrawals |
| `expectedClosingCash` | Number | Calculated expected amount |
| `countedClosingCash` | Number | Actual counted amount |
| `difference` | Number | Discrepancy |
