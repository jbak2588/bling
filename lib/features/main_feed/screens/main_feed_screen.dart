// lib/features/main_feed/screens/main_feed_screen.dart
//**
// * DocHeader
// * [기획 요약]
// * - 메인 피드는 각 피드(게시글, 상품, 구인, 경매 등)를 통합하여 한 화면에 보여줍니다.
// * - 한 번에 5개씩 각 피드 유형을 가져오며, 생성시간(createdAt) 기준으로 혼합 정렬합니다.
// * - 향후 인기순, 추천순, 광고 삽입 등 다양한 정렬/추천 로직이 추가될 예정입니다.
// *
// * [실제 구현 비교]
// * - 현재는 fetchUnifiedFeed()에서 각 피드별 5개씩 가져와 createdAt 기준으로 통합 정렬합니다.
// * - 인기순, 추천순, 광고 삽입 등은 아직 구현되지 않았습니다.
// *
// * [차이점 및 개선 제안]
// * 1. 한 피드당 5개씩 가져오는 방식은 신속한 로딩에는 유리하나, 다양한 피드가 혼합될 때 최신성/다양성/사용자 선호 반영에 한계가 있습니다.
// * 2. 생성시간(createdAt) 기준 혼합 정렬은 기본적이나, 인기순(조회수, 좋아요 등), 추천순(사용자 행동 기반), 광고 삽입(노출 빈도/타겟팅) 등 추가 로직이 필요합니다.
// * 3. 추후 페이징/무한스크롤, 피드 유형별 동적 배치, 광고/추천 피드 삽입, 사용자 맞춤형 피드 추천 알고리즘 도입을 적극 검토해야 합니다.
// * 4. 광고 삽입 시 FeedItemModel에 광고 타입 추가 및 노출 위치/빈도 제어 로직 설계 필요.
// * 5. 인기/추천/광고 로직은 KPI(조회수, 클릭률, 사용자 반응 등) 기반으로 설계/튜닝 권장.
// */


import 'package:bling_app/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/feed_item_model.dart';
import 'package:bling_app/features/main_feed/widgets/feed_thumbnail.dart';
// 상세/목록 화면 import (탭 이동용)
import 'package:bling_app/features/local_news/screens/local_news_screen.dart';
import 'package:bling_app/features/marketplace/screens/marketplace_screen.dart';
import 'package:bling_app/features/jobs/screens/jobs_screen.dart';
import 'package:bling_app/features/auction/screens/auction_screen.dart';
import 'package:bling_app/features/lost_and_found/screens/lost_and_found_screen.dart';
import 'package:bling_app/features/real_estate/screens/real_estate_screen.dart';
import 'package:bling_app/features/local_stores/screens/local_stores_screen.dart';
// POM 상세 화면(AppBar 포함)
import 'package:bling_app/features/pom/screens/pom_detail_screen.dart';
import '../../local_news/models/post_model.dart';
import 'package:bling_app/features/main_feed/widgets/post_thumb.dart';
import '../../marketplace/models/product_model.dart';
import '../data/feed_repository.dart';
// NEW: 가로 캐러셀에 필요한 추가 모델/위젯 import
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/local_stores/models/shop_model.dart';

