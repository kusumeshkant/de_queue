import 'package:dq_app/src/constants/app_string.dart';
import 'package:dq_app/src/utils/dq_widgets/Nearby_store_title_tile%20.dart';
import 'package:dq_app/src/utils/dq_widgets/screen_brightness_overlay.dart';
import 'package:dq_app/src/utils/dq_widgets/store_card.dart';
import 'package:dq_app/src/utils/dq_widgets/title_subHeading.dart';
import 'package:dq_app/src/presentation/dashBoard/widgets/dashboard_header_banner.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final bool isLoading = true;

  TextEditingController searchController = TextEditingController();
  String storeName = 'Reliance Smart';

  final List<String> storeList = [
    'Reliance Smart',
    'Reliance Fresh',
    'Reliance Digital',
    'Reliance Trends',
    'Reliance Footprint',
    'JioMart',
    'DMart',
    'More Supermarket',
    'Spencer’s Retail',
    'Big Bazaar',
    'Star Bazaar',
    'Spar Hypermarket',
    'Vishal Mega Mart',
    'Easyday',
    'Nilgiris',
  ];

  final List<Map<String, String>> gridStoreList = [
  {
    'name': 'Reliance Smart',
    'image': 'https://picsum.photos/id/1011/500/500',
  },
  {
    'name': 'Reliance Fresh',
    'image': 'https://picsum.photos/id/1015/500/500',
  },
  {
    'name': 'DMart',
    'image': 'https://picsum.photos/id/1016/500/500',
  },
  {
    'name': 'JioMart',
    'image': 'https://picsum.photos/id/1020/500/500',
  },
  {
    'name': 'Big Bazaar',
    'image': 'https://picsum.photos/id/1024/500/500',
  },
  {
    'name': 'Spencer’s',
    'image': 'https://picsum.photos/id/1027/500/500',
  },
  {
    'name': 'More Store',
    'image': 'https://picsum.photos/id/1035/500/500',
  },
];


  @override
  Widget build(BuildContext context) {
    return ScreenBrightnessOverlay(
      darkness: 0.1,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: CustomScrollView(
          slivers: [
            /// 🔹Darkened Banner
            SliverToBoxAdapter(
              child: DashboardHeaderBanner(
                searchController: searchController,
                storeList: storeList,
                storeName: storeName,
                storeAddress: 'MG Road, Bengaluru, Karnataka',
                onSearchChanged: (value) {
                  debugPrint('Search typing: $value');
                  
                },
                onStoreSelected: (store) {
                  debugPrint('Selected store: $store');
                  setState(() {
                     storeName = store;
                  });
                },
              ),
            ),

            /// 🔹 Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
                child: TitleSubheading(titleLabel: AppString.nearStores),
              ),
            ),

            /// 🔹 Horizontal Nearby Stores
         
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 10),
                  itemCount: storeList.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 260,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: NearbyStoreTitleTile(
                          title: storeList[index],
                          subTitle: '0.${index + 3} km away',
                          onTap: () {},
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
       
         /// 🔹 Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
                child: TitleSubheading(titleLabel: AppString.recentVisit),
              ),
            ),
       
       
       /// 🔹 Store Grid (2 Column)
SliverPadding(
  padding: const EdgeInsets.all(10),
  sliver: SliverGrid(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final store = gridStoreList[index];

        return StoreCard(
          imageUrl: store['image']!,
          storeName: store['name']!,
          onTap: () {
            debugPrint('${store['name']} tapped');
          },
        );
      },
      childCount: 7,
    ),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
