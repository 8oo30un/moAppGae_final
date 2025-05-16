import 'package:flutter/foundation.dart';

class WishlistProvider with ChangeNotifier {
  final Set<String> _wishlist = {};

  Set<String> get wishlist => _wishlist;

  bool isInWishlist(String productId) {
    return _wishlist.contains(productId);
  }

  void add(String productId) {
    _wishlist.add(productId);
    notifyListeners();
  }

  void remove(String productId) {
    _wishlist.remove(productId);
    notifyListeners();
  }

  void toggle(String productId) {
    if (isInWishlist(productId)) {
      remove(productId);
    } else {
      add(productId);
    }
  }
}
