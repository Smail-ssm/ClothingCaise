# 🛠️ Developer Guide - Clothing Caisse Manager

This guide explains the technical architecture and development workflow for the Clothing Caisse Manager application.

## 🏗️ Architecture Overview

The project follows **Clean Architecture** principles to ensure separation of concerns, testability, and maintainability.

### Layers

1.  **Presentation Layer** (`lib/features/`, `lib/common/`)
    -   **Widgets**: UI components (Screens, Cards, Dialogs).
    -   **State Management**: Riverpod providers for managing UI state.
    -   **Routing**: GoRouter for navigation.

2.  **Domain Layer** (`lib/core/models/`)
    -   **Entities**: Pure Dart classes representing business objects (e.g., `Product`, `Sale`).
    -   **Business Logic**: Validation rules and calculations (e.g., `CashSession` calculations).

3.  **Data Layer** (`lib/core/repositories/`)
    -   **Repositories**: Handle data fetching and persistence (Firestore).
    -   **DTOs**: Data Transfer Objects (handled via `fromJson`/`toJson`).

---

## 📂 Folder Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── models/                  # Data models (User, Product, etc.)
│   ├── repositories/            # Firestore interactions
│   ├── services/                # Hardware services (Printer, Cash Drawer)
│   ├── utils/                   # Helpers (Formatters, Validators)
│   └── providers.dart           # Global Riverpod providers
├── features/
│   ├── auth/                    # Authentication feature
│   ├── home/                    # Dashboard feature
│   ├── products/                # Product management
│   ├── variants/                # Variant management
│   ├── stock/                   # Stock movements
│   ├── sales/                   # POS feature
│   └── cash/                    # Cash session feature
└── common/
    ├── widgets/                 # Shared UI components
    ├── theme/                   # App theme configuration
    └── routing/                 # App router configuration
```

---

## ⚡ State Management (Riverpod)

We use **Riverpod** for dependency injection and state management.

### Key Providers (`lib/core/providers.dart`)

-   `authProvider`: Manages the current user's authentication state.
-   `productRepositoryProvider`: Provides access to product data.
-   `cartProvider`: Manages the POS shopping cart state.
-   `themeModeProvider`: Toggles between Light and Dark mode.

### Usage Example

```dart
// Reading a value
final user = ref.watch(authProvider).value;

// Listening to changes
ref.listen(cartProvider, (previous, next) {
  // Handle cart updates
});

// Triggering an action
ref.read(authProvider.notifier).signOut();
```

---

## 🗄️ Database (Firestore)

Data is stored in Cloud Firestore. See `04_DATABASE_SCHEMA.md` for the full schema.

### Repository Pattern
Each collection has a corresponding repository in `lib/core/repositories/`.
Example: `ProductRepository` handles all CRUD operations for the `products` collection.

```dart
class ProductRepository {
  final FirebaseFirestore _firestore;
  
  // ... methods like getProducts, addProduct, etc.
}
```

---

## 🖨️ Hardware Integration

Hardware services are located in `lib/core/services/`.

-   **PrintingService**: Handles receipt printing.
    -   Currently mocks printing for development.
    -   Intended to use `esc_pos_printer` or Windows platform channels.
-   **CashDrawerService**: Handles opening the cash drawer.
    -   Sends the open pulse command to the printer.

---

## 🚀 Development Workflow

1.  **Run the App**:
    ```bash
    flutter run -d windows  # Recommended for full features
    ```

2.  **Code Style**:
    -   Follow standard Dart linting rules.
    -   Run `flutter analyze` before committing.

3.  **Adding a New Feature**:
    1.  Define the **Model** in `lib/core/models/`.
    2.  Create a **Repository** in `lib/core/repositories/`.
    3.  Create a **Feature Folder** in `lib/features/`.
    4.  Implement the **UI** and connect to Riverpod.
    5.  Add the route in `lib/common/routing/app_router.dart`.

---

## 🧪 Testing

-   **Unit Tests**: `test/` folder.
-   **Widget Tests**: (To be implemented).

To run tests:
```bash
flutter test
```
