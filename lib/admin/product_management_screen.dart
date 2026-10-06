import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete "${product.productName}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ProductService().deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ProductService();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Product Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ProductFormDialog(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: service.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!;
                if (products.isEmpty) {
                  return const Center(child: Text('No products yet'));
                }
                return SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Product Name')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: products
                          .map((p) => DataRow(cells: [
                                DataCell(Text(p.productName)),
                                DataCell(
                                    Text('₱${p.price.toStringAsFixed(2)}')),
                                DataCell(Text('${p.stock}')),
                                DataCell(Row(children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) =>
                                          ProductFormDialog(product: p),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _confirmDelete(context, p),
                                  ),
                                ])),
                              ]))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Add / Edit form. Pass a product to edit it, or nothing to add a new one.
class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductService();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _imageUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.productName ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p != null ? '${p.price}' : '');
    _stock = TextEditingController(text: p != null ? '${p.stock}' : '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _validatePrice(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Price cannot be negative';
    return null;
  }

  String? _validateStock(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Enter a whole number';
    if (n < 0) return 'Stock cannot be negative';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'productName': _name.text.trim(),
      'description': _description.text.trim(),
      'price': double.parse(_price.text.trim()),
      'stock': int.parse(_stock.text.trim()),
      'imageUrl': _imageUrl.text.trim(),
    };

    try {
      if (widget.product == null) {
        await _service.addProduct(data);
      } else {
        await _service.updateProduct(widget.product!.id, data);
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Save failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: _required,
                ),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: _required,
                ),
                TextFormField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: _validatePrice,
                ),
                TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  validator: _validateStock,
                ),
                TextFormField(
                  controller: _imageUrl,
                  decoration: const InputDecoration(
                      labelText: 'Image URL (optional)'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}