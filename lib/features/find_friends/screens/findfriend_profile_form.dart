// lib/features/find_friends/screens/findfriend_profile_form.dart
// Basic form for creating or editing FindFriend profile

import 'package:flutter/material.dart';
import '../../../core/models/findfriend_model.dart';

class FindFriendProfileForm extends StatefulWidget {
  final FindFriend? profile;
  final void Function(FindFriend profile)? onSave;
  const FindFriendProfileForm({this.profile, this.onSave, super.key});

  @override
  State<FindFriendProfileForm> createState() => _FindFriendProfileFormState();
}

class _FindFriendProfileFormState extends State<FindFriendProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nickname;
  late bool _isDatingProfile;

  @override
  void initState() {
    super.initState();
    _nickname = widget.profile?.nickname ?? '';
    _isDatingProfile = widget.profile?.isDatingProfile ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                initialValue: _nickname,
                decoration: const InputDecoration(labelText: 'Nickname'),
                onSaved: (v) => _nickname = v ?? '',
              ),
              SwitchListTile(
                title: const Text('Dating Profile'),
                value: _isDatingProfile,
                onChanged: (v) => setState(() => _isDatingProfile = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    _formKey.currentState?.save();
    final profile = FindFriend(
      userId: widget.profile?.userId ?? '',
      nickname: _nickname,
      profileImages: widget.profile?.profileImages ?? [],
      isDatingProfile: _isDatingProfile,
    );
    widget.onSave?.call(profile);
    Navigator.of(context).pop();
  }
}
