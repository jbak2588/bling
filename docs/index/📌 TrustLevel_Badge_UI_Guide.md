# 📌 TrustLevel_Badge_UI_Guide

---

## ✅ 목적

Bling Ver.3 신뢰등급(TrustLevel) 배지를 일관되게 표시하기 위한 공통 UI 가이드입니다.

---

## ✅ 배지 상태 정의

|TrustLevel|조건|Feed/댓글|프로필/Drawer|
|---|---|---|---|
|`normal`|기본 가입|표시 없음|표시 없음|
|`verified`|닉네임 + 위치 인증|✔️ 아이콘만|✔️ 박스 + 텍스트|
|`trusted`|감사 수치 기준 상위|⭐️ 아이콘만|⭐️ 박스 + 텍스트|

---

## ✅ 위젯 사용 규칙

- Feed/댓글 → `useIconOnly = true`
    
- 프로필/Drawer → 기본 박스형 출력
    
- 모든 색상/텍스트는 정책 표준에 맞춰 사용:
    
    - Verified: 파랑 (#2196F3)
        
    - Trusted: 골드 (#FFC107)
        

---

## ✅ 예시

```dart
TrustLevelBadge(trustLevel: 'verified'); // 박스형
TrustLevelBadge(trustLevel: 'verified', useIconOnly: true); // 아이콘형
```

## ✅ 참고

- Tooltip으로 배지 의미 설명 연결 권장.
- Obsidian Vault 경로: `docs/team/teamA_Auth_Trust.md` / `docs/index/TrustLevel_Badge_UI_Guide.md`


## ✅ 📌 1️⃣ 실전 `trust_level_badge.dart` 통합 예시

아래는 **두 버전(박스형/아이콘형)** 을 선택적으로 쓸 수 있는 재사용 위젯 예시입니다.

```dart
import 'package:flutter/material.dart';

class TrustLevelBadge extends StatelessWidget {
  final String trustLevel;
  final bool useIconOnly;

  const TrustLevelBadge({
    Key? key,
    required this.trustLevel,
    this.useIconOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (trustLevel) {
      case 'verified':
        return useIconOnly
            ? Icon(
                Icons.verified,
                color: Colors.blue,
                size: 16,
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
      case 'trusted':
        return useIconOnly
            ? Icon(
                Icons.verified, // 원하는 다른 아이콘으로 대체 가능
                color: Colors.amber,
                size: 16,
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Trusted',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
      default:
        return const SizedBox.shrink();
    }
  }
}

```


### ✔️ 사용 예시

```dart
// 프로필 화면 (텍스트 박스 버전)
TrustLevelBadge(trustLevel: 'verified')

// Feed/댓글 (아이콘만)
TrustLevelBadge(trustLevel: 'verified', useIconOnly: true)


```

---

