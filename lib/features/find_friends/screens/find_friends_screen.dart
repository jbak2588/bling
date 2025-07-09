import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class FindFriendsScreen extends StatelessWidget {
  final UserModel? userModel;
  const FindFriendsScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Find Friends Screen'));
}
