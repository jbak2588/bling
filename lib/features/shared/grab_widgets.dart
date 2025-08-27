import 'package:flutter/material.dart';
import 'package:bling_app/core/theme/grab_theme.dart';
import 'package:flutter/services.dart';

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
class GrabIconTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// 5열일 때 true(아이콘 크게/여백 최소화)
  final bool compact;

  const GrabIconTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // 컴팩트 모드 값: 아이콘은 키우고, 여백/라인간격은 최소화
    final double vPad = compact ? 8 : 12; // 컨테이너 세로 패딩
    final double hPad = compact ? 10 : 12; // 컨테이너 가로 패딩
    final double dotPad = compact ? 9 : 8; // 원형 내부 패딩(아이콘 영역)
    final double iconSz = compact ? 28 : 22; // 아이콘 크기
    final double gap = compact ? 4 : 8; // 아이콘-텍스트 간격
    final double fontSz = compact ? 10 : 12; // 라벨 폰트 크기
    final double lineH = compact ? 1.0 : 1.1; // 라벨 줄간격(시각적 상하 균형)

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   padding: EdgeInsets.all(dotPad),
            //   decoration: const BoxDecoration(
            //     color: Color(0x1A00B14F), // Grab primary 10% 정도
            //     shape: BoxShape.circle,
            //   ),
            //   child: Icon(icon, color: GrabColors.primary, size: iconSz),
            // ),
            _FloatingCircleIcon(
              icon: icon,
              size: iconSz, // compact면 28, 아니면 22 등 기존 값 그대로
              pad: dotPad, // compact면 9, 아니면 8 등
              fg: GrabColors.primary,
              bg: const Color(0xFFEFFAF3), // 연한 민트/그린 틴트(자연스러운 볼륨)
            ),

            SizedBox(height: gap),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              // 라벨의 위·아래 내부 리딩을 줄여 시각적 상하 여백을 동일하게
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: fontSz,
                height: lineH, // 1.0~1.05 권장
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCircleIcon extends StatefulWidget {
  final IconData icon;
  final double size; // 아이콘 크기
  final double pad; // 원형 내부 패딩
  final Color fg; // 아이콘 색
  final Color bg; // 원형 배경

  const _FloatingCircleIcon({
    required this.icon,
    required this.size,
    required this.pad,
    required this.fg,
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
          shadowColor: Colors.black.withValues(alpha: 0.34),
          child: Padding(
            padding: EdgeInsets.all(widget.pad),
            child: Icon(widget.icon, size: widget.size, color: widget.fg),
          ),
        ),
      ),
    );
  }
}
