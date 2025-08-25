import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/models/user_model.dart';

class LocationFilterScreen extends StatefulWidget {
  final UserModel? userModel;
  const LocationFilterScreen({this.userModel, super.key});

  @override
  State<LocationFilterScreen> createState() => _LocationFilterScreenState();
}

class _LocationFilterScreenState extends State<LocationFilterScreen> {
  final List<String> _provinsiList = [];
  final List<String> _kabupatenList = [];
  final List<String> _kotaList = [];
  final List<String> _kecamatanList = [];
  final List<String> _kelurahanList = [];

  String? _selectedProvinsi;
  String? _selectedKabupaten;
  String? _selectedKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;

  bool _kabupatenEnabled = false;
  bool _kotaEnabled = false;
  bool _kecamatanEnabled = false;
  bool _kelurahanEnabled = false;
  bool _loadingProvinces = true;

  // [추가] '전체' 옵션을 위한 상수
  final String _allOption = 'locationFilter.all'.tr();

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('provinces').get();
    setState(() {
      _provinsiList.addAll(snapshot.docs.map((d) => d.id));
      _loadingProvinces = false;
    });
  }

  Future<void> _onProvinsiChanged(String? value) async {
    if (value == null) return;
    setState(() {
      _selectedProvinsi = value;
      _selectedKabupaten = null;
      _selectedKota = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kabupatenEnabled = false;
      _kotaEnabled = false;
      _kecamatanEnabled = false;
      _kelurahanEnabled = false;
      _kabupatenList.clear();
      _kotaList.clear();
      _kecamatanList.clear();
      _kelurahanList.clear();
    });

    final provRef =
        FirebaseFirestore.instance.collection('provinces').doc(value);
    final kabSnapshot = await provRef.collection('kabupaten').get();
    final kotaSnapshot = await provRef.collection('kota').get();
    setState(() {
      _kabupatenList.addAll(kabSnapshot.docs.map((d) => d.id));
      _kotaList.addAll(kotaSnapshot.docs.map((d) => d.id));
      _kabupatenEnabled = true;
      _kotaEnabled = true;
    });
  }

  Future<void> _onKabupatenChanged(String? value) async {
    // [수정] '전체' 옵션을 선택하면 하위 목록을 비웁니다.
    if (value == _allOption) {
      setState(() {
        _selectedKabupaten = null;
        _selectedKecamatan = null;
        _selectedKelurahan = null;
        _kecamatanEnabled = false;
        _kelurahanEnabled = false;
        _kecamatanList.clear();
        _kelurahanList.clear();
      });
      return;
    }
    if (value == null) return;
    setState(() {
      _selectedKabupaten = value;
      _selectedKota = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kotaEnabled = false;
      _kecamatanEnabled = false;
      _kelurahanEnabled = false;
      _kotaList.clear();
      _kecamatanList.clear();
      _kelurahanList.clear();
    });
    final provRef = FirebaseFirestore.instance.collection('provinces').doc(_selectedProvinsi);
    final kecSnapshot = await provRef.collection('kabupaten').doc(value).collection('kecamatan').get();
    setState(() {
      _kecamatanList.addAll(kecSnapshot.docs.map((d) => d.id));
      _kecamatanEnabled = true;
    });
  }

  Future<void> _onKotaChanged(String? value) async {
    if (value == _allOption) {
        setState(() {
        _selectedKota = null;
        _selectedKecamatan = null;
        _selectedKelurahan = null;
        _kecamatanEnabled = false;
        _kelurahanEnabled = false;
        _kecamatanList.clear();
        _kelurahanList.clear();
      });
      return;
    }
    if (value == null) return;
    setState(() {
      _selectedKota = value;
      _selectedKabupaten = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kabupatenEnabled = false;
      _kecamatanEnabled = false;
      _kelurahanEnabled = false;
      _kabupatenList.clear();
      _kecamatanList.clear();
      _kelurahanList.clear();
    });
    final provRef = FirebaseFirestore.instance.collection('provinces').doc(_selectedProvinsi);
    final kecSnapshot = await provRef.collection('kota').doc(value).collection('kecamatan').get();
    setState(() {
      _kecamatanList.addAll(kecSnapshot.docs.map((d) => d.id));
      _kecamatanEnabled = true;
    });
  }

  Future<void> _onKecamatanChanged(String? value) async {
    if (value == _allOption) {
      setState(() {
        _selectedKecamatan = null;
        _selectedKelurahan = null;
        _kelurahanEnabled = false;
        _kelurahanList.clear();
      });
      return;
    }
    if (value == null) return;
    setState(() {
      _selectedKecamatan = value;
      _selectedKelurahan = null;
      _kelurahanEnabled = false;
      _kelurahanList.clear();
    });
    if (_selectedProvinsi == null) return;
    final provRef = FirebaseFirestore.instance.collection('provinces').doc(_selectedProvinsi);
    CollectionReference<Map<String, dynamic>> parent;
    if (_selectedKabupaten != null) {
      parent = provRef.collection('kabupaten').doc(_selectedKabupaten!).collection('kecamatan');
    } else if (_selectedKota != null) {
      parent = provRef.collection('kota').doc(_selectedKota!).collection('kecamatan');
    } else {
      return;
    }
    final kelSnapshot = await parent.doc(value).collection('kelurahan').get();
    setState(() {
      _kelurahanList.addAll(kelSnapshot.docs.map((d) => d.id));
      _kelurahanEnabled = true;
    });
  }

  void _onKelurahanChanged(String? value) {
     if (value == _allOption) {
      setState(() => _selectedKelurahan = null);
      return;
    }
    setState(() => _selectedKelurahan = value);
  }

  void _applyFilter() {
    final result = {
      'prov': _selectedProvinsi,
      'kab': _selectedKabupaten,
      'kota': _selectedKota,
      'kec': _selectedKecamatan,
      'kel': _selectedKelurahan,
    };
    Navigator.pop(context, result);
  }

  // [추가] 필터를 초기화하는 함수
  void _resetFilter() {
    setState(() {
      _selectedProvinsi = null;
      _selectedKabupaten = null;
      _selectedKota = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kabupatenEnabled = false;
      _kotaEnabled = false;
      _kecamatanEnabled = false;
      _kelurahanEnabled = false;
      _kabupatenList.clear();
      _kotaList.clear();
      _kecamatanList.clear();
      _kelurahanList.clear();
    });
  }

  // [추가] 드롭다운 아이템을 생성하는 헬퍼 함수
  List<DropdownMenuItem<String>> _buildDropdownItems(List<String> items, {bool addAllOption = false}) {
    final List<DropdownMenuItem<String>> menuItems = [];
    if (addAllOption) {
      menuItems.add(DropdownMenuItem(value: _allOption, child: Text(_allOption)));
    }
    menuItems.addAll(items.map((item) => DropdownMenuItem(value: item, child: Text(item))));
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('locationFilter.title'.tr()),
        // [추가] 초기화 버튼
        actions: [
          TextButton(
            onPressed: _resetFilter,
            child: Text('locationFilter.reset'.tr()),
          )
        ],
      ),
      body: _loadingProvinces
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedProvinsi,
                    hint: Text('locationFilter.provinsi'.tr()),
                    isExpanded: true,
                    items: _buildDropdownItems(_provinsiList),
                    onChanged: _onProvinsiChanged,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedKabupaten,
                    hint: Text('locationFilter.kabupaten'.tr()),
                    isExpanded: true,
                    items: _buildDropdownItems(_kabupatenList, addAllOption: true),
                    onChanged: _kabupatenEnabled ? _onKabupatenChanged : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedKota,
                    hint: Text('locationFilter.kota'.tr()),
                    isExpanded: true,
                    items: _buildDropdownItems(_kotaList, addAllOption: true),
                    onChanged: _kotaEnabled ? _onKotaChanged : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedKecamatan,
                    hint: Text('locationFilter.kecamatan'.tr()),
                    isExpanded: true,
                    items: _buildDropdownItems(_kecamatanList, addAllOption: true),
                    onChanged: _kecamatanEnabled ? _onKecamatanChanged : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedKelurahan,
                    hint: Text('locationFilter.kelurahan'.tr()),
                    isExpanded: true,
                    items: _buildDropdownItems(_kelurahanList, addAllOption: true),
                    onChanged: _kelurahanEnabled ? _onKelurahanChanged : null,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilter,
                      child: Text('locationFilter.apply'.tr()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}