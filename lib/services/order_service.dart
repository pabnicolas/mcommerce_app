import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Returns null on success, or an error message on failure.
  Future<String?> placeOrder(List<CartItem> items, double total) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Please log in first';
    if (items.isEmpty) return 'Your cart is empty';

    try {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final name = userDoc.data()?['name'] ?? '';

      await _db.collection('orders').add({
        'userId': user.uid,
        'customerName': name,
        'items': items
            .map((i) => {
                  'productId': i.product.id,
                  'productName': i.product.productName,
                  'price': i.product.price,
                  'quantity': i.quantity,
                })
            .toList(),
        'total': total,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }
}