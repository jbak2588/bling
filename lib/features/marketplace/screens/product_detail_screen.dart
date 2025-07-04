// lib/features/marketplace/presentation/screens/product_detail_screen.dart

import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/marketplace/domain/product_model.dart';
import 'package:bling_app/features/marketplace/screens/product_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';

// 카테고리 이름 표시를 위한 별도 위젯
class CategoryNameWidget extends StatelessWidget {
  final String categoryId;
  const CategoryNameWidget({super.key, required this.categoryId});

  String _getCategoryName(BuildContext context, Category category) {
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('detail_category_error'.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.grey));
        }
        try {
          final category = Category.fromFirestore(
            snapshot.data as DocumentSnapshot<Map<String, dynamic>>,
          );
          return Text(
              "${'detail_category'.tr()}: ${_getCategoryName(context, category)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey));
        } catch (e) {
          return Text('detail_category_error'.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.grey));
        }
      },
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  int _likeCount = 0;

  int _currentIndex = 0; // 도트 인디케이터용
  late final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _likeCount = widget.product.likesCount;
    _checkIfFavorite();
    _increaseViewCount();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _increaseViewCount() async {
    final docRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id);
    await docRef.update({'viewsCount': FieldValue.increment(1)});
  }

  Future<void> _checkIfFavorite() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;
    final favDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('favorites')
        .doc(widget.product.id)
        .get();
    if (mounted) setState(() => _isFavorite = favDoc.exists);
  }

  Future<void> _toggleFavorite() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('favorites')
        .doc(widget.product.id);
    final prodRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id);
    setState(() {
      if (_isFavorite) {
        _likeCount--;
        favRef.delete();
        prodRef.update({'likesCount': FieldValue.increment(-1)});
      } else {
        _likeCount++;
        favRef.set({'createdAt': FieldValue.serverTimestamp()});
        prodRef.update({'likesCount': FieldValue.increment(1)});
      }
      _isFavorite = !_isFavorite;
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'time_ago_now'.tr();
    } else if (diff.inHours < 1) {
      return 'time_ago_min'.tr(args: [diff.inMinutes.toString()]);
    } else if (diff.inDays < 1) {
      return 'time_ago_hour'.tr(args: [diff.inHours.toString()]);
    } else if (diff.inDays < 7) {
      return 'time_ago_day'.tr(args: [diff.inDays.toString()]);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('dialog_delete_title'.tr()),
        content: Text('dialog_delete_content'.tr()),
        actions: [
          TextButton(
            child: Text('dialog_cancel'.tr()),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text(
              'dialog_delete_confirm'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteProduct();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('delete_success'.tr())));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('delete_error'.tr(args: [e.toString()]))));
      }
    }
  }

  void _showFullPhotoView(List<String> imageUrls, int initialIndex) {
    showGeneralDialog(
      context: context,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.98),
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            // ignore: deprecated_member_use
            backgroundColor: Colors.black.withOpacity(0.98),
            body: SafeArea(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: PageController(initialPage: initialIndex),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, idx) => PhotoView(
                      imageProvider: NetworkImage(imageUrls[idx]),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.5,
                      initialScale: PhotoViewComputedScale.contained,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: 'product_image_$idx',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 28,
                    right: 18,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 36),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final isMyProduct = myUid == widget.product.userId;
    final imageUrls = widget.product.imageUrls;

    return Scaffold(
      bottomNavigationBar: isMyProduct
          ? null
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.pink,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    Text('$_likeCount'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        child: Text('detail_chat'.tr()),
                        onPressed: () async {
                          final myUid = FirebaseAuth.instance.currentUser?.uid;
                          if (myUid == null) return;

                          final uids = [myUid, widget.product.userId];
                          uids.sort();
                          final chatId =
                              '${widget.product.id}_${uids.join('_')}';
                          final chatRoomRef = FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId);
                          await chatRoomRef.set({
                            'participants': [myUid, widget.product.userId],
                            'productId': widget.product.id,
                            'productTitle': widget.product.title,
                            'productImage': widget.product.imageUrls.isNotEmpty
                                ? widget.product.imageUrls.first
                                : '',
                            'lastTimestamp': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  chatId: chatId,
                                  otherUserName: widget.product.userName,
                                  otherUserId: widget.product.userId,
                                  productTitle: widget.product.title,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  if (imageUrls.isNotEmpty) {
                    _showFullPhotoView(
                      imageUrls,
                      _currentIndex,
                    );
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrls.isEmpty)
                      Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                      )
                    else
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: 'product_image_$index',
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(child: CircularProgressIndicator()),
                            ),
                          );
                        },
                      ),
                    // 도트 인디케이터
                    if (imageUrls.length > 1)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imageUrls.length, (idx) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _currentIndex == idx
                                    ? Colors.white
                                    // ignore: deprecated_member_use
                                    : Colors.white.withOpacity(0.45),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share(
                        'Check out this product: ${widget.product.title}');
                  }),
              if (isMyProduct)
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductEditScreen(product: widget.product),
                        ),
                      );
                    }),
              if (isMyProduct)
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _showDeleteDialog),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.userName,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(widget.product.address,
                        style: const TextStyle(color: Colors.grey)),
                    const Divider(height: 32),
                    CategoryNameWidget(categoryId: widget.product.categoryId),
                    const SizedBox(height: 8),
                    Text(widget.product.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(widget.product.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(widget.product.price),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.product.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.5),
                    ),
                    const Divider(height: 32),
                    Text(
                      '${'detail_likes'.tr()} ${widget.product.likesCount} ∙ ${'detail_chats'.tr()} ${widget.product.chatsCount} ∙ ${'detail_views'.tr()} ${widget.product.viewsCount + 1}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
