import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
// easy_localization compatibility removed; using Slang `t[...]`

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.accountPrivacy)),
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
