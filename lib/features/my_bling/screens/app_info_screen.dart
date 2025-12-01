import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final bodyStyle = theme.textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(title: Text('settings.appInfo'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. 앱 아이콘 및 버전
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.info_outline,
                      size: 48, color: theme.primaryColor),
                ),
                const SizedBox(height: 16),
                Text('Bling (블링)', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Version 2.1.0 (Field Test Build)',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 2. 서비스 소개
          Text('서비스 소개', style: titleStyle),
          const SizedBox(height: 8),
          Text(
            "블링은 우리 동네를 더 가깝고 신뢰 있게 연결하는 하이퍼로컬 슈퍼 앱입니다. 뉴스, 거래, 모임, 그리고 가벼운 번개까지, 당신의 동네 생활에 필요한 모든 것을 하나로 담았습니다.",
            style: bodyStyle,
          ),
          const Divider(height: 40),

          // 3. 주요 기능 (11개 섹션)
          Text('주요 기능 (Key Features)', style: titleStyle),
          const SizedBox(height: 16),
          _buildFeatureRow(context, Icons.volunteer_activism,
              "함께 해요 (Together)", "[NEW] 지금 당장, 가볍게 모이는 동네 번개 & QR 티켓"),
          _buildFeatureRow(context, Icons.article, "동네 소식 (Local News)",
              "우리 동네의 생생한 이야기와 정보 공유"),
          _buildFeatureRow(context, Icons.store_mall_directory,
              "중고 거래 (Marketplace)", "AI가 검수해주는 안전하고 스마트한 거래"),
          _buildFeatureRow(
              context, Icons.work, "구인 구직 (Jobs)", "동네 알바부터 전문직까지, 내 집 근처 일자리"),
          _buildFeatureRow(context, Icons.report_problem,
              "분실물 찾기 (Lost & Found)", "지도와 사례금으로 연결하는 분실/습득물 센터"),
          _buildFeatureRow(context, Icons.store, "동네 업체 (Local Stores)",
              "우리 동네 숨은 가게와 핫플레이스 정보"),
          _buildFeatureRow(context, Icons.people, "동네 친구 (Find Friends)",
              "취향이 맞는 가까운 이웃 찾기"),
          _buildFeatureRow(
              context, Icons.groups, "소모임 (Clubs)", "공통의 관심사로 뭉치는 지역 동호회"),
          _buildFeatureRow(
              context, Icons.home, "부동산 (Real Estate)", "직거래로 더 투명한 우리 동네 매물"),
          _buildFeatureRow(
              context, Icons.gavel, "경매 (Auction)", "실시간으로 참여하는 즐거운 중고 경매"),
          _buildFeatureRow(context, Icons.video_library, "뽐 (POM)",
              "짧은 영상으로 만나는 우리 동네 라이프스타일"),
          const Divider(height: 40),

          // 4. 개발 정보
          Text('개발 및 운영', style: titleStyle),
          const SizedBox(height: 8),
          Text("Powered by Flutter & Firebase", style: bodyStyle),
          const SizedBox(height: 4),
          Text("Developer: Gemini (Lead) & User (Planner)", style: bodyStyle),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
      BuildContext context, IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[700], height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
