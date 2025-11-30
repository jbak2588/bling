// lib/features/together/screens/edit_together_screen.dart

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTogetherScreen extends StatefulWidget {
  final TogetherPostModel post;

  const EditTogetherScreen({super.key, required this.post});

  @override
  State<EditTogetherScreen> createState() => _EditTogetherScreenState();
}

class _EditTogetherScreenState extends State<EditTogetherScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  late DateTime _selectedDate;
  late String _selectedTheme;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _locationController = TextEditingController(text: widget.post.location);
    _selectedDate = widget.post.meetTime.toDate();
    _selectedTheme = widget.post.designTheme;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updatedPost = TogetherPostModel(
        id: widget.post.id,
        hostId: widget.post.hostId,
        title: _titleController.text,
        description: _descController.text,
        meetTime: Timestamp.fromDate(_selectedDate),
        location: _locationController.text,
        maxParticipants: widget.post.maxParticipants,
        participants: widget.post.participants,
        qrCodeString: widget.post.qrCodeString,
        designTheme: _selectedTheme,
        status: widget.post.status,
        createdAt: widget.post.createdAt, // 생성일은 유지
      );

      await TogetherRepository().updatePost(updatedPost);

      if (!mounted) return;
      Navigator.pop(context); // 수정 완료 후 닫기
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("전단지 수정하기")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "무엇을 함께 할까요? (제목)"),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("언제 모일까요?"),
              subtitle: Text(
                  "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
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
                icon: const Icon(Icons.save),
                label: const Text("수정 완료"),
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
