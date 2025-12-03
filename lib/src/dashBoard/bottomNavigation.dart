import 'package:dq_app/src/Setting/setting_screeen.dart';
import 'package:dq_app/src/cart/cart_screen.dart';
import 'package:dq_app/src/dashBoard/dashboard.dart';
import 'package:flutter/material.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _setectedIndex = 0;

  final List<Widget> _screenList = [
    Dashboard(),
    CartPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _setectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _setectedIndex,
        children: _screenList,
      ),

      // 🚀 Floating button with scanner icon
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () {
          // 👇 Navigate to scanner page or trigger scanner feature
          print("Scanner button pressed");
          // Navigator.push(...);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _setectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,

        // Add space in center for FAB
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
