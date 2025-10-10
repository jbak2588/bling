 

- **Week**: 2025-10-01 ~ 2025-10-09 (Asia/Jakarta)

- **Author**: Personal Assistant

- **Report Date**: 2025-10-10

- **Audience**: Weekly Project Review (Developers · Investors · Personal Assistant)

  

---

  

## 1) Top Highlights (Top 3)

1. Completed post-move setup: development equipment placement, internet connection, and core system configuration (Oct 1–5).

2. Internet upgraded on Oct 6 (First Media; IDR 440,000 paid via OVO); continued device setup/testing.

3. Conducted end-to-end app smoke tests (Oct 7–10); consolidated 13 UX/functional issues and reported to the dev team.

  

---

  

## 2) Project Progress & Updates

- **Operations / Logistics**

  - Moved and organized workspace; placed development devices; configured essential software/services.

  - Internet provisioned, then upgraded on Oct 6 (First Media). Payment: IDR 440,000 via OVO (receipt in expense appendix).

- **Dev Support**

  - Oct 7: Attempted BLING install on assistant’s iPhone (failed). Installed on assistant’s Galaxy Tab and executed test scenarios.

  - Oct 7–10: Logged UI/UX issues across chat, feed, profile, marketplace chat, groups, find-friends, auction, property listing, and POM (video) features.

- **Strategy / Planning**

  - Prepared structured weekly issue list and next-week test plan; aligned with developer request for feature-by-feature testing.

- **Light metrics**

  - Devices tested: 2 (iPhone – install failed, Galaxy Tab – tests executed).

  - Reported issues: 13 unique items (see Section 5).

  - Network upgrade transactions: 1 (OVO).

  

---

  

## 3) Research · Survey · Dev Support (Details)

- **Overview**: Focused on installation feasibility (iOS/Android) and core workflows (chat, feed, profile edit, marketplace, groups, find-friends, auction, property, POM video posting).

- **Key findings**:

  - iOS install (assistant’s iPhone) failed; Android (Galaxy Tab) installation succeeded; several UI elements do not scroll or focus properly.

  - Multiple input fields not rising above the keyboard; feed and profile actions difficult or non-functional in current build.

- **Dev support/checks**:

  - Compiled reproducible steps per issue; prioritized for developer triage next week.

  - Coordinated with developer to proceed with Indonesian copy review after feature tests.

  

---

  

## 4) Operations · Logistics Improvements

- **Workspace/asset upkeep**: Device layout finalized; internet stable after upgrade.

- **Resource appropriateness**: All spending pre-approved; internet upgrade fee logged with payment method (OVO).

- **Improvements proposed**:

  - Maintain a rolling “device matrix” (iOS/Android/Tablet) to track install status, app version, and blockers.

  - Add a standard checklist for keyboard/scroll testing per screen to speed regressions.

  

---

  

## 5) Issues · Risks & Responses

- **Issue list (Oct 7–10)**  

  1) **App launch is slow** — poor first-time load experience.  

  2) **Chat**: while typing, the text in the input field does not appear.  

  3) **Find Friends**: change profile bookmark icon to heart/like.  

  4) **Comments**: tapping the input field is difficult; cannot scroll up to it.  

  5) **Feed**: change layout to a slide-style presentation.  

  6) **Profile changes**: “Save changes” area is too low; hard to tap and cannot scroll up.  

  7) **Marketplace chat**: input field does not shift up with the keyboard.  

  8) **Create Group**: screen is not full-height; cannot scroll up.  

  9) **Find Friends profile view**: cannot scroll up; screen not full-height.  

  10) **Android back**: system back not handled; must use in-app back only.  

  11) **Auction**: cannot choose location.  

  12) **Property listing**: form not full-height; cannot scroll up; cannot type in “tags” field.  

  13) **POM (video)**: cannot record directly TikTok-style; only existing videos can be posted.

- **Mitigation/next actions**

  - Provide per-screen reproduction steps and device details to devs.

  - Prioritize keyboard/scroll/focus fixes (shared root cause across multiple screens).

  - Track iOS install blocker with explicit error logs and provisioning status.

- **Requests**

  - Dev to confirm target OS versions and UI libraries handling keyboard insets/scroll areas.

  - Confirm design change requests (#3, #5) vs. bugs (others).

  

---

  

## 6) Next Week Plan (Priorities & Deliverables)

- **Top 3 priorities**

  1. Execute **feature-by-feature tests** per developer request; deliver issue tickets with repro steps and screen recordings.

  2. Start **Indonesian message/copy review** for BLING app (strings and UI labels), focusing on the tested screens.

  3. Verify **iOS install** path with updated build/provisioning; retest iPhone.

- **Milestones**

  - Keyboard/scroll fixes verified on Android tablet by end of week.

  - Revised design decisions on feed layout and bookmark icon confirmed.

  

---

  

## 7) Work Log (Hours & Collaboration)

- **Total hours**: Within policy (weekdays ≤12h/day; weekend ≤4h/day).

- **Daily log (highlights)**

  - **Oct 1–5**: Post-move setup (equipment placement, internet connection, system setup).

  - **Oct 6**: Internet upgrade (First Media; OVO payment). Baseline tests.

  - **Oct 7**: iPhone install attempt failed; Galaxy Tab install succeeded; began tests.

  - **Oct 8–10**: Consolidated findings; drafted issue list and next-week plan.

- **Comms**: Shared problem list with developer; aligned on next week’s testing/copy tasks.

  

---

  

## 8) Expenses / Settlement (Oct 1–9)

- **Internet upgrade**: First Media — **IDR 440,000** (paid via **OVO**).  

- **Appendix**: Full expense list attached separately (receipts/links).

  

---

  

## 9) Security · NDA Check

- Data and document access/sharing/backups remain compliant. No external sharing without approval.

  

---

  

## 10) Sign-off (Acknowledgement)

- **Personal Assistant**: __________________ / Date: __________

- **Developer**: __________________ / Date: __________

- **Investor**: __________________ / Date: __________

  

---

  

### Attachments

- Expense appendix (Oct 1–9).

- Issue screenshots/screen recordings (if any).
  
  ![[WhatsApp 이미지 2025-10-08, 22.07.52_39c41a0b.jpg]]