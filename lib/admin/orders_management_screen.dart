import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrdersManagementScreen extends StatelessWidget {
  const OrdersManagementScreen({super.key});

  static const _statuses = ['Pending', 'Processing', 'Delivered'];

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    final d = date.toLocal();
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day}/${d.year} ${d.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final service = OrderService();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Monitoring',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<AppOrder>>(
              stream: service.getAllOrders(),
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
                return SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 96,
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Products Ordered')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: orders.map((order) {
                        final products = order.items
                            .map((i) => '${i['quantity']} x ${i['productName']}')
                            .join('\n');
                        return DataRow(cells: [
                          DataCell(Text(_formatDate(order.timestamp))),
                          DataCell(Text(order.customerName)),
                          DataCell(Text(order.address)),
                          DataCell(Text(products)),
                          DataCell(Text('₱${order.total.toStringAsFixed(2)}')),
                          DataCell(
                            DropdownButton<String>(
                              value: _statuses.contains(order.status)
                                  ? order.status
                                  : 'Pending',
                              items: _statuses
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  service.updateOrderStatus(order.id, value);
                                }
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
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