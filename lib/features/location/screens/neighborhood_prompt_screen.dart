/// ============================================================================
/// Bling 문서헤더
/// 모듈         : 회원가입 위치 확인 (Neighborhood Prompt)
/// 파일         : lib/features/location/screens/neighborhood_prompt_screen.dart
/// 목적         : GeoPoint(현재 위치) → Google Geocoding(Reverse) → 인도네시아 행정구역
///               (Provinsi → Kabupaten/Kota → Kecamatan → Kelurahan/Desa) 파싱 및 저장
/// 사용자 가치  : 사용자가 현재 위치 기반으로 자신의 동네(케루라한/데사)를 손쉽게 설정
/// 연결 기능    : (선택) 수동 선택 화면 location_filter_screen.dart 로 폴백 가능
/// 의존성       : http, geolocator, cloud_firestore, firebase_auth
/// 주의         : GOOGLE_MAPS_API_KEY 설정 필요(환경변수 또는 상수)
///
/// 변경 이력    : 2025-09-09 최초 작성 (http + Reverse Geocoding 최종본)
/// ============================================================================

/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/screens/neighborhood_prompt_screen.dart
/// Purpose       : Google **Geocoding(Reverse)** + Firestore 행정DB 검증을 통해 사용자의 동네를 저장
/// User Impact   : 정확한 RT/RW 소속이 초근접 기능을 활성화합니다.
/// Feature Links : lib/features/location/screens/location_setting_screen.dart
/// Data Model    : Firestore `users` 필드 `locationName`, `locationParts`, `geoPoint`, `neighborhoodVerified`
/// Location Scope: Prov → Kota/Kabupaten → Kecamatan → Kelurahan 검증, GPS를 기본값으로 사용
/// Trust Policy  : 검증 성공 시 `neighborhoodVerified = true` (신뢰도 시스템 연계는 별도)
/// KPI/Analytics : I18N 키 `location.success`, `location.error` 사용 (assets/lang/*.json)
/// Dependencies  : firebase_auth, cloud_firestore, geolocator, permission_handler, easy_localization, http
/// Security/Auth : 로그인 필요, API 키는 `ApiKeys.googleApiKey` 사용
/// Changelog     : 2025-09-09 기존 Places 기반 → http Reverse Geocoding 기반으로 교체
/// ============================================================================
library;
// ============================================================================
// FILE: lib/features/location/screens/neighborhood_prompt_screen.dart
// DESC: Reverse Geocoding (http) + ID admin parsing + RT/RW form + Firestore save
// NOTE: returns `Navigator.pop(true)` on success so caller controls next route
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/api_keys.dart';
import 'package:bling_app/features/location/screens/location_manual_select_screen.dart';

class AdminAddress {
  final String province;
  final String regency;
  final String district;
  final String village;
  final String villageType; // 'kelurahan' | 'desa' | 'unknown'
  final String formattedAddress;
  final Map<String, String> components;

  const AdminAddress({
    required this.province,
    required this.regency,
    required this.district,
    required this.village,
    required this.villageType,
    required this.formattedAddress,
    required this.components,
  });

  String get displayName {
    final parts = [village, district, regency, province]
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  Map<String, dynamic> toLocationParts() => {
        'prov': province,
        'kab': regency,
        'kota': regency, // keep both keys for backward-compat
        'kec': district,
        'kel': village,
      };
}

class GoogleGeocodingService {
  GoogleGeocodingService(this.apiKey);
  final String apiKey;

  Future<AdminAddress> reverseGeocode({
    required double lat,
    required double lng,
    Duration timeout = const Duration(seconds: 10),
    int retries = 2,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('GOOGLE_MAPS_API_KEY missing');
    }

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng&language=id&region=ID&result_type='
      'administrative_area_level_1|administrative_area_level_2|'
      'administrative_area_level_3|administrative_area_level_4|'
      'sublocality|political&key=$apiKey',
    );

    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final resp = await http.get(uri).timeout(timeout);
        if (resp.statusCode != 200) {
          throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
        }
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'UNKNOWN';
        if (status != 'OK') throw Exception('Geocoding status=$status');

        final results = (data['results'] as List).cast<Map<String, dynamic>>();
        if (results.isEmpty) throw Exception('ZERO_RESULTS');

        results.sort((a, b) {
          int score(Map<String, dynamic> r) {
            final types = (r['types'] as List).cast<String>();
            int s = 0;
            for (final t in types) {
              if (t.startsWith('administrative_area_level_')) s += 3;
              if (t.startsWith('sublocality')) s += 2;
              if (t == 'political') s += 1;
            }
            return s;
          }

          return score(b).compareTo(score(a));
        });

