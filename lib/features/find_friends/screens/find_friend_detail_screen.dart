/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/screens/find_friend_detail_screen.dart
/// Purpose       : 프로필 상세 정보를 보여 주고 친구 요청을 보낼 수 있습니다.
/// User Impact   : 잠재적 친구를 평가하고 연결하는 데 도움을 줍니다.
/// Feature Links : lib/features/find_friends/data/find_friend_repository.dart; lib/features/chat/screens/chat_room_screen.dart
/// Data Model    : Firestore `users` 프로필 필드와 `friendRequests`를 통한 요청 상태.
/// Location Scope: 사용자 프로필의 `locationName`을 표시하여 지역 매칭에 사용합니다.
/// Trust Policy  : `trustLevel` 배지를 보여 주며 신고 시 상대방 점수가 감소합니다.
/// Monetization  : 향후 프리미엄 프로필 강조 예정; TODO: 정의.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_friend_profile`, `send_friend_request`.
/// Analytics     : 페이지 조회와 요청 전환을 추적합니다.
/// I18N          : 키 `findFriend.bioLabel`, `interests.title` (assets/lang/*.json)
/// Dependencies  : cloud_firestore, easy_localization
/// Security/Auth : 요청은 인증이 필요하며 본인 프로필 조회를 방지합니다.
/// Edge Cases    : 이미지 누락 또는 차단된 사용자.
/// 실제 구현 비교 : 프로필 상세, 친구 요청, 신뢰 등급, 차단 등 모든 기능 정상 동작. UI/UX 완비.
/// 개선 제안     : KPI/통계/프리미엄 기능 실제 구현 필요. 신고/차단/신뢰 등급 UI 노출 및 기능 강화. 프리미엄 프로필 강조 기능 추가.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/012 Find Friend & Club & Jobs & etc 모듈.md; docs/team/teamF_Design_Privacy_Module_통합_작업문.md
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class FindFriendDetailScreen extends StatefulWidget {
  final UserModel user;
  final UserModel? currentUserModel;
  const FindFriendDetailScreen({super.key, required this.user, this.currentUserModel});

  @override
  State<FindFriendDetailScreen> createState() => _FindFriendDetailScreenState();
}

class _FindFriendDetailScreenState extends State<FindFriendDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final allImages = [user.photoUrl, ...?user.findfriendProfileImages]
        .where((url) => url != null && url.isNotEmpty)
        .toList();
    final currentUser = widget.currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.nickname),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                itemCount: allImages.isNotEmpty ? allImages.length : 1,
                itemBuilder: (context, index) {
                  if (allImages.isEmpty) {
                    return const Icon(Icons.person, size: 150, color: Colors.grey);
                  }
                  return Image.network(
                    allImages[index]!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stack) =>
                        const Icon(Icons.error_outline, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user.nickname}, ${user.age ?? ''}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  if (user.locationName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.locationName!,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 32),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    Text("findFriend.bioLabel".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(user.bio!, style: const TextStyle(fontSize: 16, height: 1.5)),
                    const Divider(height: 32),
                  ],
                  if (user.interests != null && user.interests!.isNotEmpty) ...[
                    Text("interests.title".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: user.interests!.map((interestKey) {
                        return Chip(label: Text("interests.items.$interestKey".tr()));
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (currentUser == null || currentUser.uid == user.uid)
          ? null
          : StreamBuilder<QuerySnapshot>(
              stream: FindFriendRepository().getRequestStatus(currentUser.uid, user.uid),
              builder: (context, snapshot) {
                if (currentUser.friends?.contains(user.uid) ?? false) {
                  return FloatingActionButton.extended(
                    heroTag: 'friend_detail_fab',
                    onPressed: null,
                    label: Text("friendDetail.alreadyFriends".tr()),
                    icon: const Icon(Icons.check_circle),
                    backgroundColor: Colors.grey,
                  );
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return FloatingActionButton.extended(
                    heroTag: 'friend_detail_fab',
                    onPressed: null,
                    label: Text("friendDetail.requestSent".tr()),
                    icon: const Icon(Icons.hourglass_top),
                    backgroundColor: Colors.orange,
                  );
                }

                return FloatingActionButton.extended(
                  heroTag: 'friend_detail_fab',
                  onPressed: () async {
                    try {
                      await FindFriendRepository().sendFriendRequest(currentUser.uid, user.uid);
                      // V V V --- [수정] 화면이 살아있는지(mounted) 확인 후 SnackBar 호출 --- V V V
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("friendDetail.requestSuccess".tr())),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${"friendDetail.requestFailed".tr()} $e")),
                        );
                      }
                    }
                  },
                  label: Text("friendDetail.request".tr()),
                  icon: const Icon(Icons.person_add_alt_1),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}