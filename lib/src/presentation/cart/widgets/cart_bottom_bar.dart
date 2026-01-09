import 'package:flutter/material.dart';
import 'primary_button.dart';

class CartBottomBar extends StatelessWidget {
  final double total;

  const CartBottomBar({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text("₹${total.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            title: "Checkout",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
