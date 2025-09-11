// ============================================================================
// FILE: lib/features/location/screens/location_manual_select_screen.dart
// DESC: 수동으로 Prov → (Kab/Kota) → Kecamatan 선택 + Kel/Desa + RT/RW 입력 후 저장
// NOTE: 저장 성공 시 Navigator.pop(true)
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LocationManualSelectScreen extends StatefulWidget {
  const LocationManualSelectScreen({super.key});

  @override
  State<LocationManualSelectScreen> createState() =>
      _LocationManualSelectScreenState();
}

class _Regency {
  final String name; // 문서 id
  final String kind; // 'kota' or 'kab'
  const _Regency(this.name, this.kind);

  @override
  String toString() => '$name ($kind)';
}

class _LocationManualSelectScreenState
    extends State<LocationManualSelectScreen> {
  // UI state
  bool _loading = true;

  // 선택값
  String? _selProv;
  _Regency? _selReg;
  String? _selKec;

  final _kelCtl = TextEditingController();
  final _rtCtl = TextEditingController();
  final _rwCtl = TextEditingController();

  // 목록들
  List<String> _provinces = [];
  List<_Regency> _regencies = [];
  List<String> _kecamatans = [];

  // helpers
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _kelCtl.dispose();
    _rtCtl.dispose();
    _rwCtl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _safeSetState(() {
      _loading = true;
    });

    try {
      // 1) provinces 로드
      final provSnap =
          await FirebaseFirestore.instance.collection('provinces').get();
      final provs = provSnap.docs.map((d) => d.id).toList()..sort();

      // 2) 기존 사용자 선택 프리필
      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic>? data;
      if (user != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        data = snap.data();
      }
      final parts =
          (data?['locationParts'] as Map?)?.cast<String, dynamic>() ?? {};
      final oldProv = parts['prov'] as String?;
      final oldKota = parts['kota'] as String?;
      final oldKab = parts['kab'] as String?;
      final oldKec = parts['kec'] as String?;
      final oldKel = parts['kel'] as String?;
      final oldRt = (parts['rt'] as String?) ?? (data?['rt'] as String?);
      final oldRw = (parts['rw'] as String?) ?? (data?['rw'] as String?);

      _safeSetState(() {
        _provinces = provs;
        _selProv = oldProv ?? (provs.isNotEmpty ? provs.first : null);
        if (oldKel != null) _kelCtl.text = oldKel;
        if (oldRt != null) _rtCtl.text = _pad3(oldRt);
        if (oldRw != null) _rwCtl.text = _pad3(oldRw);
      });

      // 3) 선택된 Prov에 따라 regencies 로드
      if (_selProv != null) {
        await _loadRegencies(_selProv!);
      }

      // 4) 예전 선택(kota/kab) 복구
      if (oldKota != null || oldKab != null) {
        final wantName = (oldKota ?? oldKab)!;
        final wantKind = oldKota != null ? 'kota' : 'kab';
        final found = _regencies
            .where((r) =>
                r.name.toLowerCase() == wantName.toLowerCase() &&
                r.kind == wantKind)
            .toList();
        if (found.isNotEmpty) {
          _safeSetState(() => _selReg = found.first);
          await _loadKecamatans(_selProv!, _selReg!);
        }
      }

      // 5) 예전 kec 복구
      if (oldKec != null && _kecamatans.contains(oldKec)) {
        _safeSetState(() => _selKec = oldKec);
      }

      _safeSetState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load failed: $e')),
        );
      }
      _safeSetState(() => _loading = false);
    }
  }

  Future<void> _loadRegencies(String prov) async {
    _safeSetState(() {
      _regencies = [];
      _kecamatans = [];
      _selReg = null;
      _selKec = null;
    });

    final provRef =
        FirebaseFirestore.instance.collection('provinces').doc(prov);

    final kotaSnap = await provRef.collection('kota').get();
    final kabSnap = await provRef.collection('kabupaten').get();

    final merged = <_Regency>[
      for (final d in kotaSnap.docs) _Regency(d.id, 'kota'),
      for (final d in kabSnap.docs) _Regency(d.id, 'kab'),
    ]..sort((a, b) => a.name.compareTo(b.name));

    _safeSetState(() => _regencies = merged);
  }

  Future<void> _loadKecamatans(String prov, _Regency reg) async {
    _safeSetState(() {
      _kecamatans = [];
      _selKec = null;
    });

    final provRef =
        FirebaseFirestore.instance.collection('provinces').doc(prov);
    final col = reg.kind == 'kota' ? 'kota' : 'kabupaten';
    final kecSnap = await provRef
        .collection(col)
        .doc(reg.name)
        .collection('kecamatan')
        .get();

    final list = kecSnap.docs.map((d) => d.id).toList()..sort();
    _safeSetState(() => _kecamatans = list);
  }

  String _pad3(String raw) {
    final only = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (only.isEmpty) return '';
    return only.length >= 3 ? only.substring(0, 3) : only.padLeft(3, '0');
  }

  Future<void> _save() async {
    // 검증
    if (_selProv == null || _selReg == null || _selKec == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Province, Kab/Kota, Kecamatan.')),
      );
      return;
    }
    if (_kelCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Kel/Desa.')),
      );
      return;
    }
    if (_rtCtl.text.trim().isEmpty || _rwCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter RT/RW.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _safeSetState(() => _loading = true);

      final rt = _pad3(_rtCtl.text);
      final rw = _pad3(_rwCtl.text);

      // 기존 geoPoint 유지(수동 선택에는 좌표가 없으므로 보존)
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final oldGeo = userDoc.data()?['geoPoint'] as GeoPoint?;

      final parts = <String, String>{
        'prov': _selProv!, // 여기서는 이미 null 체크 후 return 했으므로 non-null
        'kec': _selKec!,
        'kel': _kelCtl.text.trim(),
        if (_selReg!.kind == 'kota') ...{
          'kota': _selReg!.name,
          'kab': '',
        } else ...{
          'kota': '',
          'kab': _selReg!.name,
        },
        'rt': rt,
        'rw': rw,
      };

      // '!' 제거: (value ?? '') 사용으로 안전 처리
      final addressParts = <String?>[
        parts['kel'],
        parts['kec'],
        ((parts['kab'] ?? '').isNotEmpty) ? parts['kab'] : parts['kota'],
        parts['prov'],
      ];
      final locationName = addressParts
          .where((e) => (e ?? '').trim().isNotEmpty)
          .join(', ');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'locationName': locationName,
        'locationParts': parts,
        'geoPoint': oldGeo, // 기존값 유지
        'neighborhoodVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location saved.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
      _safeSetState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual select')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Province
                  DropdownButtonFormField<String>(
                    initialValue: _selProv,
                    items: _provinces
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) async {
                      _safeSetState(() => _selProv = v);
                      if (v != null) await _loadRegencies(v);
                    },
                    decoration: const InputDecoration(labelText: 'Province'),
                  ),

                  const SizedBox(height: 12),

                  // Kab/Kota
                  DropdownButtonFormField<_Regency>(
                    initialValue: _selReg,
                    items: _regencies
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text('${r.name} (${r.kind})'),
                            ))
                        .toList(),
                    onChanged: (v) async {
                      _safeSetState(() => _selReg = v);
                      if (v != null && _selProv != null) {
                        await _loadKecamatans(_selProv!, v);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Kab/Kota'),
                  ),

                  const SizedBox(height: 12),

                  // Kecamatan
                  DropdownButtonFormField<String>(
                    initialValue: _selKec,
                    items: _kecamatans
                        .map((k) =>
                            DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => _safeSetState(() => _selKec = v),
                    decoration: const InputDecoration(labelText: 'Kecamatan'),
                  ),

                  const SizedBox(height: 12),

                  // Kel/Desa
                  TextFormField(
                    controller: _kelCtl,
                    decoration: const InputDecoration(
                      labelText: 'Kel/Desa',
                      hintText: 'e.g. Sukarasa',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _rtCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'RT',
                            hintText: '003',
                            prefixIcon: Icon(Icons.house_siding_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _rwCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'RW',
                            hintText: '007',
                            prefixIcon: Icon(Icons.groups_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
