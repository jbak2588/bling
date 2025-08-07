// lib/features/clubs/screens/club_detail_screen.dart

import 'package:bling_app/core/models/club_member_model.dart';
import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class ClubDetailScreen extends StatefulWidget {
  final ClubModel club;
  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final ClubRepository _repository = ClubRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // 동호회 가입 로직
  Future<void> _joinClub() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("로그인이 필요합니다."))); // TODO: 다국어
      return;
    }

    try {
      final newMember = ClubMemberModel(
        id: _currentUserId!,
        userId: _currentUserId!,
        joinedAt: Timestamp.now(),
      );
      await _repository.addMember(widget.club.id, newMember);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'${widget.club.title}' 동호회에 가입했습니다!"), backgroundColor: Colors.green), // TODO: 다국어
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("가입에 실패했습니다: $e"), backgroundColor: Colors.red), // TODO: 다국어
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. 동호회 제목 및 설명
          Text(
            widget.club.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            widget.club.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const Divider(height: 32),

          // 2. 멤버 수 및 활동 지역 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn(
                icon: Icons.group_outlined,
                label: 'Members', // TODO: 다국어
                value: widget.club.membersCount.toString(),
              ),
              _buildInfoColumn(
                icon: Icons.location_on_outlined,
                label: 'Location', // TODO: 다국어
                value: widget.club.location,
              ),
            ],
          ),
          const Divider(height: 32),

          // 3. 관심사 태그
          Text(
            "interests.title".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: widget.club.interestTags.map((interestKey) {
              return Chip(
                avatar: const Icon(Icons.tag, size: 16),
                label: Text("interests.items.$interestKey".tr()),
              );
            }).toList(),
          ),
        ],
      ),
      // [수정] StreamBuilder를 사용하여 가입 상태에 따라 버튼을 동적으로 변경
      floatingActionButton: StreamBuilder<bool>(
        stream: _repository.isCurrentUserMember(widget.club.id),
        builder: (context, snapshot) {
          final isMember = snapshot.data ?? false;

          // 이미 멤버인 경우
          if (isMember) {
            return FloatingActionButton.extended(
              onPressed: () {
                // TODO: 동호회 채팅방으로 이동하는 로직
              },
              label: Text('채팅 참여하기'), // TODO: 다국어
              icon: const Icon(Icons.chat_bubble_outline),
              backgroundColor: Colors.teal,
            );
          }
          
          // 아직 멤버가 아닌 경우
          return FloatingActionButton.extended(
            onPressed: _joinClub,
            label: Text('동호회 가입하기'), // TODO: 다국어
            icon: const Icon(Icons.add),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoColumn({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}