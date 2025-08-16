// lib/features/local_stores/screens/create_shop_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateShopScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateShopScreen({super.key, required this.userModel});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _hoursController = TextEditingController();

  XFile? _selectedImage;
  bool _isSaving = false;

  final ShopRepository _repository = ShopRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  Future<void> _submitShop() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('shop_images/${user.uid}/$fileName');
        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL();
      }

      final newShop = ShopModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: user.uid,
        locationName: widget.userModel.locationName,
        locationParts: widget.userModel.locationParts,
        geoPoint: widget.userModel.geoPoint,
        contactNumber: _contactController.text.trim(),
        openHours: _hoursController.text.trim(),
        imageUrl: imageUrl,
        createdAt: Timestamp.now(),
      );

      await _repository.createShop(newShop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('localStores.create.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('localStores.create.fail'
                .tr(namedArgs: {'error': e.toString()})),
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
        title: Text('localStores.create.title'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _submitShop,
                child: Text('localStores.create.submit'.tr())),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_selectedImage!.path),
                                fit: BoxFit.cover),
                          )
                        : const Center(
                            child: Icon(Icons.add_a_photo_outlined,
                                size: 50, color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.nameLabel'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'localStores.form.nameError'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.descriptionLabel'.tr(),
                      border: const OutlineInputBorder()),
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'localStores.form.descriptionError'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.contactLabel'.tr(),
                      border: const OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.hoursLabel'.tr(),
                      hintText: 'localStores.form.hoursHint'.tr(),
                      border: const OutlineInputBorder()),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
