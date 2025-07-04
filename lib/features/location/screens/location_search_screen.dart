// lib/features/location/presentation/screens/location_search_screen.dart

import 'package:bling_app/api_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter_google_maps_webservices/places.dart';



class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: ApiKeys.googleApiKey);
  List<Prediction> _predictions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.trim().length < 2) {
      if (_predictions.isNotEmpty) {
        setState(() {
          _predictions = [];
        });
      }
      return;
    }
    try {
      final response = await _places.autocomplete(
        value,
        language: context.locale.languageCode,
        components: [Component(Component.country, 'id')], // 검색 결과를 인도네시아로 제한
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.isOkay
                  ? 'API 응답 성공: ${response.predictions.length}개의 예측 결과 받음'
                  : '!!! API 응답 에러: ${response.errorMessage}',
            ),
          ),
        );
      }

      if (response.isOkay) {
        // print('API 응답 성공: ${response.predictions.length}개의 예측 결과 받음');
        setState(() {
          _predictions = response.predictions;
        });
      } else {
        // print('!!! API 응답 에러: ${response.errorMessage}');
        setState(() {
          _predictions = [];
        });
      }
    } catch (e) {
      // print('!!! API 통신 실패: $e');
      // setState(() {
      //   _predictions = [];
      // });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('!!! API 통신 실패: $e')),
        );
        setState(() {
          _predictions = [];
        });
      }

    }
  }

  Future<void> _onPlaceSelected(Prediction prediction) async {
    if (prediction.placeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await _places.getDetailsByPlaceId(prediction.placeId!);
      if (detail.isOkay && detail.result.geometry != null) {
        final location = detail.result.geometry!.location;
        final address = prediction.description ?? '';

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'location': address,
          'latitude': location.lat,
          'longitude': location.lng,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('location_setting_success'.tr())));
          Navigator.of(context).pop(address);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('location_setting_error'.tr(args: [e.toString()]))));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('location_setting_title'.tr()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'location_setting_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(prediction.description ?? ''),
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
