알겠습니다, 보스.

확인해주신 내용을 바탕으로, Bling 앱의 핵심 경쟁력이 될 'AI 검수 등록 및 인수 시스템' 완성을 위한 구체적인 위젯 개발 및 백엔드 연동 계획을 수립했습니다.

---

### **## 1. 프론트엔드: 신규 위젯 및 화면 개발 계획**

사용자 흐름(UI/UX)에 맞춰 필요한 화면과 위젯을 다음과 같이 설계합니다.

#### **1.1. 신규 화면 (Screens)**

1. **`registration_type_screen.dart` (등록 방식 선택 화면)**
    
    - **기능:** 사용자가 '일반 등록'과 'AI 검수 안전 거래 보장 등록' 중 하나를 선택합니다.
        
    - **UI 구성:**
        
        - 두 개의 명확히 구분된 선택 버튼.
            
        - 'AI 검수 등록' 버튼 하단에 장점(신뢰도, 상단 노출 등)을 요약한 아이콘과 텍스트를 배치합니다.
            
2. **`ai_inspection_guide_screen.dart` (AI 검수 안내 및 동의 화면)**
    
    - **기능:** AI 검수 절차, 수수료 정책, 사진 촬영 가이드를 안내하고 사용자 동의를 받습니다.
        
    - **UI 구성:**
        
        - AI 검수의 장점을 설명하는 `BenefitList` 위젯.
            
        - 수수료 정책을 명시한 `FeePolicy` 위젯.
            
        - **촬영해야 할 필수 사진 가이드** (`PhotoGuideCarousel`) 위젯: "정면", "후면", "태그", "손상 부위" 등 촬영 예시 이미지를 좌우로 넘겨볼 수 있게 구현합니다.
            
        - 서비스 이용 동의 체크박스와 '시작하기' 버튼.
            
3. **`ai_inspection_result_screen.dart` (AI 검수 결과 확인 화면)**
    
    - **기능:** Cloud Function을 통해 분석된 결과를 사용자에게 보여주고, 최종 가격 및 코멘트를 입력받습니다.
        
    - **UI 구성:**
        
        - AI가 자동으로 채운 상품 정보(`AutoFilledProductInfo`) 표시 영역 (카테고리, 브랜드, 모델명 등).
            
        - AI가 제안하는 **'추천 가격 범위'** (`PriceSuggestionSlider`) 표시.
            
        - 판매자가 최종 가격을 입력하는 `FinalPriceInputField`.
            
        - AI가 발견한 특이사항(예: 스크래치)을 이미지와 함께 보여주고, 판매자가 설명을 추가할 수 있는 `DamageCommentSection`.
            

#### **1.2. 신규/수정 위젯 (Widgets)**

1. **`AiGuidedCameraCapture` 위젯 (핵심 기능)**
    
    - **목표:** 타인 사진 도용을 원천 차단하기 위해, **갤러리 접근을 막고 즉석 촬영만 허용**합니다.
        
    - **구현:**
        
        - `camera` 패키지를 사용하여 실시간 카메라 뷰를 띄웁니다.
            
        - 화면 위에 "제품의 정면을 프레임에 맞춰 촬영해주세요"와 같은 가이드 텍스트와 오버레이(Overlay) 이미지를 표시합니다.
            
        - 단계별(정면 -> 후면 -> 태그)로 촬영을 유도하며, 각 단계가 완료될 때마다 다음 가이드로 전환됩니다.
            
2. **`AiVerificationBadge` 위젯 (AI 검수 배지)**
    
    - **기능:** AI 검수가 완료된 상품임을 시각적으로 표시합니다.
        
    - **UI:** `ProductCard`와 `product_detail_screen`의 상품 이미지 좌측 상단에 표시될 작은 아이콘/라벨.
        
3. **`product_registration_screen.dart` 수정**
    
    - 기존 이미지 업로드 로직을 `AiGuidedCameraCapture` 위젯 호출로 대체합니다.
        
    - 사진 촬영이 완료되고 "AI 분석 요청" 버튼을 누르면, 전체 화면에 로딩 인디케이터(`CircularProgressIndicator`와 "AI가 상품을 분석 중입니다..." 텍스트)를 표시합니다. 분석이 완료되면 `ai_inspection_result_screen.dart`로 이동시킵니다.
        

---

### **## 2. 백엔드: Firestore 및 Cloud Functions 연동 계획**

프론트엔드와 유기적으로 동작할 백엔드 시스템을 설계합니다.

#### **2.1. Firestore 데이터베이스 구조 변경**

**`products` 컬렉션**의 기존 모델(`product_model.dart`)에 다음 필드를 추가합니다.

