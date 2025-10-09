import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart'; // ✅ use cloud_functions

import 'package:bling_app/firebase_options.dart'; // ✅ adjust to your app package name

class AiPredictionScreen extends StatefulWidget {
  final String ruleId; // ✅ required
  final List<Object /*File|XFile|String|Reference*/ > images;

  const AiPredictionScreen({
    super.key,
    required this.ruleId,
    required this.images,
  });

  @override
  State<AiPredictionScreen> createState() => _AiPredictionScreenState();
}

class _AiPredictionScreenState extends State<AiPredictionScreen> {
  String? _predictedName;
  String? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      // ✅ Ensure region matches your deployed functions (us-central1)
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

      final callable = functions.httpsCallable(
        'initialproductanalysis',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      final res = await callable.call(<String, dynamic>{
        'ruleId': widget.ruleId,
        'imageUrls': await _ensureDownloadUrls(widget.images),
      });

      final data = (res.data as Map?) ?? {};
      setState(() {
        _predictedName = data['prediction']?.toString();
        _error = (data['success'] == true) ? null : 'AI 분석에 실패했습니다.';
        _busy = false;
      });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ AI prediction error: $e\n$st');
      }
      setState(() {
        _error = e.toString();
        _busy = false;
      });
    }
  }

  /// Converts any of [File|XFile|String(URL)|Reference] to public download URLs
  Future<List<String>> _ensureDownloadUrls(List<Object> items) async {
    final storage = FirebaseStorage.instance;
    final out = <String>[];
    for (final it in items) {
      if (it is String && it.startsWith('http')) {
        out.add(it);
      } else if (it is XFile) {
        out.add(await _uploadAndGetUrl(File(it.path), storage));
      } else if (it is File) {
        out.add(await _uploadAndGetUrl(it, storage));
      } else if (it is Reference) {
        out.add(await it.getDownloadURL());
      } else {
        throw StateError('Unsupported image type: ${it.runtimeType}');
      }
    }
    return out;
  }

  Future<String> _uploadAndGetUrl(File file, FirebaseStorage storage) async {
    final bytes = await file.length();
    if (bytes > 10 * 1024 * 1024) {
      throw StateError('이미지 파일이 10MB를 초과했습니다.');
    }
    final name = p.basename(file.path);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ref = storage.ref('ai_uploads/$stamp-$name');
    final snap = await ref.putFile(file);
    return await snap.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI 분석')),
        body: Center(child: Text('오류: $_error', textAlign: TextAlign.center)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('AI 분석 결과')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('예상 상품명',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_predictedName ?? '(없음)',
                style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
