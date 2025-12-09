// lib/features/user_profile/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/core/utils/address_formatter.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
// import 'package:timeago/timeago.dart' as timeago; // unused

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final bool isMe; // 내 프로필인지 여부

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isMe = false,
  });

  Future<UserModel?> _fetchUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text('profile.view.title'.tr()), // "프로필"
        actions: [
          if (isMe)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: 내 프로필 수정 화면으로 이동 (MainNavigation 등에서 처리)
              },
            )
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found"));
          }

          final user = snapshot.data!;
          final bool isPhoneVerified =
              user.phoneNumber != null && user.phoneNumber!.isNotEmpty;
          final bool isSocialEnabled = user.isVisibleInList ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 헤더 (사진, 닉네임, 기본정보)
                Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'profile-img-${user.uid}',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (user.photoUrl != null &&
                                  user.photoUrl!.isNotEmpty)
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child:
                              (user.photoUrl == null || user.photoUrl!.isEmpty)
                                  ? const Icon(Icons.person,
                                      size: 50, color: Colors.grey)
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.nickname,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          TrustLevelBadge(
                              trustLevelLabel: user.trustLevelLabel),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // 주소 포맷팅
                        AddressFormatter.toSingkatan(user.locationName ?? '') !=
                                ''
                            ? AddressFormatter.toSingkatan(
                                user.locationName ?? '')
                            : 'profile.view.locationUnknown'.tr(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'profile.view.joined'.tr(args: [
                          DateFormat('yyyy.MM.dd')
                              .format(user.createdAt.toDate())
                        ]),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. 신뢰 정보 (전화번호 인증 여부)
                _buildSectionHeader('profile.section.trust'.tr()),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPhoneVerified
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isPhoneVerified
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPhoneVerified
                            ? Icons.verified_user
                            : Icons.no_accounts,
                        color: isPhoneVerified ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isPhoneVerified
                            ? 'profile.view.phoneVerified'.tr()
                            : 'profile.view.phoneUnverified'.tr(),
                        style: TextStyle(
                          color: isPhoneVerified
                              ? Colors.green[800]
                              : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. 소셜 정보 (친구 찾기 활성화 시에만 표시)
                if (isSocialEnabled) ...[
                  _buildSectionHeader('profile.view.aboutMe'.tr()), // "자기소개"
                  const SizedBox(height: 8),
                  Text(
                    user.bio ?? 'profile.view.noBio'.tr(),
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  if (user.interests != null && user.interests!.isNotEmpty) ...[
                    _buildSectionHeader('profile.view.interests'.tr()), // "관심사"
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.interests!
                          .map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.white,
                                shape: StadiumBorder(
                                    side: BorderSide(color: Colors.grey[300]!)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
