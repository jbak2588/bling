/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/screens/neighborhood_prompt_screen.dart
/// Purpose       : 회원가입 후 또는 위치 정보가 없는 사용자에게 동네 설정을 유도합니다.
/// User Impact   : GPS 자동 설정 또는 수동 선택을 통해 정확한 동네 정보를 입력받습니다.
/// Feature Links : LocationFilterScreen (수동 선택), LocationHelper (GPS/주소 변환)
/// Data Model    : users/{uid} 업데이트 (locationParts, locationName, geoPoint, neighborhoodVerified)
/// Privacy Note : 사용자의 상세 주소(`locationParts['street']`)나 전체 `locationName`은 피드(목록/카드) 화면에서 사용자 동의 없이 표시하지 마세요. 피드에는 행정구역을 축약형(`kel.`, `kec.`, `kab.`, `prov.`)으로 간략 표기하세요.
/// ============================================================================
library;

import 'package:bling_app/core/utils/location_helper.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Placemark 직접 사용
import 'package:google_fonts/google_fonts.dart';

class NeighborhoodPromptScreen extends StatefulWidget {
  const NeighborhoodPromptScreen({super.key});

  @override
  State<NeighborhoodPromptScreen> createState() =>
      _NeighborhoodPromptScreenState();
}

class _NeighborhoodPromptScreenState extends State<NeighborhoodPromptScreen> {
  bool _isLoading = false;
  String? _statusMessage;

  // 1. GPS로 위치 가져오기 및 저장
  Future<void> _setNeighborhoodWithGPS() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "GPS 신호를 수신 중입니다...";
    });

    try {
      final position = await LocationHelper.getCurrentLocation();
      if (position == null) throw Exception("위치 정보를 가져올 수 없습니다.");

      setState(() => _statusMessage = "주소를 변환하는 중입니다...");

      // Placemark 객체를 직접 가져와서 정밀 파싱
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) throw Exception("주소를 찾을 수 없습니다.");

      final place = placemarks.first;

      // 전체 주소 문자열 조합
      final String fullAddress = [
        place.street,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.postalCode
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      // 정교한 파싱 (LocationHelper.parsePlacemark 사용)
      // subLocality가 Kelurahan, locality가 Kecamatan, subAdminArea가 Kab/Kota
      Map<String, dynamic> parts = LocationHelper.parsePlacemark(place);

      // [추가] 만약 Kelurahan(subLocality)이 비어있다면,
      // locality(Kec) 정보라도 저장하고, street 정보를 parts에 포함

      setState(() => _statusMessage = "동네 정보를 저장 중입니다...");

      await _saveLocationToUser(
        locationName: fullAddress,
        locationParts: parts,
        geoPoint: GeoPoint(position.latitude, position.longitude),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("동네 설정이 완료되었습니다.")),
        );
        // ✅ 화면 종료 (이전 화면으로 복귀)
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  // 2. 수동 선택 화면 열기
  Future<void> _openManualSelection() async {
    // LocationFilterScreen에서 결과를 받아옵니다.
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationFilterScreen()),
    );

    // 결과가 Map 형태(행정구역 필터)로 돌아왔다면 저장 로직 수행
    if (result != null && result is Map<String, String?> && mounted) {
      // 필수 값(최소 Kab/Kota) 확인
      if (result['kab'] == null && result['kota'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("최소한 시/군/구(City/District)까지 선택해야 합니다.")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _statusMessage = "선택한 동네 정보를 저장 중입니다...";
      });

      try {
        // 수동 선택이므로 좌표는 없음 (null)
        // 주소 문자열 조합 (예: 서울 > 강남구 > 역삼동)
        String locName = [
          result['prov'],
          result['kab'],
          result['kec'],
          result['kel']
        ].where((e) => e != null).join(', ');

        await _saveLocationToUser(
          locationName: locName,
          locationParts: result,
          geoPoint: null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("동네 설정이 완료되었습니다.")),
          );
          // ✅ 화면 종료
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("저장 실패: ${e.toString()}")),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // 3. Firestore 저장 공통 로직
  Future<void> _saveLocationToUser({
    required String locationName,
    required Map<String, dynamic> locationParts,
    GeoPoint? geoPoint,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'neighborhoodVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ 뒤로가기 버튼 (수동 진입 시 탈출구)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? const BackButton(color: Colors.black)
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 80, color: Color(0xFF00A66C)),
              const SizedBox(height: 24),
              Text(
                '내 동네 설정하기',
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '동네 인증을 해야 블링의 모든 기능을\n사용할 수 있어요.',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_statusMessage ?? "처리 중...",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: _setNeighborhoodWithGPS,
                  icon: const Icon(Icons.my_location),
                  label: const Text('현재 위치로 찾기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF00A66C),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _openManualSelection,
                  icon: const Icon(Icons.list),
                  label: const Text('동네 직접 선택하기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
