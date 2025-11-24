// lib/features/clubs/screens/club_proposal_detail_screen.dart

import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/models/club_proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';

class ClubProposalDetailScreen extends StatefulWidget {
  final ClubProposalModel proposal;
  const ClubProposalDetailScreen({super.key, required this.proposal});

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

  Future<void> _onJoinPressed() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.clubs.proposal.detail.loginRequired)),
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
          SnackBar(content: Text(t.clubs.proposal.detail.left)),
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
          SnackBar(content: Text(t.clubs.proposal.detail.joined)),
        );
      }
    } catch (e) {
      // If join triggered conversion, server may have deleted proposal; handle gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t.clubs.proposal.detail.error
                .replaceAll('{error}', e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_proposal.title)),
      body: SingleChildScrollView(
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
              Text(_proposal.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(_proposal.location,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey))),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _proposal.interestTags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                t.clubs.proposal.memberStatus
                    .replaceAll(
                        '{current}', _proposal.currentMemberCount.toString())
                    .replaceAll(
                        '{target}', _proposal.targetMemberCount.toString()),
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
              Text(t.clubs.proposal.members,
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
                      ? t.clubs.proposal.leave
                      : t.clubs.proposal.join),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    if (_proposal.memberIds.isEmpty) {
      return Text(t.clubs.proposal.noMembers);
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
