// lib/features/clubs/screens/club_proposal_detail_screen.dart
// 주의: 공유/딥링크를 만들 때 호스트를 직접 하드코딩하지 마세요.
// 대신 `lib/core/constants/app_links.dart`의 `kHostingBaseUrl`을 사용하세요.

import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/models/club_proposal_model.dart';
import 'package:bling_app/features/clubs/screens/edit_club_screen.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bling_app/core/constants/app_links.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart'; // [추가]

class ClubProposalDetailScreen extends StatefulWidget {
  final ClubProposalModel proposal;
  final bool embedded;
  final VoidCallback? onClose;
  const ClubProposalDetailScreen(
      {super.key, required this.proposal, this.embedded = false, this.onClose});

  @override
  State<ClubProposalDetailScreen> createState() =>
      _ClubProposalDetailScreenState();
}

class _ClubProposalDetailScreenState extends State<ClubProposalDetailScreen> {
  final ClubRepository _repo = ClubRepository();
  bool _isProcessing = false;
  late ClubProposalModel _proposal;

  @override
  void initState() {
    super.initState();
    _proposal = widget.proposal;
  }

  bool get _isJoined {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    return _proposal.memberIds.contains(uid);
  }

  double get _progress {
    final p = _proposal.currentMemberCount / _proposal.targetMemberCount;
    return p > 1.0 ? 1.0 : p;
  }

  // [추가] 제안 삭제 함수
  Future<void> _deleteProposal() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.delete'.tr()),
        content: Text('clubs.proposal.deleteConfirm'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('common.delete'.tr(),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repo.deleteClubProposal(_proposal.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('clubs.proposal.deleteSuccess'.tr())));
          Navigator.of(context).pop(); // 화면 닫기
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('clubs.proposal.deleteFail'
                  .tr(namedArgs: {'error': e.toString()}))));
        }
      }
    }
  }

  Future<void> _onJoinPressed() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('clubs.proposal.detail.loginRequired'.tr())),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      if (_isJoined) {
        await _repo.leaveClubProposal(_proposal.id, uid);
        // update local state
        setState(() {
          _proposal = ClubProposalModel(
            id: _proposal.id,
            title: _proposal.title,
            description: _proposal.description,
            ownerId: _proposal.ownerId,
            location: _proposal.location,
            locationParts: _proposal.locationParts,
            geoPoint: _proposal.geoPoint,
            mainCategory: _proposal.mainCategory,
            interestTags: _proposal.interestTags,
            imageUrl: _proposal.imageUrl,
            createdAt: _proposal.createdAt,
            targetMemberCount: _proposal.targetMemberCount,
            currentMemberCount:
                (_proposal.currentMemberCount - 1).clamp(0, 9999),
            memberIds: _proposal.memberIds.where((e) => e != uid).toList(),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('clubs.proposal.detail.left'.tr())),
        );
      } else {
        await _repo.joinClubProposal(_proposal.id, uid);
        // optimistic update: add user and increment count
        setState(() {
          final newIds = List<String>.from(_proposal.memberIds);
          if (!newIds.contains(uid)) newIds.add(uid);
          _proposal = ClubProposalModel(
            id: _proposal.id,
            title: _proposal.title,
            description: _proposal.description,
            ownerId: _proposal.ownerId,
            location: _proposal.location,
            locationParts: _proposal.locationParts,
            geoPoint: _proposal.geoPoint,
            mainCategory: _proposal.mainCategory,
            interestTags: _proposal.interestTags,
            imageUrl: _proposal.imageUrl,
            createdAt: _proposal.createdAt,
            targetMemberCount: _proposal.targetMemberCount,
            currentMemberCount: _proposal.currentMemberCount + 1,
            memberIds: newIds,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('clubs.proposal.detail.joined'.tr())),
        );
      }
    } catch (e) {
      // If join triggered conversion, server may have deleted proposal; handle gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('clubs.proposal.detail.error'
                .tr(namedArgs: {'error': e.toString()}))),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner =
        currentUser != null && currentUser.uid == _proposal.ownerId;

    final inner = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_proposal.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_proposal.imageUrl,
                    width: double.infinity, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            // [추가] 비공개 제안 배지
            if (_proposal.isPrivate)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text('clubs.card.private'.tr(),
                        style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            Text(_proposal.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(_proposal.location,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _proposal.interestTags
                  .map((t) => Chip(label: Text(t)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'clubs.proposal.memberStatus'.tr(namedArgs: {
                'current': _proposal.currentMemberCount.toString(),
                'target': _proposal.targetMemberCount.toString()
              }),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
                percent: _progress,
                lineHeight: 8.0,
                progressColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey[200]!,
                padding: EdgeInsets.zero,
                barRadius: const Radius.circular(4)),
            const SizedBox(height: 8),
            Text(
                '${_proposal.currentMemberCount} / ${_proposal.targetMemberCount}'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('clubs.proposal.members'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildMembersList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _onJoinPressed,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(_isJoined ? Icons.exit_to_app : Icons.group_add),
                label: Text(_isJoined
                    ? 'clubs.proposal.leave'.tr()
                    : 'clubs.proposal.join'.tr()),
              ),
            )
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return Container(color: Colors.white, child: inner);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_proposal.title),
        actions: [
          // V V V --- [수정] 제안자일 경우 수정/삭제 버튼 노출 --- V V V
          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.edit_outlined,
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditClubScreen(proposal: _proposal),
                    ),
                  );
                  if (result == true && mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),

          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'common.delete'.tr(),
              onPressed: _deleteProposal,
            ),

          // 공유 버튼 (항상 표시)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AppBarIcon(
              icon: Icons.share,
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                    text: 'share.club_proposal'.tr(namedArgs: {
                  'title': _proposal.title,
                  'url': '$kHostingBaseUrl/clubs/proposal/${_proposal.id}'
                })),
              ),
            ),
          ),
        ],
      ),
      body: inner,
    );
  }

  Widget _buildMembersList() {
    if (_proposal.memberIds.isEmpty) {
      return Text('clubs.proposal.noMembers'.tr());
    }
    // show up to 10 members using shared AuthorProfileTile (fetches user info)
    final ids = _proposal.memberIds.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ids
          .map((id) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: AuthorProfileTile(userId: id),
              ))
          .toList(),
    );
  }
}
