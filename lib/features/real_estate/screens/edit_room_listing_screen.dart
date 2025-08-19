// lib/features/real_estate/screens/edit_room_listing_screen.dart

import 'dart:io';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';


class EditRoomListingScreen extends StatefulWidget {
  final RoomListingModel room;
  const EditRoomListingScreen({super.key, required this.room});

  @override
  State<EditRoomListingScreen> createState() => _EditRoomListingScreenState();
}

class _EditRoomListingScreenState extends State<EditRoomListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  late String _type;
  late String _priceUnit;
  final List<dynamic> _images = []; // 기존 URL(String)과 새로운 파일(XFile)을 모두 담음
  late Set<String> _amenities;
  bool _isSaving = false;

  final RoomRepository _repository = RoomRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.room.title);
    _descriptionController = TextEditingController(text: widget.room.description);
    _priceController = TextEditingController(text: widget.room.price.toString());
    _type = widget.room.type;
    _priceUnit = widget.room.priceUnit;
    _images.addAll(widget.room.imageUrls);
    _amenities = Set<String>.from(widget.room.amenities);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 10) return;
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 70, limit: 10 - _images.length);
    if (pickedFiles.isNotEmpty && mounted) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  void _removeImage(int index) {
      if(mounted) {
        setState(() => _images.removeAt(index));
      }
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate() || _isSaving || _images.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      List<String> imageUrls = [];
      for (var image in _images) {
        if (image is XFile) {
          final fileName = Uuid().v4();
          final ref = FirebaseStorage.instance.ref().child('room_listings/${widget.room.userId}/$fileName');
          await ref.putFile(File(image.path));
          imageUrls.add(await ref.getDownloadURL());
        } else if (image is String) {
          imageUrls.add(image);
        }
      }

      // V V V --- [핵심 수정] RoomListingModel에 실제로 존재하는 필드만 사용하여 객체를 생성합니다 --- V V V
      final updatedListing = RoomListingModel(
        id: widget.room.id,
        userId: widget.room.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        price: int.tryParse(_priceController.text) ?? 0,
        priceUnit: _priceUnit,
        imageUrls: imageUrls,
        amenities: _amenities.toList(),
        // --- 기존 정보 보존 ---
        locationName: widget.room.locationName,
        locationParts: widget.room.locationParts,
        geoPoint: widget.room.geoPoint,
        createdAt: widget.room.createdAt,
        isAvailable: widget.room.isAvailable,
      );
      // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

      await _repository.updateRoomListing(updatedListing);

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('realEstate.edit.success'.tr()), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('realEstate.edit.fail'.tr(namedArgs: {'error': e.toString()})),
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
          title: Text('realEstate.edit.title'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _updateListing, child: Text('realEstate.edit.save'.tr()))
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
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
                                child: Image(image: imageProvider, width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4, right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 16)),
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
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SegmentedButton<String>(
                    segments: [
                    ButtonSegment(
                        value: 'kos', label: Text('realEstate.form.type.kos'.tr())),
                    ButtonSegment(
                        value: 'kontrakan',
                        label: Text('realEstate.form.type.kontrakan'.tr())),
                    ButtonSegment(
                        value: 'sewa', label: Text('realEstate.form.type.sewa'.tr())),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) => setState(() => _type = newSelection.first),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                         decoration: InputDecoration(
                            labelText: 'realEstate.form.priceLabel'.tr(),
                            border: const OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty)
                            ? 'realEstate.form.priceRequired'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _priceUnit,
                          items: [
                        DropdownMenuItem(
                            value: 'monthly',
                            child:
                                Text('realEstate.form.priceUnit.monthly'.tr())),
                        DropdownMenuItem(
                            value: 'yearly',
                            child:
                                Text('realEstate.form.priceUnit.yearly'.tr())),
                      ],
                      onChanged: (val) => setState(() => _priceUnit = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                decoration: InputDecoration(
                      labelText: 'realEstate.form.titleLabel'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'realEstate.form.titleRequired'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'realEstate.form.descriptionLabel'.tr(),
                      border: const OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                   Text('realEstate.form.amenities'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8.0,
                  children: ['wifi', 'ac', 'parking', 'kitchen'].map((amenity) {
                    return FilterChip(
                      label: Text('realEstate.form.amenity.$amenity'.tr()),
                      selected: _amenities.contains(amenity),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _amenities.add(amenity);
                          } else {
                            _amenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(color: Colors.black.withValues(alpha: 0.5), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}