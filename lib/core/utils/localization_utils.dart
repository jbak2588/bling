import 'package:flutter/widgets.dart';
import 'package:bling_app/i18n/strings.g.dart';

/// Safe translation helper.
String safeTr(BuildContext context, String key, {String fallback = ''}) {
  try {
    // [Fix] t[key]가 dynamic(또는 Object?)이므로 String으로 안전하게 캐스팅하고,
    // null이면 fallback을 반환하도록 수정
    final dynamic value = t[key];

    if (value == null) return fallback;

    return value.toString();
  } catch (_) {
    return fallback;
  }
}
