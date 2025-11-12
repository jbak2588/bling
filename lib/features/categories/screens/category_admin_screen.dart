/// 관리자 카테고리 관리 화면 (아이콘은 'ms:*' 문자열만 저장/표시)
/// - assets/svg 제거, Material Icons 매핑으로만 렌더링
///
/// ===============================================================
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../constants/category_icons.dart';
import '../data/category_repository.dart';
import '../data/firestore_category_repository.dart';
import '../domain/category.dart';
import '../services/category_sync_service.dart';

class CategoryAdminScreen extends StatefulWidget {
  const CategoryAdminScreen({super.key});
  static const routeName = '/admin/categories';
  @override
  State<CategoryAdminScreen> createState() => _CategoryAdminScreenState();
}

class _CategoryAdminScreenState extends State<CategoryAdminScreen> {
  final CategoryRepository _repo = FirestoreCategoryRepository();
  final _sync = CategorySyncService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _refreshAdmin();
  }

  Future<void> _refreshAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    bool ok = false;
    if (user != null) {
      final token = await user.getIdTokenResult(true); // 강제 갱신
      final claims = token.claims ?? {};
      ok = (claims['admin'] == true) ||
          (claims['isAdmin'] == true) ||
          (claims['role'] == 'admin');
    }
    if (mounted) setState(() => _isAdmin = ok);
  }

  String? _selectedParentId;
  String? _selectedParentTitle;

  void _selectParent(Category c) {
    setState(() {
      _selectedParentId = c.id;
      _selectedParentTitle =
          c.displayName(Localizations.localeOf(context).languageCode);
    });
  }

  Future<String?> _pickIcon(
    BuildContext context, {
    String? current,
    required bool isParent,
    required String nameEn,
    required String slug,
  }) async {
    // 설명(1~2줄): 현재 아이콘 또는 카테고리/슬러그 기반 추천 아이콘을 기본 선택으로 표시하고, 그리드에서 선택하면 값을 반환합니다.
    String selected = current ??
        (isParent
            ? CategoryIcons.suggestForParent(nameEn: nameEn, slug: slug)
            : CategoryIcons.suggestForSub(nameEn: nameEn, slug: slug));

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('아이콘 선택'),
          // 내부 스크롤은 GridView가 담당 (RenderShrinkWrappingViewport 예방)
          // scrollable: true,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 420),
            child: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: GridView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: CategoryIcons.options.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, i) {
                  final code = CategoryIcons.options[i];
                  final isSel = selected == code;

                  return InkWell(
                    onTap: () => Navigator.pop(context, code),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSel
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: isSel ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CategoryIcons.widget(code, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              code.replaceFirst('ms:', ''),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ), // ← ConstrainedBox를 여기서 정확히 닫아야 함

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                isParent
                    ? CategoryIcons.suggestForParent(nameEn: nameEn, slug: slug)
                    : CategoryIcons.suggestForSub(nameEn: nameEn, slug: slug),
              ),
              child: const Text('추천 사용'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openParentDialog({Category? initial}) async {
    final ko = TextEditingController(text: initial?.nameKo ?? '');
    final idn = TextEditingController(text: initial?.nameId ?? '');
    final en = TextEditingController(text: initial?.nameEn ?? '');
    final slug = TextEditingController(text: initial?.slug ?? '');
    final order = TextEditingController(text: '${initial?.order ?? 1}');
    String? icon = initial?.icon;
    bool active = initial?.active ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSB) => AlertDialog(
          title: Text(initial == null ? '부모 카테고리 추가' : '부모 카테고리 수정'),
          // 🔧 Dialog 내부 스크롤/레이아웃 안전화
          scrollable: true,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row → Wrap 로 변경해 폭 부족시 줄바꿈 허용 (RenderIntrinsicWidth 방지)
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CategoryIcons.widget(icon, size: 28),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await _pickIcon(
                          context,
                          current: icon,
                          isParent: true,
                          nameEn: en.text,
                          slug: slug.text,
                        );
                        if (picked != null) setSB(() => icon = picked);
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('아이콘 선택'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: slug,
                    decoration:
                        const InputDecoration(labelText: 'slug (kebab)')),
                TextField(
                    controller: ko,
                    decoration: const InputDecoration(labelText: '이름(KO)')),
                TextField(
                    controller: idn,
                    decoration: const InputDecoration(labelText: '이름(ID)')),
                TextField(
                    controller: en,
                    decoration: const InputDecoration(labelText: '이름(EN)')),
                TextField(
                    controller: order,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'order')),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: active,
                  onChanged: (v) => setSB(() => active = v),
                  title: const Text('active'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('저장')),
          ],
        ),
      ),
    );

    if (ok == true) {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final model = Category(
        id: initial?.id ?? '',
        parentId: null,
        slug: slug.text.trim(),
        nameKo: ko.text.trim(),
        nameId: idn.text.trim(),
        nameEn: en.text.trim(),
        order: int.tryParse(order.text.trim()) ?? 1,
        active: active,
        isParent: true,
        icon: icon, // 'ms:*'
      );
      await _repo.upsertParent(model);
      await _repo.updateParentFields(
          model.id.isNotEmpty ? model.id : (_selectedParentId ?? ''), {
        'updatedBy': uid,
      });
    }
  }

  Future<void> _openSubDialog(String parentId, {Category? initial}) async {
    final ko = TextEditingController(text: initial?.nameKo ?? '');
    final idn = TextEditingController(text: initial?.nameId ?? '');
    final en = TextEditingController(text: initial?.nameEn ?? '');
    final slug = TextEditingController(text: initial?.slug ?? '');
    final order = TextEditingController(text: '${initial?.order ?? 1}');
    String? icon = initial?.icon;
    bool active = initial?.active ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSB) => AlertDialog(
          title: Text(initial == null ? '서브 카테고리 추가' : '서브 카테고리 수정'),
          // 🔧 Dialog 내부 스크롤/레이아웃 안전화
          scrollable: true,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row → Wrap 로 변경해 폭 부족시 줄바꿈 허용
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CategoryIcons.widget(icon, size: 26),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await _pickIcon(
                          context,
                          current: icon,
                          isParent: false,
                          nameEn: en.text,
                          slug: slug.text,
                        );
                        if (picked != null) setSB(() => icon = picked);
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('아이콘 선택'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: slug,
                    decoration:
                        const InputDecoration(labelText: 'slug (kebab) / id')),
                TextField(
                    controller: ko,
                    decoration: const InputDecoration(labelText: '이름(KO)')),
                TextField(
                    controller: idn,
                    decoration: const InputDecoration(labelText: '이름(ID)')),
                TextField(
                    controller: en,
                    decoration: const InputDecoration(labelText: '이름(EN)')),
                TextField(
                    controller: order,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'order')),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: active,
                  onChanged: (v) => setSB(() => active = v),
                  title: const Text('active'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('저장')),
          ],
        ),
      ),
    );

    if (ok == true) {
      final model = Category(
        id: initial?.id ?? slug.text.trim(),
        parentId: parentId,
        slug: slug.text.trim(),
        nameKo: ko.text.trim(),
        nameId: idn.text.trim(),
        nameEn: en.text.trim(),
        order: int.tryParse(order.text.trim()) ?? 1,
        active: active,
        isParent: false,
        icon: icon, // 'ms:*'
      );
      await _repo.upsertSub(parentId, model);
    }
  }

  Widget _metaChips(Category c) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        Chip(label: Text('id=${c.id}', style: const TextStyle(fontSize: 12))),
        Chip(
            label:
                Text('slug=${c.slug}', style: const TextStyle(fontSize: 12))),
        Chip(
            label:
                Text('order=${c.order}', style: const TextStyle(fontSize: 12))),
        Chip(
          label:
              Text('active=${c.active}', style: const TextStyle(fontSize: 12)),
          backgroundColor: c.active
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final divider = const VerticalDivider(width: 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('[관리자] 카테고리 관리'),
        actions: [
          IconButton(
            tooltip: 'Publish(JSON/AI Rules 재생성)',
            icon: const Icon(Icons.cloud_upload),
            onPressed: _isAdmin
                ? () async {
                    try {
                      await _sync.publishDesignAndRules();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('카테고리 디자인/AI 룰을 재생성했습니다.'),
                        ),
                      );
                    } on NotAdminException catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    } on FirebaseFunctionsException catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? '실패했습니다.')),
                      );
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('실패했습니다. 콘솔 로그를 확인하세요.'),
                        ),
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
      body: Row(
        children: [
          // --------- Parents ---------
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: _repo.watchParents(activeOnly: false),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final parents = snap.data!;
                if (_selectedParentId == null && parents.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _selectParent(parents.first);
                  });
                }
                return Column(
                  children: [
                    ListTile(
                      title: const Text('부모 카테고리'),
                      trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _openParentDialog()),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: parents.length,
                        itemBuilder: (_, i) {
                          final p = parents[i];
                          final selected = _selectedParentId == p.id;
                          final title = p.displayName(
                              Localizations.localeOf(context).languageCode);
                          return InkWell(
                            onTap: () => _selectParent(p),
                            child: Card(
                              color: selected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.25)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CategoryIcons.widget(p.icon, size: 22),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () =>
                                                _openParentDialog(initial: p)),
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _deleteParent(p)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    _metaChips(p),
                                    const SizedBox(height: 6),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final narrow =
                                            constraints.maxWidth < 360;
                                        final actionBtn = TextButton.icon(
                                          onPressed: () => _selectParent(p),
                                          icon: const Icon(Icons.list),
                                          label: narrow
                                              ? const SizedBox.shrink()
                                              : const Text('서브 보기'),
                                        );
                                        return Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          runSpacing: 8,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('활성 토글'),
                                                const SizedBox(width: 8),
                                                Switch(
                                                  value: p.active,
                                                  onChanged: (v) => _repo
                                                      .updateParentFields(
                                                          p.id, {'active': v}),
                                                ),
                                              ],
                                            ),
                                            Wrap(
                                              // 화면 폭이 부족하면 자동으로 다음 줄로 넘겨 Overflow를 원천 차단
                                              spacing: 12,
                                              runSpacing: 12,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () async {
                                                    final picked =
                                                        await _pickIcon(
                                                      context,
                                                      current: p.icon,
                                                      isParent: true,
                                                      nameEn: p.nameEn,
                                                      slug: p.slug,
                                                    );
                                                    if (picked != null) {
                                                      await _repo
                                                          .updateParentFields(
                                                              p.id,
                                                              {'icon': picked});
                                                    }
                                                  },
                                                  icon: const Icon(Icons.image),
                                                  label: const Text('아이콘 변경'),
                                                ),
                                                const SizedBox(width: 8),
                                                actionBtn,
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
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

          divider,

          // --------- Subcategories ---------
          Expanded(
            child: _selectedParentId == null
                ? const Center(child: Text('왼쪽에서 부모 카테고리를 선택하세요.'))
                : StreamBuilder<List<Category>>(
                    stream:
                        _repo.watchSubs(_selectedParentId!, activeOnly: false),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final subs = snap.data!;
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                                '서브 카테고리 (${_selectedParentTitle ?? _selectedParentId!})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  _openSubDialog(_selectedParentId!),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: subs.isEmpty
                                ? const Center(child: Text('서브 카테고리가 없습니다.'))
                                : ListView.separated(
                                    padding: const EdgeInsets.all(8),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemCount: subs.length,
                                    itemBuilder: (_, i) {
                                      final s = subs[i];
                                      final title = s.displayName(
                                          Localizations.localeOf(context)
                                              .languageCode);
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CategoryIcons.widget(s.icon,
                                                      size: 20),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ),
                                                  IconButton(
                                                      icon: const Icon(
                                                          Icons.edit),
                                                      onPressed: () =>
                                                          _openSubDialog(
                                                              _selectedParentId!,
                                                              initial: s)),
                                                  IconButton(
                                                      icon: const Icon(
                                                          Icons.delete),
                                                      onPressed: () =>
                                                          _repo.deleteSub(
                                                              _selectedParentId!,
                                                              s.id)),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              _metaChips(s),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  const Text('활성 토글'),
                                                  Switch(
                                                    value: s.active,
                                                    onChanged: (v) => _repo
                                                        .updateSubFields(
                                                            _selectedParentId!,
                                                            s.id,
                                                            {'active': v}),
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () async {
                                                      final picked =
                                                          await _pickIcon(
                                                        context,
                                                        current: s.icon,
                                                        isParent: false,
                                                        nameEn: s.nameEn,
                                                        slug: s.slug,
                                                      );
                                                      if (picked != null) {
                                                        await _repo
                                                            .updateSubFields(
                                                                _selectedParentId!,
                                                                s.id, {
                                                          'icon': picked
                                                        });
                                                      }
                                                    },
                                                    icon:
                                                        const Icon(Icons.image),
                                                    label: const Text('아이콘 변경'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
        ],
      ),
    );
  }

  Future<void> _deleteParent(Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text(
            '"${c.displayName(Localizations.localeOf(context).languageCode)}" 및 하위를 삭제할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) {
      await _repo.deleteParentWithSubs(c.id);
      if (_selectedParentId == c.id) {
        setState(() {
          _selectedParentId = null;
          _selectedParentTitle = null;
        });
      }
    }
  }
}
