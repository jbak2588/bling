// lib/features/clubs/screens/create_club_post_screen.dart

import 'dart:io';
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/core/models/bling_location.dart';
import 'package:bling_app/features/shared/widgets/address_map_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateClubPostScreen extends StatefulWidget {
  final String clubId;
  const CreateClubPostScreen({super.key, required this.clubId});

  @override
  State<CreateClubPostScreen> createState() => _CreateClubPostScreenState();
}

class _CreateClubPostScreenState extends State<CreateClubPostScreen> {
  final _bodyController = TextEditingController();
  final List<XFile> _images = [];
  bool _isSaving = false;
  final ClubRepository _repository = ClubRepository();
  BlingLocation? _eventLocation;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
        imageQuality: 70, limit: 5 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  Future<void> _submitPost() async {
    if (_bodyController.text.trim().isEmpty || _isSaving) return;
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('club_posts/${widget.clubId}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final newPost = ClubPostModel(
        id: '',
        clubId: widget.clubId,
        userId: user.uid,
        body: _bodyController.text.trim(),
        imageUrls: imageUrls,
        createdAt: Timestamp.now(),
      );

      // Save via repository; ClubPostModel.toJson() already includes parentType: 'club'
      await _repository.createClubPost(widget.clubId, newPost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('clubs.createPost.success'.tr()),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'clubs.createPost.fail'.tr(namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('clubs.createPost.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _submitPost,
            icon: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : const Icon(Icons.save),
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                        hintText: 'clubs.createPost.bodyHint'.tr(),
                        border: const OutlineInputBorder()),
                    maxLines: 8,
                  ),
                  const SizedBox(height: 16),
                  AddressMapPicker(
                    initialValue: _eventLocation,
                    labelText: 'clubs.form.eventLocationLabel'.tr(),
                    hintText: 'clubs.form.eventLocationHint'.tr(),
                    onChanged: (loc) {
                      setState(() => _eventLocation = loc);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._images.map((xfile) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(File(xfile.path),
                                    width: 100, height: 100, fit: BoxFit.cover),
                              ),
                            )),
                        if (_images.length < 5)
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add_a_photo_outlined,
                                  color: Colors.grey),
                            ),
                          ),
                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black54,
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FilledButton(
            onPressed: _isSaving ? null : _submitPost,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('clubs.createPost.submit'.tr()),
          ),
        ),
      ),
    );
  }
}
