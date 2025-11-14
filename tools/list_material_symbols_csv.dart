// tools/list_material_symbols_csv.dart
//
// Generate CSV with icon name + codepoint (hex and decimal).
import 'dart:io';
// provides Symbols.map

void main(dynamic symbolsMap) {
  final outFile = File('material_symbols_list.csv');
  final sink = outFile.openWrite();
  sink.writeln('name,codepoint_hex,codepoint_dec');

  final map = symbolsMap; // Map<String, int>
  for (final entry in map.entries) {
    final name = entry.key;
    final cp = entry.value;
    final hex = cp.toRadixString(16).padLeft(4, '0');
    sink.writeln('$name,0x$hex,$cp');
  }

  sink.close();
  stdout.writeln('✅ material_symbols_list.csv 생성됨 (count: ${map.length})');
}