        final best = results.first;
        final comps = (best['address_components'] as List)
            .cast<Map<String, dynamic>>();
        final formatted = best['formatted_address'] as String? ?? '';

        final parsed = _parseIndoAdmin(comps);
        return AdminAddress(
          province: parsed['province'] ?? '',
          regency: parsed['regency'] ?? '',
          district: parsed['district'] ?? '',
          village: parsed['village'] ?? '',
          villageType: parsed['villageType'] ?? 'unknown',
          formattedAddress: formatted,
          components: parsed,
        );
      } on TimeoutException {
        if (attempt > retries) rethrow;
        await Future.delayed(Duration(milliseconds: 400 * attempt));
      } catch (_) {
        if (attempt > retries) rethrow;
        await Future.delayed(Duration(milliseconds: 400 * attempt));
      }
    }
  }

  Map<String, String> _parseIndoAdmin(List<Map<String, dynamic>> comps) {
    String? byTypes(List<String> wantTypes) {
      for (final c in comps) {
        final types = (c['types'] as List).cast<String>();
        final longName = (c['long_name'] as String?)?.trim();
        if (longName == null || longName.isEmpty) continue;
        if (wantTypes.any((w) => types.contains(w))) return longName;
      }
      return null;
    }

    String norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

    String stripPrefix(String s, List<String> prefixes) {
      for (final p in prefixes) {
        if (s.toLowerCase().startsWith(p.toLowerCase())) {
          return s.substring(p.length).trim();
        }
      }
      return s;
    }

    final prov = byTypes(['administrative_area_level_1']) ?? '';

    String reg = byTypes(['administrative_area_level_2']) ??
        byTypes(['locality']) ??
        '';
    reg = stripPrefix(reg, ['Kabupaten ', 'Kota ']);

    String kec = byTypes(['administrative_area_level_3']) ??
        byTypes(['sublocality_level_2']) ??
        '';
    kec = stripPrefix(kec, ['Kecamatan ']);

    String kel = byTypes(['administrative_area_level_4']) ??
        byTypes(['sublocality_level_1', 'sublocality', 'neighborhood']) ??
        '';

    String kelType = 'unknown';
    final lowerKel = kel.toLowerCase();
    if (lowerKel.startsWith('kelurahan ')) {
      kel = stripPrefix(kel, ['Kelurahan ']);
      kelType = 'kelurahan';
    } else if (lowerKel.startsWith('desa ')) {
      kel = stripPrefix(kel, ['Desa ']);
      kelType = 'desa';
    } else {
      final rawKel = byTypes(['administrative_area_level_4']) ?? '';
      final rawSub = byTypes(['sublocality_level_1', 'sublocality']) ?? '';
      if (rawKel.toLowerCase().contains('kelurahan')) kelType = 'kelurahan';
      if (rawKel.toLowerCase().contains('desa')) kelType = 'desa';
      if (kelType == 'unknown') {
        if (rawSub.toLowerCase().contains('kelurahan')) kelType = 'kelurahan';
        if (rawSub.toLowerCase().contains('desa')) kelType = 'desa';
      }
    }

    return {
      'province': norm(prov),
      'regency': norm(reg),
      'district': norm(kec),
      'village': norm(kel),
      'villageType': kelType,
    };
  }
}

class NeighborhoodPromptScreen extends StatefulWidget {
  const NeighborhoodPromptScreen({super.key});
  @override
  State<NeighborhoodPromptScreen> createState() => _NeighborhoodPromptScreenState();
}

class _NeighborhoodPromptScreenState extends State<NeighborhoodPromptScreen> {
  bool _loading = false;
  String? _error;
  Position? _position;
  AdminAddress? _address;

  // ✅ ApiKeys.googleApiKey 직접 사용
  final _geocoder = GoogleGeocodingService(ApiKeys.googleApiKey);
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final _rtCtl = TextEditingController();
  final _rwCtl = TextEditingController();

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
    _rtCtl.dispose();
    _rwCtl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pos = await _getCurrentPosition();
      final addr = await _geocoder.reverseGeocode(lat: pos.latitude, lng: pos.longitude);

