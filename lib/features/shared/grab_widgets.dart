import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:bling_app/core/theme/grab_theme.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:flutter_svg/flutter_svg.dart';

/// 상단 그라데이션 + 둥근 검색바만 보여주는 헤더
/// - AppBar는 항상 유지한다는 기획이므로, 기본적으로 타이틀 행은 숨깁니다.
/// - 필요 시 showTitleRow=true 로 켜서 타이틀/드롭다운을 쓸 수 있습니다.
class GrabHeader extends StatelessWidget {
  final String? title; // 기본 null: 타이틀 숨김
  final bool showTitleRow; // 기본 false: 타이틀 행 렌더링 안 함
  final VoidCallback? onChange; // 타이틀 옆 드롭다운 탭
  final String searchHint; // 검색 플레이스홀더 텍스트
  final VoidCallback? onSearchTap; // 검색바 탭
  final Widget? leading; // 좌측 아바타 등
  final Widget? trailing; // 우측 액션들(하트/영수증 등)

  const GrabHeader({
    super.key,
    this.title,
    this.showTitleRow = false,
    this.onChange,
    this.searchHint = '이웃, 소식, 장터, 일자리… 검색', // ← 커뮤니티 톤으로 교체
    this.onSearchTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // AppBar 아래에 붙도록 SafeArea는 사용하지 않음 (AppBar는 항상 있음)
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: GrabColors.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            leading ?? const SizedBox.shrink(),
            const Spacer(),
            if (trailing != null) trailing!,
          ]),
          if (showTitleRow && (title?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            Row(children: [
              Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              if (onChange != null)
                InkWell(
                  onTap: onChange,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
            ]),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      searchHint,
                      style: const TextStyle(color: GrabColors.subtext),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GrabAppBarShell extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final double height;
  final bool pillActions;
  final bool? centerTitle; // ✅ 추가됨
  final PreferredSizeWidget? bottom; // ✅ 추가: AppBar bottom (e.g., TabBar)

  final double actionChipSize; // 기본 36
  final EdgeInsets actionMargin; // 칩 사이 간격

  const GrabAppBarShell({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.height = kToolbarHeight + 6,
    this.pillActions = true,
    this.centerTitle, // ✅ 추가됨
    this.bottom, // ✅ 추가됨
    this.actionChipSize = 36, // << 작게
    this.actionMargin = const EdgeInsets.only(right: 6),
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    // 액션을 흰색 동글 칩으로 감싸 Grab 느낌만 추가 (원본 위젯은 그대로 child)
    List<Widget>? wrappedActions = actions;
    if (pillActions && actions != null) {
      wrappedActions = actions!.map((w) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // ↓ IconButton 기본 48을 줄이기 위해 테마로 최소 크기/패딩 축소
            child: IconButtonTheme(
              data: IconButtonThemeData(
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(
                      Size(actionChipSize, actionChipSize)),
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Material(color: Colors.transparent, child: w),
              ),
            ),
          ),
        );
      }).toList();
    }

    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: height,
      automaticallyImplyLeading: false,
      leadingWidth: 72,
      leading: leading,
      titleSpacing: 0,
      title: title,
      actions: wrappedActions,
      centerTitle: centerTitle, // ✅ AppBar에 전달
      bottom: bottom, // ✅ 전달
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: GrabColors.headerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

/// Grab 스타일의 아이콘 타일(외형만). onTap 로직은 호출부에서 기존 그대로 사용.
class GrabIconTile extends StatefulWidget {
  final IconData? icon; // 기존 IconData 지원
  final String? svgAsset; // 신규: SVG 에셋 경로 지원
  final String label;
  final VoidCallback onTap;

  /// 5열일 때 true(아이콘 크게/여백 최소화)
  final bool compact;

  const GrabIconTile({
    super.key,
    this.icon,
    this.svgAsset,
    required this.label,
    required this.onTap,
    this.compact = false,
  }) : assert(icon != null || svgAsset != null,
            'Either icon or svgAsset must be provided');

  @override
  State<GrabIconTile> createState() => _GrabIconTileState();
}

class _GrabIconTileState extends State<GrabIconTile> {
  bool _down = false; // 터치 시 3D 눌림/떠오름 효과
  final GlobalKey _bgKey = GlobalKey(); // 64x64 배경 영역 키
  double _tiltX = 0.0; // 라디안 기준 (위/아래 기울기)
  double _tiltY = 0.0; // 라디안 기준 (좌/우 기울기)
  static const double _maxTiltDeg = 8.0; // 최대 기울기 각도

  void _applyTiltFromGlobal(Offset globalPosition) {
    if (_bgKey.currentContext == null) return;
    final box = _bgKey.currentContext!.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    final size = box.size;
    if (size.width == 0 || size.height == 0) return;

    // -1..1로 정규화 (중앙=0)
    final dx =
        ((local.dx - size.width / 2) / (size.width / 2)).clamp(-1.0, 1.0);
    final dy =
        ((local.dy - size.height / 2) / (size.height / 2)).clamp(-1.0, 1.0);

    final maxRad = _maxTiltDeg * math.pi / 180;
    setState(() {
      _tiltY = dx * maxRad; // 좌우 이동 → Y축 회전
      _tiltX = -dy * maxRad; // 상하 이동 반전 → X축 회전
    });
  }

  @override
  Widget build(BuildContext context) {
    // 컴팩트 모드 값: 아이콘은 키우고, 여백/라인간격은 최소화
    // Figma 스펙: 배경 64x64(라운드 22, #F4F7F8), 내부 여백 12 → 아이콘 40x40
    const double tileBgSize = 64;
    const double tileBgRadius = 22;
    const Color tileBgColor = Color(0xFFF4F7F8);
    const double innerPad = 12; // 64 - 12*2 = 40
    const double iconSz = 40; // SVG 기준 아이콘 크기
    const double labelGap = 1; // 배경과 라벨 사이 간격
    const double labelW = 64;
    const double labelH = 20;
    const double fontSz = 12;
    const double lineH = 1.67; // Figma 텍스트 height

    // 3D 효과 파라미터 (떠있을 때 살짝 위, 그림자 진하고 작아짐)
    final double lift = _down ? 0.0 : 2.0; // 위로 뜨는 정도
    final double scale = _down ? 0.98 : 1.0; // 눌림 시 살짝 축소
    final double shadowOpacity = _down ? 0.10 : 0.16;
    final double shadowSigmaX = _down ? 7 : 8;
    final double shadowSigmaY = _down ? 5 : 6;
    final double shadowWidth = iconSz * (_down ? 0.95 : 0.90);
    final double shadowHeight = iconSz * 0.22;
    final double maxRad = _maxTiltDeg * math.pi / 180;
    // 기울기에 따른 그림자 위치 보정 (기울기의 반대 방향으로 살짝 이동)
    final double shadowDx = (_tiltY / maxRad) * 3.0; // 좌우 3px 범위
    final double shadowDy =
        2 - lift * 0.4 + (_tiltX / maxRad) * 3.0; // 상하 3px 범위

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (d) {
        _applyTiltFromGlobal(d.globalPosition);
        setState(() => _down = true);
      },
      onTapUp: (d) => setState(() {
        _down = false;
        _tiltX = 0.0;
        _tiltY = 0.0;
      }),
      onTapCancel: () => setState(() {
        _down = false;
        _tiltX = 0.0;
        _tiltY = 0.0;
      }),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 64x64 배경 박스
          Container(
            key: _bgKey,
            width: tileBgSize,
            height: tileBgSize,
            decoration: ShapeDecoration(
              color: tileBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tileBgRadius),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(innerPad),
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  // 바닥면 타원 그림자 (은은한 그라운드 섀도우)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      offset: Offset(shadowDx, shadowDy),
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                            sigmaX: shadowSigmaX, sigmaY: shadowSigmaY),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: shadowWidth,
                          height: shadowHeight,
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withValues(alpha: shadowOpacity),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 아이콘 본체
                  Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015) // 원근감
                        ..translateByVector3(vm.Vector3(0.0, -lift, 0.0))
                        ..rotateX(_tiltX)
                        ..rotateY(_tiltY)
                        ..scaleByVector3(vm.Vector3(scale, scale, scale)),
                      child: widget.svgAsset != null
                          ? SvgPicture.asset(
                              widget.svgAsset!,
                              width: iconSz,
                              height: iconSz,
                            )
                          : Icon(widget.icon,
                              size: iconSz, color: GrabColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: labelGap),
          SizedBox(
            width: labelW,
            height: labelH,
            child: Center(
              child: Text(
                widget.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF191A1C),
                  fontSize: fontSz,
                  fontWeight: FontWeight.w400,
                  height: lineH,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCircleIcon extends StatefulWidget {
  final Widget child; // 아이콘 위젯(Icon 또는 Svg)
  final double pad; // 원형 내부 패딩
  final Color bg; // 원형 배경

  const _FloatingCircleIcon({
    required this.child,
    required this.pad,
    required this.bg,
  });

  @override
  State<_FloatingCircleIcon> createState() => _FloatingCircleIconState();
}

class _FloatingCircleIconState extends State<_FloatingCircleIcon> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final double elev = _down ? 3.0 : 10.0; // ← 입체감 세기
    final double lift = _down ? 0.0 : 1.5; // ← 살짝 위로 떠보이기

    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(0, -lift, 0),
        child: Material(
          shape: const CircleBorder(),
          color: widget.bg, // 연한 틴트 배경
          elevation: elev, // ✅ 핵심: 그림자
          shadowColor: Colors.black.withValues(alpha: 1.00),
          child: Padding(
            padding: EdgeInsets.all(widget.pad),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
