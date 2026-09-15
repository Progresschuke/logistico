# Logistics Feature – Restructure + Customer Tracking Screen

## Folder Structure
```
lib/
├── main.dart
├── enum/
│   └── enum.dart (existing — keep)
├── models/
│   └── delivery.dart          [NEW] Shared data model
├── widgets/
│   ├── delivery_map.dart      [NEW] Reusable map (city + coastal styles)
│   ├── delivery_info_card.dart[NEW] ETA card (rider screen)
│   ├── delivery_status.dart   [NEW] Status stepper + tracking bar
│   └── rider_info_card.dart   [NEW] Rider bottom bar + Customer panel
└── screens/
    ├── rider_screen.dart      [MOVED+REFACTORED] Uses all widgets
    └── tracking_screen.dart   [NEW] Customer tracking view
```

## Components

### models/delivery.dart
- `DeliveryModel` data class with static sample data

### widgets/delivery_map.dart
- `enum MapStyle { city, coastal }`
- `DeliveryMap` — StatefulWidget, manages own animation, accepts overlays
- `_CityMapPainter` / `_CityRoutePainter` — green animated route
- `_CoastalMapPainter` / `_CoastalRoutePainter` — red+blue split route, shopping bag + drop pin

### widgets/delivery_info_card.dart
- `DeliveryEtaCard` — floating "12 min | 1.8 km away" card (rider screen)

### widgets/delivery_status.dart
- `DeliveryStatusStepper` — circular badge stepper with pulse (rider screen)
- `TrackingStatusBar` — minimal icon row with connecting lines (tracking screen)

### widgets/rider_info_card.dart
- `RiderStatusBar` — avatar + status text + call button (rider screen)
- `CustomerDeliveryPanel` — dark header + white ETA body (tracking screen)

## Verification
- `flutter analyze` — zero errors
- Both screens visible via named routes `/rider` and `/tracking`
