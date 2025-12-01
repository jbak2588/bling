// lib/features/together/screens/create_together_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GeoPoint? _selectedGeoPoint;
  GoogleMapController? _mapController;

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;

  // upload state
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  UploadTask? _uploadTask;
  bool _uploadFailed = false;
  String? _uploadError;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationDescController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _uploadedImageUrl = null;
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

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final locationSettings =
          LocationSettings(accuracy: LocationAccuracy.high);
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      final newPoint = GeoPoint(pos.latitude, pos.longitude);
      setState(() => _selectedGeoPoint = newPoint);
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(newPoint.latitude, newPoint.longitude),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('together.locationError'.tr())));
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

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

        // Wait for completion (success) or error
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
            Duration(milliseconds: 400 * math.pow(2, attempt - 1).toInt()));
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
    if (_selectedGeoPoint == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('together.locationError'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('together.loginRequired'.tr())));
        return;
      }

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
        geoPoint: _selectedGeoPoint,
        imageUrl: imageUrl,
        maxParticipants: 4,
        participants: [user.uid],
        qrCodeString: const Uuid().v4(),
        designTheme: _selectedTheme,
        createdAt: Timestamp.now(),
      );

      await repo.createPost(newPost);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'together.createFail'.tr(namedArgs: {'error': e.toString()}))));
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
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _selectedTheme == theme
                              ? Colors.blue
                              : Colors.grey),
                      color: _selectedTheme == theme
                          ? Color.fromRGBO(33, 150, 243, 0.1)
                          : Colors.transparent,
                    ),
                    child: Text(
                      'together.theme.$theme'.tr(),
                      style: TextStyle(
                          color: _selectedTheme == theme
                              ? Colors.blue
                              : Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'together.titleLabel'.tr(),
                  hintText: 'together.titleHint'.tr()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: 'together.descLabel'.tr(),
                  hintText: 'together.descHint'.tr()),
            ),
            const SizedBox(height: 16),
            Text('together.imageLabel'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey)),
                child: _selectedImage != null
                    ? Stack(children: [
                        Positioned.fill(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_selectedImage!,
                                    fit: BoxFit.cover))),
                        if (_isUploading)
                          Positioned.fill(
                              child: Container(
                                  color: Color.fromRGBO(0, 0, 0, 0.4),
                                  child: Center(
                                      child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                          value: _uploadProgress),
                                      const SizedBox(height: 8),
                                      Text(
                                          '${(_uploadProgress * 100).toStringAsFixed(0)}%')
                                    ],
                                  ))))
                      ])
                    : (_uploadedImageUrl != null
                        ? Stack(children: [
                            Positioned.fill(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(_uploadedImageUrl!,
                                        fit: BoxFit.cover))),
                            if (_isUploading)
                              Positioned.fill(
                                  child: Container(
                                      color: Color.fromRGBO(0, 0, 0, 0.4),
                                      child: Center(
                                          child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                              value: _uploadProgress),
                                          const SizedBox(height: 8),
                                          Text(
                                              '${(_uploadProgress * 100).toStringAsFixed(0)}%')
                                        ],
                                      ))))
                          ])
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                const Icon(Icons.add_photo_alternate,
                                    size: 40, color: Colors.grey),
                                Text('together.tapToAddPhoto'.tr(),
                                    style: const TextStyle(color: Colors.grey))
                              ])),
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
                    label: const Text('일시중지')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _uploadTask?.resume();
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('재개')),
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
                    label: const Text('취소')),
              ]),
            if (_uploadFailed && _uploadError != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('업로드 실패: $_uploadError',
                      style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 24),
            Text('together.whereLabel'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                            label: Text('together.setCurrentLocation'.tr()))),
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
            TextField(
                controller: _locationDescController,
                decoration: InputDecoration(
                    labelText: 'together.whereLabel'.tr(),
                    hintText: 'together.whereHint'.tr(),
                    prefixIcon: const Icon(Icons.location_on_outlined))),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('together.whenLabel'.tr()),
              subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} '
                  '${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}'),
              trailing: IconButton(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_month_outlined)),
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
                        : Text('together.submitBtn'.tr()))),
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
