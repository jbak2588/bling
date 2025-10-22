import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.appInfo'.tr())),
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