// Cards & widgets rendering (replaced by standardized thumbnails)
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 'New Feed' 탭에 표시될 통합 피드 화면입니다.
class MainFeedScreen extends StatefulWidget {
  final UserModel? userModel;
  const MainFeedScreen({this.userModel, super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  final FeedRepository _feedRepository = FeedRepository();
  // NEW: 가로 캐러셀 섹션에 표시할 피처 순서(좌측부터)
  static const List<FeedItemType> _sections = <FeedItemType>[
    FeedItemType.post,         // 지역 소식
    FeedItemType.product,      // 마켓플레이스
    FeedItemType.job,          // 구인
    FeedItemType.auction,      // 경매
    FeedItemType.lostAndFound, // 분실/습득
    FeedItemType.pom,          // 숏폼
    FeedItemType.realEstate,   // 부동산
    FeedItemType.localStores,  // 동네가게
  ];

  @override
  void initState() {
    super.initState();
  }

  // 새로고침 기능
  Future<void> _handleRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // NEW: Grab 스타일 — 섹션(제목) + 가로 스크롤 캐러셀을 세로로 쌓음
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        primary: false,                          // 상위 스크롤과 주도권 충돌 방지
        physics: const ClampingScrollPhysics(),  // iOS 바운스 최소화, 중첩 안정화
        slivers: [
          // ✅ 섹션 별로 데이터가 없으면 섹션 자체를 숨깁니다.
          ..._sections.map((type) => SliverToBoxAdapter(
                child: _HorizontalFeatureRow(
                  type: type,
                  repo: _feedRepository,
                  title: _labelFor(type),
                  hideWhenEmpty: true, // ← NEW
                  userModel: widget.userModel,
                ),
              )),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  String _labelFor(FeedItemType t) {
    switch (t) {
      case FeedItemType.post:
        return '이번 주의 새로운 소식'; // TODO: i18n key
      case FeedItemType.product:
        return '이번 주 최신 할인';
      case FeedItemType.job:
        return '요즘 채용 정보';
      case FeedItemType.auction:
        return '인기 경매';
      case FeedItemType.lostAndFound:
        return '분실/습득';
      case FeedItemType.pom:
        return 'POM 숏폼';
      case FeedItemType.realEstate:
        return '최신 부동산';
      case FeedItemType.localStores:
        return '동네 가게 소식';
      default:
        return '추천';
    }
  }
}

// NEW: 섹션 타이틀 + 가로 캐러셀(최신 20개)
class _HorizontalFeatureRow extends StatelessWidget {
  final FeedItemType type;
  final FeedRepository repo;
  final String title;
  final bool hideWhenEmpty;
  final UserModel? userModel;
  const _HorizontalFeatureRow({
    required this.type,
    required this.repo,
    required this.title,
    this.hideWhenEmpty = false,
    this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _rowHeightFor(type),
            child: FutureBuilder<List<FeedItemModel>>(
              future: repo.fetchByType(type, limit: 20),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('mainFeed.error'));
                }
                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return hideWhenEmpty
                      ? const SizedBox.shrink()
                      : const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('mainFeed.empty'),
                        );
                }
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    primary: false,            // 상위 스크롤과 주도권 충돌 방지
                    shrinkWrap: true,          // Sliver 내 높이 계산 안정화
                    cacheExtent: 900,          // 좌우 프리페치
                    clipBehavior: Clip.none,   // 그림자/오버플로우 시 잘림 방지
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _buildHorizontalCard(context, items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _rowHeightFor(FeedItemType t) {
    // 로그 기준 Column overflow를 전부 흡수하도록 여유치 상향
    switch (t) {
      case FeedItemType.post:         return PostThumbCard.height; // 240
      case FeedItemType.product:      return 288;
      case FeedItemType.job:          return 288; // 잡 카드 오른쪽 0.7px 오버 방지
      case FeedItemType.auction:      return 344;
      case FeedItemType.lostAndFound: return 288;
      case FeedItemType.realEstate:   return 344;
      case FeedItemType.localStores:  return 330; // 샵 카드 하단 24px 오버 보정
      case FeedItemType.pom:          return 304;
      default:                        return 280;
    }
  }

  Widget _buildHorizontalCard(BuildContext context, FeedItemModel item) {
    // Local News(게시글)는 전용 카드(PostThumbCard)를 사용하고, 나머지는 표준 썸네일 카드 사용
    if (item.type == FeedItemType.post) {
      final m = PostModel.fromFirestore(
        item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
      );
      return SizedBox(
        width: PostThumbCard.width,
        height: PostThumbCard.height,
        child: PostThumbCard(
          post: m,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LocalNewsScreen(userModel: userModel),
            ),
          ),
        ),
      );
    }

    // 그 외 타입은 표준 썸네일 카드 사용
    final thumb = _toThumb(context, item);
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(
        width: FeedThumbnailCard.cardWidth,
        height: FeedThumbnailCard.cardHeight,
      ),
      child: FeedThumbnailCard(data: thumb),
    );
  }

  FeedThumb _toThumb(BuildContext context, FeedItemModel item) {
    switch (item.type) {
      case FeedItemType.post: {
        final m = PostModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final title = (m.title != null && m.title!.isNotEmpty)
            ? m.title!
            : (m.body.isNotEmpty ? m.body : '…');
        final imageUrl = (m.mediaUrl != null && m.mediaUrl!.isNotEmpty)
            ? m.mediaUrl!.first
            : null;
        return FeedThumb(
          title: title,
          subtitle: m.locationName,
          imageUrl: imageUrl,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LocalNewsScreen(userModel: userModel),
            ),
          ),
        );
      }
      case FeedItemType.product: {
        final m = ProductModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final imageUrl = m.imageUrls.isNotEmpty ? m.imageUrls.first : null;
        final priceText = 'Rp ${m.price}';
        return FeedThumb(
          title: m.title,
          subtitle: m.locationName,
          imageUrl: imageUrl,
          badge: priceText,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MarketplaceScreen(userModel: userModel),
            ),
          ),
        );
      }
      case FeedItemType.job: {
        final m = JobModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final imageUrl = (m.imageUrls != null && m.imageUrls!.isNotEmpty)
            ? m.imageUrls!.first
            : null;
        final pay = (m.salaryAmount != null) ? 'Rp ${m.salaryAmount}' : null;
        return FeedThumb(
          title: m.title,
          subtitle: m.locationName,
          imageUrl: imageUrl,
          badge: pay,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => JobsScreen(userModel: userModel),
            ),
          ),
        );
      }
      case FeedItemType.auction: {
        final m = AuctionModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final imageUrl = m.images.isNotEmpty ? m.images.first : null;
        final bidText = 'Bid: Rp ${m.currentBid}';
        return FeedThumb(
          title: m.title,
          subtitle: m.location,
          imageUrl: imageUrl,
          badge: bidText,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuctionScreen(userModel: userModel),
            ),
          ),
        );
      }
      case FeedItemType.lostAndFound: {
        final m = LostItemModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final imageUrl = m.imageUrls.isNotEmpty ? m.imageUrls.first : null;
        return FeedThumb(
          title: m.itemDescription,
          subtitle: m.locationDescription,
          imageUrl: imageUrl,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LostAndFoundScreen(userModel: userModel),
            ),
          ),
        );
      }
      case FeedItemType.realEstate: {
        final m = RoomListingModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final imageUrl = m.imageUrls.isNotEmpty ? m.imageUrls.first : null;
        final priceText = 'Rp ${m.price}' +
            (m.priceUnit == 'monthly' ? '/mo' : (m.priceUnit == 'yearly' ? '/yr' : ''));
        return FeedThumb(
          title: m.title,
          subtitle: m.locationName,
          imageUrl: imageUrl,
          badge: priceText,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RealEstateScreen(userModel: userModel),
            ),
          ),
        );
      }
      case FeedItemType.localStores: {
        final m = ShopModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final imageUrl = m.imageUrls.isNotEmpty ? m.imageUrls.first : null;
        return FeedThumb(
          title: m.name,
          subtitle: m.locationName,
          imageUrl: imageUrl,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LocalStoresScreen(userModel: userModel),
            ),
          ),
        );
      }
      case FeedItemType.pom: {
        final m = ShortModel.fromFirestore(
          item.originalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        return FeedThumb(
          title: m.title.isNotEmpty ? m.title : 'POM',
          subtitle: m.location,
          imageUrl: m.thumbnailUrl.isNotEmpty ? m.thumbnailUrl : null,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PomDetailScreen(short: m),
            ),
          ),
        );
      }
      default:
        return FeedThumb(title: item.title, onTap: () {});
    }
  }
}

