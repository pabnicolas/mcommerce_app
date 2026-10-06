import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String productName;
  final double price;
  final String description;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.stock,
  });

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Product(
      id: doc.id,
      productName: data['productName'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
    );
  }
}