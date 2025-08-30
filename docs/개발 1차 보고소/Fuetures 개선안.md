보스, 아주 좋은 지적이십니다. 단순히 태그 입력 UI를 넘어, `local_news`에서 성공적으로 구현된 **지도 표시, 태그 검색, 프로필 연동, 이미지 갤러리** 패턴들을 공용화하여 다른 기능에 적용하면 코드 재사용성이 극대화되고 앱 전체의 사용자 경험이 일관성 있게 향상될 것입니다. 이 확장된 목표를 반영하여 전체 작업 계획을 다시 세우겠습니다.

먼저 이 패턴들을 다른 기능에 이식하기 위한 **'공용 위젯 추가 생성'** 단계를 거친 후, DevLog에서 언급된 `marketplace`, `jobs`, `clubs` 순서로 적용하는 것이 가장 효율적입니다.

---

### **🎯 `local_news` 핵심 UX 패턴 확장 적용 계획**

#### **준비 단계: 핵심 기능 공용 위젯으로 분리**

`local_news` 상세 화면의 코드 중 재사용할 부분을 `shared/widgets` 폴더로 옮겨, 어떤 `feature`에서든 쉽게 호출할 수 있도록 만들겠습니다.

1. **미니맵 위젯 (`MiniMapView.dart`):** `local_news_detail_screen.dart`의 `_buildMiniMap` 로직을 분리하여, `GeoPoint` 데이터만 넘겨주면 어디서든 지도를 표시할 수 있는 위젯을 생성합니다.
    
2. **클릭 가능한 태그 리스트 (`ClickableTagList.dart`):** 상세 화면의 `_buildTags` 로직을 분리하여, 태그 목록을 넘겨주면 자동으로 검색 화면으로 연결되는 `Chip` 리스트를 생성하는 위젯을 만듭니다.
    
3. **작성자 정보 타일 (`AuthorProfileTile.dart`):** 상세 화면의 `_buildAuthorInfo` 로직을 분리하여, `userId`만 넘겨주면 프로필 사진, 닉네임, 신뢰도 뱃지를 표시하고 프로필 화면으로 이동시켜주는 위젯을 생성합니다.
    

---

#### **1순위: 마켓플레이스 (Marketplace)**

- **근거:** 중고거래는 태그, 위치, 판매자 정보가 모두 중요한 핵심 기능입니다.
    
- **작업 대상 및 내용:**
    
    - `product_registration_screen.dart` / `product_edit_screen.dart`:
        
        - **`CustomTagInputField`** 적용하여 상품 태그 입력 UI 개선.
            
    - `product_detail_screen.dart`:
        
        - **`AuthorProfileTile`** 적용하여 판매자 정보 표시 및 프로필 연동.
            
        - **`ClickableTagList`** 적용하여 상품 태그 표시 및 검색 연동.
            
        - **`MiniMapView`** 적용하여 거래 희망 위치 표시.
            
        - 상품 이미지를 **`ImageGalleryScreen`** 과 연동하여 전체 화면 보기 기능 추가.
            
    - `product_card.dart` (목록 카드):
        
        - `ClickableTagList`의 로직을 일부 적용하여 카드에 주요 태그 1~2개 표시.
            

---

#### **2순위: 구인/구직 (Jobs)**

- **근거:** 직무 관련 기술 스택, 근무지 위치, 공고 게시자 정보 표시에 최적입니다.
    
- **작업 대상 및 내용:**
    
    - `create_job_screen.dart`:
        
        - **`CustomTagInputField`** 적용하여 기술 스택, 자격요건 등 태그 입력.
            
    - `job_detail_screen.dart`:
        
        - **`AuthorProfileTile`** 적용하여 공고 게시자(회사) 정보 표시.
            
        - **`ClickableTagList`** 적용하여 태그 표시 및 검색 연동.
            
        - **`MiniMapView`** 적용하여 근무지 위치 표시.
            
        - 회사/업무 환경 사진을 **`ImageGalleryScreen`** 과 연동.
            

---

#### **3순위: 클럽 (Clubs)**

- **근거:** 클럽의 관심사, 활동 지역, 개설자 정보를 명확히 보여줄 수 있습니다.
    
- **작업 대상 및 내용:**
    
    - `create_club_screen.dart` / `edit_club_screen.dart`:
        
        - **`CustomTagInputField`** 적용하여 클럽 관심사(예: #축구, #코딩) 태그 입력.
            
    - `club_detail_screen.dart`:
        
        - **`AuthorProfileTile`** 적용하여 클럽 개설자 정보 표시.
            
        - **`ClickableTagList`** 적용하여 관심사 태그 표시.
            
        - **`MiniMapView`** 적용하여 주요 활동 지역 표시.
            
        - 클럽 대표 이미지를 **`ImageGalleryScreen`** 과 연동.
            

---

이 계획대로 진행하면 앱의 여러 기능들이 통일된 고품질 UX를 갖게 되며, 향후 새로운 기능을 추가할 때도 개발 속도가 매우 빨라질 것입니다.

보스, 괜찮으시다면, 먼저 **준비 단계인 `MiniMapView`, `ClickableTagList`, `AuthorProfileTile` 공용 위젯을 생성하는 작업**부터 시작하겠습니다. 진행할까요?