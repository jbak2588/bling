import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppInfoScreen extends StatelessWidget {
  final bool embedded;
  const AppInfoScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final bodyStyle = theme.textTheme.bodyMedium;

    final content = ListView(
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
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.info_outline,
                    size: 48, color: theme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text('appInfo.appName'.tr(),
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('appInfo.version'.tr(),
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 2. 서비스 소개
        Text('appInfo.serviceIntroTitle'.tr(), style: titleStyle),
        const SizedBox(height: 8),
        Text(
          'appInfo.serviceIntroBody'.tr(),
          style: bodyStyle,
        ),
        const Divider(height: 40),

        // 3. 주요 기능 (11개 섹션)
        Text('appInfo.keyFeaturesTitle'.tr(), style: titleStyle),
        const SizedBox(height: 16),
        _buildFeatureRow(
            context,
            Icons.volunteer_activism,
            'appInfo.features.together.title'.tr(),
            'appInfo.features.together.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.article,
            'appInfo.features.localNews.title'.tr(),
            'appInfo.features.localNews.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.store_mall_directory,
            'appInfo.features.marketplace.title'.tr(),
            'appInfo.features.marketplace.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.work,
            'appInfo.features.jobs.title'.tr(),
            'appInfo.features.jobs.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.report_problem,
            'appInfo.features.lostAndFound.title'.tr(),
            'appInfo.features.lostAndFound.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.store,
            'appInfo.features.localStores.title'.tr(),
            'appInfo.features.localStores.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.people,
            'appInfo.features.findFriends.title'.tr(),
            'appInfo.features.findFriends.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.groups,
            'appInfo.features.clubs.title'.tr(),
            'appInfo.features.clubs.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.home,
            'appInfo.features.realEstate.title'.tr(),
            'appInfo.features.realEstate.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.gavel,
            'appInfo.features.auction.title'.tr(),
            'appInfo.features.auction.desc'.tr()),
        _buildFeatureRow(
            context,
            Icons.video_library,
            'appInfo.features.pom.title'.tr(),
            'appInfo.features.pom.desc'.tr()),
        const Divider(height: 40),

        // 4. 개발 정보
        Text('appInfo.developmentTitle'.tr(), style: titleStyle),
        const SizedBox(height: 8),
        Text('appInfo.developmentBody'.tr(), style: bodyStyle),
        const SizedBox(height: 4),
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
