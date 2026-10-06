import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    final d = date.toLocal();
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day}/${d.year}  ${d.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppOrder>>(
      stream: OrderService().getUserOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return const Center(child: Text('No orders yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(order.timestamp),
                            style: const TextStyle(color: Colors.grey)),
                        Chip(
                          label: Text(order.status,
                              style: const TextStyle(color: Colors.white)),
                          backgroundColor: _statusColor(order.status),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Text(
                        '${item['quantity']} x ${item['productName']}')),
                    const Divider(),
                    Text('Total: ₱${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}