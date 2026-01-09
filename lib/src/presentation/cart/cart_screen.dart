import 'package:flutter/material.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_bottom_bar.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text("Remove (2)",
                style: TextStyle(color: Colors.red, fontSize: 12)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                CartItemCard(
                  title: "Nike Air Max 95",
                  subtitle: "Laser Fuschia · UK 10",
                  price: 2000,
                  quantity: 1,
                ),
                CartItemCard(
                  title: "Nike Air Max 95",
                  subtitle: "Laser Fuschia · UK 10",
                  price: 2000,
                  quantity: 1,
                ),
                CartItemCard(
                  title: "Nike Air Max 95",
                  subtitle: "Laser Fuschia · UK 10",
                  price: 2000,
                  quantity: 1,
                ),
              ],
            ),
          ),
          const CartBottomBar(total: 28000),
        ],
      ),
    );
  }
}
