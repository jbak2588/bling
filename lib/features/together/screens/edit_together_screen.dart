// lib/features/together/screens/edit_together_screen.dart

// NOTE: Firebase Storage의 `putFile`은 `UploadTask`를 반환합니다. 앱 전체에서
// 업로드/진행률 처리를 `UploadTask`로 통일하려면 repo 전체를 수정해야 하므로
// 대대적인 작업이 필요합니다. 일단 `together` 섹션 내부에서는
// `TogetherRepository.uploadImage(File)`(현재는 URL을 반환) 형태로 사용합니다.
// 전체 통일 작업은 별도 제안(리팩터)이 필요합니다.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // ✅ 추가
import 'package:flutter/gestures.dart'; // ✅ 추가
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ 추가
import 'package:image_picker/image_picker.dart'; // 이미지 선택
import 'package:geolocator/geolocator.dart'; // 현재 위치
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bling_app/api_keys.dart';
import 'package:flutter_google_maps_webservices/places.dart';

class EditTogetherScreen extends StatefulWidget {
  final TogetherPostModel post;

  const EditTogetherScreen({super.key, required this.post});

  @override
  State<EditTogetherScreen> createState() => _EditTogetherScreenState();
}

class _EditTogetherScreenState extends State<EditTogetherScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  late DateTime _selectedDate;
  late String _selectedTheme;
  bool _isSubmitting = false;
  // 이미지 및 위치 선택 상태
  File? _selectedImage;
  GeoPoint? _selectedGeoPoint;
  bool _isLoadingLocation = false;
  // 업로드 상태
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  UploadTask? _uploadTask;
  bool _uploadFailed = false;
  String? _uploadError;
  String? _uploadedImageUrl;
  GoogleMapController? _mapController;
  LatLng _currentMapPosition =
      const LatLng(-6.2088, 106.8456); // default Jakarta
  // 모집 인원
  int _maxParticipants = 4;
  // Places API
  late GoogleMapsPlaces _places;

  @override
  void initState() {
    super.initState();
    // Places API 초기화
    _places = GoogleMapsPlaces(apiKey: ApiKeys.serverKey);
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _locationController = TextEditingController(text: widget.post.location);
    _selectedDate = widget.post.meetTime.toDate();
    _selectedTheme = widget.post.designTheme;
    _selectedGeoPoint = widget.post.geoPoint;
    // 초기 모집 인원 값 설정
    _maxParticipants = widget.post.maxParticipants;
    if (_selectedGeoPoint != null) {
      _currentMapPosition =
          LatLng(_selectedGeoPoint!.latitude, _selectedGeoPoint!.longitude);
    } else {
      _initUserLocation();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _mapController?.dispose();
    _places.dispose();
    super.dispose();
  }

  Future<void> _initUserLocation() async {
    try {
      final locationSettings =
          LocationSettings(accuracy: LocationAccuracy.high);
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      setState(() {
        _currentMapPosition = LatLng(position.latitude, position.longitude);
      });
      if (_mapController != null) {
        _mapController!
            .animateCamera(CameraUpdate.newLatLng(_currentMapPosition));
      }
    } catch (_) {
      // ignore - keep default
    }
  }

  void _submit() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = TogetherRepository();
      String? imageUrl = widget.post.imageUrl;

      // 새 이미지를 선택했다면 업로드(UploadTask)해서 URL을 얻음
      if (_selectedImage != null) {
        final uploaded = await _startImageUpload(_selectedImage!);
        imageUrl = uploaded;
      }

      final updatedPost = TogetherPostModel(
        id: widget.post.id,
        hostId: widget.post.hostId,
        title: _titleController.text,
        description: _descController.text,
        meetTime: Timestamp.fromDate(_selectedDate),
        location: _locationController.text,
        geoPoint: _selectedGeoPoint ??
            widget.post.geoPoint ??
            GeoPoint(
                _currentMapPosition.latitude, _currentMapPosition.longitude),
        imageUrl: imageUrl,
        maxParticipants: _maxParticipants,
        participants: widget.post.participants,
        qrCodeString: widget.post.qrCodeString,
        designTheme: _selectedTheme,
        status: widget.post.status,
        createdAt: widget.post.createdAt, // 생성일은 유지
      );

      await repo.updatePost(updatedPost);

      if (!mounted) {
        return;
      }
      Navigator.pop(context); // 수정 완료 후 닫기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'together.updateFail'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final locationSettings =
          LocationSettings(accuracy: LocationAccuracy.high);
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      setState(() {
        _selectedGeoPoint = GeoPoint(position.latitude, position.longitude);
        _currentMapPosition = LatLng(position.latitude, position.longitude);
      });
      if (_mapController != null) {
        _mapController!
            .animateCamera(CameraUpdate.newLatLng(_currentMapPosition));
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
  }

  // Places API 선택 핸들러
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
          _locationController.text = detail.result.name;
        });
      }
    } catch (e) {
      debugPrint("Place detail error: $e");
    }
  }

  // 이미지 업로드 시작(재시도/재사용 가능)
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
          debugPrint('EditTogether upload snapshotEvents error: $e');
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
        debugPrint('EditTogether upload attempt $attempt failed: $e');
        if (mounted) {
          setState(() {
            _uploadFailed = true;
            _uploadError = e.toString();
          });
        }

        // fallback synchronous upload attempt
        try {
          debugPrint(
              'EditTogether upload: attempting synchronous fallback upload (putFile)');
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
              'EditTogether synchronous fallback upload failed: $fallbackErr');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("together.editTitle".tr())), // ✅ 수정
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("together.theme".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)), // ✅ 수정
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
              decoration:
                  InputDecoration(labelText: "together.whatLabel".tr()), // ✅ 수정
              maxLength: 20,
            ),
            const SizedBox(height: 16),

            // 설명 입력 필드 (create 화면과 동일하게 노출)
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: "together.descLabel".tr(),
                hintText: "together.descHint".tr(),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 이미지 업로드 블록 (선택) - 기존 썸네일 아래 진행률 노출
            const SizedBox(height: 8),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: _uploadProgress),
                    const SizedBox(height: 6),
                    Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            // 업로드 컨트롤: 일시정지/재개/취소
            if (_isUploading)
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.pause();
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.pause),
                    label: Text('upload.pause'.tr()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.resume();
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text('upload.resume'.tr()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.cancel();
                        setState(() {
                          _isUploading = false;
                          _uploadProgress = 0.0;
                          _uploadTask = null;
                          _uploadFailed = true;
                          _uploadError = 'cancelled';
                          _uploadedImageUrl = null;
                        });
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.cancel),
                    label: Text('upload.cancel'.tr()),
                  ),
                ],
              ),

            // 업로드 실패 시 재시도 버튼
            if (!_isUploading && _uploadFailed)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _selectedImage == null
                      ? null
                      : () async {
                          final url = await _startImageUpload(_selectedImage!);
                          if (url != null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('upload.success'.tr())));
                            }
                          }
                        },
                  icon: const Icon(Icons.refresh),
                  label: Text('upload.retry'.tr()),
                ),
              ),
            if (!_isUploading && _uploadFailed && _uploadError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _uploadError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),

            // 이미지 업로드 블록 (선택)
            Text('together.imageOptional'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
                if (picked != null && mounted) {
                  setState(() => _selectedImage = File(picked.path));
                }
              },
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : (_uploadedImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_uploadedImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : (widget.post.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.post.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null)),
                ),
                child: _selectedImage == null && widget.post.imageUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate,
                              size: 36, color: Colors.grey),
                          Text('together.tapToAddPhoto'.tr(),
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            // 주소 검색창 (Autocomplete)
            LayoutBuilder(builder: (context, constraints) {
              return Autocomplete<Prediction>(
                optionsBuilder: (textEditingValue) async {
                  if (textEditingValue.text.isEmpty) return [];
                  try {
                    final res =
                        await _places.autocomplete(textEditingValue.text);
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
            const SizedBox(height: 8),

            // 지도 선택기: 중심 핀으로 위치 선택
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Stack(
                children: [
                  GoogleMap(
                    myLocationEnabled: true,
                    initialCameraPosition:
                        CameraPosition(target: _currentMapPosition, zoom: 16),
                    onMapCreated: (controller) => _mapController = controller,
                    onCameraMove: (pos) => _currentMapPosition = pos.target,
                    onCameraIdle: () {
                      setState(() {});
                    },
                    // ✅ [Fix] 제스처 우선권 설정 (스크롤 뷰 간섭 해결)
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                  ),
                  // ✅ [Fix] 핀의 '끝'이 지도 중앙에 오도록 패딩으로 위치 보정
                  // 아이콘 크기가 48이므로, 하단에 48만큼 패딩을 주어 아이콘 전체를 위로 올림
                  const Padding(
                    padding: EdgeInsets.only(bottom: 48.0),
                    child: Icon(Icons.location_pin,
                        size: 48, color: Colors.redAccent),
                  ),
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
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('together.selectedLocation'.tr()),
              subtitle: Text(
                  "${(_selectedGeoPoint != null ? _selectedGeoPoint!.latitude : _currentMapPosition.latitude).toStringAsFixed(6)}, ${(_selectedGeoPoint != null ? _selectedGeoPoint!.longitude : _currentMapPosition.longitude).toStringAsFixed(6)}"),
              trailing: _isLoadingLocation
                  ? const SizedBox(
                      width: 24, height: 24, child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: Text('together.setCurrentLocation'.tr()),
                    ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("together.whenLabel".tr()),
              subtitle: Text(
                  "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (pickedDate != null && mounted) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),
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
                icon: const Icon(Icons.save),
                label: Text("together.updateBtn".tr()),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            )
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