      // Prefill RT/RW from existing user doc (backward-compat: locationParts.rt/rw or top-level rt/rw)
      final user = _auth.currentUser;
      if (user != null) {
        final snap = await _firestore.collection('users').doc(user.uid).get();
        final data = snap.data(); // Map<String, dynamic>?
        final parts = (data?['locationParts'] as Map?)?.cast<String, dynamic>();
        final rt0 = (parts?['rt'] ?? data?['rt']) as String?;
        final rw0 = (parts?['rw'] ?? data?['rw']) as String?;
        if (rt0 != null && rt0.isNotEmpty) _rtCtl.text = _normDigits(rt0);
        if (rw0 != null && rw0.isNotEmpty) _rwCtl.text = _normDigits(rw0);
      }

      setState(() {
        _position = pos;
        _address = addr;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      _safeSetState(() => _loading = false); // <- dispose 이후면 실행 안 됨
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  String _normDigits(String raw) {
    final only = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (only.isEmpty) return '';
    // Canonical: 3-digit zero-pad (e.g., 3 -> 003)
    return only.length >= 3 ? only.substring(0, 3) : only.padLeft(3, '0');
  }

  Future<void> _saveAndContinue() async {
    if (_address == null || _position == null) return;

    // Validate RT/RW
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Login required');

      final rt = _normDigits(_rtCtl.text);
      final rw = _normDigits(_rwCtl.text);

      final docRef = _firestore.collection('users').doc(user.uid);

      final geo = GeoPoint(_position!.latitude, _position!.longitude);
      final locName = _address!.displayName;
      final baseParts = _address!.toLocationParts();

      await docRef.update({
        'locationName': locName,
        'locationParts': {
          ...baseParts,
          'rt': rt,
          'rw': rw,
        },
        'geoPoint': geo,
        'neighborhoodVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('location.success'.tr())),
      );

      // IMPORTANT: keep original navigation contract — pop(true)
      Navigator.of(context).pop(true);
    } catch (e) {
      _safeSetState(() => _error = e.toString());
    } finally {
     _safeSetState(() => _loading = false);
    }
  }

 void _goManualSelect() async {
  final ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LocationManualSelectScreen()),
  );

  // 수동 저장 성공 시, 이 화면도 성공 종료(pop(true))
  if (ok == true && mounted) {
    Navigator.of(context).pop(true);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Neighborhood')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_error != null)
                  ? _ErrorView(
                      message: _error!,
                      onRetry: _bootstrap,
                      onManual: _goManualSelect,
                    )
                  : _Content(
                      formKey: _formKey,
                      address: _address!,
                      position: _position!,
                      rtCtl: _rtCtl,
                      rwCtl: _rwCtl,
                      onSave: _saveAndContinue,
                      onManual: _goManualSelect,
                      onRefresh: _bootstrap,
                    ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onManual,
  });
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onManual,
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: const Text('Manual select'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.formKey,
    required this.address,
    required this.position,
    required this.rtCtl,
    required this.rwCtl,
    required this.onSave,
    required this.onManual,
    required this.onRefresh,
  });

  final GlobalKey<FormState> formKey;
  final AdminAddress address;
  final Position position;
  final TextEditingController rtCtl;
  final TextEditingController rwCtl;
  final VoidCallback onSave;
  final VoidCallback onManual;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detected neighborhood', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _InfoRow(label: 'Display', value: address.displayName),
          _InfoRow(label: 'Province', value: address.province),
          _InfoRow(label: 'Kab/Kota', value: address.regency),
          _InfoRow(label: 'Kecamatan', value: address.district),
          _InfoRow(label: 'Kel/Desa', value: '${address.village} (${address.villageType})'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Lat/Lng', value: '${position.latitude}, ${position.longitude}'),
          const SizedBox(height: 16),
          Text('Add detailed address (RT/RW)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: rtCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RT',
                    hintText: 'e.g. 003',
                    prefixIcon: Icon(Icons.house_siding_outlined),
                  ),
                  validator: (v) {
                    final s = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (s.isEmpty) return 'Please enter RT';
                    if (s.length > 3) return 'Max 3 digits';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: rwCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RW',
                    hintText: 'e.g. 007',
                    prefixIcon: Icon(Icons.groups_outlined),
                  ),
                  validator: (v) {
                    final s = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (s.isEmpty) return 'Please enter RW';
                    if (s.length > 3) return 'Max 3 digits';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'RT/RW will not be public. They help boost trust and enable hyperlocal features.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onManual,
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  label: const Text('Manual select'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Save this location'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh from GPS'),
            ),
          )
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.titleSmall)),
        ],
      ),
    );
  }
}
