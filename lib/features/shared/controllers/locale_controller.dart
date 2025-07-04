import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  // 앱 시작 시 기본 언어를 인도네시아어로 설정
  final Rx<Locale> _locale = const Locale('id').obs;
  Locale get locale => _locale.value;

  final locales = const [
    Locale('id', 'ID'),
    Locale('ko', 'KR'),
    Locale('en', 'US'),
  ];

  // 언어를 순서대로 변경하는 함수
  void changeLocale() {
    final currentLang = _locale.value.languageCode;
    if (currentLang == 'id') {
      _locale.value = locales[1]; // 한국어로 변경
    } else if (currentLang == 'ko') {
      _locale.value = locales[2]; // 영어로 변경
    } else {
      _locale.value = locales[0]; // 인도네시아어로 변경
    }
    Get.updateLocale(_locale.value); // 앱 전체의 언어를 업데이트
  }
}