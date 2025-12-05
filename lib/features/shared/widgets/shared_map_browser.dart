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
            LayoutBuilder(
              builder: (context, constraints) {
                final Map<String, List<T>> groups = {};

                for (final item in items) {
                  final title = widget.titleExtractor?.call(item);
                  final gp = widget.locationExtractor(item);
                  if (gp == null) continue;
                  if (title == null || title.isEmpty) continue;
                  final key =
                      '${gp.latitude.toStringAsFixed(6)},${gp.longitude.toStringAsFixed(6)}';
                  groups.putIfAbsent(key, () => <T>[]).add(item);
                }

                return FutureBuilder<void>(
                  future: _updateMarkerScreenPositions(),
                  builder: (_, __) {
                    return Stack(
                      children: groups.values.map((groupItems) {
                        final primaryItem = groupItems.first;
                        final primaryId = widget.idExtractor(primaryItem);
                        final pos = _markerScreenPositions[MarkerId(primaryId)];
                        if (pos == null) return const SizedBox.shrink();

                        final count = groupItems.length;
                        final baseTitle =
                            widget.titleExtractor?.call(primaryItem) ?? '';
                        final displayTitle =
                            count > 1 ? '$baseTitle +${count - 1}' : baseTitle;

                        final groupDataItems = groupItems
                            .map((it) => _itemsById[widget.idExtractor(it)])
                            .whereType<T>()
                            .toList();
                        if (groupDataItems.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Positioned(
                          left: pos.dx,
                          top: pos.dy,
                          child: FractionalTranslation(
                            translation: const Offset(-0.5, -1.4),
                            child: GestureDetector(
                              onTap: () {
                                _showGroupListBottomSheet(groupDataItems,
                                    baseTitle.isEmpty ? '...' : baseTitle);
                              },
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .cardColor
                                        .withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
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
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showGroupListBottomSheet(List<T> items, String baseTitle) {
    if (items.isEmpty) return;

    final headerTitle =
        items.length > 1 ? '$baseTitle · ${items.length}' : baseTitle;

    final posts = items.map((it) {
      final id = widget.idExtractor(it);
      final title = widget.titleExtractor?.call(it) ?? '';
      final subtitle = widget.subtitleExtractor?.call(it) ?? '';
      final locationLabel = widget.locationLabelExtractor?.call(it) ?? '';
      final replyCount = widget.replyCountExtractor?.call(it) ?? 0;
      final createdAt = widget.createdAtExtractor?.call(it) ?? DateTime.now();
      return SharedMapPostSummary(
        id: id,
        title: title,
        subtitle: subtitle,
        locationLabel: locationLabel,
        replyCount: replyCount,
        createdAt: createdAt,
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: SharedMapPostListBottomSheet(
            headerTitle: headerTitle,
            posts: posts,
            onPostTap: (summary) {
              Navigator.of(ctx).pop();
              final selected = _itemsById[summary.id];
              if (selected != null) {
                _showBottomSheet(selected);
              } else {
                widget.onPostSelected?.call(summary.id);
              }
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
        setState(() {
          _markerScreenPositions
            ..clear()
            ..addAll(next);
        });
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
