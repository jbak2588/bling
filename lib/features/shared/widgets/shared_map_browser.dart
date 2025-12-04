import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart'; // [추가] 제스처 인식을 위해 필요
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

/// [공용 위젯] 데이터 스트림을 받아 지도 위에 마커를 표시하고,
/// 클릭 시 상세 정보를 BottomSheet로 보여주는 지도 브라우저입니다.
class SharedMapBrowser<T> extends StatefulWidget {
  /// 표시할 데이터 리스트 스트림 (예: 상점 목록, 매물 목록)
  final Stream<List<T>> dataStream;

  /// 각 아이템(T)에서 좌표(GeoPoint)를 추출하는 함수
  final GeoPoint? Function(T) locationExtractor;

  /// 각 아이템(T)의 고유 ID를 추출하는 함수 (마커 ID용)
  final String Function(T) idExtractor;

  /// [추가] (선택) 핀 위에 표시할 제목(툴팁) 추출 함수.
  /// 이 값이 제공되면 핀 클릭 시 툴팁이 먼저 뜨고, 툴팁 클릭 시 카드가 뜹니다.
  final String? Function(T)? titleExtractor;

  /// 마커 클릭 시 보여줄 상세 정보 카드 빌더
  final Widget Function(BuildContext, T) cardBuilder;

  /// (선택) 초기 카메라 위치 (없으면 기본값 사용)
  final CameraPosition? initialCameraPosition;

  /// (선택) 커스텀 마커 아이콘 (없으면 기본 핀 사용)
  final BitmapDescriptor? customMarkerIcon;

  const SharedMapBrowser({
    super.key,
    required this.dataStream,
    required this.locationExtractor,
    required this.idExtractor,
    this.titleExtractor, // [추가]
    required this.cardBuilder,
    this.initialCameraPosition,
    this.customMarkerIcon,
  });

  @override
  State<SharedMapBrowser> createState() => _SharedMapBrowserState<T>();
}

