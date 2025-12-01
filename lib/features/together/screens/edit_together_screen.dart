// lib/features/together/screens/edit_together_screen.dart

// NOTE: Firebase Storage의 `putFile`은 `UploadTask`를 반환합니다. 앱 전체에서
// 업로드/진행률 처리를 `UploadTask`로 통일하려면 repo 전체를 수정해야 하므로
// 대대적인 작업이 필요합니다. 일단 `together` 섹션 내부에서는
// `TogetherRepository.uploadImage(File)`(현재는 URL을 반환) 형태로 사용합니다.
// 전체 통일 작업은 별도 제안(리팩터)이 필요합니다.

import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ 추가
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // 현재 위치
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택

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
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  // 업로드 상태
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  UploadTask? _uploadTask;
  bool _uploadFailed = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _locationController = TextEditingController(text: widget.post.location);
    _selectedDate = widget.post.meetTime.toDate();
    _selectedTheme = widget.post.designTheme;
    _selectedGeoPoint = widget.post.geoPoint;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _mapController?.dispose();
    super.dispose();
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
        geoPoint: _selectedGeoPoint ?? widget.post.geoPoint,
        imageUrl: imageUrl,
        maxParticipants: widget.post.maxParticipants,
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
      final newPoint = GeoPoint(position.latitude, position.longitude);
      setState(() {
        _selectedGeoPoint = newPoint;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(newPoint.latitude, newPoint.longitude),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('위치를 가져올 수 없습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  // 이미지 업로드 시작(재시도/재사용 가능)
  Future<String?> _startImageUpload(File imageFile) async {
    final repo = TogetherRepository();
    int attempt = 0;
    const maxAttempts = 3;

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
        final downloadUrl = await snapshot.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadFailed = false;
            _uploadError = null;
            _uploadTask = null;
          });
        }
        return downloadUrl;
      } catch (e) {
        debugPrint('Together upload attempt $attempt failed: $e');
        if (attempt >= maxAttempts) {
          if (mounted) {
            setState(() {
              _isUploading = false;
              _uploadFailed = true;
              _uploadError = e.toString();
              _uploadTask = null;
            });
          }
          return null;
        }
        await Future.delayed(
          Duration(milliseconds: (400 * math.pow(2, attempt - 1)).toInt()),
        );
      } finally {
        await sub?.cancel();
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
        _uploadFailed = true;
        _uploadError = 'upload_failed';
        _uploadTask = null;
      });
    }
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
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
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            _selectedTheme == theme ? Colors.blue : Colors.grey,
                      ),
                      color: _selectedTheme == theme
                          ? Color.fromRGBO(33, 150, 243, 0.1)
                          : Colors.transparent,
                    ),
                    child: Text(
                      "together.theme.$theme".tr(),
                      style: TextStyle(
                        color: _selectedTheme == theme
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "together.titleLabel".tr(),
                hintText: "together.titleHint".tr(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "together.descLabel".tr(),
                hintText: "together.descHint".tr(),
              ),
            ),
            const SizedBox(height: 16),
            Text("together.imageLabel".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (_isUploading)
                            Positioned.fill(
                              child: Container(
                                color: Color.fromRGBO(0, 0, 0, 0.4),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        value: _uploadProgress,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : (widget.post.imageUrl != null
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.post.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (_isUploading)
                                Positioned.fill(
                                  child: Container(
                                    color: Color.fromRGBO(0, 0, 0, 0.4),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            value: _uploadProgress,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '사진을 추가하려면 탭하세요',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )),
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
                    Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
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
                    label: const Text('일시중지'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.resume();
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('재개'),
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
                        });
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('취소'),
                  ),
                ],
              ),
            if (_uploadFailed && _uploadError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '업로드 실패: $_uploadError',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),

            // 위치 선택 / 현재 위치 버튼
            if (_selectedGeoPoint == null)
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[100],
                child: Center(
                  child: _isLoadingLocation
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: Text('together.setCurrentLocation'.tr()),
                        ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _selectedGeoPoint!.latitude,
                          _selectedGeoPoint!.longitude,
                        ),
                        zoom: 16,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      onCameraMove: (position) {
                        _selectedGeoPoint = GeoPoint(
                          position.target.latitude,
                          position.target.longitude,
                        );
                      },
                      gestureRecognizers: <Factory<
                          OneSequenceGestureRecognizer>>{
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
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.my_location,
                              color: Colors.black),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("선택된 위치"),
              subtitle: Text(_locationController.text),
              trailing: IconButton(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("together.whenLabel".tr()),
              subtitle: Text(
                "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} "
                "${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}",
              ),
              trailing: IconButton(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_month_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "together.whereLabel".tr(),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)
                    : Text("together.submitBtn".tr()),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Color _getThemeColor(String theme) {
    if (theme == 'neon') return const Color(0xFFCCFF00);
    if (theme == 'paper') return const Color(0xFFF5F5DC);
    return const Color(0xFF2C2C2C);
  }
}
