// lib/core/utils/ai_rule_uploader.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 17번 요청에서 생성한 모델 파일을 import 합니다.
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';

class AiRuleUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadInitialRules() async {
    final rulesCollection = _firestore.collection('ai_verification_rules');
    final List<AiVerificationRule> initialRules = _getInitialRules();

    WriteBatch batch = _firestore.batch();

    for (final rule in initialRules) {
      final docRef = rulesCollection.doc(rule.id);
      batch.set(docRef, rule.toMap());
    }

    try {
      await batch.commit();
      debugPrint('AI 검수 규칙 초기 데이터 업로드 성공!');
    } catch (e) {
      debugPrint('AI 검수 규칙 초기 데이터 업로드 실패: $e');
    }
  }

  List<AiVerificationRule> _getInitialRules() {
    return [
      // 1. 스마트폰 카테고리 규칙
      AiVerificationRule(
        id: 'smartphone',
        nameKo: '스마트폰',
        nameId: 'Smartphone',
        isAiVerificationSupported: true,
        minGalleryPhotos: 3,
        requiredShots: {
          'front':
              RequiredShot(nameKo: '정면 스크린 샷', descKo: '화면이 켜진 상태로 정면을 촬영하세요.'),
          'back': RequiredShot(nameKo: '후면 샷', descKo: '카메라와 기기 뒷면 전체를 촬영하세요.'),
          'corners': RequiredShot(
              nameKo: '모서리 흠집 샷', descKo: '가장 흠집이 잘 보이는 모서리를 가까이서 찍어주세요.'),
          'imei': RequiredShot(
              nameKo: 'IMEI 정보 샷', descKo: '*#06#을 눌러 나오는 IMEI 화면을 촬영하세요.'),
        },
        reportTemplatePrompt: '''
        당신은 인도네시아 중고 스마트폰 거래 전문가입니다. 제공된 이미지들과 사용자 정보를 바탕으로, 아래 JSON 형식에 맞춰 인도네시아어로 상세 판매 게시글을 작성해주세요.

        사용자 정보:
        - 희망 가격: {{userPrice}} IDR
        - 간단 설명: {{userDescription}}

        {
          "title": "[브랜드] [모델명] [용량] [색상] 판매합니다.",
          "description": "상세한 제품 설명 (최초 구매일, 사용 기간, 특징 등)",
          "specs": { "brand": "브랜드", "model": "모델명", "storage": "저장 용량", "color": "색상" },
          "condition_check": {
            "overall": "전체적인 상태 (A급, B급 등)와 그 이유",
            "screen": "화면 상태 (스크래치, 번인 유무)",
            "body": "외관 상태 (찍힘, 흠집 등)",
            "battery_performance": "배터리 성능에 대한 추정"
          },
          "included_items": "포함된 구성품 목록 (예: '박스, 충전기 포함')",
          "suggested_price": "적정 중고 가격 (IDR 숫자만)"
        }
        ''',
      ),

      // 2. 여성 가방 카테고리 규칙
      AiVerificationRule(
        id: 'womens_bag',
        nameKo: '여성 가방',
        nameId: 'Tas Wanita',
        isAiVerificationSupported: true,
        minGalleryPhotos: 4,
        requiredShots: {
          'front':
              RequiredShot(nameKo: '가방 정면', descKo: '가방의 전체적인 앞모습을 촬영하세요.'),
          'logo': RequiredShot(
              nameKo: '브랜드 로고', descKo: '브랜드 로고 부분을 선명하게 가까이서 찍어주세요.'),
          'interior': RequiredShot(
              nameKo: '가방 내부', descKo: '가방 내부의 전체적인 모습과 오염도를 보여주세요.'),
          'corners': RequiredShot(
              nameKo: '모서리 마모', descKo: '가장 마모가 심한 하단 모서리를 촬영하세요.'),
        },
        reportTemplatePrompt: '''
        당신은 인도네시아 중고 명품 가방 거래 전문가입니다. 제공된 이미지들과 사용자 정보를 바탕으로, 아래 JSON 형식에 맞춰 인도네시아어로 상세 판매 게시글을 작성해주세요.

        사용자 정보:
        - 희망 가격: {{userPrice}} IDR
        - 간단 설명: {{userDescription}}

        {
          "title": "[브랜드] [모델명/라인] [색상] 가방 판매합니다.",
          "description": "상세한 제품 설명 (구매처, 구매 시기, 실사용 횟수 등)",
          "specs": { "brand": "브랜드", "model": "모델명/라인", "material": "소재", "color": "색상" },
          "condition_check": {
            "overall": "전체적인 상태 (A급, B급 등)와 그 이유",
            "exterior": "외부 상태 (스크래치, 오염, 가죽 마모 상태)",
            "interior": "내부 상태 (오염, 찢어짐 등)",
            "hardware": "금속 장식 상태 (벗겨짐, 변색 등)"
          },
          "included_items": "포함된 구성품 목록 (예: '더스트백, 개런티 카드 포함')",
          "suggested_price": "적정 중고 가격 (IDR 숫자만)"
        }
        ''',
      ),

      // 3. 신발 카테고리 규칙
      AiVerificationRule(
        id: 'shoes',
        nameKo: '신발',
        nameId: 'Sepatu',
        isAiVerificationSupported: true,
        minGalleryPhotos: 4,
        requiredShots: {
          'side':
              RequiredShot(nameKo: '측면 전체 샷', descKo: '신발의 전체적인 옆모습을 촬영하세요.'),
          'sole':
              RequiredShot(nameKo: '밑창 샷', descKo: '밑창의 마모도를 확인할 수 있도록 촬영하세요.'),
          'tag': RequiredShot(
              nameKo: '내부 탭/사이즈 샷', descKo: '사이즈와 모델 정보가 보이는 탭을 선명하게 찍어주세요.'),
          'front': RequiredShot(
              nameKo: '앞코 샷', descKo: '신발 앞코 부분의 사용감을 가까이서 촬영하세요.'),
        },
        reportTemplatePrompt: '''
        당신은 인도네시아 중고 신발 거래 전문가입니다. 제공된 이미지들과 사용자 정보를 바탕으로, 아래 JSON 형식에 맞춰 인도네시아어로 상세 판매 게시글을 작성해주세요.

        사용자 정보:
        - 희망 가격: {{userPrice}} IDR
        - 간단 설명: {{userDescription}}

        {
          "title": "[브랜드] [모델명] [사이즈] 판매합니다.",
          "description": "상세한 제품 설명 (구매 시기, 실착 횟수, 착화감 등)",
          "specs": { "brand": "브랜드", "model": "모델명", "size": "사이즈 (mm)", "color": "주요 색상" },
          "condition_check": {
            "overall": "전체적인 상태 (A급, B급 등)와 그 이유",
            "upper": "갑피 상태 (오염, 주름, 스크래치 등)",
            "sole": "밑창 마모 상태",
            "interior": "내부 깔창 및 뒤꿈치 상태"
          },
          "included_items": "포함된 구성품 목록 (예: '정품 박스 포함')",
          "suggested_price": "적정 중고 가격 (IDR 숫자만)"
        }
        ''',
      ),
    ];
  }
}
