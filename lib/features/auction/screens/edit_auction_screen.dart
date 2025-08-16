// lib/features/auction/screens/edit_auction_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/auction_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

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
          if (!_isSaving)
            TextButton(
                onPressed: _updateAuction,
                child: Text('auctions.edit.save'.tr())),
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
