import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return '-';
    final d = value.toDate().toLocal();
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Monitoring',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return const Center(child: Text('No users yet'));
                }
                return SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Registered')),
                      ],
                      rows: users.map((doc) {
                        final data = doc.data();
                        return DataRow(cells: [
                          DataCell(Text(data['name'] ?? '')),
                          DataCell(Text(data['email'] ?? '')),
                          DataCell(Text(data['address'] ?? '')),
                          DataCell(Text(data['role'] ?? '')),
                          DataCell(Text(_formatDate(data['createdAt']))),
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