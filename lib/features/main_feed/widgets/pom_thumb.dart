// lib/features/main_feed/widgets/pom_thumb.dart
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/models/pom_model.dart';
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
  final PomModel short;
  final List<PomModel> allShorts; // 전체 POM 목록 (상세 화면 이동 시 필요)
  final int currentIndex; // 현재 POM의 인덱스 (상세 화면 이동 시 필요)
  final void Function(Widget, String)? onIconTap;

  const PomThumb({
    super.key,
    required this.short,
    required this.allShorts,
    required this.currentIndex,
    this.onIconTap,
  });

  @override
  State<PomThumb> createState() => _PomThumbState();
}

class _PomThumbState extends State<PomThumb> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _hasError = false;
  late final bool _isVideo;
  late final bool _hasImage;

  @override
  void initState() {
    super.initState();
    // 미디어 타입 판정
    _isVideo = widget.short.mediaType == PomMediaType.video;
    _hasImage = widget.short.mediaType == PomMediaType.image &&
        widget.short.mediaUrls.isNotEmpty &&
        (Uri.tryParse(widget.short.mediaUrls.first)?.isAbsolute == true);

    // 비디오 URL이 유효한 경우에만 컨트롤러 초기화
    if (_isVideo &&
        widget.short.mediaUrls.isNotEmpty &&
        Uri.tryParse(widget.short.mediaUrls.first)?.isAbsolute == true) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.short.mediaUrls.first),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: true,
        ),
      );

      _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
        // MD: "메인 피드에서는 무음"
        _controller!.setVolume(0);
        _controller!.setLooping(true);
        if (mounted) setState(() {});
      }).catchError((error) {
        debugPrint("===== VideoPlayer Init Error: $error =====");
        if (mounted) setState(() => _hasError = true);
      });
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
          // Provider를 통해 현재 UserModel 가져오기 (PomScreen 생성자에 필요)
          final userModel = Provider.of<UserModel?>(context, listen: false);
          final pomScreen = PomScreen(
            userModel: userModel,
            initialPoms: widget.allShorts,
            initialIndex: widget.currentIndex,
          );
          if (widget.onIconTap != null) {
            widget.onIconTap!(pomScreen, 'main.tabs.pom');
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => pomScreen),
            );
          }
        },
        child: Card(
          elevation: 0, // Stack 사용으로 그림자 제거 또는 조정 필요
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          // ✅ [수정] Column 대신 Stack 사용
          child: Stack(
            alignment: Alignment.center, // 기본 정렬을 중앙으로
            children: [
              // 1. 미디어 영역 (비디오/이미지)
              _buildMediaArea(context),
              // 2. 제목 텍스트 (비디오 위에 오버레이)
              _buildOverlayMeta(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- 미디어 영역: 비디오 또는 이미지 ---
  Widget _buildMediaArea(BuildContext context) {
    // ✅ [수정] 카드 전체 높이(240px)를 사용하도록 변경
    const double playerHeight = 240.0;

    if (_isVideo) {
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
              ? _buildPlaceholder(Icons.videocam_off_outlined)
              : FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        !_hasError) {
                      return AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio > 0
                            ? _controller!.value.aspectRatio
                            : 16 / 9,
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
                      return _buildPlaceholder(Icons.error_outline);
                    } else {
                      return (widget.short.thumbnailUrl.isNotEmpty)
                          ? Image.network(
                              widget.short.thumbnailUrl,
                              height: playerHeight,
                              width: 220,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : _buildPlaceholder(null),
                              errorBuilder: (context, error, stack) =>
                                  _buildPlaceholder(Icons.image_not_supported),
                            )
                          : _buildPlaceholder(null);
                    }
                  },
                ),
        ),
      );
    }

    // 이미지 타입: 첫 번째 이미지 URL 또는 썸네일 표시
    final String? imageUrl = _hasImage
        ? widget.short.mediaUrls.first
        : (widget.short.thumbnailUrl.isNotEmpty
            ? widget.short.thumbnailUrl
            : null);

    return SizedBox(
      height: playerHeight,
      width: 220,
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                imageUrl,
                height: playerHeight,
                width: 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _buildPlaceholder(null),
                errorBuilder: (context, error, stack) =>
                    _buildPlaceholder(Icons.image_not_supported),
              ),
            )
          : _buildPlaceholder(Icons.image_not_supported),
    );
  }

  // --- 플레이스홀더 위젯 ---
  Widget _buildPlaceholder(IconData? icon) {
    // ✅ [수정] 카드 전체 높이 사용
    const double playerHeight = 240.0;
    return Container(
      height: playerHeight,
      width: 220,
      color: Colors.grey[900], // 어두운 배경
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.grey[700], size: 50) // 아이콘 크기 조정
            : const SizedBox(
                // 로딩 인디케이터
                width: 30, height: 30,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.white54), // 인디케이터 조정
              ),
      ),
    );
  }

  // ✅ [수정] 하단 정렬 + 그라디언트 페이드 오버레이 (Reels/Shorts 패턴)
  Widget _buildOverlayMeta(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true, // 오버레이가 탭을 가로채지 않도록
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            // 바닥쪽만 어둡게 페이드되는 그라디언트
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
            child: Text(
              widget.short.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
