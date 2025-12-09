// lib/features/find_friends/screens/find_friend_detail_screen.dart
/// ============================================================================\
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/screens/find_friend_detail_screen.dart
/// Purpose       : 프로필 상세 정보를 보여 주고 친구 요청을 보낼 수 있습니다.
/// User Impact   : 잠재적 친구를 평가하고 연결하는 데 도움을줍니다.
/// Feature Links : lib/features/find_friends/data/find_friend_repository.dart; lib/features/chat/screens/chat_room_screen.dart
/// Data Model    : Firestore `users` 프로필 필드.
/// Location Scope: 사용자 프로필의 `locationName`을 표시하여 지역 매칭에 사용합니다.
/// Privacy Note : 리스트/카드형 피드에서 `locationParts['street']` 또는 전체 `locationName`을 사용자 동의 없이 표시하지 마세요. 피드에는 행정구역을 축약형(`kel.`, `kec.`, `kab.`, `prov.`)으로 간략 표기하세요.
/// Trust Policy  : `trustLevel` 배지를 보여 주며 신고 시 상대방 점수가 감소합니다.
/// Monetization  : 향후 프리미엄 프로필 강조 예정;
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_friend_profile`, `start_chat`.
/// Analytics     : 페이지 조회와 채팅 전환을 추적합니다.
/// I18N          : 키 `findFriend.bioLabel`, `interests.title` (assets/lang/*.json)
/// Dependencies  : cloud_firestore, easy_localization
/// Security/Auth : 본인 프로필 조회를 방지합니다.
///
/// [v2.1 REFACTORING]
/// - '친구 요청' (Friend Request) 로직을 '대화 시작하기' (Start Chat)로 변경.
/// - `friend_requests` 컬렉션을 사용하지 않고 `ChatService`를 통해 즉시 채팅방 생성.
/// - `getRequestStatus` StreamBuilder 제거.
/// - FAB UI 및 로직 변경 (icon: person_add -> chat, action: sendRequest -> startChat).
/// - [작업 10] ChatRoomScreen 탐색 로직을 chatId 기반으로 수정 (user_friend_list.dart 참조)
/// ============================================================================
/// // [v2.1 리팩토링 이력: Job 6-31]
// - (Job 6) 'StreamBuilder' 및 'sendFriendRequest' 로직 삭제.
// - (Job 6, 10, 11) FAB를 '친구 요청'에서 '대화 시작하기'로 변경.
// - (Job 10) 'ChatRoomScreen'의 생성자 변경에 따라 'chatId'를 생성하여 전달하도록 수정.
// - (Job 15, 17) 'isNewChat: true' 플래그를 'ChatRoomScreen'으로 전달.
// - (Job 29-31) 'startFriendChat' Cloud Function을 호출하는 스팸 방지 로직(일일 한도) 적용.
// - [Task 16] 상세 화면 위치 정보 프라이버시 포맷 적용
// - [Task 18] 관심 이웃(즐겨찾기) 기능 추가 및 Firestore 연동

// 주의: 공유/딥링크를 만들 때 호스트를 직접 하드코딩하지 마세요.
// 대신 `lib/core/constants/app_links.dart`의 `kHostingBaseUrl`을 사용하세요.
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:cloud_functions/cloud_functions.dart'; // [v2.1] 스팸 방지 함수 호출
import 'package:share_plus/share_plus.dart';
import 'package:bling_app/features/my_bling/screens/profile_edit_screen.dart';
import 'package:bling_app/core/constants/app_links.dart';
import 'package:bling_app/core/utils/address_formatter.dart';
// ChatService: 채팅방 생성/조회 일원화
import 'package:bling_app/features/chat/data/chat_service.dart';
// import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';

class FindFriendDetailScreen extends StatefulWidget {
  final UserModel user;
  final UserModel currentUserModel;
  final bool embedded;
  final VoidCallback? onClose;

  const FindFriendDetailScreen({
    super.key,
    required this.user,
    required this.currentUserModel,
    this.embedded = false,
    this.onClose,
  });

  @override
  State<FindFriendDetailScreen> createState() => _FindFriendDetailScreenState();
}

class _FindFriendDetailScreenState extends State<FindFriendDetailScreen> {
  late UserModel user;
  late UserModel currentUser;
  bool _isStartingChat = false; // [v2.1] 스팸 방지 로딩 상태
  bool _isBookmarked = false; // [Task 18] 관심 이웃 상태

  // [Task 16] 위치 정보 프라이버시 보호 헬퍼 (카드와 동일 로직 적용)
  String _getSafeLocationText(UserModel user) {
    final formatted = AddressFormatter.formatKelKabFromParts(
        user.locationParts); // kel/kab only
    if (formatted.isNotEmpty) return formatted;
    return '';
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    currentUser = widget.currentUserModel;
    // [Task 18] 초기 즐겨찾기 상태 확인
    _isBookmarked = currentUser.bookmarkedUserIds?.contains(user.uid) ?? false;
  }

  // [Task 18] 관심 이웃 토글 로직
  Future<void> _toggleBookmark() async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(currentUser.uid);
    final targetId = user.uid;

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      if (_isBookmarked) {
        await userRef.update({
          'bookmarkedUserIds': FieldValue.arrayUnion([targetId])
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('friendDetail.bookmarkeded'
                  .tr(namedArgs: {'nickname': user.nickname}))));
        }
      } else {
        await userRef.update({
          'bookmarkedUserIds': FieldValue.arrayRemove([targetId])
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('friendDetail.unbookmarked'
                  .tr(namedArgs: {'nickname': user.nickname}))));
        }
      }
    } catch (e) {
      // 실패 시 롤백
      if (mounted) {
        setState(() => _isBookmarked = !_isBookmarked);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('common.error'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBlockedByMe = currentUser.blockedUsers?.contains(user.uid) ?? false;
    bool amIBlocked = user.blockedUsers?.contains(currentUser.uid) ?? false;

    final content = ListView(
      children: [
        Hero(
          tag: 'profile-image-${user.uid}',
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              image: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(user.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: (user.photoUrl == null || user.photoUrl!.isEmpty)
                  ? Colors.grey[300]
                  : null,
            ),
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? Icon(Icons.person, size: 150, color: Colors.grey[600])
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user.nickname,
                      style: Theme.of(context).textTheme.headlineMedium),
                  TrustLevelBadge(trustLevelLabel: user.trustLevelLabel),
                ],
              ),
              // [Task 16] 상세 화면에서도 정제된 위치 표시
              if (user.locationName != null || user.locationParts != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_getSafeLocationText(user),
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return Container(color: Colors.white, child: content);
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () {
              if (widget.embedded && widget.onClose != null) {
                widget.onClose!();
                return;
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text(user.nickname),
        actions: [
          // 공유 아이콘
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => SharePlus.instance.share(ShareParams(
                text:
                    '${user.nickname}님 프로필 보기: $kHostingBaseUrl/user/${user.uid}')),
          ),
          // [Task 18] 관심 이웃(즐겨찾기) 버튼 추가
          if (currentUser.uid != user.uid) // 본인은 즐겨찾기 불가
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.star : Icons.star_border,
                color: _isBookmarked ? Colors.amber : null,
              ),
              tooltip: _isBookmarked
                  ? 'friendDetail.unbookmarked'.tr()
                  : 'friendDetail.bookmark'.tr(),
              onPressed: _toggleBookmark,
            ),
          // 본인 프로필이면 편집 아이콘 노출
          if (currentUser.uid == user.uid)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
            )
          else ...[
            // 비소유자에게는 차단/신고 아이콘을 직접 노출
            IconButton(
              icon: Icon(isBlockedByMe ? Icons.block_flipped : Icons.block),
              tooltip: isBlockedByMe
                  ? 'friendDetail.unblock'.tr()
                  : 'friendDetail.block'.tr(),
              onPressed: () async {
                final firestore = FirebaseFirestore.instance;
                final userRef =
                    firestore.collection('users').doc(currentUser.uid);
                if (isBlockedByMe) {
                  await userRef.update({
                    'blockedUsers': FieldValue.arrayRemove([user.uid])
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('friendDetail.unblocked'
                              .tr(namedArgs: {'nickname': user.nickname}))),
                    );
                  }
                } else {
                  await userRef.update({
                    'blockedUsers': FieldValue.arrayUnion([user.uid])
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('friendDetail.blocked'
                              .tr(namedArgs: {'nickname': user.nickname}))),
                    );
                  }
                }
                setState(() {
                  isBlockedByMe = !isBlockedByMe;
                  if (isBlockedByMe) {
                    currentUser.blockedUsers?.add(user.uid);
                  } else {
                    currentUser.blockedUsers?.remove(user.uid);
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.flag),
              tooltip: 'common.report'.tr(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('common.report'.tr()),
                    content: const Text("이 사용자를 신고하시겠습니까? (검토 후 조치됩니다)"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('common.cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("신고가 접수되었습니다.")),
                          );
                        },
                        child: Text('common.report'.tr()),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'profile-image-${user.uid}',
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                image: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(user.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? Colors.grey[300]
                    : null,
              ),
              child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                  ? Icon(Icons.person, size: 150, color: Colors.grey[600])
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user.nickname,
                        style: Theme.of(context).textTheme.headlineMedium),
                    // [v2.1] 뱃지 파라미터 수정 (int -> String Label)
                    TrustLevelBadge(trustLevelLabel: user.trustLevelLabel),
                  ],
                ),
                // [Task 16] 리스트 뷰 내부 위치 텍스트도 수정
                if (user.locationName != null || user.locationParts != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_getSafeLocationText(user),
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('findFriend.bioLabel'.tr(),
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(user.bio!, style: Theme.of(context).textTheme.bodyLarge),
                ],
                if (user.interests != null && user.interests!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('interests.title'.tr(),
                      style: Theme.of(context).textTheme.titleSmall),
                  Wrap(
                    spacing: 8.0,
                    children: user.interests!
                        .map((interest) => Chip(label: Text(interest)))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          // [v2.1] '친구 요청' StreamBuilder 제거. '대화 시작하기' FAB로 변경.
          (currentUser.uid == user.uid ||
                  amIBlocked ||
                  isBlockedByMe) // [v2.1] 차단 상태이거나 내 프로필이면 FAB 숨김
              ? null
              : FloatingActionButton.extended(
                  // [v2.1] 로딩 상태에 따라 UI 변경
                  backgroundColor: _isStartingChat
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  heroTag: 'friend_detail_fab',
                  onPressed: _isStartingChat
                      ? null // 로딩 중 탭 방지
                      : () async {
                          // [v2.1] '대화 시작하기' 로직 (스팸 방지 적용)
                          setState(() => _isStartingChat = true);
                          try {
                            // [Task 12] 친구 또는 관심 이웃(찜) 관계인지 확인
                            // 친구 관계라면 일일 제한(Cloud Function)을 우회하고 바로 진입합니다.
                            final bool isAlreadyFriend =
                                (currentUser.friends?.contains(user.uid) ??
                                        false) ||
                                    (currentUser.bookmarkedUserIds
                                            ?.contains(user.uid) ??
                                        false);

                            if (isAlreadyFriend) {
                              // 0. 친구 관계: 제한 없이 즉시 입장 + 보호 모드 해제
                              final chatService = ChatService();
                              final String chatRoomId = await chatService
                                  .createOrGetChatRoom(otherUserId: user.uid);

                              if (mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChatRoomScreen(
                                      chatId: chatRoomId,
                                      otherUserId: user.uid,
                                      otherUserName: user.nickname,
                                      isNewChat: false, // 친구이므로 보호 모드 해제
                                    ),
                                  ),
                                );
                              }
                            } else {
                              // 1. Cloud Function 호출
                              final result =
                                  await FirebaseFunctions.instanceFor(
                                          region: 'asia-southeast2')
                                      .httpsCallable("startFriendChat")
                                      .call({"otherUserId": user.uid});

                              final bool allow = result.data['allow'] ?? false;

                              if (allow) {
                                // 2. 허용됨 (신규 또는 기존)
                                final chatService = ChatService();
                                final String chatRoomId = await chatService
                                    .createOrGetChatRoom(otherUserId: user.uid);
                                // [Task 23] 자동 친구 추가 로직 제거 (사용자 선택권 존중)
                                // 친구 추가는 '관심 이웃(Star)' 또는 추후 '친구 맺기' 액션을 통해서만 이루어짐.
                                if (mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        chatId: chatRoomId,
                                        otherUserId: user.uid,
                                        otherUserName: user.nickname,
                                        // [v2.1] 기존 채팅이 아닐 때만 보호 모드 활성화
                                        isNewChat:
                                            !(result.data['isExisting'] ??
                                                false),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                // 3. 한도 도달로 거부됨
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'findFriend.chatLimitReached'
                                              .tr(namedArgs: {
                                        'limit':
                                            result.data['limit']?.toString() ??
                                                '5'
                                      })),
                                    ),
                                  );
                                }
                              }
                            }
                          } catch (e) {
                            // 4. 함수 호출 오류
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "${"friendDetail.chatError".tr()} ${e.toString()}")),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isStartingChat = false);
                            }
                          }
                        },
                  label: _isStartingChat
                      ? Text("findFriend.chatChecking".tr()) // "확인 중..."
                      : Text("friendDetail.startChat".tr()), // "대화 시작"
                  icon: _isStartingChat
                      // [v2.1] Container -> SizedBox로 변경 (경고 수정)
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.chat_bubble_outline), // [v2.1] 아이콘 변경
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
