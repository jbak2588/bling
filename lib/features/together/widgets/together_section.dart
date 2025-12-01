// lib/features/together/widgets/together_section.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/screens/together_detail_screen.dart';
import 'package:bling_app/features/together/screens/together_screen.dart';
import 'package:bling_app/features/together/widgets/together_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TogetherSection extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final Function(Widget, String) onIconTap;

  const TogetherSection({
    super.key,
    required this.userModel,
    required this.locationFilter,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240, // 카드 높이에 맞춰 조정 (Overflow 방지된 카드 사용)
      child: StreamBuilder<List<TogetherPostModel>>(
        stream: TogetherRepository().fetchActivePosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) return const SizedBox();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: posts.length + 1, // +1 for View More
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return _buildViewMoreCard(context);
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 160,
                  child: TogetherCard(
                    post: posts[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TogetherDetailScreen(post: posts[index]),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildViewMoreCard(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          if (userModel == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('main.errors.loginRequired'.tr())),
            );
            return;
          }
          final nextScreen = TogetherScreen(
              userModel: userModel, locationFilter: locationFilter);
          onIconTap(nextScreen, 'home.menu.together');
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 160,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.more_horiz,
                  size: 32,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(height: 8),
              Text('common.viewMore'.tr(),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
