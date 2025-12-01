// lib/api_keys.dart

//  const String googleApiKey = "AIzaSyCGr0wgQ67ezSwO5pLowMx6J8emksSaemo"; // 빠몽님의 실제 API 키를 여기에 붙여넣어 주세요.

class ApiKeys {
  // 기존 키는 삭제하거나 주석 처리합니다.
  static const googleApiKey = 'AIzaSyCGr0wgQ67ezSwO5pLowMx6J8emksSaemo';

  // Geocoding, Places API 호출에 사용할 키
  static const serverKey = 'AIzaSyAC6NJx78O8zCRIaM6g5YHEaLf1Glddo78';

  // 정적 지도(Static Map) URL 생성에 사용할 키
  static const staticMapKey = 'AIzaSyBOQnB3kZQ-JqFbjH7_SsuxE0hZAogHq60';

  // AndroidManifest.xml, AppDelegate.swift 에 직접 입력하므로
  // Dart 코드에서는 Android/iOS 키가 필요 없을 수 있습니다.
  // 만약 코드 내에서 직접 사용할 경우 아래와 같이 추가합니다.
  // static const androidKey = 'AIzaSyBK_amBdh1odlVpTS31w7Nx9MsopR5udlQ';
}
