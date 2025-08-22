// 파일 경로: lib/features/main_screen/home_screen.dart
import 'package:bling_app/core/models/feed_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
// [수정] feed_repository.dart의 정확한 경로로 수정합니다.
import 'package:bling_app/features/main_feed/data/feed_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// 아이콘 그리드에서 사용할 각 기능별 화면을 import 합니다.
import 'package:bling_app/features/local_news/screens/local_news_screen.dart';
import 'package:bling_app/features/marketplace/screens/marketplace_screen.dart';
import 'package:bling_app/features/clubs/screens/clubs_screen.dart';
import 'package:bling_app/features/find_friends/screens/find_friends_screen.dart';
import 'package:bling_app/features/jobs/screens/jobs_screen.dart';
import 'package:bling_app/features/local_stores/screens/local_stores_screen.dart';
import 'package:bling_app/features/auction/screens/auction_screen.dart';
import 'package:bling_app/features/pom/screens/pom_screen.dart';
import 'package:bling_app/features/lost_and_found/screens/lost_and_found_screen.dart';
import 'package:bling_app/features/real_estate/screens/real_estate_screen.dart';

// [신규] 아이콘 그리드의 메뉴 아이템을 위한 클래스입니다.
class MenuItem {
  final IconData icon;
  final String labelKey;
  final Widget screen;
  MenuItem({required this.icon, required this.labelKey, required this.screen});
}

// 새로운 '가구' 위젯입니다.
class HomeScreen extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? activeLocationFilter;
  final Function(Widget) onIconTap; // [신규] '방'을 바꿔달라고 요청할 함수

  const HomeScreen({
    super.key, 
    this.userModel, 
    this.activeLocationFilter, 
    required this.onIconTap // [신규] 요청 함수를 받도록 생성자 수정
  });
  

  static final List<MenuItem> menuItems = [
    MenuItem(icon: Icons.newspaper_outlined, labelKey: 'main.tabs.localNews', screen: const LocalNewsScreen()),
    MenuItem(icon: Icons.storefront_outlined, labelKey: 'main.tabs.marketplace', screen: const MarketplaceScreen()),
    MenuItem(icon: Icons.groups_outlined, labelKey: 'main.tabs.clubs', screen: const ClubsScreen()),
    MenuItem(icon: Icons.favorite_border_outlined, labelKey: 'main.tabs.findFriends', screen: const FindFriendsScreen()),
    MenuItem(icon: Icons.work_outline, labelKey: 'main.tabs.jobs', screen: const JobsScreen()),
    MenuItem(icon: Icons.store_mall_directory_outlined, labelKey: 'main.tabs.localStores', screen: const LocalStoresScreen()),
    MenuItem(icon: Icons.gavel_outlined, labelKey: 'main.tabs.auction', screen: const AuctionScreen()),
    MenuItem(icon: Icons.star_outline, labelKey: 'main.tabs.pom', screen: const PomScreen()),
    MenuItem(icon: Icons.help_outline, labelKey: 'main.tabs.lostAndFound', screen: const LostAndFoundScreen()),
    MenuItem(icon: Icons.house_outlined, labelKey: 'main.tabs.realEstate', screen: const RealEstateScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          sliver: SliverGrid.count(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: menuItems.map((item) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (userModel == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('user.notLoggedIn'.tr())));
                      return;
                    }
                    final screen = item.screen;
                    Widget nextScreen;
                    if (screen is LocalNewsScreen) {
                      nextScreen = LocalNewsScreen(userModel: userModel, locationFilter: activeLocationFilter);
                    } else if (screen is MarketplaceScreen) {
                      nextScreen = MarketplaceScreen(userModel: userModel, locationFilter: activeLocationFilter);
                    } else if (screen is ClubsScreen) {
                      nextScreen = ClubsScreen(userModel: userModel);
                    } else if (screen is FindFriendsScreen) {
                      nextScreen = FindFriendsScreen(userModel: userModel);
                    } else if (screen is JobsScreen) {
                      nextScreen = JobsScreen(userModel: userModel);
                    } else if (screen is LocalStoresScreen) {
                      nextScreen = LocalStoresScreen(userModel: userModel);
                    } else if (screen is AuctionScreen) {
                      nextScreen = AuctionScreen(userModel: userModel);
                    } else if (screen is PomScreen) {
                      nextScreen = PomScreen(userModel: userModel);
                    } else if (screen is LostAndFoundScreen) {
                      nextScreen = LostAndFoundScreen(userModel: userModel);
                    } else if (screen is RealEstateScreen) {
                      nextScreen = RealEstateScreen(userModel: userModel);
                    } else {
                      nextScreen = screen;
                    }
                     onIconTap(nextScreen); 
                  },

                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 32, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 8),
                      Text(item.labelKey.tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),


        const SliverToBoxAdapter(child: Divider(height: 8, thickness: 8, color: Color(0xFFF0F2F5))),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("home.newFeedTitle".tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        FutureBuilder<List<FeedItemModel>>(
          future: FeedRepository().fetchUnifiedFeed(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("mainFeed.empty".tr()))));
            }
            final feedItems = snapshot.data!;
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => FeedItemCard(item: feedItems[index]),
                childCount: feedItems.length,
              ),
            );
          },
        ),
      ],
    );
  }
}

class FeedItemCard extends StatelessWidget {
  final FeedItemModel item;
  const FeedItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image, color: Colors.grey))),
                ),
              ),
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty) const SizedBox(height: 12),
            Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                // [수정] 'capitalize' 에러 해결
                Text(item.type.name.capitalize(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                const Spacer(),
                // [수정] Timestamp -> DateTime 변환 에러 해결
                Text(DateFormat('yy/MM/dd HH:mm').format(item.createdAt.toDate()), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// [신규] capitalize 에러 해결을 위해 StringExtension을 추가합니다.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}