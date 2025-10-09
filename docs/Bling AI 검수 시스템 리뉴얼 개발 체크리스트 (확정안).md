
---

# **Bling AI 검수 시스템 리뉴얼 개발 체크리스트 (확정안)**

이 문서는 블링 앱의 신규 AI 검수 시스템 개발을 위한 최종 작업 목록입니다. 각 항목의 완료 여부를 체크하며 프로젝트를 진행합니다.

관련 코드들 
---

### **코드 목록: Gemini AI 시스템  **

#### **✅ 새로운 Gemini AI 검수 시스템 코드 (유지)**

아래 파일들은 우리가 함께 개발한 새로운 AI 검수 플로우의 핵심 구성요소입니다. **절대 삭제하시면 안 됩니다.**

**- 프론트엔드 (Flutter)**

- `lib/features/marketplace/models/ai_verification_rule_model.dart`
    
    - **설명:** Firestore의 AI 규칙(`ai_verification_rules`)을 위한 데이터 모델입니다.
        
- `lib/features/marketplace/screens/registration_type_screen.dart`
    
    - **설명:** '신품 판매'와 '중고품 판매(AI 검수)'를 선택하는 첫 화면입니다.
        
- `lib/features/marketplace/screens/ai_category_selection_screen.dart`
    
    - **설명:** AI 검수가 가능한 카테고리를 Firestore에서 불러와 보여주는 화면입니다.
        
- `lib/features/marketplace/screens/ai_gallery_upload_screen.dart`
    
    - **설명:** 1차 분석을 위해 갤러리에서 사진을 업로드하는 화면입니다.
        
- `lib/features/marketplace/screens/ai_prediction_screen.dart`
    
    - **설명:** 1차 분석 후 AI가 예측한 상품명을 사용자에게 확인받는 화면입니다.
        
- `lib/features/marketplace/screens/ai_guided_camera_screen.dart`
    
    - **설명:** AI가 요구하는 특정 각도의 사진을 촬영하도록 안내하는 화면입니다.
        
- `lib/features/marketplace/screens/ai_final_report_screen.dart`
    
    - **설명:** AI가 생성한 최종 판매글을 사용자가 검토하고 등록하는 마지막 화면입니다.
        

**- 백엔드 (Cloud Functions)**

- `functions-v2/index.js`
    
    - **설명:** `initialproductanalysis`, `generatefinalreport` 등 새로운 Gemini 기반 함수와 기존 `calculateTrustScore` 함수가 포함된 **최신 버전의 백엔드 파일**입니다.
        
- `functions-v2/package.json`
    
    - **설명:** `@google/generative-ai` 패키지가 포함된 최신 의존성 파일입니다.



### **Phase 1: 백엔드 기반 설계 (Firestore DB 구축)**

- [x] **1-1. `product_categories` 컬렉션 생성 및 확장:**
    
    - [x] Firestore에 `product_categories` 컬렉션 생성
        
    - [x] 신품/중고품 공통 카테고리 구조 설계
        
    - [x] `is_ai_verification_supported` (AI 검수 지원 여부) 필드 추가
        
    - [x] `required_shots` (필수 사진 목록) 필드 추가
        
    - [x] `report_template_prompt` (AI 보고서 프롬프트) 필드 추가
        
- [ ] **1-2. 카테고리별 초기 데이터 입력:**
    
    - [x] 주요 카테고리(스마트폰, 가방, 신발 등) 선정
        
    - [x] 각 카테고리별 `is_ai_verification_supported` 값 설정
        
    - [x] AI 검수 지원 카테고리에 대한 `required_shots` 규칙 정의 및 입력
        

### **Phase 2: Flutter 앱 UI/UX 개발**

- [ ] **2-1. 판매 유형 선택 화면 신규 개발:**
    
    - [x] 사용자가 [신품 판매] / [중고품 판매]를 선택하는 UI 구현 (`registration_type_screen.dart`)
        
- [ ] **2-2. [신품 판매] 등록 양식 개발:**
    
    - [ ] 사진(갤러리), 상품명, 카테고리, 가격, 설명 등 기본 양식 UI 구현
        
    - [ ] Firestore `products` 컬렉션에 저장하는 로직 구현
        
- [ ] **2-3. [중고품 판매] AI 검수 플로우 UI 개발:**
    
    - [ ] **(1) 카테고리 선택 화면:** `is_ai_verification_supported: true`인 카테고리만 목록에 표시
        
    - [ ] **(2) 1차 갤러리 업로드 화면:** 카테고리에 지정된 최소 사진 수만큼 업로드 안내
        
    - [ ] **(3) AI 품목 예측 및 확인 화면:** AI가 예측한 상품명을 보여주고 사용자에게 확인받는 UI 구현
        
    - [ ] **(4) AI 가이드 카메라 촬영 화면:**
        
        - [ ] `required_shots` 목록을 기반으로 촬영 미션 체크리스트 UI 구현
            
        - [ ] **사진 위치 검증 로직:**
            
            - [ ] 촬영된 사진에서 EXIF GPS 메타데이터 추출
                
            - [ ] 사용자의 현재 위치(`geolocator`) 정보 가져오기
                
            - [ ] 두 위치 좌표 비교 후 불일치 시 경고 및 재촬영 유도
                
    - [ ] **(5) AI 자동 생성 보고서 확인 및 수정 화면:** AI가 생성한 판매글을 최종 검토/수정 후 등록 완료
        

### **Phase 3: 백엔드 AI 로직 개발 (Cloud Functions & Gemini API)**

- [x] **3-1. `initialproductanalysis` (1차 품목 분석) 함수 개발:**
    
    - [x] Cloud Functions에 HTTPS Callable 함수 생성
        
    - [ ] 입력: 이미지 URL 리스트
        
    - [ ] 로직: Gemini API를 호출하여 상품의 브랜드/모델명 예측
        
    - [ ] 출력: 예측된 상품명 텍스트
        
- [x] **3-2. `generatefinalreport` (최종 보고서 생성) 함수 개발:**
    
    - [ ] Cloud Functions에 HTTPS Callable 함수 생성
        
    - [ ] 입력: 모든 사진 URL, 품목명, 사용자 입력 정보
        
    - [ ] 로직:
        
        - [ ] Firestore에서 카테고리에 맞는 `report_template_prompt` 조회
            
        - [ ] 프롬프트와 입력 데이터를 결합하여 Gemini API에 최종 요청
            
        - [ ] (서버 측 위치 검증) 이미지 EXIF 데이터와 사용자 위치 정보 비교 로그 기록 (선택적 심화)
            
    - [ ] 출력: 판매글 전체 내용이 담긴 상세 JSON 객체
        

---

