import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
// easy_localization compatibility removed; using Slang `t[...]`

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.appInfo)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 48, color: Theme.of(context).hintColor),
            const SizedBox(height: 12),
            Text('Bling App', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('v1.0.0', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
