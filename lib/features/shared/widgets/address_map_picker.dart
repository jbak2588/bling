// lib/features/shared/widgets/address_map_picker.dart

/*
  AddressMapPicker
  - 주소 검색 + 지도 선택 UI 위젯
  - Google Places Autocomplete + Place Details + Reverse Geocoding 기능 포함
  - BlingLocation 모델을 사용하여 위치 정보를 표준화합니다.
3. 공용 위젯: Address + Map + Pin

파일 경로: lib/features/shared/widgets/address_map_picker.dart

한 위젯 안에서
“주소 검색 → 자동완성 리스트 → 선택 → 지도 이동 + 중앙 핀 → 드래그 후 Reverse Geocode”까지 처리하는 공용 위치 선택 위젯입니다.

BlingLocation 을 입/출력 타입으로 사용

Scroll 내부에서도 동작하도록 EagerGestureRecognizer 적용

    “현재 위치로 이동” 버튼 포함
*/


import 'dart:async';

import 'package:bling_app/core/models/bling_location.dart';
import 'package:bling_app/core/services/location_search_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

/// 공용 주소 + 지도 선택 위젯.
/// - 검색창에 주소를 입력하면 Google Places Autocomplete 리스트가 나오고,
/// - 후보를 선택하면 지도 카메라가 해당 위치로 이동 + 중앙 핀 표시,
/// - 지도를 드래그 후 멈추면 Reverse Geocode로 주소를 다시 가져와 갱신.
/// 최종 선택값은 BlingLocation 으로 onChanged 에 전달됩니다.
class AddressMapPicker extends StatefulWidget {
  const AddressMapPicker({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.enableMyLocationButton = true,
    this.initialCameraPosition,
  });

  /// 초기 위치 (예: 기존 게시물 수정 시)
  final BlingLocation? initialValue;

  /// 선택된 위치가 바뀔 때마다 콜백 호출
  final ValueChanged<BlingLocation> onChanged;

  /// 검색 필드 라벨 / 힌트
  final String? labelText;
  final String? hintText;

  /// "현재 위치로 이동" 버튼 표시 여부
  final bool enableMyLocationButton;

  /// 초기 카메라 위치 (초기값 / fallback용)
  final LatLng? initialCameraPosition;

  @override
  State<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker> {
  final _searchController = TextEditingController();
  final _labelController = TextEditingController();

  final _locationService = LocationSearchService();
  final _uuid = const Uuid();

  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  BlingLocation? _currentLocation;

  String? _sessionToken;
  Timer? _debounce;

  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _isReverseGeocoding = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      _currentLocation = widget.initialValue;
      final geo = widget.initialValue!.geoPoint;
      _currentLatLng = LatLng(geo.latitude, geo.longitude);
      _searchController.text = widget.initialValue!.mainAddress;
      if (widget.initialValue!.shortLabel != null) {
        _labelController.text = widget.initialValue!.shortLabel!;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _labelController.dispose();
    _mapController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _ensureSessionToken() {
    _sessionToken ??= _uuid.v4();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        setState(() => _isSearching = true);
        _ensureSessionToken();

        final list = await _locationService.autocomplete(
          input: value,
          languageCode: context.locale.languageCode,
          sessionToken: _sessionToken,
        );

        if (!mounted) return;
        setState(() {
          _suggestions = list;
        });
      } catch (e) {
        // 가볍게 무시하고, 필요하면 상위에서 SnackBar 처리 가능
        debugPrint('AddressMapPicker autocomplete error: $e');
      } finally {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  Future<void> _selectSuggestion(LocationSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = [];
      _searchController.text = suggestion.description;
    });

    try {
      _ensureSessionToken();
      final loc = await _locationService.getLocationFromPlaceId(
        placeId: suggestion.placeId,
        languageCode: context.locale.languageCode,
        sessionToken: _sessionToken,
      );

      if (!mounted) return;

      _updateLocationFromBlingLocation(loc, fromUserSelection: true);
    } catch (e) {
      debugPrint('AddressMapPicker selectSuggestion error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("location.searchError".tr(args: [e.toString()])),
      ));
    }
  }

