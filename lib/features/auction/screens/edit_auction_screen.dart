// lib/features/auction/screens/edit_auction_screen.dart

import 'dart:io';
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:bling_app/core/constants/app_categories.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/core/utils/search_helper.dart'; // [추가]

class EditAuctionScreen extends StatefulWidget {
  final AuctionModel auction;
  const EditAuctionScreen({super.key, required this.auction});

  @override
  State<EditAuctionScreen> createState() => _EditAuctionScreenState();
}

class _EditAuctionScreenState extends State<EditAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  List<dynamic> _images = []; // 기존 URL(String)과 새로운 파일(XFile)을 모두 담기 위함
  bool _isSaving = false;
  String? _selectedCategory; // ✅ 카테고리 선택 상태
  List<String> _tags = [];

  final AuctionRepository _repository = AuctionRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 기존 경매 정보로 UI 상태를 초기화합니다.
    _titleController = TextEditingController(text: widget.auction.title);
    _descriptionController =
        TextEditingController(text: widget.auction.description);
    _images = List.from(widget.auction.images);
    _selectedCategory = widget.auction.category; // ✅ 초기 카테고리
    _tags = List<String>.from(widget.auction.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 10) return;
    final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70, limit: 10 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _updateAuction() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      // 이미지 유효성 검사
      return;
    }

    setState(() => _isSaving = true);

    try {
      List<String> imageUrls = [];
      for (var image in _images) {
        if (image is XFile) {
          // 새로운 이미지 파일(XFile)이면 Storage에 업로드
          final fileName = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('auction_images/${widget.auction.ownerId}/$fileName');
          await ref.putFile(File(image.path));
          imageUrls.add(await ref.getDownloadURL());
        } else if (image is String) {
          // 기존 이미지 URL(String)이면 그대로 사용
          imageUrls.add(image);
        }
      }

      // [추가] 검색 키워드
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _tags,
        description: _descriptionController.text,
      );

      final updatedAuction = AuctionModel(
        id: widget.auction.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: imageUrls,
        // 수정되지 않는 필드들은 기존 값을 그대로 사용
        startPrice: widget.auction.startPrice,
        currentBid: widget.auction.currentBid,
        bidHistory: widget.auction.bidHistory,
        location: widget.auction.location,
        geoPoint: widget.auction.geoPoint,
        startAt: widget.auction.startAt,
        endAt: widget.auction.endAt,
        ownerId: widget.auction.ownerId,
        category: _selectedCategory,
        tags: _tags,
        searchIndex: searchKeywords,
      );

      await _repository.updateAuction(updatedAuction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.auctions.edit.success),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                t.auctions.edit.fail.replaceAll('{error}', e.toString())),
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
        title: Text(t.auctions.edit.title),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _updateAuction,
                child: Text(t.auctions.edit.save)),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 이미지 선택 및 수정 UI
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        ImageProvider imageProvider;
                        if (image is XFile) {
                          imageProvider = FileImage(File(image.path));
                        } else {
                          imageProvider = NetworkImage(image as String);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image(
                                    image: imageProvider,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover),
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
                                          color: Colors.white, size: 16)),
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
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ 카테고리 선택 드롭다운
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
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
                const SizedBox(height: 16),

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
                CustomTagInputField(
                  hintText: t.tagInput.help,
                  initialTags: _tags,
                  titleController: _titleController,
                  onTagsChanged: (tags) {
                    setState(() => _tags = tags);
                  },
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
