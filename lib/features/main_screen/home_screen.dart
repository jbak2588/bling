// 파일 경로: lib/features/main_screen/home_screen.dart
import 'package:bling_app/core/models/feed_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/main_feed/data/feed_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 모든 card 위젯과 그에 필요한 model들을 import 합니다.
import 'package:bling_app/features/local_news/widgets/post_card.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/marketplace/widgets/product_card.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/jobs/widgets/job_card.dart';
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/auction/widgets/auction_card.dart';
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/clubs/widgets/club_post_card.dart';
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/lost_and_found/widgets/lost_item_card.dart';
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/local_stores/widgets/shop_card.dart';
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/features/find_friends/widgets/findfriend_card.dart';

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


class MenuItem {
  final IconData icon;
  final String labelKey;
  final Widget screen;
  MenuItem({required this.icon, required this.labelKey, required this.screen});
}

class HomeScreen extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? activeLocationFilter;
  final Function(Widget, String) onIconTap;

  final List<FeedItemModel> allFeedItems;
  final int currentIndex;

  const HomeScreen({
    super.key,
    required this.userModel,
    required this.activeLocationFilter,
    required this.onIconTap,
    this.allFeedItems = const [],
    this.currentIndex = 0,
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
                    onIconTap(nextScreen, item.labelKey);
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
            child: Text("main.tabs.newFeed".tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            // [수정] Provider를 통해 userModel을 하위 위젯에 전달합니다.
            return Provider.value(
              value: userModel,
           child: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FeedItemCard(
                    item: feedItems[index],
                    onIconTap: onIconTap,
                    allFeedItems: feedItems, // [신규] 전체 피드 리스트 전달
                    currentIndex: index,      // [신규] 현재 인덱스 전달
                  ),
                  childCount: feedItems.length,
                ),
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
  final Function(Widget, String) onIconTap;
  // [신규] 전체 피드 목록과 현재 아이템의 인덱스를 받습니다.
  final List<FeedItemModel> allFeedItems;
  final int currentIndex;

  const FeedItemCard({
    super.key,
    required this.item,
    required this.onIconTap,
    required this.allFeedItems,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case FeedItemType.post:
        final post = PostModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
        return PostCard(post: post);
      case FeedItemType.product:
        final product = ProductModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
        return ProductCard(product: product);
      case FeedItemType.job:
        final job = JobModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
        return JobCard(job: job);
      case FeedItemType.auction:
         final auction = AuctionModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
         return AuctionCard(auction: auction);
      case FeedItemType.club:
         final clubPost = ClubPostModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
         final tempClub = ClubModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
         return ClubPostCard(post: clubPost, club: tempClub);
      case FeedItemType.lostAndFound:
        final lostItem = LostItemModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
        return LostItemCard(item: lostItem);
      case FeedItemType.pom:
        final short = ShortModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
              // [신규] 전체 피드에서 POM 영상만 필터링하여 새로운 리스트를 만듭니다.
        final allShorts = allFeedItems
            .where((feedItem) => feedItem.type == FeedItemType.pom)
            .map((feedItem) => ShortModel.fromFirestore(feedItem.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();
            
        // [신규] 현재 POM 영상이 필터링된 리스트에서 몇 번째인지 찾습니다.
        final currentShortIndex = allShorts.indexWhere((s) => s.id == short.id);

        return _ShortFeedCardWithPlayer(
          short: short,
          onCardTap: () {
            final userModel = Provider.of<UserModel?>(context, listen: false);
            // [수정] PomScreen으로 이동 시, 전체 POM 목록과 시작 인덱스를 전달합니다.
            onIconTap(
              PomScreen(
                userModel: userModel,
                initialShorts: allShorts,
                initialIndex: currentShortIndex,
              ),
              'main.tabs.pom',
            );
          },
        );
      case FeedItemType.realEstate:
        final room = RoomListingModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
        return RoomCard(room: room);
      case FeedItemType.localStores:
        final shop = ShopModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
        return ShopCard(shop: shop);
      case FeedItemType.findFriends:
         final user = UserModel.fromFirestore(item.originalDoc as DocumentSnapshot<Map<String, dynamic>>);
         return FindFriendCard(user: user);
      default:
        return Card(
          child: ListTile(
            title: Text(item.title),
            subtitle: const Text('Unknown item type'),
          ),
        );
    }
  }
}

class _ShortFeedCardWithPlayer extends StatefulWidget {
 final ShortModel short;
  final VoidCallback onCardTap; // Function(Widget, String) -> VoidCallback
  const _ShortFeedCardWithPlayer({required this.short, required this.onCardTap});

  @override
  State<_ShortFeedCardWithPlayer> createState() => _ShortFeedCardWithPlayerState();
}

class _ShortFeedCardWithPlayerState extends State<_ShortFeedCardWithPlayer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.short.videoUrl.isNotEmpty) {
      final videoUri = Uri.parse(widget.short.videoUrl);
      _controller = VideoPlayerController.networkUrl(videoUri);
      
      _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
        _controller!.setVolume(0);
        _controller!.setLooping(true);
        if (mounted) setState(() {});
      }).catchError((error) {
        debugPrint("===== VideoPlayer Init Error for short ${widget.short.id}: $error =====");
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    } else {
      _hasError = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserInfoRow(userId: widget.short.userId),
          GestureDetector(
            onTap: widget.onCardTap, // [수정] 상세 화면 이동을 위해 콜백 함수 호출
            child: VisibilityDetector(
              key: Key(widget.short.id),
              onVisibilityChanged: (visibilityInfo) {
                if (!mounted || _controller == null || !_controller!.value.isInitialized || _hasError) return;
                
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage > 50 && !_controller!.value.isPlaying) {
                  _controller!.play();
                } 
                else if (visiblePercentage < 10 && _controller!.value.isPlaying) {
                  _controller!.pause();
                }
              },
              child: (_hasError || _controller == null) 
              ? _buildErrorThumbnail()
              : FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && !_hasError) {
                      return AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      );
                    } else if (snapshot.hasError) {
                      return _buildErrorThumbnail();
                    }
                    else {
                      return _buildLoadingThumbnail();
                    }
                  },
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.short.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingThumbnail() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.short.thumbnailUrl.isNotEmpty)
          Image.network(
            widget.short.thumbnailUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorThumbnail(),
          ),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildErrorThumbnail(){
    return const SizedBox(
      height: 200,
      width: double.infinity,
      child: Center(child: Icon(Icons.error_outline, color: Colors.red, size: 48)),
    );
  }
}

class _UserInfoRow extends StatelessWidget {
  final String userId;
  const _UserInfoRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
          final user = UserModel.fromFirestore(snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  user.nickname,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }
        return const SizedBox(height: 48);
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}