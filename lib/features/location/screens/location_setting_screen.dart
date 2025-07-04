// lib/features/location/screens/location_setting_screen.dart

import 'package:bling_app/api_keys.dart';
// import 'package:bling_app/features/main_screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _LocationSettingScreenState();
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  final _searchController = TextEditingController();
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: ApiKeys.googleApiKey);
  List<Prediction> _predictions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  // 장소 검색 결과로 주소 업데이트
  Future<void> _onPlaceSelected(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null) return;

    setState(() => _isLoading = true);

    try {
      final detailResult = await _places.getDetailsByPlaceId(placeId);
      if (mounted &&
          detailResult.isOkay &&
          detailResult.result.geometry != null) {
        final location = detailResult.result.geometry!.location;
        final components = detailResult.result.addressComponents;
        final locationMap = _createLocationParts(components);
        final fullAddress = prediction.description ?? '';
        final geoPoint = GeoPoint(location.lat, location.lng);

        await _updateUserLocation(fullAddress, locationMap, geoPoint);
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

  // 현재 GPS 위치로 주소 업데이트
  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);

    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('location.permissionDenied'.tr())));
        openAppSettings(); // 사용자가 직접 설정에서 권한을 켜도록 유도
      }
      setState(() => _isLoading = false);
      return;
    }

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        // final response = await _places.searchByText('${position.latitude},${position.longitude}');
           final response = await _places.searchNearbyWithRadius(
          Location(lat: position.latitude, lng: position.longitude),
         100, // 100미터 반경
         language: context.locale.languageCode, // 언어 코드 명시
       );

        if (mounted && response.isOkay && response.results.isNotEmpty) {
          final detailResult =
              await _places.getDetailsByPlaceId(response.results.first.placeId);
                final firstResult = response.results.first;
          if (mounted &&
              detailResult.isOkay &&
              detailResult.result.geometry != null) {
            final location = detailResult.result.geometry!.location;
            final components = detailResult.result.addressComponents;
            final locationMap = _createLocationParts(components);
            // final fullAddress = detailResult.result.formattedAddress ??
            //     response.results.first.formattedAddress ??
            //     '';
            final fullAddress = firstResult.formattedAddress ??
                firstResult.vicinity ??
                firstResult.name;
            final geoPoint = GeoPoint(location.lat, location.lng);

            await _updateUserLocation(fullAddress, locationMap, geoPoint);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'location.error'.tr(namedArgs: {'error': e.toString()}))));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('location.permissionDenied'.tr())));
        setState(() => _isLoading = false);
      }
    }
    
  }

  // 검색어 입력 시 자동완성 목록을 가져오는 함수
  Future<void> _onSearchChanged(String value) async {
    if (value.trim().length < 2) {
      if (_predictions.isNotEmpty && mounted) setState(() => _predictions = []);
      return;
    }
    final response = await _places.autocomplete(value,
        language: context.locale.languageCode,
        components: [Component(Component.country, 'id')]);
    if (response.isOkay && mounted) {
      setState(() => _predictions = response.predictions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('location.title'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'location.searchHint'.tr(),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF00A66C), width: 2)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _useCurrentLocation,
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  label: Text('location.gpsButton'.tr(),
                      style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF00A66C),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: Color(0xFF616161)),
                  title: Text(prediction.description ?? ''),
                  subtitle: Text(
                      prediction.structuredFormatting?.secondaryText ?? ''),
                  onTap: () => _onPlaceSelected(prediction),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
