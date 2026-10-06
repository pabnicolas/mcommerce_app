import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // READ
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  // CREATE
  Future<void> addProduct(Map<String, dynamic> data) {
    return _db.collection('products').add(data);
  }

  // UPDATE
  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _db.collection('products').doc(id).update(data);
  }

  // DELETE
  Future<void> deleteProduct(String id) {
    return _db.collection('products').doc(id).delete();
  }
}