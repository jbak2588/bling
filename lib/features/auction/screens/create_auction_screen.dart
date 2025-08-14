// lib/features/auction/screens/create_auction_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

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
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 70, limit: 10 - _images.length);
      if (pickedFiles.isNotEmpty && mounted) {
        setState(() => _images.addAll(pickedFiles));
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }
  
  // [추가] 선택한 이미지 제거 함수
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitAuction() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('auctions.create.errors.noPhoto'.tr())));
      return;
    }
    
    setState(() => _isSaving = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        // [수정] const를 제거하여 매번 새로운 고유 ID를 생성합니다.
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance.ref().child('auction_images/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final now = Timestamp.now();
      final endAt = Timestamp.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch + Duration(days: _durationInDays).inMilliseconds);
      final startPrice = int.tryParse(_startPriceController.text) ?? 0;

      final newAuction = AuctionModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: imageUrls,
        startPrice: startPrice,
        currentBid: startPrice,
        bidHistory: [],
        location: widget.userModel.locationName ?? 'Unknown',
        geoPoint: widget.userModel.geoPoint,
        startAt: now,
        endAt: endAt,
        ownerId: user.uid,
      );

      await _repository.createAuction(newAuction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('auctions.create.success'.tr()), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('auctions.create.fail'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('auctions.create.title'.tr()),
        actions: [ if (!_isSaving) TextButton(onPressed: _submitAuction, child: Text('common.done'.tr())) ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // V V V --- [수정] 이미지 선택 및 취소 기능이 포함된 UI --- V V V
                Text('사진 등록 (최대 10장)', style: Theme.of(context).textTheme.titleMedium),
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
                                child: Image.file(File(xfile.path), width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4, right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(
                                    radius: 12, backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, color: Colors.white, size: 16),
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
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'auctions.create.form.title'.tr(), border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '제목을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'auctions.create.form.description'.tr(), border: const OutlineInputBorder()),
                  maxLines: 5,
                  validator: (value) => (value == null || value.trim().isEmpty) ? '설명을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                 TextFormField(
                  controller: _startPriceController,
                  decoration: InputDecoration(labelText: 'auctions.create.form.startPrice'.tr(), border: const OutlineInputBorder(), prefixText: 'Rp '),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.trim().isEmpty) ? '시작가를 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _durationInDays,
                  decoration: InputDecoration(labelText: 'auctions.create.form.duration'.tr(), border: const OutlineInputBorder()),
                  items: [3, 5, 7].map((days) => DropdownMenuItem(value: days, child: Text('$days일'))).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _durationInDays = value);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                  title: Text('auctions.create.form.location'.tr()),
                  subtitle: Text(widget.userModel.locationName ?? '위치 정보 없음'),
                  dense: true,
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}