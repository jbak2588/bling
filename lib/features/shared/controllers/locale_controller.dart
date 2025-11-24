import 'package:flutter/material.dart';
import 'package:bling_app/i18n/strings.g.dart';

class LocaleController {
  // (기존 메소드들...)

  // 언어 변경 함수 (이름은 다를 수 있으니 로직을 참고하세요)
  Future<void> changeLocale(BuildContext context, Locale locale) async {
    // Replace EasyLocalization API with Slang LocaleSettings
    LocaleSettings.setLocaleRaw(locale.languageCode);
  }
}
