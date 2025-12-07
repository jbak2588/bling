import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // flutter_svg 패키지 필요
import 'package:easy_localization/easy_localization.dart';

class AppInfoScreen extends StatelessWidget {
  final bool embedded;
  const AppInfoScreen({super.key, this.embedded = false});

  // [Task 29] SVG 경로 및 다국어 키 매핑 데이터
  // home_screen.dart의 순서와 리소스를 참조함
  final List<Map<String, String>> _features = const [
    {
      'key': 'together',
      'icon': 'assets/icons/ico_together.svg', // 경로 확인 필요
    },
    {
      'key': 'localNews',
      'icon': 'assets/icons/ico_news.svg',
    },
    {
      'key': 'marketplace',
      'icon': 'assets/icons/ico_secondhand.svg',
    },
    {
      'key': 'jobs',
      'icon': 'assets/icons/ico_job.svg',
    },
    {
      'key': 'lostAndFound',
      'icon': 'assets/icons/ico_lost_item.svg',
    },
    {
      'key': 'localStores',
      'icon': 'assets/icons/ico_store.svg',
    },
    {
      'key': 'findFriends',
      'icon': 'assets/icons/ico_friend_3d_deep.svg',
    },
    {
      'key': 'clubs',
      'icon': 'assets/icons/ico_community.svg',
    },
    {
      'key': 'realEstate',
      'icon': 'assets/icons/ico_real_estate.svg',
    },
    {
      'key': 'auction',
      'icon': 'assets/icons/ico_auction.svg',
    },
    {
      'key': 'pom',
      'icon': 'assets/icons/ico_pom.svg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final bodyStyle = theme.textTheme.bodyMedium;

    final content = ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 1. 앱 아이콘 및 버전 (로고 왼쪽, 텍스트 오른쪽)
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4), // SVG 패딩
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                // [Task 29] 메인 로고: SVG
                child: SvgPicture.asset(
                  'assets/icons/ico_info.svg',
                  fit: BoxFit.contain,
                  semanticsLabel: 'Bling logo',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('appInfo.appName'.tr(),
                      style: theme.textTheme.headlineSmall),
                  Text('appInfo.version'.tr(),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 2. 서비스 소개
        Text('appInfo.serviceIntroTitle'.tr(), style: titleStyle),
        const SizedBox(height: 8),
        Text(
          'appInfo.serviceIntroBody'.tr(),
          style: bodyStyle?.copyWith(height: 1.5),
        ),
        const Divider(height: 40),

        // 3. 주요 기능 매뉴얼 (제목과 서브타이틀을 세로 배치)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('appInfo.manualTitle'.tr(), style: titleStyle), // "사용자 매뉴얼"
            Text(
              'appInfo.manualIntro'.tr(), // "탭하여 상세 사용법 확인"
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // [Task 29] SVG 아이콘과 확장형 매뉴얼 생성
        ..._features.map((item) {
          final key = item['key']!;
          final iconPath = item['icon']!;

          return _buildFeatureManualItem(
            context,
            iconPath,
            'appInfo.features.$key.title'.tr(),
            'appInfo.features.$key.desc'.tr(),
            'appInfo.features.$key.guide'.tr(), // 상세 가이드 텍스트
          );
        }),

        const Divider(height: 40),

        // 4. 개발 정보
        Text('appInfo.developmentTitle'.tr(), style: titleStyle),
        const SizedBox(height: 8),
        // Text('appInfo.developmentBody'.tr(), style: bodyStyle),
        // const SizedBox(height: 4),
        Text('appInfo.developerNames'.tr(), style: bodyStyle),
        const SizedBox(height: 40),
      ],
    );

    if (embedded) return content;

    return Scaffold(
      appBar: AppBar(title: Text('settings.appInfo'.tr())),
      body: content,
    );
  }

  // [Task 29] 확장형 매뉴얼 아이템 빌더
  Widget _buildFeatureManualItem(BuildContext context, String svgPath,
      String title, String desc, String guide) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        backgroundColor: Colors.grey.shade50, // 펼쳤을 때 배경색
        collapsedBackgroundColor: Colors.white,
        leading: Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          // [Task 29] SVG 아이콘 적용
          child: SvgPicture.asset(
            svgPath,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          desc,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  "How to use:",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  guide,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[800], height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
