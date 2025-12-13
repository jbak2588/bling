// lib/features/auction/screens/edit_auction_screen.dart

import 'dart:io';
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/core/constants/app_categories.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/core/models/user_model.dart'; // ✅ Import 추가
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import 추가
import 'package:cloud_firestore/cloud_firestore.dart';
// search index generation removed to reduce background indexing

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
  // [신규] 가격 수정을 위한 컨트롤러 추가
  late final TextEditingController _startPriceController;

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
    // [신규] 기존 시작가로 초기화 (0원인 경우 빈 문자열 처리 가능)
    _startPriceController = TextEditingController(
        text: widget.auction.startPrice > 0
            ? widget.auction.startPrice.toString()
            : '');
    _images = List.from(widget.auction.images);
    _selectedCategory = widget.auction.category; // ✅ 초기 카테고리
    _tags = List<String>.from(widget.auction.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startPriceController.dispose(); // [신규] dispose 추가
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 10) return;
    final pickedFiles = await _picker.pickMultiImage(
        limit: 10 - _images.length); // [수정] imageQuality 제거
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
      // ✅ [Fix] 사용자 최신 정보(위치) 가져오기
      final user = FirebaseAuth.instance.currentUser;
      UserModel? userModel;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) userModel = UserModel.fromFirestore(userDoc);
      }

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

      // [신규] 가격 파싱 로직 적용 (숫자만 추출)
      final rawPrice =
          _startPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final int startPrice = int.tryParse(rawPrice) ?? 0;

      final updatedAuction = AuctionModel(
        id: widget.auction.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: imageUrls,
        // [수정] 수정된 시작가 적용
        startPrice: startPrice,
        currentBid: widget.auction.currentBid,
        bidHistory: widget.auction.bidHistory,
        // Prefer fresh user profile for location info, fallback to existing auction data
        location: userModel?.locationName ?? widget.auction.location,
        locationParts: userModel?.locationParts ?? widget.auction.locationParts,
        geoPoint: userModel?.geoPoint ?? widget.auction.geoPoint,
        startAt: widget.auction.startAt,
        endAt: widget.auction.endAt,
        ownerId: widget.auction.ownerId,
        category: _selectedCategory,
        tags: _tags,
        // 'searchIndex' intentionally omitted — client-side token generation disabled; use server-side/background indexing.
      );

      await _repository.updateAuction(updatedAuction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('auctions.edit.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'auctions.edit.fail'.tr(namedArgs: {'error': e.toString()})),
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
        title: Text('auctions.edit.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _updateAuction,
            icon: const Icon(Icons.save),
          ),
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
                      labelText: 'auctions.create.form.category'.tr(),
                      border: const OutlineInputBorder()),
                  hint: Text('auctions.create.form.categoryHint'.tr()),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'auctions.form.categoryRequired'.tr()
                      : null,
                  items: AppCategories.auctionCategories
                      .map((category) => DropdownMenuItem(
                            value: category.categoryId,
                            child: Text(
                                "${category.emoji} ${category.nameKey.tr()}"),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
                const SizedBox(height: 16),
                // [신규] 시작가 입력 필드 추가
                TextFormField(
                  controller: _startPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'auctions.create.form.startPrice'.tr(),
                    border: const OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  validator: (value) {
                    final raw = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (raw.isEmpty) return null; // optional
                    final v = int.tryParse(raw) ?? 0;
                    if (v <= 0) return 'auctions.form.startPriceInvalid'.tr();
                    return null;
                  },
                  // 시작가는 선택 사항이거나 0일 수 있으므로 필수 체크는 상황에 맞게 (여기선 생략 가능하나 원본 로직 유지)
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'auctions.create.form.title'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'auctions.form.titleRequired'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'auctions.create.form.description'.tr(),
                      border: const OutlineInputBorder()),
                  maxLines: 5,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'auctions.form.descriptionRequired'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTagInputField(
                  hintText: 'tag_input.addHint'.tr(),
                  initialTags: _tags,
                  titleController: _titleController,
                  onTagsChanged: (tags) {
                    setState(() => _tags = tags);
                  },
                ),
                const SizedBox(height: 88),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FilledButton(
            onPressed: _isSaving ? null : _updateAuction,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('common.save'.tr()),
          ),
        ),
      ),
    );
  }
}
