/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/screens/neighborhood_prompt_screen.dart
/// Purpose       : 회원가입 후 또는 위치 정보가 없는 사용자에게 동네 설정을 유도합니다.
/// User Impact   : GPS 자동 설정 또는 수동 선택을 통해 정확한 동네 정보를 입력받습니다.
/// Feature Links : LocationFilterScreen (수동 선택), LocationHelper (GPS/주소 변환)
/// Data Model    : users/{uid} 업데이트 (locationParts, locationName, geoPoint, neighborhoodVerified)
/// ============================================================================
library;

import 'package:bling_app/core/utils/location_helper.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bling_app/core/utils/logging/logger.dart';

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
      // 1) 권한 확인 및 위치 가져오기
      final position = await LocationHelper.getCurrentLocation();
      if (position == null) {
        throw Exception("위치 권한이 없거나 GPS가 꺼져 있습니다.");
      }

      setState(() => _statusMessage = "주소를 변환하는 중입니다...");

      // 2) 좌표 -> 주소 변환 (Google Geocoding)
      final address = await LocationHelper.getAddressFromCoordinates(position);
      if (address == null) {
        throw Exception("주소를 찾을 수 없습니다. 다시 시도해주세요.");
      }

      // 3) 주소 파싱 (Prov, Kab, Kec, Kel 추출)
      final parts = LocationHelper.parseAddress(address);

      // [검증] 최소한 Prov, Kab 정보는 있어야 함
      if (parts['prov'] == null || parts['kab'] == null) {
        Logger.warn(
            "NeighborhoodPrompt: Parsing failed. Parts: $parts"); // 디버깅 로그
        // 파싱 실패 시 수동 입력 유도
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("주소 정보를 상세히 가져오지 못했습니다. (행정구역 누락)\n수동 설정을 진행합니다."),
              duration: Duration(seconds: 3),
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) _openManualSelection();
        }
        return;
      }

      setState(() => _statusMessage = "동네 정보를 저장 중입니다...");

      // [수정] 화면 표시용 약어 주소 생성 (UI 오버플로우 방지)
      // 예: "Kel. Bencongan, Kec. Kelapa Dua, Kab. Tangerang"
      String formattedAddress = address; // 기본값은 전체 주소
      if (parts['kel'] != null &&
          parts['kec'] != null &&
          parts['kab'] != null) {
        // 키워드 제거 및 약어 적용 헬퍼 함수
        String clean(String? val, String remove) =>
            val?.replaceAll(RegExp(remove, caseSensitive: false), '').trim() ??
            '';

        final kel = clean(parts['kel'], 'Kelurahan|Desa');
        final kec = clean(parts['kec'], 'Kecamatan');
        final kab = clean(parts['kab'], 'Kabupaten|Kota');

        formattedAddress = "Kel. $kel, Kec. $kec, Kab. $kab";
      }

      // 4) Firestore 저장
      await _saveLocationToUser(
        locationName: formattedAddress,
        locationParts: parts,
        geoPoint: GeoPoint(position.latitude, position.longitude),
      );
      Logger.info("NeighborhoodPrompt: Location saved successfully.");
    } catch (e) {
      String errorMessage = "위치 정보를 가져오는 중 알 수 없는 오류가 발생했습니다.";

      if (e.toString().contains("permission")) {
        errorMessage = "위치 권한이 필요합니다.";
      } else if (e.toString().contains("Service")) {
        errorMessage = "GPS가 꺼져 있습니다.";
      } else if (e.toString().contains("IOError") ||
          e.toString().contains("network")) {
        errorMessage = "네트워크 상태가 좋지 않아 주소를 변환할 수 없습니다.";
      }

      Logger.error("NeighborhoodPrompt Error: $e", error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            action: SnackBarAction(
              label: '수동 선택',
              onPressed: _openManualSelection,
              textColor: Colors.white,
            ),
          ),
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
    // 1. LocationFilterScreen을 열고 결과를 기다립니다.
    // LocationFilterScreen은 '적용' 버튼 클릭 시 provider.adminFilter(Map)를 반환하도록 되어 있습니다.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const LocationFilterScreen(initialTabIndex: 0)),
    );

    // 2. 결과값이 있는지 확인합니다. (사용자가 뒤로가기를 누르면 null)
    if (result != null && result is Map) {
      final String? prov = result['prov'] as String?;
      final String? kab = result['kab'] as String?;

      // 3. 유효성 검사: 동네 설정이므로 최소한 '도'와 '시/군' 정보는 필수입니다.
      if (prov != null && kab != null) {
        setState(() {
          _isLoading = true;
          _statusMessage = "선택한 동네를 저장 중입니다...";
        });

        try {
          // [수정] 수동 선택 시에도 통일된 포맷(약어) 적용
          String formattedName = "";

          // 입력값이 "Kecamatan OO" 형태인지 단순 "OO"인지에 따라 처리가 다르지만,
          // LocationFilterScreen 데이터가 순수 이름만 온다면 약어만 붙여줌.
          // 여기서는 안전하게 조합합니다.
          final kKel = result['kel'] != null ? "Kel. ${result['kel']}" : "";
          final kKec = result['kec'] != null ? "Kec. ${result['kec']}" : "";
          final kKab = kab.startsWith("KOTA") || kab.startsWith("KAB")
              ? kab
              : "Kab. $kab";

          // 역순 조합 (동 -> 구 -> 시) 또는 순차 조합. 인니는 보통 작은 단위부터 씀.
          // 기존 예시: Kel. Muja Muju, Kec. Umbulharjo, Kab. Yogyakarta
          formattedName =
              [kKel, kKec, kKab].where((s) => s.isNotEmpty).join(', ');

          // 5. Firestore 저장 로직 호출
          await _saveLocationToUser(
            locationName: formattedName,
            locationParts: Map<String, dynamic>.from(result),
            geoPoint: null, // 수동 선택은 좌표가 없으므로 null
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("저장 중 오류가 발생했습니다: $e")),
            );
            setState(() => _isLoading = false);
          }
        }
      } else {
        // 필수 정보가 누락된 경우 경고
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("최소한 '도'와 '시/군'까지는 선택해야 합니다.")),
          );
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
      'neighborhoodVerified': true, // 인증 완료 플래그
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 저장 완료 후 메인 화면(AuthGate -> MainNavigation)으로 이동됨
    // (StreamBuilder가 자동으로 감지)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                '내 동네 설정하기', // i18n 키로 교체 권장
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
