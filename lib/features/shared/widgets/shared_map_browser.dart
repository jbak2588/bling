import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/features/shared/widgets/shared_map_post_list_bottom_sheet.dart';

/// 지도에 마커를 표시하고, 동일 좌표의 마커들을 그룹으로 묶어
/// 그룹 클릭 시 리스트 바텀시트를 보여주는 재사용 가능한 위젯입니다.
class SharedMapBrowser<T> extends StatefulWidget {
  final Stream<List<T>> dataStream;
  final GeoPoint? Function(T) locationExtractor;
  final String Function(T) idExtractor;
  final String? Function(T)? titleExtractor;
  final String? Function(T)? subtitleExtractor;
  final String? Function(T)? locationLabelExtractor;

  /// [옵션] 리스트 바텀시트에 표시할 썸네일 이미지 URL 추출 함수.
  final String? Function(T)? thumbnailUrlExtractor;

  /// [옵션] 리스트 바텀시트/리스트 아이템에 사용할 카테고리 아이콘 추출 함수.
  final Widget? Function(T)? categoryIconExtractor;
  final int Function(T)? replyCountExtractor;
  final DateTime? Function(T)? createdAtExtractor;
  final void Function(String id)? onPostSelected;
  final Widget Function(BuildContext, T) cardBuilder;
  final CameraPosition? initialCameraPosition;
  final BitmapDescriptor? customMarkerIcon;

