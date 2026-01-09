import 'package:flutter/material.dart';
import 'quantity_button.dart';

class CartItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final int quantity;
  final bool isSelected;

  const CartItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.quantity,
    this.isSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (_) {},
            shape: const CircleBorder(),
          ),

          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image, size: 30),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  "₹${price.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),

          Column(
            children: [
              QuantityButton(icon: Icons.remove, onTap: () {}),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              QuantityButton(icon: Icons.add, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
