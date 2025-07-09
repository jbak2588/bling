import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class LocalStoresScreen extends StatelessWidget {
  final UserModel? userModel;
  const LocalStoresScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Local Stores Screen'));
}
