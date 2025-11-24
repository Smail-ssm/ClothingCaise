# French Translation Guide for Clothing Caisse Manager

## Fichiers Traduits

### ✅ Complété:
1. **main.dart** - Titre de l'app: "Gestion de Caisse"
2. **lib/common/l10n/app_fr.dart** - Toutes les chaînes de traduction
3. **lib/common/l10n/strings.dart** - Alias pour import facile

### 📋 Instructions pour Traduction Manuelle

Pour traduire vos écrans, importez les strings:
```dart
import '../../common/l10n/strings.dart';
```

Puis remplacez les chaînes en dur par les constantes:

#### Exemples de Remplacement:

**Avant**:
```dart
AppBar(title: const Text('Products'))
'New Sale'
'User Management'
'Sign In'
```

**Après**:
```dart
AppBar(title: const Text(S.products))
S.newSale
S.userManagement
S.signIn
```

---

## 📚 Traductions Complètes Disponibles

### Navigation & Menu
- `S.home` → "Accueil"
- `S.products` → "Produits"
- `S.variants` → "Variantes"
- `S.stock` → "Stock"
- `S.sales` → "Ventes"
- `S.salesPOS` → "Ventes (POS)"
- `S.cashSession` → "Session de Caisse"
- `S.users` → "Utilisateurs"
- `S.profile` → "Profil"

### Actions Rapides
- `S.newSale` → "Nouvelle Vente"
- `S.addProduct` → "Ajouter Produit"
- `S.stockIn` → "Entrée Stock"
- `S.userManagement` → "Gestion des Utilisateurs"
- `S.stockManagement` → "Gestion du Stock"

### Authentification
- `S.signIn` → "Connexion"
- `S.email` → "Email"
- `S.password` → "Mot de passe"
- `S.signInButton` → "Se Connecter"
- `S.signOut` → "Déconnexion"

### Produits
- `S.productName` → "Nom du produit"
- `S.category` → "Catégorie"
- `S.brand` → "Marque"
- `S.buyingPrice` → "Prix d'achat"
- `S.sellingPrice` → "Prix de vente"
- `S.currentStock` → "Stock actuel"
- `S.lowStock` → "Stock faible"

### Ventes
- `S.Cart` → "Panier"
- `S.scanBarcode` → "Scanner Code-barres"
- `S.total` → "Total"
- `S.completeSale` → "Finaliser la vente"
- `S.emptyCart` → "Panier vide"

### Actions Générales
- `S.add` → "Ajouter"
- `S.edit` → "Modifier"
- `S.delete` → "Supprimer"
- `S.save` → "Enregistrer"
- `S.cancel` → "Annuler"
- `S.refresh` → "Actualiser"
- `S.search` → "Rechercher"

### Thème
- `S.appearance` → "Apparence"
- `S.light` → "Clair"
- `S.dark` → "Sombre"
- `S.system` → "Système"

---

## 🔄 Traduction Rapide par Fichier

### HomeScreen (Priorité Haute)
Remplacer:
- `'Quick Actions'` → `S.quickActions` ("Actions Rapides")
- `'New Sale'` → `S.newSale` ("Nouvelle Vente")
- `'Cash Session'` → `S.cashSession` ("Session de Caisse")
- `'Products'` → `S.products` ("Produits")
- `'Variants'` → `S.variants` ("Variantes")
- `'Stock'` → `S.stock` ("Stock")
- `'Users'` → `S.users` ("Utilisateurs")
- `'POS Terminal'` → `S.posTerminal` ("Terminal de Caisse")
- `'Caisse Manager'` → `S.caisseManager` ("Gestionnaire de Caisse")

### LoginScreen (Priorité Haute)
Remplacer:
- `'Sign In'` → `S.signIn` ("Connexion")
- `'Email'` → `S.email`
- `'Password'` → `S.password` ("Mot de passe")
- `'Sign In'` (button) → `S.signInButton` ("Se Connecter")
- `'Please enter your email'` → `S.pleaseEnterEmail` ("Veuillez saisir votre email")

### ProfileScreen (Priorité Haute)
Remplacer:
- `'My Profile'` → `S.myProfile` ("Mon Profil")
- `'Appearance'` → `S.appearance` ("Apparence")
- `'Light'` → `S.light` ("Clair")
- `'Dark'` → `S.dark` ("Sombre")
- `'System'` → `S.system` ("Système")
- `'Sign Out'` → `S.signOut` ("Déconnexion")
- `'User Management'` → `S.userManagement` ("Gestion des Utilisateurs")
- `'Stock Management'` → `S.stockManagement` ("Gestion du Stock")
- `'Sales (POS)'` → `S.salesPOS` ("Ventes (POS)")

### ProductsScreen (Priorité Moyenne)
Remplacer:
- `'Products'` → `S.products` ("Produits")
- `'Low stock'` → `S.lowStock` ("Stock faible")
- `'Product archived'` → `S.productArchived` ("Produit archivé")
- `'Product deleted'` → `S.productDeleted` ("Produit supprimé")

### SalesScreen (Priorité Moyenne)
Remplacer:
- `'Sales (POS)'` → `S.salesPOS` ("Ventes (POS)")
- `'Cart'` → `S.cart` ("Panier")
- `'Total'` → `S.total`
- `'Complete Sale'` → `S.completeSale` ("Finaliser la vente")
- `'Empty cart'` → `S.emptyCart` ("Panier vide")

---

## 🚀 Import Automatique

Ajoutez en haut de chaque fichier à traduire:
```dart
import '../../common/l10n/strings.dart';
```

Puis utilisez `S.constantName` partout où vous avez des chaînes en anglais.

---

## 📝 Notes

- Tous les textes UI visibles par l'utilisateur sont disponibles
- Les messages d'erreur sont inclus
- Les labels de formulaire sont inclus
- Les tooltips et hints sont inclus
- Format de devise: "DH" (Dirham Marocain)

**État**: Fichiers de traduction créés ✅  
**Prochaine étape**: Mettre à jour les imports dans les screens et remplacer les strings
