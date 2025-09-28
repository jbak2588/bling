
/// ============================================================================

/// Bling 문서헤더

/// 모듈         : 회원가입 위치 확인 (Neighborhood Prompt)

/// 파일         : lib/features/location/screens/neighborhood_prompt_screen.dart

/// 목적         : GeoPoint(현재 위치) → Google Geocoding(Reverse) → 인도네시아 행정구역

///               (Provinsi → Kabupaten/Kota → Kecamatan → Kelurahan/Desa) 파싱 및 저장

/// 사용자 가치  : 사용자가 현재 위치 기반으로 자신의 동네(케루라한/데사)를 손쉽게 설정

/// 연결 기능    : (선택) 수동 선택 화면 location_filter_screen.dart 로 폴백 가능

/// 의존성       : http, geolocator, cloud_firestore, firebase_auth

/// 주의         : GOOGLE_MAPS_API_KEY 설정 필요(환경변수 또는 상수)

///

/// 변경 이력    : 2025-09-09 최초 작성 (http + Reverse Geocoding 최종본)

/// ============================================================================

library;

  

import 'dart:async';

import 'dart:convert';

  

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

  

/// --------------------------------------------------------------------------

/// ⚙️ API 키 설정

/// - 우선순위: (1) --dart-define=GOOGLE_MAPS_API_KEY=...  (2) 아래 상수 직접 기입

/// --------------------------------------------------------------------------

const String kGoogleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY',

    defaultValue: 'AIzaSyCGr0wgQ67ezSwO5pLowMx6J8emksSaemo');

  

/// 행정주소 결과 모델

class AdminAddress {

  final String province; // Provinsi

  final String regency; // Kabupaten/Kota (표준화: 접두어 제거)

  final String district; // Kecamatan (표준화: "Kecamatan " 제거)

  final String village; // Kelurahan/Desa (표준화: 접두어 제거)

  final String villageType; // 'kelurahan' | 'desa' | 'unknown'

  final String formattedAddress; // 전체 주소 문자열

  final Map<String, String> components; // 타입별 추출 결과(디버깅용)

  

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

    // 예: "Bencongan, Kelapa Dua, Tangerang, Banten"

    final parts = [village, district, regency, province]

        .where((e) => e.trim().isNotEmpty)

        .toList();

    return parts.join(', ');

  }

  

  Map<String, dynamic> toLocationParts() => {

        'prov': province,

        'kabkot': regency,

        'kec': district,

        'kel': village,

        'kelType': villageType,

      };

}

  

/// Google Geocoding Reverse 서비스 (http 직접 호출)

class GoogleGeocodingService {

  GoogleGeocodingService(this.apiKey);

  final String apiKey;

  

  /// Reverse Geocoding 호출 (언어: 인도네시아어, 지역 바이어스: ID, 결과 타입 필터: 행정/정치)

