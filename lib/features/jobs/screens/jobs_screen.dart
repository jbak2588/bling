import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/user_model.dart';

class JobsScreen extends StatelessWidget {
  final UserModel? userModel;
  const JobsScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('main.tabs.jobs'.tr()));
}
