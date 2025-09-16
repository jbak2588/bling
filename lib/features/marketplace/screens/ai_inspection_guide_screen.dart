// lib/features/marketplace/screens/ai_inspection_guide_screen.dart

import 'package:flutter/material.dart';
import '../widgets/ai_guided_camera_capture.dart';

class AiInspectionGuideScreen extends StatefulWidget {
  const AiInspectionGuideScreen({super.key});

  @override
  State<AiInspectionGuideScreen> createState() => _AiInspectionGuideScreenState();
}

class _AiInspectionGuideScreenState extends State<AiInspectionGuideScreen> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 검수 안내'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'AI 검수 등록의 장점'),
            _buildBenefitItem(Icons.security, '신뢰도 상승', 'AI가 상품의 정보를 분석하여 구매자에게 신뢰를 줍니다.'),
            _buildBenefitItem(Icons.speed, '빠른 판매', '신뢰도 높은 매물은 더 빠르게 판매될 확률이 높습니다.'),
            _buildBenefitItem(Icons.trending_up, '상단 노출', 'AI 검수 상품은 리스트 상단에 우선적으로 노출됩니다.'),
            const Divider(height: 40),
            _buildSectionTitle(context, '필수 촬영 안내'),
            const Text('AI가 정확하게 분석할 수 있도록, 아래 가이드에 맞춰 선명하게 촬영해주세요. 흐리거나 가려진 사진은 검수가 거부될 수 있습니다.'),
            const SizedBox(height: 16),
            _buildPhotoGuide(),
            const Divider(height: 40),
            _buildSectionTitle(context, '수수료 및 정책'),
            const Text('AI 검수 등록 상품이 판매 완료될 경우, 최종 판매가의 3%가 서비스 수수료로 부과됩니다.'),
            const SizedBox(height: 24),
            CheckboxListTile(
              title: const Text('위 내용을 모두 확인했으며 AI 검수 등록에 동의합니다.'),
              value: _isAgreed,
              onChanged: (bool? value) {
                setState(() {
                  _isAgreed = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // 동의해야 버튼 활성화
          onPressed: _isAgreed
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiGuidedCameraCapture()),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('촬영 시작하기'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPhotoGuide() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _PhotoGuideCard(icon: Icons.fullscreen, label: '정면'),
          _PhotoGuideCard(icon: Icons.flip_camera_android, label: '후면'),
          _PhotoGuideCard(icon: Icons.label, label: '태그'),
          _PhotoGuideCard(icon: Icons.broken_image, label: '손상 부위'),
        ],
      ),
    );
  }
}

class _PhotoGuideCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PhotoGuideCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}