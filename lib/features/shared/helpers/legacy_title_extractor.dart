String? legacyExtractTitle(dynamic item) {
  if (item == null) return null;
  String? val;
  try {
    val = (item.title as String?);
    if (val != null && val.isNotEmpty) return val;
  } catch (_) {}
  try {
    val = (item.name as String?);
    if (val != null && val.isNotEmpty) return val;
  } catch (_) {}
  try {
    val = (item.headline as String?);
    if (val != null && val.isNotEmpty) return val;
  } catch (_) {}
  try {
    val = (item.itemDescription as String?);
    if (val != null && val.isNotEmpty) return val;
  } catch (_) {}
  try {
    val = (item.body as String?);
    if (val != null && val.isNotEmpty) return val;
  } catch (_) {}
  return null;
}