  const SharedMapBrowser({
    super.key,
    required this.dataStream,
    required this.locationExtractor,
    required this.idExtractor,
    this.titleExtractor,
    this.subtitleExtractor,
    this.locationLabelExtractor,
    this.thumbnailUrlExtractor,
    this.categoryIconExtractor,
    this.replyCountExtractor,
    this.createdAtExtractor,
    this.onPostSelected,
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
  final Map<MarkerId, Offset> _markerScreenPositions = {};
  Set<String> _lastItemIds = <String>{};
  final Set<String> _loggedMarkerIds = <String>{};

  final Map<String, T> _itemsById = <String, T>{};
  final Map<String, T> _markerItemMap = {};

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

        _itemsById.clear();
        for (final item in items) {
          _itemsById[widget.idExtractor(item)] = item;
        }

        final newIds = items.map(widget.idExtractor).toSet();
        final shouldRebuildMarkers = !setEquals(newIds, _lastItemIds);

        if (shouldRebuildMarkers) {
          _lastItemIds = newIds;
          _loggedMarkerIds.removeWhere((id) => !newIds.contains(id));

          _markerItemMap.clear();
          _markers = items
              .map((item) {
                final geoPoint = widget.locationExtractor(item);
                if (geoPoint == null) return null;

                final markerId = widget.idExtractor(item);
                final title = widget.titleExtractor?.call(item);

                final marker = Marker(
                  markerId: MarkerId(markerId),
                  position: LatLng(geoPoint.latitude, geoPoint.longitude),
                  icon:
                      widget.customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                  infoWindow: title != null
                      ? InfoWindow(title: title)
                      : InfoWindow.noText,
                  onTap: () => _showBottomSheet(item),
                );

                _markerItemMap[markerId] = item;

                return marker;
              })
              .whereType<Marker>()
              .toSet();

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await _updateMarkerScreenPositions();
            } catch (_) {}
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await _updateMarkerScreenPositions();
          } catch (_) {}
        });

        if (_markers.length != _lastMarkerCount) {
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
              } catch (_) {}
            });
          }
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: widget.initialCameraPosition ??
                  const CameraPosition(
                    target: LatLng(-6.2088, 106.8456),
                    zoom: 13,
                  ),
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                  // Ensure we attempt to compute marker screen positions once
                  // the map controller becomes available. This fixes a race
                  // where markers are created before the controller is
                  // ready (e.g. when opening a sub-category tab first),
                  // causing overlay tooltips to never be shown.
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    try {
                      // [수정] 맵 재진입 시 렌더링 지연으로 인한 툴팁 누락 방지를 위해 딜레이 추가
                      await Future.delayed(const Duration(milliseconds: 350));
                      await _updateMarkerScreenPositions();
                    } catch (_) {}
                  });
                }
              },
              onCameraIdle: () async {
                try {
                  await _updateMarkerScreenPositions();
                } catch (_) {}
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
            // [수정] 동일 좌표의 마커를 하나의 그룹으로 묶어
            // "첫 번째 제목 +9" 형식의 툴팁을 지도 위에 보여주고,
            // 툴팁을 탭하면 리스트 바텀시트를 띄웁니다.
            LayoutBuilder(
              builder: (context, constraints) {
                // key: "lat,lng" (소수점 6자리 기준) -> 해당 좌표의 마커 목록
                final Map<String, List<Marker>> groups =
                    <String, List<Marker>>{};

                for (final m in _markers.where(
                  (m) =>
                      m.infoWindow.title != null &&
                      m.infoWindow.title!.isNotEmpty,
                )) {
                  final key =
                      '${m.position.latitude.toStringAsFixed(6)},${m.position.longitude.toStringAsFixed(6)}';
                  groups.putIfAbsent(key, () => <Marker>[]).add(m);
                }

                if (groups.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Stack(
                  children: groups.values.map((group) {
                    final primary = group.first;
                    final screenPos = _markerScreenPositions[primary.markerId];
                    if (screenPos == null) {
                      return const SizedBox.shrink();
                    }

                    final count = group.length;
                    final baseTitle = primary.infoWindow.title ?? '';
                    final displayTitle =
                        count > 1 ? '$baseTitle +${count - 1}' : baseTitle;

                    // 마커 ID에서 실제 아이템 리스트 복구
                    final List<T> groupItems = group
                        .map((m) => _itemsById[m.markerId.value])
                        .whereType<T>()
                        .toList();
                    if (groupItems.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // 마커 기준으로 살짝 위쪽/가운데에 떠 있도록 위치 보정
                    return Positioned(
                      left: screenPos.dx,
                      top: screenPos.dy,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -1.4),
                        child: GestureDetector(
                          onTap: () {
                            _showGroupListBottomSheet(
                              groupItems,
                              baseTitle.isEmpty ? '...' : baseTitle,
                            );
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                // 살짝 투명한 카드 배경 + 매우 약한 그림자만 적용
                                color: Theme.of(context)
                                    .cardColor
                                    .withAlpha((0.92 * 255).round()),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withAlpha((0.08 * 255).round()),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// 동일 좌표 그룹을 리스트 바텀시트로 보여주는 헬퍼
  void _showGroupListBottomSheet(List<T> items, String baseTitle) {
    if (items.isEmpty) return;

    // If the group only contains a single item, skip the list bottom sheet
    // and open the detail directly for smoother UX.
    if (items.length == 1) {
      _showBottomSheet(items.first);
      return;
    }

    final headerTitle =
        items.length > 1 ? '$baseTitle · ${items.length}' : baseTitle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: SharedMapPostListBottomSheet<T>(
            headerTitle: headerTitle,
            items: items,
            titleBuilder: (item) => widget.titleExtractor?.call(item) ?? '',
            subtitleBuilder: widget.subtitleExtractor,
            locationLabelBuilder: widget.locationLabelExtractor,
            thumbnailUrlBuilder: widget.thumbnailUrlExtractor,
            categoryIconBuilder: widget.categoryIconExtractor,
            onItemTap: (item) {
              Navigator.of(ctx).pop();
              _showBottomSheet(item);
            },
          ),
        );
      },
    );
  }

  Future<void> _updateMarkerScreenPositions() async {
    try {
      if (!_controller.isCompleted) return;
      final ctrl = await _controller.future;
      final Map<MarkerId, Offset> next = {};
      final dpr = MediaQuery.of(context).devicePixelRatio;
      for (final m in _markers) {
        try {
          final sc = await ctrl.getScreenCoordinate(m.position);
          final logicalX = sc.x.toDouble() / dpr;
          final logicalY = sc.y.toDouble() / dpr;
          next[m.markerId] = Offset(logicalX, logicalY);
        } catch (_) {}
      }
      if (mounted) {
        // Don't immediately clear existing positions when the newly
        // computed `next` map is empty. This can happen transiently
        // during stream/tab changes or when the map controller cannot
        // provide coordinates yet. Preserving previous positions avoids
        // a brief disappearance of overlay tooltips/labels.
        if (next.isNotEmpty || _markerScreenPositions.isEmpty) {
          setState(() {
            _markerScreenPositions
              ..clear()
              ..addAll(next);
          });
        }
        // If `next` is empty but we already have positions, keep them
        // until a real update with positions occurs.
      }
    } catch (_) {}
  }

  void _showBottomSheet(T item) {
    final draggableController = DraggableScrollableController();
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

    Future.delayed(const Duration(milliseconds: 120), () {
      try {
        final ctx = contentKey.currentContext;
        if (ctx == null) return;
        final renderBox = ctx.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final contentHeight = renderBox.size.height + 32.0;
        final screenHeight = MediaQuery.of(context).size.height;
        var targetFraction = (contentHeight / screenHeight).clamp(0.2, 0.85);
        if (targetFraction < 0.4) targetFraction = 0.4;
        try {
          draggableController.animateTo(targetFraction,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        } catch (_) {}
      } catch (e) {
        if (kDebugMode) debugPrint('[SharedMapBrowser] measure error: $e');
      }
    });
  }
}
