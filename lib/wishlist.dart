import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider with ChangeNotifier {
  final Set<String> _wishlist = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WishlistProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadWishlist();
      } else {
        clearWishlist();
      }
    });
  }

  Set<String> get wishlist => _wishlist;

  Future<void> loadWishlist() async {
    final user = _auth.currentUser;
    if (user == null) {
      clearWishlist();
      return;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .get();
    _wishlist.clear();
    for (var doc in snapshot.docs) {
      _wishlist.add(doc.id);
    }
    notifyListeners();
  }

  void clearWishlist() {
    _wishlist.clear();
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _wishlist.contains(productId);
  }

  Future<void> add(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (isInWishlist(productId)) return; // Prevent duplicate addition

    _wishlist.add(productId);
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> remove(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _wishlist.remove(productId);
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  Future<void> toggle(String productId) async {
    if (isInWishlist(productId)) {
      await remove(productId);
    } else {
      await add(productId);
    }
  }
}
