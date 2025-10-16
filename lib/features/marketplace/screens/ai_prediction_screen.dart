import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_guided_camera_screen.dart';

class AiPredictionScreen extends StatefulWidget {
  // [수정] 이전 화면에서 분석 결과를 전달받도록 생성자 변경
  final AiVerificationRule rule;
  final List<XFile> initialImages;
  final String predictedName;

  const AiPredictionScreen({
    super.key,
    required this.rule,
    required this.initialImages,
    required this.predictedName,
  });

  @override
  State<AiPredictionScreen> createState() => _AiPredictionScreenState();
}

class _AiPredictionScreenState extends State<AiPredictionScreen> {
  // [추가] 사용자가 상품명을 수정할 수 있도록 TextEditingController 추가
  late final TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.predictedName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiGuidedCameraScreen(
          rule: widget.rule,
          initialImages: widget.initialImages,
          // [수정] 확정된 상품명(수정되었을 수 있음)을 다음 화면으로 전달
          confirmedProductName: _nameController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.prediction.title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ai_flow.prediction.guide'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // [추가] 상품명 표시 및 수정 UI
            _isEditing
                ? TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'ai_flow.prediction.edit_label'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => setState(() => _isEditing = false),
                  )
                : Text(
                    _nameController.text,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 16),
            // [추가] 수정/저장 버튼
            TextButton.icon(
              icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
              label: Text(_isEditing
                  ? 'ai_flow.prediction.save_button'.tr()
                  : 'ai_flow.prediction.edit_button'.tr()),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
            const Spacer(),
            // [추가] 다음 단계로 가는 버튼
            ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('ai_flow.prediction.confirm_button'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
