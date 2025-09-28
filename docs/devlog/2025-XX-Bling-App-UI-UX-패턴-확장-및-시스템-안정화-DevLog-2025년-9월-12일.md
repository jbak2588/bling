
---

### **## Bling App: UI/UX 패턴 확장 및 시스템 안정화 DevLog (세션 최종본)**

**날짜:** 2025년 9월 12일 **작성자:** 재민 (Gemini)

**세션 목표:** `local_news`에서 성공적으로 검증된 UI/UX 패턴을 다른 핵심 기능으로 확장하고, iOS 빌드 문제를 해결하여 멀티-플랫폼 테스트 환경을 구축한다.

### **## 완료된 작업 상세 내역**

1. **공용 UI/UX 시스템 구축 및 확장:**
    
    - `CustomTagInputField`, `ClickableTagList`, `AuthorProfileTile`, `MiniMapView`, `ImageCarouselCard`, `ImageGalleryScreen` 등 6개의 핵심 공용 위젯 및 화면 제작.
        
    - `local_news`, `marketplace`, `jobs`, `clubs`, `auction`, `lost_and_found`, `real_estate` 기능에 위 패턴들을 성공적으로 적용하여 UI/UX 일관성 확보.
        
2. **핵심 버그 해결 및 시스템 안정화:**
    
    - **이미지 자동 슬라이딩 문제:** `TabBarView` 환경에서 `AutomaticKeepAliveClientMixin`을 `PostCard`와 같은 목록의 개별 카드 위젯에 직접 적용하여 상태 파괴 문제를 최종 해결.
        
    - **Google API 오류:** API 키의 'Android 앱' 제한 설정을 '제한 없음'으로 변경하여 `Places API` 통신 오류를 해결. `Maps Static API`를 활성화하여 상세 화면의 지도 이미지 로딩 문제 해결.
        
    - **상세 화면 예외 발생:** 상세 화면의 `GoogleMap` 위젯을 가벼운 `Maps Static API` 이미지로 교체하여 그래픽 리소스 충돌 문제 해결.
        
3. **iOS 테스트 환경 구축 완료:**
    
    - Mac에 VS Code, Xcode, CocoaPods 등 개발 환경 설정 완료.
        
    - Flutter 패키지 버전 동기화 및 `Podfile` 의존성 충돌 문제 해결.
        
    - `firebase_options.dart`에 iOS 설정을 추가하여 Firebase 연동 완료.
        
    - 실제 iPhone 기기 연결 및 앱 설치/실행 확인.
        
4. **위치 설정 기능 고도화:**
    
    - `neighborhood_prompt_screen.dart`의 구조를 `Service/Model/UI`로 분리하여 안정성 및 유지보수성 향상.
        
    - GPS로 파악한 위치를 기반으로 `provinces` DB를 조회하여, 사용자에게 `Kelurahan`을 직접 선택하게 하는 팝업 기능 추가.
        
    - '수동 선택' 기능을 통해 `Kelurahan`을 재선택하거나 `RT`/`RW`를 직접 입력하는 UI/UX 흐름 구현.
        

---

### **## 다음 세션을 위한 작업 계획**

#### **1단계: UI/UX 최종 일관성 확보**

후반부에 해결된 버그 수정 및 개선안(카드 위젯의 `KeepAlive` 적용, 상세 화면의 `Static Map` 사용 등)을 초반에 작업했던 기능들에 역으로 적용하여 앱 전체의 안정성과 통일성을 최종 확보합니다.

- **점검 및 수정 대상:**
    
    - **카드 위젯 (`PostCard`, `ProductCard`, `JobCard` 등):** 모든 카드 위젯이 `StatefulWidget` + `AutomaticKeepAliveClientMixin` 구조를 사용하는지, `ImageCarouselCard` 호출 시 `storageId` 및 `keepPage: false` 로직이 완벽히 적용되었는지 최종 점검.
        
    - **상세 화면 (`local_news_detail_screen.dart` 등):** 모든 상세 화면의 미니맵이 `Static Map API` 이미지 방식으로 통일되었는지 확인.
        
    - **신규 적용 대상 (`find_friends`, `local_stores`):** 아직 패턴이 적용되지 않은 두 기능의 목록, 상세, 생성/수정 화면에 공용 위젯을 적용.
        
- **필요 파일:**
    
    - `find_friends` 및 `local_stores` 관련 전체 파일 (models, screens, widgets)
        

#### **2단계: `marketplace` AI 검수 시스템 개발**

위의 일관성 확보 작업이 마무리된 후, 다음 핵심 작업으로 `marketplace`의 AI 검수 시스템 개발을 시작합니다.

- **1단계 (데이터 모델):** `product_model.dart`에 `aiVerificationStatus`, `aiVerificationData`, `sellerVerificationImages`, `buyerReceiptImages` 필드 추가.
    
- **2단계 (판매자 UI):** 상품 등록/수정 화면에 'AI 검수용 사진' 업로드 UI 추가 및 판매 목록에 검수 상태 표시.
    
- **3단계 (백엔드):** 검수용 사진 업로드 시 Cloud Function이 실행되어 Google Vision AI로 이미지를 분석하고, 결과를 Firestore에 업데이트하는 기능 개발.
    
- **4단계 (구매자 UI):** 구매자가 상품 수령 후, 사진을 찍어 업로드하는 '인수 확인' 기능 추가.
    
- **5단계 (운영):** AI가 '거절'하거나 '분쟁' 상태로 판정한 상품을 관리자가 검토할 수 있는 페이지 구상.
