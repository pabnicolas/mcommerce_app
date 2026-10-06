import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock <= 0;

    return Scaffold(
      appBar: AppBar(title: Text(product.productName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: product.imageUrl.isEmpty
                  ? const Icon(Icons.propane_tank, size: 120)
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.broken_image, size: 120),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('₱${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    outOfStock ? 'Out of stock' : 'In stock: ${product.stock}',
                    style: TextStyle(
                        color: outOfStock ? Colors.red : Colors.green[700]),
                  ),
                  const SizedBox(height: 16),
                  Text(product.description),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: outOfStock
                ? null
                : () {
                    final added = context.read<CartProvider>().add(product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          added ? 'Added to cart' : 'No more stock available'),
                    ));
                  },
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(outOfStock ? 'Out of stock' : 'Add to Cart'),
          ),
        ),
      ),
    );
  }
}