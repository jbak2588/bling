import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// 앱바 하단에 표시되는 인라인 검색 칩 위젯
///
/// 탭하면 스스로 TextField로 확장되며,
/// 외부 [openNotifier]를 통해 강제로 열 수 있습니다.
/// 검색어 제출 시 [onSubmitted] 콜백을 호출합니다.
class InlineSearchChip extends StatefulWidget {
  final String hintText;
  final ValueNotifier<bool>? openNotifier;
  final ValueChanged<String>? onSubmitted;
  // 사용자가 검색 입력창 자체를 닫을 때 호출 (텍스트 지우기와 별도)
  final VoidCallback? onClose;

  const InlineSearchChip({
    super.key,
    required this.hintText,
    this.openNotifier,
    this.onSubmitted,
    this.onClose,
  });

  @override
  State<InlineSearchChip> createState() => _InlineSearchChipState();
}

class _InlineSearchChipState extends State<InlineSearchChip> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    // 외부 Notifier를 리스닝하여 검색창을 엽니다.
    widget.openNotifier?.addListener(_handleExternalOpen);
  }

  void _handleExternalOpen() {
    // Notifier 값이 true가 되면, _editing 상태를 true로 바꾸고 포커스 요청
    if (widget.openNotifier?.value == true) {
      if (mounted) {
        setState(() => _editing = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNode.requestFocus();
          }
          // 자동으로 재오픈 방지: 즉시 false로 리셋
          widget.openNotifier?.value = false;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.openNotifier?.removeListener(_handleExternalOpen);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 검색 취소 로직
  void _cancel() {
    if (!mounted) return;
    setState(() => _editing = false);
    _controller.clear();
    _focusNode.unfocus();
    // 취소 시 빈 검색어를 부모에게 전달
    widget.onSubmitted?.call('');
    // 닫힘 콜백 (부모가 칩 자체를 숨기고 싶을 때 사용)
    widget.onClose?.call();
  }

  // 텍스트만 지우기 (칩은 유지, 포커스 유지)
  void _clearText() {
    _controller.clear();
    // 빈 검색으로 업데이트하되, 칩은 유지됨
    widget.onSubmitted?.call('');
    // 포커스는 유지
    if (mounted) _focusNode.requestFocus();
  }

  // 검색 제출 로직
  void _submit(String value) {
    final kw = value.trim();
    if (kw.isEmpty) {
      // 빈 값 제출은 "검색 초기화"로 간주 (칩은 유지)
      _clearText();
      return;
    }
    widget.onSubmitted?.call(kw); // 부모에게 키워드 전달

    // 제출 후에도 칩을 닫지 않고 포커스만 해제 (선택사항)
    // _cancel(); // (이전 로직)
    _focusNode.unfocus(); // (새 제안)
  }

  @override
  Widget build(BuildContext context) {
    // (디자인 로직은 home_screen.dart 백업본과 동일)
    final TextStyle? chipTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14);
    final mainContainer = Container(
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
      child: _editing
          ? Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: chipTextStyle,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: chipTextStyle,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: _submit,
                  ),
                ),
                // 텍스트만 지우기 (지우개/백스페이스 느낌의 아이콘 사용)
                IconButton(
                  icon: const Icon(Icons.cleaning_services, size: 20),
                  onPressed: _clearText,
                  tooltip: 'common.clear'.tr(),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.hintText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: _editing
          ? Row(
              // ✅ [신규] Row로 감싸기
              children: [
                // ✅ [신규] 검색창 본체
                Expanded(
                  child: mainContainer,
                ),
                // ✅ [신규] 닫기(X) 버튼을 검색창 *바깥*에 배치
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: _cancel,
                  tooltip: 'common.cancel'.tr(),
                ),
              ],
            )
          : GestureDetector(
              onTap: () {
                if (mounted) setState(() => _editing = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _focusNode.requestFocus();
                });
              },
              child: mainContainer, // 닫혀있을 땐 mainContainer만 보임
            ),
    );
  }
}
