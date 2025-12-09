// lib/features/find_friends/screens/create_friend_post_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 필수
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/models/friend_post_model.dart';
import 'package:bling_app/features/find_friends/data/friend_post_repository.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/features/shared/grab_widgets.dart'; // GrabAppBarShell

class CreateFriendPostScreen extends StatefulWidget {
  final UserModel userModel;
  final FriendPostModel? post; // 수정 시 전달

  const CreateFriendPostScreen({
    super.key,
    required this.userModel,
    this.post,
  });

  @override
  State<CreateFriendPostScreen> createState() => _CreateFriendPostScreenState();
}

class _CreateFriendPostScreenState extends State<CreateFriendPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  List<String> _tags = [];
  bool _isMultiChat = false;
  double _maxParticipants = 2.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      // 수정 모드 초기값 설정
      _contentController.text = widget.post!.content;
      _tags = List.from(widget.post!.tags);
      _isMultiChat = widget.post!.isMultiChat;
      _maxParticipants = widget.post!.maxParticipants.toDouble();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('friendPost.create.error.tagRequired'.tr())), // [작업 12]
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = FriendPostRepository();

      if (widget.post != null) {
        // 수정 (Update)
        await repo.updatePost(widget.post!.id, {
          'content': _contentController.text.trim(),
          'tags': _tags,
          'isMultiChat': _isMultiChat,
          'maxParticipants': _maxParticipants.toInt(),
          // 위치 정보는 수정 시 업데이트하지 않음 (정책에 따라 변경 가능)
        });
      } else {
        // 생성 (Create)
        final newPost = FriendPostModel(
          id: '', // Firestore가 생성
          authorId: widget.userModel.uid,
          authorNickname: widget.userModel.nickname,
          authorPhotoUrl: widget.userModel.photoUrl,
          content: _contentController.text.trim(),
          tags: _tags,
          createdAt: Timestamp.now(),
          expiresAt: Timestamp.fromDate(
              DateTime.now().add(const Duration(hours: 24))), // 24시간 후 만료
          locationName: widget.userModel.locationName,
          locationParts: widget.userModel.locationParts,
          isMultiChat: _isMultiChat,
          maxParticipants: _isMultiChat ? _maxParticipants.toInt() : 2,
          currentParticipantIds: [widget.userModel.uid], // 작성자 포함
        );
        await repo.createPost(newPost);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.post != null
                  ? "friendPost.create.snackbar.edited".tr()
                  : "friendPost.create.snackbar.created".tr())), // [작업 12]
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.post != null;

    return Scaffold(
      appBar: GrabAppBarShell(
        title: Text(isEdit
            ? "friendPost.create.title.edit".tr()
            : "friendPost.create.title.create".tr()), // [작업 12]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 내용 입력
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: "friendPost.create.contentHint".tr(), // [작업 12]
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return "friendPost.create.error.contentShort"
                        .tr(); // [작업 12]
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. 태그 입력
              Text("friendPost.create.tagLabel".tr(),
                  style:
                      const TextStyle(fontWeight: FontWeight.bold)), // [작업 12]
              const SizedBox(height: 8),
              CustomTagInputField(
                initialTags: _tags,
                hintText: "friendPost.create.tagHint".tr(), // [작업 12]
                onTagsChanged: (tags) {
                  setState(() => _tags = tags);
                },
              ),
              const SizedBox(height: 24),

              // 3. 채팅 설정 (수정 시에는 변경 불가하게 할 수도 있으나 여기선 허용)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("friendPost.create.groupChatTitle".tr(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)), // [작업 12]
                      subtitle: Text("friendPost.create.groupChatSubtitle"
                          .tr()), // [작업 12]
                      value: _isMultiChat,
                      onChanged: (val) {
                        setState(() {
                          _isMultiChat = val;
                          if (!val) _maxParticipants = 2; // 1:1은 2명
                        });
                      },
                    ),
                    if (_isMultiChat) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("friendPost.create.maxParticipants"
                              .tr()), // [작업 12]
                          Text("${_maxParticipants.toInt()}명",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: _maxParticipants,
                        min: 2,
                        max: 10, // 최대 10명 제한 (정책)
                        divisions: 8,
                        label: "${_maxParticipants.toInt()}명",
                        onChanged: (val) =>
                            setState(() => _maxParticipants = val),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. 완료 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEdit
                              ? "friendPost.create.button.edit".tr()
                              : "friendPost.create.button.create"
                                  .tr(), // [작업 12]
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
