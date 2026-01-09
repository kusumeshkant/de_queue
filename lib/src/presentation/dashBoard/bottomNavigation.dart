import 'package:dq_app/src/presentation/Setting/setting_screeen.dart';
import 'package:dq_app/src/presentation/cart/cart_screen.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard.dart';
import 'package:flutter/material.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _setectedIndex = 0;
  final List<Widget> _screenList = [
    DashboardScreen(),
    CartScreen(),
    SettingScreeen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _setectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _setectedIndex, children: _screenList),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _setectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
