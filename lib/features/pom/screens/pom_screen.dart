import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/user_model.dart';

class PomScreen extends StatelessWidget {
  final UserModel? userModel;
  const PomScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('main.tabs.pom'.tr()));
}
