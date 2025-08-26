/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/screens/find_friends_screen.dart
/// Purpose       : 관심사와 위치 기반으로 주변 사용자를 탐색하고 연결합니다.
/// User Impact   : 주민이 1~5km 내 이웃이나 데이팅 매치를 발견하도록 돕습니다.
/// Feature Links : lib/features/find_friends/screens/find_friend_detail_screen.dart; lib/features/find_friends/screens/findfriend_form_screen.dart; lib/features/find_friends/widgets/findfriend_card.dart
/// Data Model    : `users/{uid}`와 `/users/{uid}/findfriend_profile/main`을 읽고 관계는 `follows` 컬렉션을 사용합니다.
/// Location Scope: Province→Kabupaten/Kota→Kecamatan→Kelurahan로 필터링하며 LocationFilterScreen을 통한 선택적 RT/RW; 기본값은 사용자 `locationParts`입니다.
/// Trust Policy  : `isDatingProfile`이 true이고 TrustLevel 기준을 충족해야 하며 `blockedUsers`를 존중합니다.
/// Monetization  : 향후 프로필 노출 프리미엄 부스트 예정; TODO.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `profile_view`, `start_follow`, `start_chat`.
/// Analytics     : 필터 사용과 프로필 노출을 추적합니다.
/// I18N          : 키 `findFriend.prompt_title`, `findFriend.prompt_button` (assets/lang/*.json)
/// Dependencies  : easy_localization, lib/features/find_friends/data/find_friend_repository.dart, lib/features/location/screens/location_filter_screen.dart
/// Security/Auth : 인증된 접근이 필요하며 나이와 개인정보 설정을 적용합니다.
/// Edge Cases    : 프로필 미완성, 위치 필터 없음, 결과 없음.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/012  Find Friend & Club & Jobs & etc 모듈.md; docs/Bling FindFriend DB 구조 설계 문서.md
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/find_friends/widgets/findfriend_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'findfriend_form_screen.dart';

class FindFriendsScreen extends StatefulWidget {
  final UserModel? userModel;
  const FindFriendsScreen({this.userModel, super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  Map<String, String?>? _locationFilter;

  Future<void> _openLocationFilter() async {
    final raw = await Navigator.push<Map<String, String?>>(
      context,
      MaterialPageRoute(
          builder: (_) => LocationFilterScreen(userModel: widget.userModel)),
    );
    if (raw != null) {
      setState(() {
        _locationFilter = {
          'prov': raw['prov'],
          'kab': raw['kab'] ?? raw['kota'],
          'kec': raw['kec'],
          'kel': raw['kel'],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = widget.userModel;
    if (userModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userModel.isDatingProfile != true) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                "findFriend.prompt_title".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FindFriendFormScreen(userModel: userModel)),
                  );
                },
                child: Text("findFriend.prompt_button".tr()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<List<UserModel>>(
        stream: FindFriendRepository()
            .getUsersForFindFriends(userModel, locationFilter: _locationFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("findFriend.noFriendsFound".tr()));
          }

          final userList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FindFriendDetailScreen(
                          user: user, currentUserModel: userModel),
                    ),
                  );
                },
                child: FindFriendCard(user: user),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'find_friends_filter',
            onPressed: _openLocationFilter,
            tooltip: 'locationFilter.title'.tr(),
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'find_friends_edit_profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FindFriendFormScreen(userModel: userModel)),
              );
            },
            tooltip: "findFriend.editProfileTitle".tr(),
            child: const Icon(Icons.edit_note_outlined),
          ),
        ],
      ),
    );
  }
}
