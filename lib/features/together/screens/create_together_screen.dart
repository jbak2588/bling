// lib/features/together/screens/create_together_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bling_app/api_keys.dart'; // ✅ API Key 추가
import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // ✅ 추가
import 'package:flutter/gestures.dart'; // ✅ 추가
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart'; // ✅ Places API 추가
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // ✅ 지도 추가
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateTogetherScreen extends StatefulWidget {
  const CreateTogetherScreen({super.key});

  @override
  State<CreateTogetherScreen> createState() => _CreateTogetherScreenState();
}

class _CreateTogetherScreenState extends State<CreateTogetherScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationDescController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  String _selectedTheme = 'neon';

  File? _selectedImage;
  String? _uploadedImageUrl;

  // ✅ 지도 및 검색 관련 상태
  GoogleMapController? _mapController;
  LatLng _currentMapPosition = const LatLng(-6.2088, 106.8456); // 자카르타 기본값
  late GoogleMapsPlaces _places; // Places API 객체

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  int _maxParticipants = 4;

  // upload state
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  UploadTask? _uploadTask;
  bool _uploadFailed = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    // ✅ Places API 초기화
    _places = GoogleMapsPlaces(apiKey: ApiKeys.serverKey);
    _initUserLocation(); // ✅ 지도 초기 위치 설정
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationDescController.dispose();
    _mapController?.dispose(); // ✅ 맵 컨트롤러 해제
    _places.dispose(); // ✅ Places 해제
    super.dispose();
  }

  // ✅ 초기 지도 위치 설정 (Geolocator 사용)
  Future<void> _initUserLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentMapPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        // 지도가 로드된 상태라면 카메라 이동
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentMapPosition),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // ✅ 주소 검색 선택 핸들러
  Future<void> _onPlaceSelected(Prediction prediction) async {
    if (prediction.placeId == null) return;

    try {
      final detail = await _places.getDetailsByPlaceId(prediction.placeId!);
      final lat = detail.result.geometry?.location.lat;
      final lng = detail.result.geometry?.location.lng;

      if (lat != null && lng != null) {
        final newPos = LatLng(lat, lng);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 17));
        setState(() {
          _currentMapPosition = newPos;
          // 장소 설명 자동 입력 (사용자가 수정 가능)
          _locationDescController.text = detail.result.name;
        });
      }
    } catch (e) {
      debugPrint("Place detail error: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // Upload with exponential backoff retry.
  Future<String?> _startImageUpload(File imageFile) async {
    final repo = TogetherRepository();
    const int maxAttempts = 5;
    int attempt = 0;
    const int baseDelayMs = 500;

    if (!mounted) return null;
    setState(() {
      _isUploading = true;
      _uploadFailed = false;
      _uploadError = null;
      _uploadProgress = 0.0;
    });

    while (attempt < maxAttempts) {
      attempt += 1;
      StreamSubscription<TaskSnapshot>? sub;
      try {
        _uploadTask = repo.uploadImageAsTask(imageFile);

        final completer = Completer<TaskSnapshot>();

        sub = _uploadTask!.snapshotEvents.listen((snapshot) {
          final total = snapshot.totalBytes;
          final transferred = snapshot.bytesTransferred;
          if (total > 0 && mounted) {
            setState(() => _uploadProgress = transferred / total);
          }
          if (snapshot.state == TaskState.success) {
            if (!completer.isCompleted) completer.complete(snapshot);
          }
        }, onError: (e) {
          debugPrint('Together upload snapshotEvents error: $e');
          if (!completer.isCompleted) completer.completeError(e);
        });

        final snapshot = await completer.future;
        final url = await snapshot.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadTask = null;
            _uploadFailed = false;
            _uploadError = null;
            _uploadProgress = 0.0;
            _uploadedImageUrl = url;
          });
        }
        await sub.cancel();
        return url;
      } catch (e) {
        debugPrint('Together upload attempt $attempt failed: $e');
        if (mounted) {
          setState(() {
            _uploadFailed = true;
            _uploadError = e.toString();
          });
        }

        // Try synchronous fallback
        try {
          debugPrint('Together upload: attempting synchronous fallback upload');
          final url = await repo.uploadImage(imageFile);
          if (mounted) {
            setState(() {
              _isUploading = false;
              _uploadTask = null;
              _uploadFailed = false;
              _uploadError = null;
              _uploadProgress = 0.0;
              _uploadedImageUrl = url;
            });
          }
          return url;
        } catch (fallbackErr) {
          debugPrint(
              'Together synchronous fallback upload failed: $fallbackErr');
        }

        if (attempt >= maxAttempts) break;
        final delayMs = (baseDelayMs * math.pow(2, attempt - 1)).toInt();
        await Future.delayed(Duration(milliseconds: delayMs));
      } finally {
        try {
          await sub?.cancel();
        } catch (_) {}
        if (mounted) setState(() => _uploadTask = null);
      }
    }

    if (mounted) setState(() => _isUploading = false);
    return null;
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('together.enterTitle'.tr())));
      return;
    }
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('together.enterDesc'.tr())));
      return;
    }
    if (_locationDescController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('together.enterLocationDesc'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final repo = TogetherRepository();
      String? imageUrl = _uploadedImageUrl;
      if (_selectedImage != null && imageUrl == null) {
        imageUrl = await _startImageUpload(_selectedImage!);
      }

      final newPost = TogetherPostModel(
        id: const Uuid().v4(),
        hostId: user.uid,
        title: _titleController.text,
        description: _descController.text,
        meetTime: Timestamp.fromDate(_selectedDate),
        location: _locationDescController.text,
        // ✅ 최종 선택된 핀 위치(중심점)를 GeoPoint로 저장
        geoPoint: GeoPoint(
            _currentMapPosition.latitude, _currentMapPosition.longitude),
        imageUrl: imageUrl,
        maxParticipants: _maxParticipants,
        participants: [user.uid],
        qrCodeString: const Uuid().v4(),
        designTheme: _selectedTheme,
        createdAt: Timestamp.now(),
      );

      await repo.createPost(newPost);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('together.createFail'.tr())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('together.createTitle'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('together.theme'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: ['neon', 'paper', 'dark'].map((theme) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedTheme = theme),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _getThemeColor(theme),
                      border: _selectedTheme == theme
                          ? Border.all(color: Colors.blue, width: 3)
                          : Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'together.whatLabel'.tr(),
                  hintText: 'together.whatHint'.tr()),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                  labelText: 'together.descLabel'.tr(),
                  hintText: 'together.descHint'.tr(),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // ✅ [지도 섹션 시작]
            Text('together.whereLabel'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // 1. 주소 검색창 (Autocomplete)
            LayoutBuilder(builder: (context, constraints) {
              return Autocomplete<Prediction>(
                optionsBuilder: (textEditingValue) async {
                  if (textEditingValue.text.isEmpty) return [];
                  try {
                    final res =
                        await _places.autocomplete(textEditingValue.text);

                    // ✅ [Debug] 로그 출력 (이 로그를 확인해야 함)
                    debugPrint("Places API Status: ${res.status}");
                    if (res.errorMessage != null) {
                      debugPrint("Places API Error: ${res.errorMessage}");
                    }

                    if (res.isOkay) {
                      return res.predictions;
                    } else {
                      return [];
                    }
                  } catch (e) {
                    debugPrint("Places API Exception: $e");
                    return [];
                  }
                },
                displayStringForOption: (option) => option.description ?? '',
                onSelected: _onPlaceSelected,
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted: (_) => onSubmitted(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'together.searchHint'.tr(),
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(option.description ?? ''),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 12),

            // 2. 지도 위젯 (핀 이동 및 제스처 처리)
            Container(
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _isLoadingLocation
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentMapPosition,
                              zoom: 15,
                            ),
                            onMapCreated: (controller) =>
                                _mapController = controller,
                            onCameraMove: (position) {
                              // 지도를 움직이면 중심 좌표 변수에 저장
                              _currentMapPosition = position.target;
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            // ✅ [Fix] 제스처 우선권 설정 (스크롤 뷰 간섭 해결)
                            gestureRecognizers: <Factory<
                                OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                          ),
                    // ✅ [Fix] 핀 위치 보정 (Padding으로 핀 끝을 중앙에 맞춤)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child:
                          Icon(Icons.location_on, size: 40, color: Colors.red),
                    ),
                    // 안내 문구
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'together.mapHint'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationDescController,
              decoration: InputDecoration(
                  labelText: 'together.whereHint'.tr(),
                  prefixIcon: const Icon(Icons.location_on_outlined)),
            ),
            const SizedBox(height: 8),
            // 선택된 위치 표시 및 현재 위치 버튼
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('together.selectedLocation'.tr()),
              subtitle: Text(
                  "${_currentMapPosition.latitude.toStringAsFixed(6)}, ${_currentMapPosition.longitude.toStringAsFixed(6)}"),
              trailing: _isLoadingLocation
                  ? const SizedBox(
                      width: 24, height: 24, child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: () async {
                        // 현재 위치로 설정
                        setState(() => _isLoadingLocation = true);
                        try {
                          final pos = await Geolocator.getCurrentPosition(
                              locationSettings: const LocationSettings(
                                  accuracy: LocationAccuracy.high));
                          setState(() {
                            _currentMapPosition =
                                LatLng(pos.latitude, pos.longitude);
                          });
                          if (_mapController != null) {
                            _mapController!.animateCamera(
                                CameraUpdate.newLatLng(_currentMapPosition));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('together.locationFetchError'
                                    .tr(namedArgs: {'error': e.toString()}))));
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoadingLocation = false);
                          }
                        }
                      },
                      icon: const Icon(Icons.my_location),
                      label: Text('together.setCurrentLocation'.tr()),
                    ),
            ),
            // ✅ [지도 섹션 끝]

            const SizedBox(height: 16),

            // Time selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('together.whenLabel'.tr()),
              subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)));
                if (pickedDate != null && mounted) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate));
                  if (pickedTime != null) {
                    setState(() => _selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute));
                  }
                }
              },
            ),

            const SizedBox(height: 24),
            Text('together.imageOptional'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            const Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey),
                            Text('together.tapToAddPhoto'.tr(),
                                style: const TextStyle(color: Colors.grey))
                          ])
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 6),
                      Text('${(_uploadProgress * 100).toStringAsFixed(0)}%')
                    ]),
              ),
            if (_isUploading)
              Row(children: [
                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.pause();
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.pause),
                    label: Text('upload.pause'.tr())),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.resume();
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text('upload.resume'.tr())),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.cancel();
                        if (mounted) {
                          setState(() {
                            _isUploading = false;
                            _uploadProgress = 0.0;
                            _uploadTask = null;
                            _uploadFailed = true;
                            _uploadError = 'upload.cancelled';
                          });
                        }
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.cancel),
                    label: Text('upload.cancel'.tr())),
              ]),
            (!_isUploading && _uploadFailed)
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _selectedImage == null
                              ? null
                              : () async {
                                  final url =
                                      await _startImageUpload(_selectedImage!);
                                  if (url != null && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('upload.success'.tr()),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.refresh),
                          label: Text('upload.retry'.tr()),
                        ),
                        if (_uploadError != null) const SizedBox(height: 8),
                        if (_uploadError != null)
                          Text(
                            _uploadError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),

            const SizedBox(height: 24),
            // ✅ 모집 인원 슬라이더
            Text(
              'together.maxParticipants'
                  .tr(namedArgs: {'count': '$_maxParticipants'}),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _maxParticipants.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              label: "$_maxParticipants명",
              onChanged: (val) {
                setState(() {
                  _maxParticipants = val.round();
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: const Icon(Icons.check),
                    label: Text('together.submitBtn'.tr()),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)))),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor(String theme) {
    if (theme == 'neon') return const Color(0xFFCCFF00);
    if (theme == 'paper') return const Color(0xFFF5F5DC);
    return const Color(0xFF2C2C2C);
  }
}
