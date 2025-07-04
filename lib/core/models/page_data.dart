// lib/core/models/page_data.dart
// Bling App v0.4
import 'package:flutter/material.dart';

/// 화면 스택 관리를 위한 데이터 클래스입니다.
/// 앱 전체에서 공유되는 단일 정의입니다.
class PageData {
  final Widget screen;
  final String title;
  PageData({required this.screen, required this.title});
}
