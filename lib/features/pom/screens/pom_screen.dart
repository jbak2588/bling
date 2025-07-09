import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class PomScreen extends StatelessWidget {
  final UserModel? userModel;
  const PomScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Pom Screen'));
}
