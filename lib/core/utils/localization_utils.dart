import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

/// Safe translation helper.
///
/// Uses `.tr()` but returns [fallback] when the translation resolves to the
/// key itself (which indicates the localization wasn't loaded yet) or when
/// an exception occurs. Call this from widgets that may be built very early
/// (AppBar tooltips, top-level titles, etc.) to avoid noisy missing-key
/// warnings and temporarily showing the raw key.
String safeTr(BuildContext context, String key, {String fallback = ''}) {
  try {
    final translated = key.tr();
    if (translated == key) return fallback;
    return translated;
  } catch (_) {
    return fallback;
  }
}
