import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class ClubsScreen extends StatelessWidget {
  final UserModel? userModel;
  const ClubsScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Clubs Screen'));
}

