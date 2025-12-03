import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Jordan Hebert",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.attach_money, size: 16, color: Colors.black),
                  Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // Promo Banner
          _promoBanner(),
          const SizedBox(height: 15),

          // Category Section
          _sectionHeader("We Offer", "View all"),
          _categoryList(),
          const SizedBox(height: 20),

          // Recommended Section
          _sectionHeader("Recommended For You", ""),
          _recommendedFood(),
        ],
      ),
    );
  }

  // Promo Banner
  Widget _promoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: const DecorationImage(
            image: NetworkImage("https://via.placeholder.com/400x200"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                "Order Salmon\nSteak Today",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "And Save Up To",
                style: TextStyle(color: Colors.white70),
              ),
              const Text(
                "35%",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _indicator(true),
                  _indicator(false),
                  _indicator(false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator(bool active) {
    return Container(
      width: active ? 12 : 6,
      height: 6,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (action.isNotEmpty)
            Text(action,
                style: const TextStyle(color: Colors.blue, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _categoryList() {
    final categories = [
      {"name": "Meat", "img": "https://via.placeholder.com/60"},
      {"name": "Salads", "img": "https://via.placeholder.com/60"},
      {"name": "Pasta", "img": "https://via.placeholder.com/60"},
      {"name": "Fish", "img": "https://via.placeholder.com/60"},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(categories[i]['img']!, height: 40),
                const SizedBox(height: 5),
                Text(categories[i]['name']!,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _recommendedFood() {
    final foods = [
      {
        "name": "Caesar with Chicken",
        "img": "https://via.placeholder.com/150",
        "new": false
      },
      {
        "name": "Creamy Chicken Alfredo",
        "img": "https://via.placeholder.com/150",
        "new": true
      }
    ];

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: foods.length,
        itemBuilder: (_, i) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network('https://via.placeholder.com/150',
                          height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'PRIDUCT',
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.favorite_border, color: Colors.grey),
                    Icon(Icons.add_circle_outline, color: Colors.black),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
