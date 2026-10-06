import 'package:cloud_firestore/cloud_firestore.dart';

class AppOrder {
  final String id;
  final String userId;
  final String customerName;
  final double total;
  final String status;
  final DateTime? timestamp;
  final List<Map<String, dynamic>> items;

  AppOrder({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.total,
    required this.status,
    required this.timestamp,
    required this.items,
  });

  factory AppOrder.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'Pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
    );
  }
}