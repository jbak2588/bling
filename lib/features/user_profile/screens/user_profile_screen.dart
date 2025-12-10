// lib/features/user_profile/screens/user_profile_screen.dart

import 'package:bling_app/features/user_profile/screens/profile_setup_screen.dart'; // [New] 수정 화면 연결
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/core/utils/address_formatter.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart'; // [New] 줌/슬라이더 지원

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isMe; // 내 프로필인지 여부

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isMe = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // 데이터 갱신을 위해 FutureBuilder 대신 별도 로드 로직이나 setState 활용이 필요할 수 있으나,
  // 여기서는 상세 화면 진입 시마다 새로 데이터를 가져오도록 FutureBuilder 유지하되
  // 수정 후 복귀 시 갱신을 위해 setState를 트리거할 수 있는 구조로 변경.

  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<UserModel?> _fetchUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
    return null;
  }

  // [New] 수정 화면으로 이동하고 돌아왔을 때 데이터 새로고침
  Future<void> _navigateToEdit(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSetupScreen(
          userModel: user,
          isEditMode: true,
        ),
      ),
    );

    // 수정 화면에서 true를 반환하면(저장 성공 시) 화면 갱신
    if (result == true) {
      setState(() {
        _userFuture = _fetchUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        // 데이터 로딩 중이거나 에러가 있을 때도 기본적인 스캐폴드는 보여줌
        final user = snapshot.data;

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
              // [New] 내 프로필이면 수정 버튼 활성화
              if (widget.isMe && user != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEdit(user),
                )
            ],
          ),
          body: user == null
              ? (snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : const Center(child: Text("User not found")))
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 프로필 이미지 영역 (단일 or 멀티 슬라이더)
                      _buildProfileHeaderImage(user),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. 기본 정보 (닉네임, 주소, 신뢰등급)
                            _buildBasicInfo(user),
                            const SizedBox(height: 32),

                            // 3. 신뢰 정보 (전화번호 인증 여부)
                            _buildSectionHeader('profile.section.trust'.tr()),
                            const SizedBox(height: 8),
                            _buildTrustInfo(user),
                            const SizedBox(height: 32),

                            // 4. 소셜 정보 (친구 찾기 활성화 시에만 표시)
                            if (user.isVisibleInList == true)
                              _buildSocialInfo(user),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // [New] 프로필 이미지 영역 개선
  // 친구 찾기 사진이 있으면 슬라이더로 보여주고, 없으면 기존 원형 아바타 사용
  Widget _buildProfileHeaderImage(UserModel user) {
    // 친구 찾기용 추가 이미지가 있는지 확인
    final hasSocialImages = user.findfriendProfileImages != null &&
        user.findfriendProfileImages!.isNotEmpty;

    // 보여줄 이미지 리스트 구성
    List<String> imagesToShow = [];
    if (hasSocialImages) {
      imagesToShow = user.findfriendProfileImages!;
    } else if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      imagesToShow = [user.photoUrl!];
    }

    // 이미지가 여러 장이면 상단에 꽉 찬 슬라이더로 표시
    if (imagesToShow.length > 1) {
      return ImageCarouselCard(
        storageId: 'profile-${user.uid}', // 고유 ID
        imageUrls: imagesToShow,
        height: 350, // 프로필용으로 조금 더 크게
        width: double.infinity,
      );
    }

    // 이미지가 1장 이하이거나 없을 때는 기존 스타일 (원형 아바타 중심) 유지
    // 단, 디자인 통일성을 위해 상단 배경을 두고 그 위에 아바타를 얹는 방식 고려 가능하나,
    // 여기서는 기존 로직과 호환되게 처리.
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Hero(
          tag: 'profile-img-${user.uid}',
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(UserModel user) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.nickname,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              TrustLevelBadge(trustLevelLabel: user.trustLevelLabel),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AddressFormatter.toSingkatan(user.locationName ?? '') != ''
                ? AddressFormatter.toSingkatan(user.locationName ?? '')
                : 'profile.view.locationUnknown'.tr(),
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'profile.view.joined'.tr(args: [
              DateFormat('yyyy.MM.dd').format(user.createdAt.toDate())
            ]),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustInfo(UserModel user) {
    final bool isPhoneVerified =
        user.phoneNumber != null && user.phoneNumber!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPhoneVerified
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPhoneVerified
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPhoneVerified ? Icons.verified_user : Icons.no_accounts,
            color: isPhoneVerified ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isPhoneVerified
                  ? 'profile.view.phoneVerified'.tr()
                  : 'profile.view.phoneUnverified'.tr(),
              style: TextStyle(
                color: isPhoneVerified ? Colors.green[800] : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialInfo(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
