# Firestore Security Rules Overview (Draft)

## 1. Scope
신규/핵심 컬렉션: listings, reservations, lost_items, auctions, bids, feed (materialized), ai_checks, club_posts, jobs, job_applications.

## 2. Principles
- 최소 권한(Principle of Least Privilege)
- 서버 신뢰 불가(모든 write 조건 검증)
- 상태 전이 유효성(State Machine Guards)
- 가시성/위치 기반 제한(지역 위조 방지)

## 3. Collections & Conditions (요약)
Collection | Read | Create | Update | Delete | Notes
----------|------|--------|--------|--------|------
listings | public filtered | auth & owner | owner & allowed fields | owner if draft | status transitions validate
ai_checks | owner (mask risk) | Function only | Function only | - | write via Cloud Function
reservations | owner(buyer)/seller | buyer auth | Function (payment webhook) | - | escrow integrity enforced
lost_items | public active only | auth | owner (limited) | owner if active | expiresAt set on create only
auctions | public running | seller auth | seller (no revert start) | seller if no bids | status start/end by Function
bids | bidder or seller limited | bidder auth | - | - | amount & maxAutoBid immutable
feed_entries_* | public | Function only | Function only | Function only | materialized indexes
club_posts | members of club | member | author (content) or mod (hidden) | author/mod | hidden flag only by mod/admin
jobs | public active subset | employer verified/unverified allowed | employer; guarded state changes | employer if draft | deadline immutable after active
job_applications | applicant or employer | applicant | employer (status field) or applicant (withdraw) | applicant (withdraw early) | status enum transitions

## 4. Example Rule Snippets (Pseudo)
```js
match /listings/{id} {
  allow read: if resource.data.status in ['active','reserved'];
  allow create: if request.auth != null && request.resource.data.ownerUid == request.auth.uid;
  allow update: if request.auth.uid == resource.data.ownerUid && validListingTransition(resource, request.resource);
  allow delete: if request.auth.uid == resource.data.ownerUid && resource.data.status == 'draft';
}
```

```js
function validListingTransition(before, after) {
  return (before.status == after.status) ||
    (before.status == 'draft' && after.status == 'pending_ai') ||
    (before.status == 'pending_ai' && after.status == 'active') ||
    // disallow reverse & illegal jumps
    !(['reserved','sold'].has(before.status) && after.status == 'active');
}
```

## 5. State Machine Validation Targets
- listings.status
- auctions.status (scheduled→running→ended)
- reservations.status (pending→active→released/refunded)
- job_applications.status (pending→review→interview→accepted/rejected)

## 6. Data Integrity Checks
Type | Example
----|--------
Enum whitelist | status, category
Immutable fields | ownerUid, createdAt
Reference existence | listingId exists when creating reservation
Max length | description <= 5k chars
Array bounds | images <= 10
Numeric ranges | price > 0 && price < 10_000_000

## 7. Geo & Region Guard
- Writes require region field consistent with user.profile.region (prevent cross-region spoof)
- Option: Cloud Function sets canonical region; client-sent region is advisory only

## 8. Auditing & Logging
- Cloud Functions wrap privileged writes (ai_checks, feed_entries)
- Structured logs: rule_deny(reason_code)
- Weekly export of denies for tuning

## 9. Testing Strategy
Test Type | Focus
---------|-----
Unit (rules unit harness) | transition helpers
Integration (emulator) | invalid updates / denial reasons
Performance | query plan (indexes) validation

## 10. TODO
- [ ] Implement validAuctionTransition helper
- [ ] Add riskScore masking rule
- [ ] Write emulator tests for reservation state tamper
- [ ] Region spoof test set
- [ ] Deny reason code taxonomy
- [ ] finalize job_applications transition helper

## 11. Open Questions
- ai_checks read masking: full vs partial?
- feed_entries shard naming convention exposure?
- multi-region replication 영향?
