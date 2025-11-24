import 'package:flutter/material.dart';
import 'package:bling_app/i18n/strings.g.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(t.community.title));
  }
}