class _SharedMapBrowserState<T> extends State<SharedMapBrowser<T>> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  int _lastMarkerCount = 0;
  // 마커의 화면 좌표(픽셀) 캐시: MarkerId -> Offset
  final Map<MarkerId, Offset> _markerScreenPositions = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: widget.dataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('common.error'.tr()));
        }

        final items = snapshot.data ?? [];
        // Debug: log how many items arrived and first few geoPoints to help
        // diagnose maps-without-pins issues (non-invasive, no behavior change).
        if (kDebugMode) {
          debugPrint('[SharedMapBrowser] received ${items.length} items');
          for (var i = 0; i < items.length && i < 5; i++) {
            final gp = widget.locationExtractor(items[i]);
            debugPrint('[SharedMapBrowser] item[$i] geoPoint=$gp');
          }
        }

        if (items.isEmpty) {
          // 데이터가 없을 때도 지도는 보여주되 마커만 없음
          // (혹은 빈 화면 메시지를 보여줄 수도 있음)
        }

        // 마커 생성
        _markers = items
            .map((item) {
              final geoPoint = widget.locationExtractor(item);
              if (geoPoint == null) return null;

              final markerId = widget.idExtractor(item);
              final title = widget.titleExtractor?.call(item);

              final marker = Marker(
                markerId: MarkerId(markerId),
                position: LatLng(geoPoint.latitude, geoPoint.longitude),
                icon: widget.customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                // InfoWindow은 제목만 표시하도록 하고,
                // 마커 탭(onTap)에서 바로 바텀시트를 엽니다.
                infoWindow: title != null
                    ? InfoWindow(title: title)
                    : InfoWindow.noText,
                onTap: () => _showBottomSheet(item),
              );

              if (kDebugMode) {
                debugPrint('[SharedMapBrowser] created marker id=$markerId'
                    ' pos=(${geoPoint.latitude}, ${geoPoint.longitude})');
              }

              return marker;
            })
            .whereType<Marker>()
            .toSet();

        // 초기 렌더 때는 모든 마커의 툴팁을 자동으로 표시합니다.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAllInfoWindows();
        });

        // 디버그 모드에서만 마커가 갱신될 때 카메라를 마커 범위로 이동
        if (kDebugMode && _markers.length != _lastMarkerCount) {
          _lastMarkerCount = _markers.length;
          if (_markers.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                if (_controller.isCompleted) {
                  final controller = await _controller.future;
                  if (_markers.length == 1) {
                    final only = _markers.first.position;
                    await controller.animateCamera(
                      CameraUpdate.newLatLngZoom(only, 15),
                    );
                  } else {
                    // 여러 마커의 bounds 계산
                    double? minLat, maxLat, minLng, maxLng;
                    for (final m in _markers) {
                      final lat = m.position.latitude;
                      final lng = m.position.longitude;
                      minLat = (minLat == null)
                          ? lat
                          : (lat < minLat ? lat : minLat);
                      maxLat = (maxLat == null)
                          ? lat
                          : (lat > maxLat ? lat : maxLat);
                      minLng = (minLng == null)
                          ? lng
                          : (lng < minLng ? lng : minLng);
                      maxLng = (maxLng == null)
                          ? lng
                          : (lng > maxLng ? lng : maxLng);
                    }
                    if (minLat != null &&
                        minLng != null &&
                        maxLat != null &&
                        maxLng != null) {
                      final southWest = LatLng(minLat, minLng);
                      final northEast = LatLng(maxLat, maxLng);
                      final bounds = LatLngBounds(
                          southwest: southWest, northeast: northEast);
                      await controller.animateCamera(
                          CameraUpdate.newLatLngBounds(bounds, 64));
                    }
                  }
                }
              } catch (e, st) {
                debugPrint('[SharedMapBrowser] fit-bounds failed: $e\n$st');
              }
            });
          }
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: widget.initialCameraPosition ??
                  const CameraPosition(
                    target: LatLng(-6.2088, 106.8456), // 자카르타 기본값
                    zoom: 13,
                  ),
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              // 카메라 이동이 멈추면 마커의 화면 좌표를 갱신합니다 (오버레이 툴팁 위치).
              onCameraIdle: () async {
                // best-effort: 업데이트 실패해도 무시
                try {
                  await _updateMarkerScreenPositions();
                } catch (_) {}
              },
              // (참고) 이전에 onCameraIdle로 보이는 마커만 필터하던 로직이 있었음.
              // 현재는 모든 마커의 InfoWindow를 자동으로 보이게 유지합니다.
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              // [추가] 스크롤 뷰 내부에서도 지도가 제스처를 우선적으로 처리하도록 설정
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),

            // [수정] 오버레이: 모든 마커의 제목(툴팁)을 항상 표시
            // 터치 차단을 피하기 위해 IgnorePointer로 래핑합니다.
            IgnorePointer(
              child: Stack(
                children: _markers
                    .where((m) =>
                        // [수정] infoWindow.title이 있기만 하면 무조건 표시 (클릭 여부 무관)
                        m.infoWindow.title != null &&
                        m.infoWindow.title!.isNotEmpty)
                    .map((m) {
                  final pos = _markerScreenPositions[m.markerId];
                  if (pos == null) return const SizedBox.shrink();
                  // 오버레이 위젯을 마커 핀 위쪽에 표시 (조정값은 필요 시 튜닝)
                  return Positioned(
                    left: pos.dx - 60,
                    top: pos.dy - 70,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withAlpha(243),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        // [추가] 텍스트 오버플로우 처리: 길면 1줄로 줄이고 말줄임표 표시
                        child: Text(
                          m.infoWindow.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, // 폰트 살짝 줄여서 공간 확보
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // 마커의 LatLng를 화면 좌표로 변환하여 캐시에 저장합니다.
  Future<void> _updateMarkerScreenPositions() async {
    try {
      if (!_controller.isCompleted) return;
      final ctrl = await _controller.future;
      final Map<MarkerId, Offset> next = {};
      for (final m in _markers) {
        try {
          final sc = await ctrl.getScreenCoordinate(m.position);
          next[m.markerId] = Offset(sc.x.toDouble(), sc.y.toDouble());
        } catch (_) {
          // ignore individual failures
        }
      }
      // 상태 업데이트
      if (mounted) {
        setState(() {
          _markerScreenPositions
            ..clear()
            ..addAll(next);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SharedMapBrowser] updateScreenPos error: $e');
      }
    }
  }

  // Try to show InfoWindow for all markers (best-effort). Safe to call
  // repeatedly; errors are caught and ignored. Useful for initial UX where
  // tooltips should be visible without extra taps.
  Future<void> _showAllInfoWindows() async {
    try {
      if (!_controller.isCompleted) return;
      final ctrl = await _controller.future;
      for (final m in _markers) {
        try {
          await ctrl.showMarkerInfoWindow(m.markerId);
        } catch (_) {
          // ignore individual failures
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SharedMapBrowser] showInfo error: $e');
      }
    }
  }

  // 바텀시트 표시 로직 분리
  void _showBottomSheet(T item) {
    // Create a controller to allow programmatic resizing of the draggable sheet.
    final draggableController = DraggableScrollableController();
    // Key to measure the rendered card height.
    final contentKey = GlobalKey();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        controller: draggableController,
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.95,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                children: [
                  // Wrap card in a Container with a GlobalKey so we can measure its height
                  Container(
                    key: contentKey,
                    color: Theme.of(context).cardColor,
                    child: widget.cardBuilder(context, item),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: SafeArea(
                      child: Material(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black45
                            : Colors.black26,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: Colors.blue.shade800,
                            width: 0.8,
                          ),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(Icons.close,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // After the bottom sheet renders, measure the content and expand the sheet
    // so that the card fits (or up to maxChildSize). We delay slightly to allow
    // asynchronous inner loads (images/streambuilders) to settle.
    Future.delayed(const Duration(milliseconds: 120), () {
      try {
        final ctx = contentKey.currentContext;
        if (ctx == null) return;
        final renderBox = ctx.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final contentHeight = renderBox.size.height + 32.0; // include paddings
        final screenHeight = MediaQuery.of(context).size.height;
        var targetFraction = (contentHeight / screenHeight).clamp(0.2, 0.85);

        // If content is small, ensure at least initialChildSize
        if (targetFraction < 0.4) targetFraction = 0.4;

        // Animate sheet to the computed fraction (best-effort)
        try {
          draggableController.animateTo(targetFraction,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        } catch (_) {
          // if controller is not attached yet, ignore — sheet stays at initial size
        }
      } catch (e) {
        // ignore measurement errors — sheet will remain at initial size
        if (kDebugMode) debugPrint('[SharedMapBrowser] measure error: $e');
      }
    });
  }
}
