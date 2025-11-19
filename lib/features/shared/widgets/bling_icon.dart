/// ============================================================================
/// Bling DocHeader
/// Module        : Shared
/// File          : lib/features/shared/widgets/bling_icon.dart
/// Purpose       : 앱 내 모든 아이콘(IconData, MS Icon String, SVG Asset)을 통합 관리하고
///                 브랜드 컬러(Primary)를 기본값으로 적용하여 시각적 통일성을 제공합니다.
/// User Impact   : 앱 전반에 걸쳐 일관된 아이콘 스타일과 색상을 경험합니다.
/// ============================================================================
library;

import 'package:bling_app/features/categories/constants/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BlingIcon extends StatelessWidget {
  /// 아이콘 소스:
  /// 1. IconData (예: Icons.home)
  /// 2. String ('ms:...' 형태의 마켓플레이스 아이콘 코드)
  /// 3. String ('assets/...' 형태의 SVG 파일 경로)
  final dynamic iconSource;

  /// 아이콘 크기 (기본값: 24.0)
  final double size;

  /// 아이콘 색상 (기본값: 앱의 Primary Color)
  /// null을 전달하면 원래 색상(SVG의 경우) 또는 테마 기본색을 따르지 않고 Primary를 강제합니다.
  /// 특정 색을 원하면 명시적으로 전달하세요.
  final Color? color;

  const BlingIcon(
    this.iconSource, {
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 기본 색상은 테마의 Primary Color 사용
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    if (iconSource is IconData) {
      return Icon(
        iconSource as IconData,
        size: size,
        color: effectiveColor,
      );
    } else if (iconSource is String) {
      final String src = iconSource as String;

      // 1. 마켓플레이스 'ms:' 아이콘 코드인 경우
      if (src.startsWith('ms:')) {
        // CategoryIcons의 내부 로직을 재사용하되, 색상은 우리가 제어
        return CategoryIcons.widget(
          src,
          size: size,
          color: effectiveColor,
        );
      }
      // 2. SVG 에셋 경로인 경우 (.svg)
      else if (src.endsWith('.svg')) {
        return SvgPicture.asset(
          src,
          width: size,
          height: size,
          // SVG에 색상을 입힘 (BlendMode.srcIn)
          colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
        );
      }
      // 3. 일반 이미지 에셋 (.png 등)
      else {
        return Image.asset(
          src,
          width: size,
          height: size,
          // 이미지는 색상을 입히면 실루엣만 남으므로, color가 명시된 경우에만 적용 고려
          // 여기서는 통일성을 위해 요청대로 색상을 입힘 (필요시 color: null 처리)
          color: effectiveColor,
        );
      }
    }

    // 알 수 없는 타입인 경우 빈 박스 반환 (에러 방지)
    return SizedBox(width: size, height: size);
  }
}
