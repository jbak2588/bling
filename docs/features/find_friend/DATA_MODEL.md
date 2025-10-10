# Find Friend Data Model (Draft)

## Collections
```
/users/{uid}
  - nickname
  - ageRange
  - gender
  - intro
  - interests[]
  - geo: { lat, lng }
  - trustLevel
  - verified: { phone, email, neighborhood }
  - createdAt, updatedAt

/match_requests/{id}
  - fromUid
  - toUid
  - status (pending|accepted|rejected|blocked)
  - createdAt
  - respondedAt

/chats/{chatId}
  - participants[]
  - lastMessage
  - lastMessageAt

/user_daily_limits/{uid}
  - date
  - friendRequestCount
  - limit
```

## Indexing
- Geo queries via composite (if using geohash: store `geoHash`)
- `match_requests` index on (toUid, status)

## Integrity Rules (요약)
- 하나의 pending 요청 중복 금지 (transaction or security rules)
- 수락 시 chat 문서 생성 원자적 처리
- rejected 30일 지난 요청 자동 삭제 (scheduled function)

## Security / Rules Considerations
- `match_requests`: only `fromUid` create; only `toUid` update accept/reject
- read restricted to involved users
- daily limit: server-enforced (function) to prevent client tampering
