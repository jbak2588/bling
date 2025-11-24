// lib/features/auction/screens/create_auction_screen.dart

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
// ✅ [탐색 기능] 1. AppCategories import
import 'package:bling_app/core/constants/app_categories.dart';
import 'package:bling_app/core/utils/search_helper.dart'; // [추가]

class CreateAuctionScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateAuctionScreen({super.key, required this.userModel});

  @override
  State<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startPriceController = TextEditingController();
  List<String> _tags = []; // ✅ 태그 상태 변수 추가
  String? _selectedCategory; // ✅ [탐색 기능] 2. 선택된 카테고리 상태 변수

  final List<XFile> _images = [];
  int _durationInDays = 3;
  bool _isSaving = false;
  bool _isPickingImages = false;

  final AuctionRepository _repository = AuctionRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_isPickingImages || _images.length >= 10) return;
    setState(() => _isPickingImages = true);
    try {
      final pickedFiles = await _picker.pickMultiImage(
          imageQuality: 70, limit: 10 - _images.length);
      if (pickedFiles.isNotEmpty && mounted) {
        setState(() => _images.addAll(pickedFiles));
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitAuction() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.auctions.create.errors.noPhoto)));
      return;
    }

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final fileName = Uuid().v4(); // [수정] const 제거
        final ref = FirebaseStorage.instance
            .ref()
            .child('auction_images/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final now = Timestamp.now();
      final endAt = Timestamp.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch +
              Duration(days: _durationInDays).inMilliseconds);
      final startPrice = int.tryParse(_startPriceController.text) ?? 0;

      // [추가] 검색 키워드
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _tags,
        description: _descriptionController.text,
      );

      final newAuction = AuctionModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: imageUrls,
        startPrice: startPrice,
        currentBid: startPrice,
        bidHistory: [],
        location: widget.userModel.locationName ?? t.postCard.locationNotSet,
        // V V V --- [추가] 사용자의 지역 정보를 경매 데이터에 포함시킵니다 --- V V V
        locationParts: widget.userModel.locationParts,
        // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^
        geoPoint: widget.userModel.geoPoint,
        startAt: now,
        endAt: endAt,
        ownerId: user.uid,
        category: _selectedCategory, // ✅ [탐색 기능] 3. 저장 시 category 전달
        tags: _tags, // ✅ 저장 시 태그 목록을 전달
        searchIndex: searchKeywords, // [추가]
      );

      await _repository.createAuction(newAuction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.auctions.create.success),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                t.auctions.create.fail.replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.auctions.create.title),
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _submitAuction, child: Text(t.common.done))
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(t.auctions.create.form.photoSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final xfile = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(File(xfile.path),
                                    width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_images.length < 10)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: t.auctions.create.form.title,
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? t.auctions.form.titleRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: t.auctions.create.form.description,
                      border: const OutlineInputBorder()),
                  maxLines: 5,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? t.auctions.form.descriptionRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startPriceController,
                  decoration: InputDecoration(
                      labelText: t.auctions.create.form.startPrice,
                      border: const OutlineInputBorder(),
                      prefixText: 'Rp '),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? t.auctions.form.startPriceRequired
                      : null,
                ),
                const SizedBox(height: 16),
                // ✅ [탐색 기능] 4. 카테고리 선택 드롭다운 추가
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                      labelText: t.auctions.create.form.category,
                      border: const OutlineInputBorder()),
                  hint: Text(t.auctions.create.form.categoryHint),
                  validator: (value) => (value == null || value.isEmpty)
                      ? t.auctions.form.categoryRequired
                      : null,
                  items: AppCategories.auctionCategories
                      .map((category) => DropdownMenuItem(
                            value: category.categoryId,
                            child: Text(
                                "${category.emoji} ${t[category.nameKey]}"),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
                // ✅ 상세 설명 다음, 기간 설정 전에 태그 입력 필드를 추가합니다.
                const SizedBox(height: 16),
                CustomTagInputField(
                  hintText: t.shared.tagInput.defaultHint,
                  onTagsChanged: (tags) {
                    setState(() {
                      _tags = tags;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _durationInDays,
                  decoration: InputDecoration(
                      labelText: t.auctions.create.form.duration,
                      border: const OutlineInputBorder()),
                  items: [3, 5, 7]
                      .map((days) => DropdownMenuItem(
                            value: days,
                            child: Text(t.auctions.create.form.durationOption
                                .replaceAll('{days}', days.toString())),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _durationInDays = value);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                  title: Text(t.auctions.create.form.location),
                  subtitle: Text(widget.userModel.locationName ??
                      t.postCard.locationNotSet),
                  dense: true,
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
