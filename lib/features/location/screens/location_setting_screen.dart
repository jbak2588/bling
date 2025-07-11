// lib/features/location/screens/location_setting_screen.dart

import 'package:bling_app/api_keys.dart';
// import 'package:bling_app/features/main_screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _LocationSettingScreenState();
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: ApiKeys.googleApiKey);
  bool _isLoading = false;

  // 주소 정보를 locationParts 맵으로 변환하는 Helper 함수
  Map<String, String> _createLocationParts(List<AddressComponent> components) {
    final parts = <String, String>{};
    for (var component in components) {
      final types = component.types;
      if (types.contains('administrative_area_level_1')) {
        parts['prov'] = component.longName;
      } else if (types.contains('administrative_area_level_2')) {
        parts['kab'] = component.longName;
      } else if (types.contains('locality') ||
          types.contains('sublocality_level_1')) {
        parts['kec'] = component.longName;
      } else if (types.contains('administrative_area_level_4') ||
          types.contains('sublocality_level_2')) {
        parts['kel'] = component.longName;
      }
    }
    return parts;
  }

  // Firestore에 사용자 위치 정보를 생성 또는 업데이트하는 통합 함수
  Future<void> _updateUserLocation(String locationName,
      Map<String, String> locationParts, GeoPoint geoPoint) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // .set(..., merge: true)를 사용하여, 문서가 없으면 생성하고 있으면 필드를 업데이트합니다.
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'neighborhoodVerified': true,
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('location.success'.tr())));
      // 성공 후, 모든 이전 화면을 지우고 HomeScreen으로 이동합니다.
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const HomeScreen()),
      //   (Route<dynamic> route) => false,
      // );
    }
  }

  // 현재 GPS 위치로 주소 업데이트
  Future<void> _setNeighborhoodWithGPS() async {
    setState(() => _isLoading = true);

    try {
      // 1. 위치 서비스 활성화 여부 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('location.error'
                .tr(namedArgs: {'error': 'GPS service is disabled'}))));
        setState(() => _isLoading = false);
        return;
      }

      // 2. 위치 권한 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('location.permissionDenied'.tr())));
        }
        openAppSettings();
        setState(() => _isLoading = false);
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // 3. 현재 위치 가져오기
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // 4. 좌표를 주소로 변환
        final response = await _places.searchNearbyWithRadius(
            Location(lat: position.latitude, lng: position.longitude), 100,
            language: context.locale.languageCode);

        if (mounted && response.isOkay && response.results.isNotEmpty) {
          final place = response.results.first;
          final detailResult =
              await _places.getDetailsByPlaceId(place.placeId);

          if (mounted &&
              detailResult.isOkay &&
              detailResult.result.geometry != null) {
            final location = detailResult.result.geometry!.location;
            final components = detailResult.result.addressComponents;
            final locationMap = _createLocationParts(components);
            final fullAddress = detailResult.result.formattedAddress ??
                place.formattedAddress ??
                place.name;
            final geoPoint = GeoPoint(location.lat, location.lng);

            await _updateUserLocation(fullAddress, locationMap, geoPoint);
          }
        } else {
          throw Exception("Could not find address for current location.");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('location.error'.tr(namedArgs: {'error': e.toString()}))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 검색어 입력 시 자동완성 목록을 가져오는 함수


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('location.title'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 80, color: Color(0xFF00A66C)),
                const SizedBox(height: 24),
                Text('prompt.title'.tr(),
                    style: GoogleFonts.inter(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('prompt.subtitle'.tr(),
                    style: GoogleFonts.inter(
                        fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isLoading ? null : _setNeighborhoodWithGPS,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF00A66C),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('prompt.button'.tr(),
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
