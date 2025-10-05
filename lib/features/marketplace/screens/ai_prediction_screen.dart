// lib/features/marketplace/screens/ai_prediction_screen.dart

import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_guided_camera_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:uuid/uuid.dart';

class AiPredictionScreen extends StatefulWidget {
  final AiVerificationRule rule;
  final List<XFile> images;

  const AiPredictionScreen({
    super.key,
    required this.rule,
    required this.images,
  });

  @override
  State<AiPredictionScreen> createState() => _AiPredictionScreenState();
}

class _AiPredictionScreenState extends State<AiPredictionScreen> {
  String _statusMessage = 'ai_flow.prediction.loading';
  String? _prediction;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      _statusMessage = 'ai_flow.prediction.loading';
      _prediction = null;
      _hasError = false;
    });

    try {
      // 1. 이미지 업로드
      setState(() {
        _statusMessage = 'ai_flow.prediction.uploading';
      });
      List<String> imageUrls = [];
      for (final image in widget.images) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('ai_verification_images')
            .child(fileName);
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // 2. Cloud Function 호출
      setState(() {
        _statusMessage = 'ai_flow.prediction.analyzing';
      });
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('initialProductAnalysis');
      final result =
          await callable.call<Map<String, dynamic>>({'imageUrls': imageUrls});

      if (result.data['success'] == true) {
        setState(() {
          _prediction = result.data['prediction'];
        });
      } else {
        throw Exception(result.data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'ai_flow.prediction.error';
      });
    }
  }

  void _onConfirm() {
    // 기존: ScaffoldMessenger...
    // 수정: 새로 만든 AI 가이드 카메라 촬영 화면으로 이동
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AiGuidedCameraScreen(
        rule: widget.rule,
        initialImages: widget.images,
        confirmedProductName: _prediction!,
      ),
    ));
  }

  void _onReject() {
    Navigator.of(context).pop(); // 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.prediction.title'.tr()),
        automaticallyImplyLeading:
            _prediction == null && !_hasError, // 분석 중에는 뒤로가기 방지
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(_statusMessage.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: _onReject,
                  child: Text('ai_flow.prediction.back_button'.tr())),
              const SizedBox(width: 16),
              ElevatedButton(
                  onPressed: _runAnalysis,
                  child: Text('ai_flow.prediction.retry_button'.tr())),
            ],
          )
        ],
      );
    }

    if (_prediction == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(_statusMessage.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('ai_flow.prediction.question'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _prediction!,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16)),
          child: Text('ai_flow.prediction.confirm_button'.tr()),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _onReject,
          child: Text('ai_flow.prediction.reject_button'.tr()),
        ),
      ],
    );
  }
}
