import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("My Cart"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _cartItem(
                  image: "https://via.placeholder.com/80",
                  name: "NMD_R1 Shoes",
                  desc: "Running Shoes",
                  price: 180,
                  quantity: 1,
                ),
                _cartItem(
                  image: "https://via.placeholder.com/80",
                  name: "NMD_R1 V2 Shoes",
                  desc: "Special Running Shoes",
                  price: 120,
                  quantity: 1,
                ),
                _dismissibleCartItem(
                  image: "https://via.placeholder.com/80",
                  name: "Ultraboost 20 Shoes",
                  desc: "Special Running Shoes",
                  price: 180,
                  quantity: 1,
                ),
                _cartItem(
                  image: "https://via.placeholder.com/80",
                  name: "Ultraboost DNA Shoes",
                  desc: "Comfort Running Shoes",
                  price: 140,
                  quantity: 1,
                ),
              ],
            ),
          ),
          _bottomCheckout(),
        ],
      ),
    );
  }

  // Basic Cart Item (without swipe)
  Widget _cartItem({
    required String image,
    required String name,
    required String desc,
    required double price,
    required int quantity,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Icon(Icons.person,size: 60,),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(desc, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text("\$${price.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        trailing: _quantityControl(quantity),
      ),
    );
  }

  // Swipe-able Cart Item
  Widget _dismissibleCartItem({
    required String image,
    required String name,
    required String desc,
    required double price,
    required int quantity,
  }) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {},
      child: _cartItem(
        image: image,
        name: name,
        desc: desc,
        price: price,
        quantity: quantity,
      ),
    );
  }

  // Quantity Buttons
  Widget _quantityControl(int quantity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyButton(Icons.remove),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        _qtyButton(Icons.add),
      ],
    );
  }

  Widget _qtyButton(IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // Bottom checkout area
  Widget _bottomCheckout() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Total", style: TextStyle(fontSize: 18)),
              Text("\$620.00",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: const Text("Proceed to checkout"),
          ),
        ],
      ),
    );
  }
}