  Future<AdminAddress> reverseGeocode({

    required double lat,

    required double lng,

    Duration timeout = const Duration(seconds: 10),

    int retries = 2,

  }) async {

    if (apiKey.isEmpty || apiKey == 'REPLACE_WITH_YOUR_KEY') {

      throw Exception('GOOGLE_MAPS_API_KEY가 설정되지 않았습니다.');

    }

  

    final uri = Uri.parse(

      'https://maps.googleapis.com/maps/api/geocode/json'

      '?latlng=$lat,$lng'

      '&language=id'

      '&region=ID'

      '&result_type='

      'administrative_area_level_1|administrative_area_level_2|'

      'administrative_area_level_3|administrative_area_level_4|'

      'sublocality|political'

      '&key=$apiKey',

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

        if (status != 'OK') {

          throw Exception('Geocoding status=$status');

        }

  

        final results = (data['results'] as List).cast<Map<String, dynamic>>();

        if (results.isEmpty) {

          throw Exception('결과가 없습니다(ZERO_RESULTS).');

        }

  

        // 행정단위에 가까운 결과 우선. types에 political/administrative가 많은 항목 선호.

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

      } catch (e) {

        if (attempt > retries) rethrow;

        await Future.delayed(Duration(milliseconds: 400 * attempt));

      }

    }

  }

  

  /// address_components 파싱 → 인도네시아 행정단위 매핑

  Map<String, String> _parseIndoAdmin(List<Map<String, dynamic>> comps) {

    String? byTypes(List<String> wantTypes) {

      for (final c in comps) {

        final types = (c['types'] as List).cast<String>();

        final longName = (c['long_name'] as String?)?.trim();

        if (longName == null || longName.isEmpty) continue;

        if (wantTypes.any((w) => types.contains(w))) {

          return longName;

        }

      }

      return null;

    }

  

    String norm(String s) {

      s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

      return s;

    }

  

    String stripPrefix(String s, List<String> prefixes) {

      for (final p in prefixes) {

        if (s.toLowerCase().startsWith(p.toLowerCase())) {

          return s.substring(p.length).trim();

        }

      }

      return s;

    }

  

    // Province

    final prov = byTypes(['administrative_area_level_1']) ?? '';

  

    // Regency (Kabupaten/Kota)

    String reg = byTypes(['administrative_area_level_2']) ??

        byTypes(['locality']) ??

        '';

    reg = stripPrefix(reg, ['Kabupaten ', 'Kota ']);

  

    // District (Kecamatan)

    String kec = byTypes(['administrative_area_level_3']) ??

        byTypes(['sublocality_level_2']) ??

        '';

    kec = stripPrefix(kec, ['Kecamatan ']);

  

    // Village (Kelurahan/Desa)

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

      // 타입으로 추정 (보수적)

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

  

/// 화면: 사용자의 현재 위치를 가져와 Reverse Geocoding → 확인/저장

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

  

  final _geocoder = GoogleGeocodingService(kGoogleMapsApiKey);

  final _auth = FirebaseAuth.instance;

  final _firestore = FirebaseFirestore.instance;

  

  @override

  void initState() {

    super.initState();

    _bootstrap();

  }

  

  Future<void> _bootstrap() async {

    setState(() {

      _loading = true;

      _error = null;

    });

  

    try {

      // 1) 위치 권한 & 좌표 획득

      final pos = await _getCurrentPosition();

      // 2) Reverse Geocoding

      final addr = await _geocoder.reverseGeocode(lat: pos.latitude, lng: pos.longitude);

  

      setState(() {

        _position = pos;

        _address = addr;

      });

    } catch (e) {

      setState(() {

        _error = e.toString();

      });

    } finally {

      setState(() => _loading = false);

    }

  }

  

  Future<Position> _getCurrentPosition() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {

      throw Exception('위치 서비스가 꺼져 있습니다. 설정에서 활성화해 주세요.');

    }

  

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {

        throw Exception('위치 권한이 거부되었습니다.');

      }

    }

  

    if (permission == LocationPermission.deniedForever) {

      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용하세요.');

    }

  

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  }

  

  Future<void> _saveAndContinue() async {

    if (_address == null || _position == null) return;

  

    setState(() {

      _loading = true;

      _error = null;

    });

  

    try {

      final user = _auth.currentUser;

      if (user == null) {

        throw Exception('로그인이 필요합니다.');

      }

  

      final docRef = _firestore.collection('users').doc(user.uid);

  

      final geo = GeoPoint(_position!.latitude, _position!.longitude);

      final locName = _address!.displayName; // 예: "Bencongan, Kelapa Dua, Tangerang, Banten"

      final locParts = _address!.toLocationParts();

  

      await docRef.update({

        'locationName': locName,

        'locationParts': locParts,

        'geoPoint': geo,

        // 최초엔 미검증으로, 추후 동네 인증 플로우에서 true로 전환

        'neighborhoodVerified': false,

        'updatedAt': FieldValue.serverTimestamp(),

      });

  

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('위치가 저장되었습니다.')),

      );

  

      // TODO: 다음 화면으로 이동 (예: 메인/홈)

      Navigator.of(context).pop(true);

    } catch (e) {

      setState(() => _error = e.toString());

    } finally {

      setState(() => _loading = false);

    }

  }

  

  void _goManualSelect() {

    // TODO: 수동 선택 화면으로 이동 (location_filter_screen.dart)

    // Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationFilterScreen()));

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text('수동 선택 화면은 준비 중입니다.')),

    );

  }

  

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('동네 설정')),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(16.0),

          child: _loading

              ? const _Loading()

              : (_error != null)

                  ? _ErrorView(

                      message: _error!,

                      onRetry: _bootstrap,

                      onManual: _goManualSelect,

                    )

                  : _Content(

                      address: _address!,

                      position: _position!,

                      onSave: _saveAndContinue,

                      onManual: _goManualSelect,

                      onRefresh: _bootstrap,

                    ),

        ),

      ),

    );

  }

}

  

class _Loading extends StatelessWidget {

  const _Loading();

  @override

  Widget build(BuildContext context) {

    return const Center(child: CircularProgressIndicator());

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

        Text('문제가 발생했습니다', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 8),

        Text(message, style: Theme.of(context).textTheme.bodyMedium),

        const Spacer(),

        Row(

          children: [

            Expanded(

              child: OutlinedButton.icon(

                onPressed: onManual,

                icon: const Icon(Icons.edit_location_alt_outlined),

                label: const Text('수동 선택'),

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: FilledButton.icon(

                onPressed: onRetry,

                icon: const Icon(Icons.refresh),

                label: const Text('다시 시도'),

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

    required this.address,

    required this.position,

    required this.onSave,

    required this.onManual,

    required this.onRefresh,

  });

  

  final AdminAddress address;

  final Position position;

  final VoidCallback onSave;

  final VoidCallback onManual;

  final VoidCallback onRefresh;

  

  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text('현재 위치로 추정된 동네', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 8),

        _InfoRow(label: '표시명', value: address.displayName),

        _InfoRow(label: 'Province', value: address.province),

        _InfoRow(label: 'Kab/Kota', value: address.regency),

        _InfoRow(label: 'Kecamatan', value: address.district),

        _InfoRow(label: 'Kel/Desa', value: '${address.village} (${address.villageType})'),

        const SizedBox(height: 12),

        _InfoRow(label: '위도/경도', value: '${position.latitude}, ${position.longitude}'),

        const SizedBox(height: 12),

        Text(address.formattedAddress, style: Theme.of(context).textTheme.bodySmall),

        const Spacer(),

        Row(

          children: [

            Expanded(

              child: OutlinedButton.icon(

                onPressed: onManual,

                icon: const Icon(Icons.edit_location_alt_outlined),

                label: const Text('수동 선택'),

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: FilledButton.icon(

                onPressed: onSave,

                icon: const Icon(Icons.check_circle_outline),

                label: const Text('이 위치로 설정'),

              ),

            ),

          ],

        ),

        const SizedBox(height: 8),

        Center(

          child: TextButton.icon(

            onPressed: onRefresh,

            icon: const Icon(Icons.refresh),

            label: const Text('다시 측정'),

          ),

        )

      ],

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