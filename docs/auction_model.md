# AuctionModel Overview

`AuctionModel` represents a premium auction listing stored in Firestore.
It mirrors the schema defined in the project documentation for the `auctions`
collection.

Fields:
- `title` and `description` describe the item
- `images` holds photo URLs
- `startPrice` is the initial amount
- `currentBid` tracks the highest bid
- `bidHistory` stores bid snapshots
- `location` and `geoPoint` mark where the item is located
- `startAt` and `endAt` define the auction window
- `ownerId` references the seller
- `trustLevelVerified` and `isAiVerified` flag vetted auctions

See `lib/core/models/auction_model.dart` for implementation.
