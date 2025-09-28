# RoomListingModel Overview

`RoomListingModel` defines the data used for Kos/boarding and other real estate listings.
It mirrors the `rooms_listings` collection described in the project docs.

Fields captured include:
- `roomType` (e.g. private or shared)
- `address` and optional `geoPoint`
- `price` and optional `deposit`
- `size` and `amenities`
- `photos` URLs
- `contactInfo` for the host
- `ownerType` (owner or agent)
- `createdAt` timestamp

See `lib/core/models/room_listing_model.dart` for implementation.
