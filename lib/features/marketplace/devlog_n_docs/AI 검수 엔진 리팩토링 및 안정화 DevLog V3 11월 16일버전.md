### **1부: V3 AI 검수 엔진 리팩토링 및 안정화 DevLog (Task 49 \~ 117 요약)**

#### **1\. Phase 1: V2 "룰 엔진"의 붕괴 및 V3 설계 (Task 49 \~ 61\)**

* **문제 발생 (Task 51-53):** `List<Map>`을 `String`으로 처리하려다 치명적인 `_TypeError`가 발생하며 V2 로직이 붕괴되었습니다.  
* **근본 원인 식별 (Task 57-60):** V2 "룰 엔진"(`ai_verification_rules`) 자체가 너무 복잡하고(Tightly Coupled), AI의 지식 컷오프(예: "iPhone 16"을 미래 제품으로 오인)에 대응할 수 없는 취약한 구조임이 드러났습니다.  
* **핵심 결정 (Task 61):** **"AI 룰 엔진"을 전면 폐기.** 모든 이미지와 텍스트를 AI에 한 번에 제공하고, AI가 "단순 감정 JSON"을 반환하는 \*\*V3 "단순 감정 엔진"\*\*으로의 전환을 결정했습니다. 새로운 V3 `aiReport` JSON 스키마를 확정했습니다.

#### **2\. Phase 2: V3 "단순 감정 엔진" 전면 적용 (Task 62 \~ 70\)**

* **백엔드 (`index.js` / Task 64, 92, 118):** `ai_verification_rules` 컬렉션에 대한 모든 참조를 삭제했습니다. `generateFinalReport` 함수를 위한 `buildV3FinalPrompt`를 새로 작성하여, AI가 V3 JSON을 생성하도록 지시했습니다. AI의 날짜 인식 오류(지식 컷오프)를 해결하기 위해 프롬프트에 `[CONTEXT] (현재 날짜)`를 주입했습니다.  
* **앱 (Task 65-67):**  
  * `ai_evidence_suggestion_screen`: V2의 "룰 키" 대신 V3의 "단순 텍스트 제안"(`suggestedShots`)을 받도록 수정했습니다.  
  * `ai_final_report_screen`: V2 리포트 대신 V3 JSON 스키마(가격 범위, 상태 등급)를 파싱하도록 `_initializeControllers`를 전면 수정했습니다. (Task 52/55 버그 해결)  
  * `ai_report_viewer`: V3 JSON을 렌더링하도록 UI 로직을 전면 수정했습니다. (Task 53 버그 해결)  
* **철거 (Task 68, 70, 71):** `ai_verification_rule_model.dart`, `categories_sync.js` 등 "룰 엔진" 관련 파일을 **물리적으로 삭제**하고, 관리자 화면의 "룰 배포" 버튼을 제거했습니다.

#### **3\. Phase 3: "관리자 검증" (Pending) 흐름 구축 (Task 77 \~ 79\)**

* **문제 식별 (Task 76-77):** "iPhone 16" 오탐 사례를 통해, AI가 선의의 판매자를 '사기'로 오인할 수 있는 "False Positive" 위험을 발견했습니다.  
* **백엔드 (Task 78):** `buildV3FinalPrompt`를 수정하여, AI가 리포트에 `trustVerdict: "suspicious" | "clear"` (신뢰 등급) 키를 포함하도록 했습니다.  
* **앱 (Task 79):** `ai_evidence_suggestion_screen`의 `_continue` 로직을 수정했습니다. AI가 `trustVerdict: 'suspicious'`를 반환하면, `AiFinalReportScreen`을 건너뛰고 \*\*"블라인드 제출"\*\*을 실행합니다.  
  * 상품 상태를 `status: 'pending'`, `aiVerificationStatus: 'pending_admin'`으로 즉시 저장합니다.  
  * 사용자에게는 불쾌한 보고서 대신 "관리자 검토를 위해 제출되었습니다"라는 중립적인 팝업(Task 87 수정)을 띄우고 홈으로 이동시킵니다. (Task 86 수정)

#### **4\. Phase 4: 알림 시스템 완성 (Task 79 \~ 82, 94 \~ 97\)**

* **목표:** `pending` 상태 변경 시 관리자와 판매자에게 알림을 전송하고, 승인/거절 시 판매자에게 결과를 알립니다.  
* **백엔드 (Task 79, 94, 106):** `index.js`에 **2개의 새로운 Firestore 트리거**를 추가했습니다.  
  * `onProductStatusPending`: `status`가 `pending`이 되면, 관리자와 판매자 모두에게 FCM을 **전송**하고 `users/{uid}/notifications` 하위 컬렉션에 알림을 **저장**합니다.  
  * `onProductStatusResolved`: `status`가 `pending`에서 `selling`(승인) 또는 `rejected`(거절)로 변경되면, 판매자에게 "승인됨" 또는 "거절됨 (사유: ...)" 알림을 전송/저장합니다.  
* **앱 (Task 80-82, 95-97):**  
  * `notification_service.dart` (신규): FCM 초기화, 토큰 관리(`fcmTokens` 필드, Task 82), 알림 탭 내비게이션 로직을 구현했습니다.  
  * `notification_list_screen.dart` (신규): `main_navigation_screen.dart`의 종(Bell) 아이콘(Task 96)과 연결되어, `users/{uid}/notifications` 컬렉션을 읽어와 목록을 보여줍니다.  
  * `GetX` 네비게이션 충돌(`ambiguous_extension_member_access`, `contextless navigation`)을 `Navigator.of(context)`로 교체하여 해결했습니다. (Task 97, 101\)

#### **5\. Phase 5: AI 현장 인수(Takeover) 안정화 (Task 98 \~ 118\)**

* **문제:** "AI 인수" 흐름이 V3로 업데이트되지 않아 `match key` 오류가 발생했습니다.  
* **백엔드 (Task 98, 109, 112, 115, 118):** `verifyProductOnSite` 함수를 "A/B 이미지 비교" 프롬프트로 교체했습니다. Copilot의 도움으로 "AI 실패" 시 `match: null` (판단 불가)을 반환하도록 수정하여 "거래 취소"를 방지했습니다. (Task 110, 115, 118\)  
* **앱 (Task 99, 107, 111, 113, 116-117):** `ai_takeover_screen.dart`를 수정하여 V3 `onSiteVerificationChecklist` UI를 표시하고(Task 99), `match: null`을 받을 경우 "거래 취소"가 아닌 **"재시도"** 팝업을 띄우도록 **3-Way Logic**을 구현했습니다. (Task 111, 117\)  
* **안정화 (Task 102-105):** `admin_product_detail_screen`의 승인/거절 로직을 수정하고(Task 102, 104), 관리자용 `AiReportViewer` UI를 개선했습니다. (Task 91, 105\)

