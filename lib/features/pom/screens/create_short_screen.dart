// lib/features/pom/screens/create_short_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class CreateShortScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateShortScreen({super.key, required this.userModel});

  @override
  State<CreateShortScreen> createState() => _CreateShortScreenState();
}

class _CreateShortScreenState extends State<CreateShortScreen> {
  final _descriptionController = TextEditingController();
  final ShortRepository _repository = ShortRepository();
  final ImagePicker _picker = ImagePicker();

  XFile? _videoFile;
  VideoPlayerController? _videoController;
  bool _isSaving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(pickedFile.path))
        ..initialize().then((_) {
          setState(() {
            _videoFile = pickedFile;
            _videoController?.play();
            _videoController?.setLooping(true);
          });
        });
    }
  }

  Future<void> _submitShort() async {
    if (_videoFile == null || _isSaving) return;

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. 비디오를 Firebase Storage에 업로드
      final fileName = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('shorts/${user.uid}/$fileName.mp4');
      final uploadTask = ref.putFile(File(_videoFile!.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final videoUrl = await snapshot.ref.getDownloadURL();

      // 2. ShortModel 생성
      final newShort = ShortModel(
        id: '',
        userId: user.uid,
        videoUrl: videoUrl,
        title: _descriptionController.text.trim(), // You may want a separate title field
        thumbnailUrl: '', // Provide a valid thumbnail URL if available
        description: _descriptionController.text.trim(),
        location: widget.userModel.locationName ?? 'Unknown',
        createdAt: Timestamp.now(),
      );

      // 3. Firestore에 저장
      await _repository.createShort(newShort);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('POM이 등록되었습니다.'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록에 실패했습니다: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 POM 등록'), // TODO: 다국어
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _submitShort, child: Text('등록')), // TODO: 다국어
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: (_videoController != null && _videoController!.value.isInitialized)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : const Center(child: Icon(Icons.video_call_outlined, size: 60, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '영상 설명', // TODO: 다국어
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          if (_isSaving)
            Container(color: Colors.black.withValues(alpha: 0.5), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
