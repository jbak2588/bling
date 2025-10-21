import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Uploads a single product image to Firebase Storage under a user-scoped path.
///
/// Path format: product_images/{userId}/{uuid}{ext}
/// Returns the download URL upon success.
Future<String> uploadProductImage(XFile image, String userId) async {
  final fileName = '${const Uuid().v4()}${p.extension(image.path)}';
  final ref =
      FirebaseStorage.instance.ref().child('product_images/$userId/$fileName');
  await ref.putFile(File(image.path));
  return ref.getDownloadURL();
}

/// Uploads multiple product images and returns their download URLs, preserving order.
Future<List<String>> uploadAllProductImages(
  List<XFile> images,
  String userId,
) async {
  final urls = <String>[];
  for (final image in images) {
    urls.add(await uploadProductImage(image, userId));
  }
  return urls;
}
