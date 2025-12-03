// lib/features/together/screens/edit_together_screen.dart
// Minimal, clean EditTogetherScreen using BlingLocation and AddressMapPicker

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bling_app/core/models/bling_location.dart';
import 'package:bling_app/features/shared/widgets/address_map_picker.dart';
import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditTogetherScreen extends StatefulWidget {
  final TogetherPostModel post;
  const EditTogetherScreen({super.key, required this.post});

  @override
  State<EditTogetherScreen> createState() => _EditTogetherScreenState();
}

class _EditTogetherScreenState extends State<EditTogetherScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  DateTime _selectedDate = DateTime.now();
  String _selectedTheme = 'neon';

  File? _selectedImage;
  String? _uploadedImageUrl;
  BlingLocation? _meetLocation;

  bool _isSubmitting = false;
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
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _selectedDate = widget.post.meetTime.toDate();
    _selectedTheme = widget.post.designTheme;
    _meetLocation = widget.post.meetLocation ??
        (widget.post.geoPoint != null
            ? BlingLocation(
                geoPoint: widget.post.geoPoint!,
                mainAddress: widget.post.location)
            : null);
    _uploadedImageUrl = widget.post.imageUrl;
    _maxParticipants = widget.post.maxParticipants;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

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
    if (_meetLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('together.enterLocationDesc'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = TogetherRepository();
      String? imageUrl = _uploadedImageUrl;
      if (_selectedImage != null && imageUrl == null) {
        imageUrl = await _startImageUpload(_selectedImage!);
      }

      final updatedPost = TogetherPostModel(
        id: widget.post.id,
        hostId: widget.post.hostId,
        title: _titleController.text,
        description: _descController.text,
        meetTime: Timestamp.fromDate(_selectedDate),
        location: _meetLocation!.mainAddress,
        geoPoint: _meetLocation!.geoPoint,
        meetLocation: _meetLocation,
        imageUrl: imageUrl,
        maxParticipants: _maxParticipants,
        participants: widget.post.participants,
        qrCodeString: widget.post.qrCodeString,
        designTheme: _selectedTheme,
        status: widget.post.status,
        createdAt: widget.post.createdAt,
      );

      await repo.updatePost(updatedPost);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('together.updateFail'.tr())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('together.editTitle'.tr())),
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

            // Map section
            Text('together.whereLabel'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            AddressMapPicker(
              initialValue: _meetLocation,
              onChanged: (loc) {
                setState(() => _meetLocation = loc);
              },
              labelText: 'together.selectedLocation'.tr(),
              hintText: 'together.mapHint'.tr(),
            ),
            const SizedBox(height: 8),
            if (_meetLocation != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('together.selectedLocation'.tr()),
                subtitle: Text(_meetLocation!.shortLabel?.isNotEmpty == true
                    ? '${_meetLocation!.mainAddress}\n(${_meetLocation!.shortLabel})'
                    : _meetLocation!.mainAddress),
              ),

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
                      : (_uploadedImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_uploadedImageUrl!),
                              fit: BoxFit.cover)
                          : null),
                ),
                child: (_selectedImage == null && _uploadedImageUrl == null)
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
            // max participants
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
                    label: Text('together.updateBtn'.tr()),
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
