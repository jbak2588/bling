/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/screens/location_filter_screen.dart
/// Purpose       : 검색 범위를 설정하는 화면 (행정구역, 내 주변, 전국)
/// User Impact   : 사용자가 원하는 방식(동네 이름 or 거리)으로 검색 범위를 자유롭게 조정합니다.
/// Data Model    : Firestore `provinces` 컬렉션 기반 (하위 호환성 유지)
/// ============================================================================
library;

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationFilterScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] 초기 탭 인덱스를 외부에서 지정할 수 있도록 함 (기본값은 null)
  final int? initialTabIndex;

  const LocationFilterScreen({super.key, this.userModel, this.initialTabIndex});

  @override
  State<LocationFilterScreen> createState() => _LocationFilterScreenState();
}

class _LocationFilterScreenState extends State<LocationFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 행정구역 선택 상태
  String? _tempProv;
  String? _tempKab;
  String? _tempKec;
  String? _tempKel;

  // 거리 선택 상태
  double _tempRadius = 5.0;

  // 컬렉션 이름 상수 (DB 변경 시 여기만 수정)
  static const String _colProvinces = 'provinces';
  static const String _colKabupaten = 'kabupaten';
  static const String _colKota = 'kota';
  static const String _colKecamatan = 'kecamatan';
  static const String _colKelurahan = 'kelurahan';

  @override
  void initState() {
    super.initState();
    final provider = context.read<LocationProvider>();

    // 초기값 로드
    _tempProv = provider.adminFilter['prov'];
    _tempKab = provider.adminFilter['kab'];
    _tempKec = provider.adminFilter['kec'];
    _tempKel = provider.adminFilter['kel'];
    if (provider.mode == LocationSearchMode.nearby) {
      _tempRadius = provider.radiusKm;
    }

    // 탭 인덱스 설정
    int initialIndex = 0;
    // 1순위: 생성자로 전달된 값이 있다면 최우선 적용
    if (widget.initialTabIndex != null) {
      initialIndex = widget.initialTabIndex!;
    } else {
      // 2순위: Provider의 현재 모드에 따라 결정 (기존 로직)
      switch (provider.mode) {
        case LocationSearchMode.administrative:
          initialIndex = 0;
          break;
        case LocationSearchMode.nearby:
          initialIndex = 1;
          break;
        case LocationSearchMode.national:
          initialIndex = 2;
          break;
      }
    }

    _tabController =
        TabController(length: 3, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final provider = context.read<LocationProvider>();

    // [수정] 행정구역 탭에서 '지역(Province)'이 선택되지 않은 경우(All Areas)
    // '상위 지역 선택' 에러 대신 '전국 모드'로 전환합니다.
    if (_tabController.index == 0 && _tempProv == null) {
      provider.setMode(LocationSearchMode.national);
      Navigator.pop(context, provider.adminFilter);
      return;
    }

    switch (_tabController.index) {
      case 0: // 행정구역
        provider.setAdminFilter(
          prov: _tempProv,
          kab: _tempKab,
          kec: _tempKec,
          kel: _tempKel,
        );
        break;
      case 1: // 내 주변
        provider.setNearbyRadius(_tempRadius);
        break;
      case 2: // 전국
        provider.setMode(LocationSearchMode.national);
        break;
    }
    // ✅ [수정] 선택된 필터 정보를 반환 (NeighborhoodPromptScreen 등에서 사용)
    // Provider가 이미 업데이트되었으므로 true만 반환하거나, 명시적으로 필터 맵 반환 가능
    Navigator.pop(context, provider.adminFilter);
  }

  // [기능] 필터 초기화
  void _resetFilter() {
    setState(() {
      _tempProv = null;
      _tempKab = null;
      _tempKec = null;
      _tempKel = null;
      _tempRadius = 5.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.locationfilter.title), // 변경
        actions: [
          TextButton(
            onPressed: _resetFilter,
            child: Text(t.locationfilter.reset,
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _applyFilter,
            child: Text(
                t[
                    'locationfilter.apply'], // 변경 (또는 common.confirm 유지 가능하지만 여기선 통일)
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor)),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t.locationfilter.tab.admin),
            Tab(text: t.locationfilter.tab.nearby),
            Tab(text: t.locationfilter.tab.national),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdminSelector(),
          _buildNearbySelector(),
          _buildNationalSelector(),
        ],
      ),
    );
  }

  // 1. 행정구역 선택 탭 (Firestore 실데이터 연동)
  Widget _buildAdminSelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Province 선택
          _buildFirestoreDropdown(
            label: t.locationfilter.provinsi,
            collectionPath: _colProvinces, // Root collection
            selectedValue: _tempProv,
            onChanged: (val) {
              setState(() {
                _tempProv = val;
                _tempKab = null;
                _tempKec = null;
                _tempKel = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Kab/Kota 선택 (Province 하위)
          // [주의] 기존 DB 구조상 Province 밑에 'kota'와 'kabupaten' 컬렉션이 분리되어 있을 수 있음.
          // 여기서는 두 컬렉션을 모두 조회하여 합치는 로직이 필요하나, StreamBuilder로는 복잡함.
          // 따라서 _buildDualCollectionDropdown 헬퍼를 사용합니다.
          _buildDualCollectionDropdown(
            label: t.locationfilter.kabupaten,
            parentPath: _tempProv != null ? '$_colProvinces/$_tempProv' : null,
            cols: [_colKabupaten, _colKota], // 둘 다 조회
            selectedValue: _tempKab,
            onChanged: (val) {
              setState(() {
                _tempKab = val;
                _tempKec = null;
                _tempKel = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Kecamatan 선택 (Kab/Kota 하위)
          // Kab인지 Kota인지 모르므로, 부모 경로를 동적으로 찾아야 함.
          // 여기서는 편의상 Kab/Kota 구분 없이 ID만으로 쿼리하거나,
          // 상위에서 선택된 값이 어느 컬렉션 출신인지 알면 좋겠지만,
          // 현재 구조상 _tempKab 값만으로는 알 수 없음.
          // -> 해결책: FutureBuilder를 사용하여 Kab/Kota 양쪽을 다 찔러보고 존재하는 경로를 찾거나,
          //    애초에 Dropdown Item에 메타데이터를 심어야 함.
          //    (여기서는 단순화를 위해 Kab/Kota 컬렉션을 순차적으로 탐색하는 FutureBuilder 사용)
          if (_tempProv != null && _tempKab != null)
            _buildKecamatanDropdown(
              label: t.locationfilter.kecamatan,
              provId: _tempProv!,
              kabId: _tempKab!,
              selectedValue: _tempKec,
              onChanged: (val) {
                setState(() {
                  _tempKec = val;
                  _tempKel = null;
                });
              },
            )
          else
            _disabledDropdown(t.locationfilter.kecamatan), // 변경
          const SizedBox(height: 16),

          // Kelurahan 선택
          // Kecamatan 하위 'kelurahan' 컬렉션 조회
          // (Kecamatan 경로를 찾기 위해 위 단계에서 경로 정보를 넘겨받아야 함)
          // -> 복잡성을 피하기 위해, Kecamatan 선택 시 경로를 저장하는 별도 변수 도입 필요.
          // -> 하지만 UI 상태가 너무 복잡해지므로, 여기서는 _buildKelurahanDropdown 내부에서 해결 시도.
          if (_tempProv != null && _tempKab != null && _tempKec != null)
            _buildKelurahanDropdown(
              // [간소화] 경로 찾기 로직 내장
              label: t.locationfilter.kelurahan,
              provId: _tempProv!,
              kabId: _tempKab!,
              kecId: _tempKec!,
              selectedValue: _tempKel,
              onChanged: (val) => setState(() => _tempKel = val),
            )
          else
            _disabledDropdown(t.locationfilter.kelurahan),

          const SizedBox(height: 24),
          if (_tempProv != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_getSummaryText(),
                          style: const TextStyle(color: Colors.blueAccent))),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _disabledDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8)),
          child: Text(t.locationfilter.hint.selectParent,
              style: const TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  // 단일 컬렉션 드롭다운 (Province용)
  Widget _buildFirestoreDropdown({
    required String label,
    required String collectionPath,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionPath).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _disabledDropdown(label); // 로딩 중
        }

        final items = snapshot.data!.docs.map((doc) => doc.id).toList();
        // 정렬 (가나다순)
        items.sort();

        return _renderDropdown(label, items, selectedValue, onChanged);
      },
    );
  }

  // 두 컬렉션 합쳐서 보여주는 드롭다운 (Kabupaten + Kota)
  Widget _buildDualCollectionDropdown({
    required String label,
    required String? parentPath,
    required List<String> cols,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    if (parentPath == null) return _disabledDropdown(label);

    // 두 스트림 병합을 위해 FutureBuilder 사용 (스냅샷 결합)
    return FutureBuilder<List<String>>(
      future: _fetchMergedCollections(parentPath, cols),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _disabledDropdown(label);
        return _renderDropdown(label, snapshot.data!, selectedValue, onChanged);
      },
    );
  }

  Future<List<String>> _fetchMergedCollections(
      String parentPath, List<String> subCols) async {
    final parentRef = FirebaseFirestore.instance.doc(parentPath);
    final Set<String> allIds = {}; // ✅ 중복 방지를 위해 Set 사용

    for (var col in subCols) {
      final snap = await parentRef.collection(col).get();
      allIds.addAll(snap.docs.map((d) => d.id));
    }
    final sortedList = allIds.toList()..sort(); // ✅ 리스트 변환 및 정렬
    return sortedList;
  }

  // Kecamatan용 (Kab/Kota 경로 찾기 포함)
  Widget _buildKecamatanDropdown({
    required String label,
    required String provId,
    required String kabId,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    // 경로 추적: Prov -> (Kota OR Kab) -> Kec
    // KabId가 'KOTA ...' 또는 'KABUPATEN ...'을 포함할 수도 있고 아닐 수도 있음.
    // 가장 확실한 건 두 경로 다 찔러보는 것.
    return FutureBuilder<List<String>>(
      future: _fetchKecamatan(provId, kabId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _disabledDropdown(label);
        return _renderDropdown(label, snapshot.data!, selectedValue, onChanged);
      },
    );
  }

  Future<List<String>> _fetchKecamatan(String provId, String kabId) async {
    final provRef =
        FirebaseFirestore.instance.collection(_colProvinces).doc(provId);

    // 1. Kabupaten에서 검색
    var snap = await provRef
        .collection(_colKabupaten)
        .doc(kabId)
        .collection(_colKecamatan)
        .get();
    if (snap.docs.isNotEmpty) {
      return snap.docs.map((d) => d.id).toList()..sort();
    }

    // 2. 없으면 Kota에서 검색
    snap = await provRef
        .collection(_colKota)
        .doc(kabId)
        .collection(_colKecamatan)
        .get();
    return snap.docs.map((d) => d.id).toList()..sort();
  }

  // Kelurahan용
  Widget _buildKelurahanDropdown({
    required String label,
    required String provId,
    required String kabId,
    required String kecId,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return FutureBuilder<List<String>>(
      future: _fetchKelurahan(provId, kabId, kecId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _disabledDropdown(label);
        return _renderDropdown(label, snapshot.data!, selectedValue, onChanged);
      },
    );
  }

  Future<List<String>> _fetchKelurahan(
      String prov, String kab, String kec) async {
    final provRef =
        FirebaseFirestore.instance.collection(_colProvinces).doc(prov);

    // 1. Kab -> Kec -> Kel
    var kecRef = provRef
        .collection(_colKabupaten)
        .doc(kab)
        .collection(_colKecamatan)
        .doc(kec);
    var snap = await kecRef.collection(_colKelurahan).get();
    if (snap.docs.isNotEmpty) {
      return snap.docs.map((d) => d.id).toList()..sort();
    }

    // 2. Kota -> Kec -> Kel
    kecRef = provRef
        .collection(_colKota)
        .doc(kab)
        .collection(_colKecamatan)
        .doc(kec);
    snap = await kecRef.collection(_colKelurahan).get();
    return snap.docs.map((d) => d.id).toList()..sort();
  }

  // 공통 드롭다운 렌더러
  Widget _renderDropdown(String label, List<String> items,
      String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(t.locationfilter.hint.all),
              value: items.contains(selectedValue) ? selectedValue : null,
              items: [
                DropdownMenuItem(
                    value: null, child: Text(t.locationfilter.hint.all)),
                ...items.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  String _getSummaryText() {
    List<String> parts = [];
    if (_tempProv != null) parts.add(_tempProv!);
    if (_tempKab != null) parts.add(_tempKab!);
    if (_tempKec != null) parts.add(_tempKec!);
    if (_tempKel != null) parts.add(_tempKel!);
    return parts.join(' > ');
  }

  // 2. 내 주변 (거리) 선택 탭
  Widget _buildNearbySelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.near_me_rounded, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          Text(
              t.locationfilter.nearby.radius
                  .replaceAll('{km}', _tempRadius.toInt().toString()),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            width: 300,
            child: Slider(
              value: _tempRadius,
              min: 1,
              max: 50,
              divisions: 49,
              label: "${_tempRadius.toInt()}km",
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => _tempRadius = val),
            ),
          ),
          const SizedBox(height: 16),
          Text(t.locationfilter.nearby.desc,
              textAlign: TextAlign.center, // ✅ 텍스트 중앙 정렬 추가
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  // 3. 전국 선택 탭
  Widget _buildNationalSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_rounded, size: 64, color: Colors.teal),
          const SizedBox(height: 24),
          Text(t.locationfilter.national.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              t.locationfilter.national.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
