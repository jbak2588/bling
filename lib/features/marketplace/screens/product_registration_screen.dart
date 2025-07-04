// lib/features/marketplace/presentation/screens/product_registration_screen.dart

import 'dart:io';
import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/features/categories/screens/parent_category_screen.dart';
import 'package:bling_app/features/marketplace/domain/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({super.key});

  @override
  State<ProductRegistrationScreen> createState() =>
      _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _transactionPlaceController = TextEditingController();

  List<XFile> _images = [];
  bool _isNegotiable = false;
  bool _isLoading = false;

  Category? _selectedCategory;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkLocationAndPermission();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _transactionPlaceController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationAndPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      final requestedStatus = await Permission.location.request();
      if (requestedStatus.isGranted) {
        await _getCurrentLocation();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final placemark = placemarks.first;
        final neighborhood = placemark.subLocality?.isNotEmpty == true
            ? placemark.subLocality
            : placemark.locality;

        setState(() {
          _addressController.text = neighborhood ?? '';
          _currentPosition = position;
        });
      }
    } catch (e) {
      // 위치 정보 가져오기 실패 시 처리
    }
  }

  void _selectCategory() async {
    final result = await Navigator.of(context).push<Category>(
      MaterialPageRoute(builder: (context) => const ParentCategoryScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage(limit: 10);
    if (pickedImages.isNotEmpty) {
      setState(() {
        _images = pickedImages;
      });
    }
  }

  Future<void> _submitProduct() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('err_no_photo'.tr())));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('err_no_category'.tr())));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      List<String> imageUrls = [];
      for (var image in _images) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance.ref().child(
              'product_images/$fileName',
            );
        final uploadTask = ref.putFile(File(image.path));
        final snapshot = await uploadTask;
        imageUrls.add(await snapshot.ref.getDownloadURL());
      }

      final geo = GeoFlutterFire();
      final point = geo.point(
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
      );

      final newProductId =
          FirebaseFirestore.instance.collection('products').doc().id;
      final newProduct = Product(
        id: newProductId,
        imageUrls: imageUrls,
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory!.id,
        price: int.tryParse(_priceController.text) ?? 0,
        negotiable: _isNegotiable,
        address: _addressController.text,
        transactionPlace: _transactionPlaceController.text,
        geo: point,
        status: 'selling',
        isAiVerified: false,
        userId: user.uid,
        userName: user.displayName ?? "Bling User",
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('products')
          .doc(newProductId)
          .set(newProduct.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('product_reg_success'.tr())),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상품 등록 실패: $e')), // 개발자용 에러
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCategoryName(BuildContext context, Category? category) {
    if (category == null) {
      return 'selectCategory'.tr();
    }
    // easy_localization의 현재 로케일을 가져옵니다.
    final langCode = context.locale.languageCode;
    switch (langCode) {
      case 'ko':
        return category.nameKo;
      case 'id':
        return category.nameId;
      default:
        return category.nameEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('product_reg_title'.tr()),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitProduct,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'product_reg_done'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: _pickImages,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _images.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(4.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(_images[index].path),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration:
                    InputDecoration(labelText: 'product_reg_title_hint'.tr()),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'err_required_field'.tr()
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                onTap: _selectCategory,
                title: Text(_getCategoryName(context, _selectedCategory)),
                leading: const Icon(Icons.category_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'address_neighborhood'.tr(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'err_required_field'.tr()
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transactionPlaceController,
                decoration:
                    InputDecoration(labelText: 'address_detail_hint'.tr()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration:
                    InputDecoration(labelText: 'product_reg_price_hint'.tr()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'err_required_field'.tr()
                    : null,
              ),
              SwitchListTile(
                title: Text('product_reg_negotiable'.tr()),
                value: _isNegotiable,
                onChanged: (value) => setState(() => _isNegotiable = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'product_reg_description_hint'.tr(),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'err_required_field'.tr()
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
