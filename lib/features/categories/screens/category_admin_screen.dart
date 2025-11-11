// Simplified, corrected CategoryAdminScreen implementation
// (Reconstructed to fix earlier accidental corruption.)

import 'package:bling_app/features/categories/data/category_admin_repository.dart';
import 'package:bling_app/features/categories/services/category_sync_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryAdminScreen extends StatefulWidget {
  const CategoryAdminScreen({super.key});
  static const routeName = '/admin/categories';

  @override
  State<CategoryAdminScreen> createState() => _CategoryAdminScreenState();
}

class _CategoryAdminScreenState extends State<CategoryAdminScreen> {
  final _repo = CategoryAdminRepository(db: FirebaseFirestore.instance);
  final _sync = CategorySyncService();
  String? _selectedParentId;

  Future<void> _openParentDialog({Map<String, dynamic>? initial}) async {
    final idCtrl = TextEditingController(text: initial?['slug'] ?? '');
    final nameKo = TextEditingController(text: initial?['nameKo'] ?? '');
    final nameId = TextEditingController(text: initial?['nameId'] ?? '');
    final nameEn = TextEditingController(text: initial?['nameEn'] ?? '');
    final orderCtrl =
        TextEditingController(text: (initial?['order'] ?? 1).toString());
    bool active = initial?['active'] ?? true;
    final iconCtrl = TextEditingController(text: initial?['icon'] ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(initial == null ? '부모 카테고리 추가' : '부모 카테고리 수정'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idCtrl,
                decoration:
                    const InputDecoration(labelText: 'ID/Slug (영문-kebab)'),
              ),
              TextField(
                controller: nameKo,
                decoration: const InputDecoration(labelText: '이름(KO)'),
              ),
              TextField(
                controller: nameId,
                decoration: const InputDecoration(labelText: '이름(ID)'),
              ),
              TextField(
                controller: nameEn,
                decoration: const InputDecoration(labelText: '이름(EN)'),
              ),
              TextField(
                controller: orderCtrl,
                decoration: const InputDecoration(labelText: '정렬(order)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: iconCtrl,
                decoration: const InputDecoration(labelText: '아이콘(optional)'),
              ),
              SwitchListTile(
                value: active,
                onChanged: (v) => setState(() => active = v),
                title: const Text('활성(active)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      await _repo.upsertParent(
        id: idCtrl.text.trim(),
        nameKo: nameKo.text.trim(),
        nameId: nameId.text.trim(),
        nameEn: nameEn.text.trim(),
        order: int.tryParse(orderCtrl.text) ?? 1,
        active: active,
        icon: iconCtrl.text.trim().isEmpty ? null : iconCtrl.text.trim(),
        updatedBy: uid,
      );
      setState(() {});
    }
  }

  Future<void> _openSubDialog(String parentId,
      {Map<String, dynamic>? initial}) async {
    final idCtrl = TextEditingController(text: initial?['slug'] ?? '');
    final nameKo = TextEditingController(text: initial?['nameKo'] ?? '');
    final nameId = TextEditingController(text: initial?['nameId'] ?? '');
    final nameEn = TextEditingController(text: initial?['nameEn'] ?? '');
    final orderCtrl =
        TextEditingController(text: (initial?['order'] ?? 1).toString());
    bool active = initial?['active'] ?? true;
    final iconCtrl = TextEditingController(text: initial?['icon'] ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(initial == null ? '서브카테고리 추가' : '서브카테고리 수정'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idCtrl,
                decoration:
                    const InputDecoration(labelText: 'ID/Slug (영문-kebab)'),
              ),
              TextField(
                controller: nameKo,
                decoration: const InputDecoration(labelText: '이름(KO)'),
              ),
              TextField(
                controller: nameId,
                decoration: const InputDecoration(labelText: '이름(ID)'),
              ),
              TextField(
                controller: nameEn,
                decoration: const InputDecoration(labelText: '이름(EN)'),
              ),
              TextField(
                controller: orderCtrl,
                decoration: const InputDecoration(labelText: '정렬(order)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: iconCtrl,
                decoration: const InputDecoration(labelText: '아이콘(optional)'),
              ),
              SwitchListTile(
                value: active,
                onChanged: (v) => setState(() => active = v),
                title: const Text('활성(active)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      await _repo.upsertSubcategory(
        parentId: parentId,
        id: idCtrl.text.trim(),
        nameKo: nameKo.text.trim(),
        nameId: nameId.text.trim(),
        nameEn: nameEn.text.trim(),
        order: int.tryParse(orderCtrl.text) ?? 1,
        active: active,
        icon: iconCtrl.text.trim().isEmpty ? null : iconCtrl.text.trim(),
        updatedBy: uid,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[관리자] 카테고리 관리'),
        actions: [
          IconButton(
            tooltip: 'Publish(JSON/AI Rules 재생성)',
            onPressed: () async {
              await _sync.publishDesignAndRules();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('카테고리 디자인/AI 룰을 재생성했습니다.')));
              }
            },
            icon: const Icon(Icons.cloud_upload),
          ),
        ],
      ),
      body: Row(
        children: [
          // 부모 카테고리 패널
          Expanded(
            flex: 1,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _repo.fetchParents(),
              builder: (context, snap) {
                final data = snap.data ?? const <Map<String, dynamic>>[];
                return Column(
                  children: [
                    ListTile(
                      title: const Text('부모 카테고리'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _openParentDialog(),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, i) {
                          final p = data[i];
                          return ListTile(
                            selected: _selectedParentId == p['id'],
                            title: Text(
                                '${p['nameKo']} / ${p['nameId']} / ${p['nameEn']}'),
                            subtitle: Text(
                                'id=${p['id']}  · order=${p['order']} · active=${p['active']}'),
                            onTap: () =>
                                setState(() => _selectedParentId = p['id']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _openParentDialog(initial: p)),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('삭제 확인'),
                                        content: Text(
                                            '부모 카테고리 "${p['nameKo']}" 및 모든 하위 카테고리를 삭제할까요?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('취소')),
                                          ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('삭제')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await _repo.deleteParent(p['id']);
                                      if (_selectedParentId == p['id']) {
                                        _selectedParentId = null;
                                      }
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
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
          const VerticalDivider(width: 1),
          // 서브 카테고리 패널
          Expanded(
            flex: 1,
            child: _selectedParentId == null
                ? const Center(child: Text('왼쪽에서 부모 카테고리를 선택하세요.'))
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _repo.fetchSubcategories(_selectedParentId!),
                    builder: (context, snap) {
                      final data = snap.data ?? const <Map<String, dynamic>>[];
                      return Column(
                        children: [
                          ListTile(
                            title: Text('서브 카테고리 (${_selectedParentId!})'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  _openSubDialog(_selectedParentId!),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (_, i) {
                                final s = data[i];
                                return ListTile(
                                  title: Text(
                                      '${s['nameKo']} / ${s['nameId']} / ${s['nameEn']}'),
                                  subtitle: Text(
                                      'id=${s['id']} · order=${s['order']} · active=${s['active']}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _openSubDialog(
                                              _selectedParentId!,
                                              initial: s)),
                                      IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('삭제 확인'),
                                                content: Text(
                                                    '서브 카테고리 "${s['nameKo']}"를 삭제할까요?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child: const Text('취소')),
                                                  ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: const Text('삭제')),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await _repo.deleteSubcategory(
                                                  _selectedParentId!, s['id']);
                                              setState(() {});
                                            }
                                          }),
                                    ],
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
}
