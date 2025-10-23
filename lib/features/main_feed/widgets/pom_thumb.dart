// lib/features/main_feed/widgets/pom_thumb.dart
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/features/pom/screens/pom_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:provider/provider.dart'; // UserModel 가져오기 위해

/// [개편] 9단계: 메인 피드용 표준 썸네일 (POM 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: POM 상세 뷰어 "ontop push"
/// 3. POM 재생 정책: 무음, 100% 노출 시 자동 재생, 한 개만 재생 (-> 현재는 개별 재생만 구현)
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class PomThumb extends StatefulWidget {
  final ShortModel short;
  final List<ShortModel> allShorts; // 전체 POM 목록 (상세 화면 이동 시 필요)
  final int currentIndex; // 현재 POM의 인덱스 (상세 화면 이동 시 필요)

  const PomThumb({
    super.key,
    required this.short,
    required this.allShorts,
    required this.currentIndex,
  });

  @override
  State<PomThumb> createState() => _PomThumbState();
}

class _PomThumbState extends State<PomThumb> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    //
    if (widget.short.videoUrl.isNotEmpty) {
      final videoUri = Uri.parse(widget.short.videoUrl);
      _controller = VideoPlayerController.networkUrl(videoUri);

      _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
        // MD: "메인 피드에서는 무음"
        _controller!.setVolume(0);
        _controller!.setLooping(true);
        if (mounted) setState(() {});
      }).catchError((error) {
        debugPrint("===== VideoPlayer Init Error: $error =====");
        if (mounted) setState(() => _hasError = true);
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
    // MD: "표준 썸네일(고정 크기)로 노출 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          // MD: "탭 시 POM 상세 뷰어를 ontop으로 열어 뒤로가기 가능"
          // Provider를 통해 현재 UserModel 가져오기 (PomScreen 생성자에 필요)
          final userModel = Provider.of<UserModel?>(context, listen: false);

          Navigator.of(context).push(
            MaterialPageRoute(
              //
              builder: (_) => PomScreen(
                userModel: userModel,
                initialShorts: widget.allShorts, // 전체 목록 전달
                initialIndex: widget.currentIndex, // 현재 인덱스 전달
              ),
            ),
          );
        },
        child: Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 비디오 플레이어 영역 (MD: 재생 정책 적용)
              _buildVideoPlayerArea(context),
              // 2. 하단 메타 (제목)
              _buildMeta(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- 상단 비디오 플레이어 영역 ---
  Widget _buildVideoPlayerArea(BuildContext context) {
    // 플레이어 영역 높이 조절 (비율 유지 시도)
    const double playerHeight = 160.0; // 240 높이 중 일부 할당

    return VisibilityDetector(
      key: Key(widget.short.id), // 고유 키
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted ||
            _controller == null ||
            !_controller!.value.isInitialized ||
            _hasError) {
          return;
        }
        // MD: "카드가 화면에 ‘완전 노출(=100%)’일 때만 재생"
        final isFullyVisible = visibilityInfo.visibleFraction == 1.0;

        if (isFullyVisible && !_controller!.value.isPlaying) {
          _controller!.play();
        } else if (!isFullyVisible && _controller!.value.isPlaying) {
          _controller!.pause();
        }
      },
      child: SizedBox(
        height: playerHeight,
        width: 220,
        child: (_hasError || _controller == null)
            ? _buildPlaceholder(Icons.videocam_off_outlined) // 에러 시 아이콘
            : FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      !_hasError) {
                    // 비디오 비율에 맞춰 AspectRatio 사용
                    // ✅ [수정] FittedBox 추가하여 contain 스케일링 적용
                    return AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio > 0
                          ? _controller!.value.aspectRatio
                          : 16 / 9, // 비율 정보 없으면 16:9 가정
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return _buildPlaceholder(Icons.error_outline); // 초기화 에러
                  } else {
                    // 로딩 중: 썸네일 이미지 또는 Placeholder 표시
                    //
                    return (widget.short.thumbnailUrl.isNotEmpty)
                        ? Image.network(
                            widget.short.thumbnailUrl,
                            height: playerHeight, width: 220, fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : _buildPlaceholder(null), // 로딩 중 아이콘 없음
                            errorBuilder: (context, error, stack) =>
                                _buildPlaceholder(
                                    Icons.image_not_supported), // 썸네일 로드 에러
                          )
                        : _buildPlaceholder(null); // 썸네일 없고 로딩 중
                  }
                },
              ),
      ),
    );
  }

  // --- 플레이스홀더 위젯 ---
  Widget _buildPlaceholder(IconData? icon) {
    const double playerHeight = 160.0;
    return Container(
      height: playerHeight,
      width: 220,
      color: Colors.grey[900], // 어두운 배경
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.grey[700], size: 40)
            : const SizedBox(
                // 로딩 인디케이터
                width: 30, height: 30,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white54),
              ),
      ),
    );
  }

  // --- 하단 메타 (제목) ---
  Widget _buildMeta(BuildContext context) {
    // 하단 영역 높이: 240 - 160 = 80
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
          children: [
            // 제목
            Text(
              widget.short.title, //
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            // (추가 정보 필요 시 여기에)
          ],
        ),
      ),
    );
  }
}
