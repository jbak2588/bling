import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('community.title'.tr()));
  }
}
