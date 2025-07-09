import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class JobsScreen extends StatelessWidget {
  final UserModel? userModel;
  const JobsScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Jobs Screen'));
}
