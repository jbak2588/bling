import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/widgets/together_card.dart';
import 'package:bling_app/features/together/screens/together_detail_screen.dart'; // ✅ 추가
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ 추가
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'package:bling_app/features/shared/helpers/legacy_title_extractor.dart';

class TogetherScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;

  const TogetherScreen({super.key, this.userModel, this.locationFilter});

  @override
  State<TogetherScreen> createState() => _TogetherScreenState();
}

class _TogetherScreenState extends State<TogetherScreen> {
  bool _isMapMode = false;

  @override
  Widget build(BuildContext context) {
    final repository = TogetherRepository();

    // LocationProvider 우선값으로 초기 지도 중심 좌표 결정
    final locationProvider = context.watch<LocationProvider>();
    final LatLng initialMapCenter = (() {
      try {
        if (locationProvider.mode == LocationSearchMode.nearby &&
            locationProvider.user?.geoPoint != null) {
          final gp = locationProvider.user!.geoPoint!;
          return LatLng(gp.latitude, gp.longitude);
        }
        if (locationProvider.user?.geoPoint != null) {
          final gp = locationProvider.user!.geoPoint!;
          return LatLng(gp.latitude, gp.longitude);
        }
        if (widget.userModel?.geoPoint != null) {
          final gp = widget.userModel!.geoPoint!;
          return LatLng(gp.latitude, gp.longitude);
        }
      } catch (_) {}
      return const LatLng(-6.200000, 106.816666);
    })();

    // TODO: locationFilter를 Repository 쿼리에 반영하려면 Repository 수정 필요 (현재는 전체 조회)
    // repository.fetchActivePosts(locationFilter: locationFilter);

    return PopScope(
      canPop: !_isMapMode,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (!mounted) return;
        setState(() => _isMapMode = false);
      },
      child: Scaffold(
        // [수정] 중복 AppBar 제거
        body: _isMapMode
            ? Stack(
                children: [
                  // SharedMapBrowser 사용 주석 (Together):
                  // - dataStream: `repository.fetchActivePosts()` -> 활성화된 TogetherPost 스트림.
                  // - initialCameraPosition: `initialMapCenter` 사용(상단에 계산 로직 있음).
                  // - locationExtractor: `post.geoPoint`.
                  // - idExtractor: `post.id`.
                  // - titleExtractor: `legacyExtractTitle(post)` -> title 필드가 존재하지만 레거시 안전 추출 사용 중.
                  // - cardBuilder: `TogetherCard(post)` (내부 onTap에서 상세 화면으로 이동).
                  // - thumbnailUrlExtractor: post.imageUrl (nullable).
                  SharedMapBrowser<TogetherPostModel>(
                    dataStream: repository.fetchActivePosts(),
                    initialCameraPosition: CameraPosition(
                      target: initialMapCenter,
                      zoom: 14,
                    ),
                    locationExtractor: (post) => post.geoPoint,
                    idExtractor: (post) => post.id,
                    titleExtractor: (post) => legacyExtractTitle(post),
                    cardBuilder: (context, post) => TogetherCard(
                      post: post,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TogetherDetailScreen(post: post),
                        ),
                      ),
                    ),
                    thumbnailUrlExtractor: (post) => post.imageUrl,
                    categoryIconExtractor: (post) {
                      try {
                        final statusEmoji = post.status == 'open'
                            ? '🟢'
                            : post.status == 'closed'
                                ? '🔒'
                                : post.status == 'completed'
                                    ? '✅'
                                    : '⌛';
                        return Text(statusEmoji,
                            style: const TextStyle(fontSize: 14));
                      } catch (_) {
                        return null;
                      }
                    },
                  ),
                  // [추가] 지도 닫기 오버레이 버튼
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: InkWell(
                        onTap: () => setState(() => _isMapMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'common.closeMap'.tr(), // "지도 닫기"
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.close,
                                  size: 20,
                                  color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : StreamBuilder<List<TogetherPostModel>>(
                stream: repository.fetchActivePosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volunteer_activism,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            "together.emptyList".tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // [추가] 상단 지도 안내 문구 + 토글 버튼 (리스트 위에 배치)
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'together.viewMapHint'.tr(),
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.map_outlined),
                              onPressed: () =>
                                  setState(() => _isMapMode = true),
                              tooltip: 'common.viewMap'.tr(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: posts.length,
                          separatorBuilder: (ctx, idx) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 200,
                              child: TogetherCard(
                                post: posts[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TogetherDetailScreen(
                                          post: posts[index]),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