  Future<void> _useMyLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("location.permissionDenied".tr())),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;

      final loc = await _locationService.reverseGeocode(
        latitude: lat,
        longitude: lng,
        languageCode: context.locale.languageCode,
      );

      if (!mounted) return;
      _updateLocationFromBlingLocation(loc, fromUserSelection: true);
    } catch (e) {
      debugPrint('AddressMapPicker _useMyLocation error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("location.currentLocationError".tr())),
      );
    }
  }

  /// 지도 드래그 or API 응답으로 BlingLocation 업데이트 후 콜백 호출
  void _updateLocationFromBlingLocation(
    BlingLocation loc, {
    required bool fromUserSelection,
  }) {
    _currentLocation = loc;
    _currentLatLng = LatLng(loc.geoPoint.latitude, loc.geoPoint.longitude);

    _searchController.text = loc.mainAddress;

    // shortLabel 은 별도 TextField 로 관리
    final effectiveLocation = loc.copyWith(
      shortLabel: _labelController.text.isEmpty ? null : _labelController.text,
    );

    widget.onChanged(effectiveLocation);

    setState(() {});

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_currentLatLng!),
    );
  }

  Future<void> _onCameraIdle() async {
    if (_currentLatLng == null) return;

    // 검색 → placeId 기반 선택 후 바로 드래그할 경우 reverse geocode 남발 방지용
    if (_isReverseGeocoding) return;

    setState(() => _isReverseGeocoding = true);
    try {
      final loc = await _locationService.reverseGeocode(
        latitude: _currentLatLng!.latitude,
        longitude: _currentLatLng!.longitude,
        languageCode: context.locale.languageCode,
      );

      if (!mounted) return;
      _updateLocationFromBlingLocation(loc, fromUserSelection: false);
    } catch (e) {
      debugPrint('AddressMapPicker reverseGeocode error: $e');
      // 조용히 실패, 기존 주소 유지
    } finally {
      if (mounted) {
        setState(() => _isReverseGeocoding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelText = widget.labelText ?? 'location.addressSearchLabel'.tr();
    final hintText = widget.hintText ?? 'location.addressSearchHint'.tr();

    final LatLng initialCamera = _currentLatLng ??
        widget.initialCameraPosition ??
        const LatLng(-6.200000, 106.816666); // Jakarta fallback

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _suggestions = [];
                            _sessionToken = null;
                          });
                        },
                      )
                    : null),
          ),
          onChanged: _onSearchChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 6,
                  offset: Offset(0, 2),
                  color: Colors.black12,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    s.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectSuggestion(s),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialCamera,
                  zoom: _currentLatLng == null ? 13 : 16,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: widget.enableMyLocationButton,
                myLocationButtonEnabled: false, // 우리 버튼으로 대신
                zoomControlsEnabled: false,
                onCameraMove: (position) {
                  _currentLatLng = position.target;
                },
                onCameraIdle: _onCameraIdle,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
              const Center(
                child: Icon(
                  Icons.place,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              if (widget.enableMyLocationButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.black),
                      onPressed: _useMyLocation,
                    ),
                  ),
                ),
              if (_isReverseGeocoding)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'location.updatingAddress'.tr(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _labelController,
          decoration: InputDecoration(
            labelText: 'location.shortLabelLabel'.tr(),
            hintText: 'location.shortLabelHint'.tr(),
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          onChanged: (value) {
            if (_currentLocation == null) return;
            final updated = _currentLocation!.copyWith(
              shortLabel: value.isEmpty ? null : value,
            );
            _currentLocation = updated;
            widget.onChanged(updated);
          },
        ),
      ],
    );
  }
}
