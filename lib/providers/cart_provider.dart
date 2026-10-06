import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.values.fold<int>(0, (sum, i) => sum + i.quantity);
  double get total =>
      _items.values.fold<double>(0, (sum, i) => sum + i.subtotal);

  // Returns false when the stock limit is reached.
  bool add(Product product) {
    final existing = _items[product.id];
    final current = existing?.quantity ?? 0;
    if (current >= product.stock) return false;
    if (existing == null) {
      _items[product.id] = CartItem(product: product);
    } else {
      existing.quantity++;
    }
    notifyListeners();
    return true;
  }

  bool increase(String productId) {
    final item = _items[productId];
    if (item == null || item.quantity >= item.product.stock) return false;
    item.quantity++;
    notifyListeners();
    return true;
  }

  void decrease(String productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}