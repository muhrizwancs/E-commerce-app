import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;
  
  int get cartCount => _cartItems.length;
  
  double get totalAmount => _cartItems
      .fold(0.0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product),
    );

    if (_cartItems.contains(existingItem)) {
      existingItem.quantity++;
    } else {
      _cartItems.add(existingItem);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
    );
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  List<OrderItem> getOrderItems() {
    return _cartItems
        .map((cartItem) => OrderItem(
              productId: cartItem.product.id,
              productName: cartItem.product.name,
              price: cartItem.product.price,
              quantity: cartItem.quantity,
              image: cartItem.product.image,
            ))
        .toList();
  }
}
