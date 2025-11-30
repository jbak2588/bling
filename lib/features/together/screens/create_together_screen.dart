// lib/features/together/screens/create_together_screen.dart

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateTogetherScreen extends StatefulWidget {
  const CreateTogetherScreen({super.key});

  @override
  State<CreateTogetherScreen> createState() => _CreateTogetherScreenState();
}

class _CreateTogetherScreenState extends State<CreateTogetherScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate =
      DateTime.now().add(const Duration(hours: 1)); // 기본 1시간 뒤
  String _selectedTheme = 'neon';
  bool _isSubmitting = false;

// [수정 코드]
  void _submit() async {
    // ✅ [Fix] 중괄호 {} 추가로 스타일 경고 해결
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final newPost = TogetherPostModel(
        id: const Uuid().v4(),
        hostId: user.uid,
        title: _titleController.text,
        description: _descController.text,
        meetTime: Timestamp.fromDate(_selectedDate),
        location: _locationController.text,
        maxParticipants: 4, // MVP: 4명 고정
        participants: [user.uid], // 주최자 자동 참여
        qrCodeString: const Uuid().v4(), // 고유 QR 코드 생성
        designTheme: _selectedTheme,
        createdAt: Timestamp.now(),
      );

      await TogetherRepository().createPost(newPost);

      if (!mounted) return;
      Navigator.pop(context); // 생성 후 닫기
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("전단지 만들기")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 디자인 선택
            const Text("디자인 테마", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: ['neon', 'paper', 'dark'].map((theme) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedTheme = theme),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _getThemeColor(theme),
                      border: _selectedTheme == theme
                          ? Border.all(color: Colors.blue, width: 3)
                          : Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 2. 입력 필드
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: "무엇을 함께 할까요? (제목)", hintText: "예: 한강 러닝, 담배 타임"),
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                  labelText: "어디서 모일까요? (장소)",
                  prefixIcon: Icon(Icons.location_on_outlined)),
            ),
            const SizedBox(height: 16),

            // 3. 시간 선택
            // 3. 시간 선택
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("언제 모일까요?"),
              subtitle: Text(
                  "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                // ✅ [Fix] 날짜 및 시간 선택 로직 구현 (변수 업데이트로 final 경고 해결)
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );

                if (pickedDate != null && mounted) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: const Icon(Icons.print),
                label: const Text("전단지 붙이기 (생성)"),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getThemeColor(String theme) {
    if (theme == 'neon') return const Color(0xFFCCFF00);
    if (theme == 'paper') return const Color(0xFFF5F5DC);
    return const Color(0xFF2C2C2C);
  }
}
