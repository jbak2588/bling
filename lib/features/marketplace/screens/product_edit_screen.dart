import 'dart:io';
// import 'package:bling_app/features/marketplace/domain/product_model_old.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/models/product_model.dart';
import '../../../core/models/user_model.dart';
import '../../categories/domain/category.dart';
import '../../categories/screens/parent_category_screen.dart';

class ProductEditScreen extends StatefulWidget {
final ProductModel product;
  const ProductEditScreen({super.key, required this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _transactionPlaceController = TextEditingController();

  bool _isNegotiable = false;
  List<String> _existingImageUrls = [];
  final List<XFile> _images = [];
  bool _isLoading = false;
  Category? _selectedCategory;
  String _condition = 'used';

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.product.title;
    _priceController.text = widget.product.price.toString();
    _descriptionController.text = widget.product.description;
  _addressController.text = widget.product.locationName ?? '';
    _transactionPlaceController.text = widget.product.transactionPlace ?? '';
    _isNegotiable = widget.product.negotiable;
    _existingImageUrls = List<String>.from(widget.product.imageUrls);
    _condition = widget.product.condition;
    _loadInitialCategory();
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

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _loadInitialCategory() async {
    final doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.product.categoryId)
        .get();
    if (doc.exists) {
      setState(() {
        _selectedCategory = Category.fromFirestore(doc);
      });
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

  String _getCategoryName(BuildContext context, Category? category) {
    if (category == null) return 'selectCategory'.tr();
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

  Future<void> _saveProduct() async {
    if (_isLoading) return;
    if (_existingImageUrls.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('marketplace.errors.noPhoto'.tr())),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 새로 추가된 이미지 업로드
      List<String> uploadedUrls = [];
      for (var image in _images) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = FirebaseStorage.instance.ref().child('product_images/$fileName');
        final uploadTask = ref.putFile(File(image.path));
        final snapshot = await uploadTask;
        uploadedUrls.add(await snapshot.ref.getDownloadURL());
      }

      // 기존 이미지 + 새로 업로드된 이미지 합치기
      final allImageUrls = [..._existingImageUrls, ...uploadedUrls];

      // final updatedProduct = widget.product.copyWith(
      //   title: _titleController.text,
      //   price: int.tryParse(_priceController.text) ?? 0,
      //   description: _descriptionController.text,
      //   address: _addressController.text,
      //   transactionPlace: _transactionPlaceController.text,
      //   negotiable: _isNegotiable,
      //   imageUrls: allImageUrls,
      //   updatedAt: Timestamp.fromDate(DateTime.now()),
      // );

      // await FirebaseFirestore.instance
      //     .collection('products')
      //     .doc(widget.product.id)
      //     .update(updatedProduct.toJson());
// ✅ [핵심 수정] 사용자의 최신 정보를 가져와서 위치 정보를 업데이트합니다.
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) throw Exception("사용자 정보를 찾을 수 없습니다.");
      final userModel = UserModel.fromFirestore(userDoc);


      // ✅ [핵심 수정] copyWith 대신, Map을 직접 만들어 업데이트합니다.
      final updatedData = {
        'title': _titleController.text,
        'price': int.tryParse(_priceController.text) ?? 0,
        'description': _descriptionController.text,
        'transactionPlace': _transactionPlaceController.text,
        'negotiable': _isNegotiable,
        'imageUrls': allImageUrls,
        'categoryId': _selectedCategory?.id ?? widget.product.categoryId,
        'condition': _condition,
        'updatedAt': Timestamp.now(),
        // ✅ 구버전 address 대신, 사용자의 최신 위치 정보로 덮어씁니다.
        'locationName': userModel.locationName,
        'locationParts': userModel.locationParts,
        'geoPoint': userModel.geoPoint,
      };

// ✅ [핵심 수정] toJson() 대신 생성한 Map을 사용하여 update합니다.
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('marketplace.edit.success'.tr())),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('marketplace.edit.fail'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('marketplace.edit.title'.tr()),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'marketplace.edit.done'.tr(),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 미리보기: 기존 이미지 + 새로 추가된 이미지 + 삭제/추가 기능
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingImageUrls.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final url = entry.value;
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => _removeExistingImage(idx),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    ..._images.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final xfile = entry.value;
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.file(
                              File(xfile.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => _removeNewImage(idx),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // 이미지 추가 버튼
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'marketplace.edit.titleHint'.tr()),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'marketplace.errors.requiredField'.tr()
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
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'marketplace.edit.priceHint'.tr()),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'marketplace.errors.requiredField'.tr()
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: 'marketplace.edit.descriptionHint'.tr()),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'marketplace.errors.requiredField'.tr()
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                    labelText: 'marketplace.edit.addressHint'.tr()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transactionPlaceController,
                decoration: InputDecoration(labelText: 'address_detail_hint'.tr()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('marketplace.edit.negotiable'.tr()),
                  Switch(
                    value: _isNegotiable,
                    onChanged: (value) {
                      setState(() {
                        _isNegotiable = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: const [
                  DropdownMenuItem(value: 'new', child: Text('New')),
                  DropdownMenuItem(value: 'used', child: Text('Used')),
                ],
                onChanged: (value) =>
                    setState(() => _condition = value ?? 'used'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
