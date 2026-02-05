import 'package:dq_app/src/presentation/Setting/setting_page.dart';
import 'package:dq_app/src/presentation/cart/cart_page.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_page.dart';
import 'package:dq_app/src/presentation/scanner_page/scanner_page.dart';
import 'package:flutter/material.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [DashboardPage(), CartPage(), SettingsPage()];

  void _onTabTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),

          if (_selectedIndex == 0)
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.white38,
                  elevation: 12,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScannerPage()),
                    );
                  },
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _navItem(icon: Icons.home, label: 'Home', index: 0),
            ),
            Expanded(
              child: _navItem(
                icon: Icons.shopping_cart,
                label: 'Cart',
                index: 1,
              ),
            ),
            Expanded(
              child: _navItem(
                icon: Icons.settings,
                label: 'Settings',
                index: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? Colors.lightBlue : Colors.grey.shade300,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.lightBlue : Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
