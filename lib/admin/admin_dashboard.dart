import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'product_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _index = 0;

  final _pages = const [
    ProductManagementScreen(),
    Center(child: Text('Orders - coming next')),
    Center(child: Text('Users - coming next')),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            extended: wide,
            labelType: wide ? null : NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Primo Gas\nAdmin',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout),
                    onPressed: () => AuthService().logout(),
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.inventory_2), label: Text('Products')),
              NavigationRailDestination(
                  icon: Icon(Icons.receipt_long), label: Text('Orders')),
              NavigationRailDestination(
                  icon: Icon(Icons.people), label: Text('Users')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _pages[_index]),
        ],
      ),
    );
  }
}