// === POM 숏폼 Compact 타일 – 오디오 무음, 2/3 이상 보일 때만 재생(커스텀: 완전 노출 시 재생), 한 번에 하나만 ===
class _ShortPlaybackCoordinator {
  static final _ShortPlaybackCoordinator I = _ShortPlaybackCoordinator._();
  _ShortPlaybackCoordinator._();
  final ValueNotifier<String?> currentPlayingId = ValueNotifier(null);
}

class _CompactShortTile extends StatefulWidget {
  final ShortModel short;
  const _CompactShortTile({required this.short});
  @override
  State<_CompactShortTile> createState() => _CompactShortTileState();
}

class _CompactShortTileState extends State<_CompactShortTile> {
  VideoPlayerController? _c;
  Future<void>? _initFut;
  bool _ready = false;
  bool _hasError = false;
  late final String _id;

  @override
  void initState() {
    super.initState();
    _id = 'short-${widget.short.id}';
    if (widget.short.videoUrl.isEmpty) {
      _hasError = true;
      return;
    }
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.short.videoUrl));
    _initFut = _c!.initialize().then((_) {
      _c!
        ..setLooping(true)
        ..setVolume(0)
        ..setPlaybackSpeed(1);
      _ready = true;
      if (mounted) setState(() {});
    }).catchError((e) {
      _hasError = true;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _maybePlay(double visibleFraction) {
    if (!_ready || _hasError || _c == null) return;
    final threshold = 1.0; // ✅ 완전 노출일 때만 재생
    final coord = _ShortPlaybackCoordinator.I;
    if (visibleFraction >= threshold) {
      if (coord.currentPlayingId.value != _id) {
        coord.currentPlayingId.value = _id;
      }
    } else {
      if (_c!.value.isPlaying && coord.currentPlayingId.value == _id) {
        _c!.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const _ShortErrorBox();
    }
    return ValueListenableBuilder<String?>(
      valueListenable: _ShortPlaybackCoordinator.I.currentPlayingId,
      builder: (_, current, __) {
        if (_ready && _c != null) {
          if (current == _id) {
            if (!_c!.value.isPlaying) _c!.play();
          } else {
            if (_c!.value.isPlaying) _c!.pause();
          }
        }
        return VisibilityDetector(
          key: Key('short-${widget.short.id}-$_id'),
          onVisibilityChanged: (info) {
            _maybePlay(info.visibleFraction);
          },
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PomDetailScreen(short: widget.short),
              ));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _c?.value.aspectRatio == null || _c!.value.aspectRatio.isNaN
                    ? 9 / 16
                    : _c!.value.aspectRatio,
                child: FutureBuilder(
                  future: _initFut,
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.done && !_hasError) {
                      return VideoPlayer(_c!);
                    }
                    if (snap.hasError) return const _ShortErrorBox();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.short.thumbnailUrl.isNotEmpty)
                          Image.network(widget.short.thumbnailUrl, fit: BoxFit.cover),
                        const CircularProgressIndicator(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShortErrorBox extends StatelessWidget {
  const _ShortErrorBox();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      child: ColoredBox(
        color: Color(0x11000000),
        child: Center(child: Icon(Icons.error_outline, size: 36, color: Colors.red)),
      ),
    );
  }
}

// === NEW: 숏폼 Compact 타일 – 오디오 무음, 2/3 이상 보일 때만 재생, 한 번에 하나만 ===
// (기존 POM 동영상 카드 코드는 표준 썸네일 타일로 대체되었습니다.)
