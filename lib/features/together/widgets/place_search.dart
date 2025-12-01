import 'dart:async';
import 'dart:convert';

import 'package:bling_app/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

class PlaceResult {
  final double lat;
  final double lng;
  final String description;

  PlaceResult(
      {required this.lat, required this.lng, required this.description});
}

Future<PlaceResult?> showPlaceSearchDialog(BuildContext context) async {
  final TextEditingController ctrl = TextEditingController();
  final suggestions = <Map<String, String>>[]; // [{'description','place_id'}]
  Timer? debounce;

  return showDialog<PlaceResult>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('places.searchTitle'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: InputDecoration(hintText: 'places.searchHint'.tr()),
                onChanged: (v) async {
                  debounce?.cancel();
                  debounce = Timer(const Duration(milliseconds: 300), () async {
                    if (v.trim().isEmpty) return;
                    final key = ApiKeys.serverKey;
                    if (key.isEmpty || key.startsWith('[')) {
                      // no API key configured — show a message instead of silently doing nothing
                      (ctx as Element).markNeedsBuild();
                      return;
                    }
                    final url = Uri.https('maps.googleapis.com',
                        '/maps/api/place/autocomplete/json', {
                      'input': v,
                      'key': key,
                      'language': 'en',
                    });
                    try {
                      final res = await http.get(url);
                      if (res.statusCode == 200) {
                        final body =
                            json.decode(res.body) as Map<String, dynamic>;
                        final preds = body['predictions'] as List<dynamic>?;
                        suggestions.clear();
                        if (preds != null) {
                          for (final p in preds) {
                            suggestions.add({
                              'description': p['description'] as String,
                              'place_id': p['place_id'] as String,
                            });
                          }
                        }
                      }
                    } catch (_) {}
                    // rebuild dialog
                    (ctx as Element).markNeedsBuild();
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Builder(builder: (innerCtx) {
                  final key = ApiKeys.serverKey;
                  if (key.isEmpty || key.startsWith('[')) {
                    return Center(child: Text('places.missingKey'.tr()));
                  }
                  if (suggestions.isEmpty) {
                    return Center(child: Text('places.noSuggestions'.tr()));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    itemBuilder: (_, idx) {
                      final s = suggestions[idx];
                      return ListTile(
                        title: Text(s['description']!),
                        onTap: () async {
                          final placeId = s['place_id']!;
                          final key = ApiKeys.serverKey;
                          if (key.isEmpty || key.startsWith('[')) {
                            Navigator.of(context).pop();
                            return;
                          }
                          final url = Uri.https('maps.googleapis.com',
                              '/maps/api/place/details/json', {
                            'place_id': placeId,
                            'key': key,
                            'fields': 'formatted_address,geometry',
                          });
                          try {
                            final res = await http.get(url);
                            if (res.statusCode == 200) {
                              final body =
                                  json.decode(res.body) as Map<String, dynamic>;
                              final result =
                                  body['result'] as Map<String, dynamic>?;
                              if (result != null) {
                                final geom =
                                    result['geometry'] as Map<String, dynamic>?;
                                final loc =
                                    geom?['location'] as Map<String, dynamic>?;
                                final lat = (loc?['lat'] as num?)?.toDouble();
                                final lng = (loc?['lng'] as num?)?.toDouble();
                                final formatted =
                                    result['formatted_address'] as String?;
                                if (lat != null &&
                                    lng != null &&
                                    formatted != null) {
                                  Navigator.of(context).pop(PlaceResult(
                                      lat: lat,
                                      lng: lng,
                                      description: formatted));
                                  return;
                                }
                              }
                            }
                          } catch (_) {}
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                }),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('places.close'.tr())),
        ],
      );
    },
  );
}