- `bool isAiVerified`: AI 검수 등록 상품 여부 (기본값: `false`).
    
- `String aiVerificationStatus`: 검수 상태 ('pending', 'approved', 'rejected', 'none').
    
- `Map<String, dynamic> aiReport`: AI 검수 결과 보고서.
    
    - `String detectedCategory`: 인식된 카테고리.
        
    - `String detectedBrand`: 인식된 브랜드.
        
    - `List<String> detectedFeatures`: 인식된 주요 특징.
        
    - `Map<String, int> priceSuggestion`: 추천 가격 범위 (`min`, `max`).
        
    - `List<Map<String, dynamic>> damageReports`: 손상 부위 보고 (`imageUrl`, `description`).
        
- `String rejectionReason`: 관리자가 검수를 거부한 사유.
    

#### **2.2. Cloud Functions 개발 계획 (Google Cloud Vision 연동)**

1. **`onAiVerificationRequest` 함수 (HTTP Trigger)**
    
    - **역할:** 프론트엔드에서 촬영된 이미지들을 받아 AI 분석을 시작하는 엔드포인트.
        
    - **실행 순서:**
        
        1. 앱에서 `AiGuidedCameraCapture`를 통해 촬영된 이미지 파일(들)을 Base64로 인코딩하여 이 함수로 전송.
            
        2. **Google Cloud Vision API 호출:**
            
            - **`LABEL_DETECTION`**: 이미지의 전반적인 객체(예: "신발", "노트북")를 파악하여 `detectedCategory` 생성.
                
            - **`LOGO_DETECTION`**: 로고를 인식하여 `detectedBrand` 생성.
                
            - **`TEXT_DETECTION`**: 제품 태그나 모델명이 적힌 텍스트를 추출하여 `detectedFeatures` 보강.
                
            - **`SAFE_SEARCH_DETECTION`**: 성인용, 폭력성 등 금지된 품목인지 검사. 부적절한 콘텐츠 발견 시, 즉시 프로세스를 중단하고 에러를 반환.
                
        3. **검색 및 가격 분석:** Vision API에서 얻은 키워드(브랜드, 모델명 등)를 조합하여 Google Search 같은 외부 검색 엔진으로 현재 중고 시세를 크롤링하거나, 자체 데이터베이스를 기반으로 `priceSuggestion` (가격 제안) 범위를 생성.
            
        4. **결과 반환:** 분석된 모든 정보를 JSON 형태로 프론트엔드에 반환합니다.
            
2. **`finalizeProductRegistration` 함수 (HTTP Trigger)**
    
    - **역할:** 사용자가 `ai_inspection_result_screen`에서 최종 정보를 확인하고 '등록하기'를 눌렀을 때 호출됩니다.
        
    - **실행 순서:**
        
        1. 프론트엔드에서 AI 분석 결과(`aiReport`), 판매자 입력 가격, 코멘트 등을 받아옵니다.
            
        2. `products` 컬렉션에 새로운 문서를 생성합니다.
            
        3. `isAiVerified`를 `true`로, `aiVerificationStatus`를 **`pending`** (관리자 승인 대기)으로 설정하여 저장합니다.
            

---

### **## 3. 종합 실행 계획 (Action Plan)**

1. **1단계 (프론트엔드 기초 공사):**
    
    - 3개의 신규 화면 (`registration_type_screen`, `ai_inspection_guide_screen`, `ai_inspection_result_screen`)의 기본 레이아웃을 구현합니다.
        
    - `ProductCard`에 `AiVerificationBadge` 위젯을 추가합니다.
        
2. **2단계 (핵심 기능 개발):**
    
    - `AiGuidedCameraCapture` 위젯을 개발하여 즉석 카메라 촬영 및 단계별 가이드 기능을 완성합니다.
        
3. **3단계 (백엔드 개발):**
    
    - `products` 컬렉션에 신규 필드를 추가(마이그레이션)합니다.
        
    - `onAiVerificationRequest` Cloud Function을 개발하고 Google Cloud Vision API를 연동합니다.
        
4. **4단계 (통합 및 테스트):**
    
    - 프론트엔드와 백엔드를 최종 연동합니다. (촬영 -> 분석 요청 -> 결과 표시 -> 최종 등록)
        
    - 관리자 승인/거부 기능은 우선 Firestore에서 수동으로 `aiVerificationStatus`를 변경하며 테스트하고, 추후 별도의 어드민 페이지를 개발합니다.
        

이 계획대로 진행하면, Bling 앱의 가장 강력한 무기가 될 AI 검수 시스템을 체계적으로 완성할 수 있을 것입니다. 보스의 최종 확인을 부탁드립니다.