# SnapShift - iOS Development Guide

## Executive Summary

**SnapShift** is a privacy-first, ad-free progress photo comparison app for iOS that helps users track body transformations through before-and-after photos. Targeting the US fitness market, SnapShift differentiates itself with three core value propositions: **zero ads forever**, **100% on-device privacy** (no server uploads), and a **one-time purchase model** ($9.99) that eliminates subscription fatigue.

### Product Vision
Enable anyone to visually track their body transformation journey with perfect photo alignment, complete privacy, and zero recurring costs.

### Target Audience
- Fitness enthusiasts tracking weight loss or muscle gain (primary)
- Home renovation before/after documentation (secondary)
- Beauty/makeup transformation tracking (tertiary)

### Key Differentiators
| Feature | SnapShift | Competitors |
|---------|-----------|-------------|
| Ads | Never | Most have ads |
| Privacy | 100% on-device | Many upload to servers |
| Pricing | $9.99 one-time | $29-99 lifetime or subscription |
| Photo Alignment | Ghost overlay + voice shutter | None or basic |
| Selfie Support | Voice-activated + timer | Most require another person |

---

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Shapez** (4.4★) | Ghost overlay, 25 body measurements, GIF export, Apple Health sync, 100K+ users | Introduced free photo limits causing user churn; subscription model; cloud data storage raises privacy concerns | Cheaper one-time price; no subscription; 100% local storage; voice shutter |
| **Before & After Photo Compare** | Video/photo collage creation, text/stickers/music, variety of templates | $4.49/week subscription; watermark on free; no ghost overlay; no camera integration | One-time price vs weekly sub; ghost overlay camera; no watermark; privacy-first |
| **BodyShapr** (2.2★) | Slider/GIF/Lapse/Collage modes, superimpose tool, one-time purchase | Server errors, registration failures, no camera timer, no import, poor UX | Stable experience; camera with timer; photo import; voice shutter; better alignment |
| **Sizr** | Auto-cropping, multi-user, before/after compare, charts | New app with few reviews; limited comparison modes; no ghost overlay | Ghost overlay; voice shutter; timelapse; HealthKit; Face ID lock |
| **BodyLapse** | Timelapse focus, pose guidelines, face blur, offline-first | Limited comparison modes; new app; no ghost overlay | Ghost overlay; 3 comparison modes; HealthKit; iCloud sync |

---

## Apple Design Guidelines Compliance

- **HIG - Photography Apps**: Use AVFoundation for custom camera; respect user photo library permissions; provide clear camera UI with minimal chrome
- **HIG - Privacy**: Implement Face ID/Touch ID via LocalAuthentication; clearly explain why each permission is needed; store data on-device by default
- **HIG - Health Data**: HealthKit integration requires NSHealthShareUsageDescription; must not share health data with third parties; provide privacy policy
- **App Store Review 5.1.1 (Privacy)**: Must disclose all data collection; body photos are sensitive data requiring maximum protection
- **App Store Review 2.5.6 (Speech Recognition)**: Must request Speech Recognition permission; provide fallback for denied permission
- **App Store Review 3.1.1 (IAP)**: One-time non-consumable purchase for Pro unlock; must use StoreKit; Family Sharing supported
- **HIG - Dark Mode**: Default dark theme for fitness context; photos appear more vivid on dark backgrounds
- **HIG - Accessibility**: VoiceOver labels on all controls; Dynamic Type support; reduced motion respect; voice shutter as alternative input

---

## Technical Architecture

- **Language**: Swift 5.9+ with strict concurrency
- **Framework**: SwiftUI (primary), AVFoundation (camera), Speech (voice), LocalAuthentication (Face ID)
- **Data**: Core Data with optional CloudKit sync
- **Photos**: File system storage with PHAsset references
- **Health**: HealthKit (read-only for weight/body fat)
- **Video**: AVAssetWriter for timelapse generation
- **IAP**: StoreKit 2 for non-consumable purchase
- **Dependencies**: Picture-Comparison-View-SwiftUI (SPM) — before/after slider component

---

## Module Structure

```
SnapShift/
├── App/
│   └── SnapShiftApp.swift
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Albums/
│   │   ├── AlbumListView.swift
│   │   ├── AlbumDetailView.swift
│   │   └── CreateAlbumView.swift
│   ├── Camera/
│   │   ├── GhostOverlayCameraView.swift
│   │   └── CameraControlsView.swift
│   ├── Comparison/
│   │   ├── ComparisonView.swift
│   │   ├── SliderComparisonView.swift
│   │   ├── SideBySideView.swift
│   │   └── OverlayComparisonView.swift
│   ├── Timeline/
│   │   └── TimelineView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Common/
│       ├── MetricBadge.swift
│       ├── DifferenceBadge.swift
│       └── ProUpgradeSheet.swift
├── ViewModels/
│   ├── AlbumListViewModel.swift
│   ├── CameraViewModel.swift
│   ├── ComparisonViewModel.swift
│   ├── TimelineViewModel.swift
│   └── SettingsViewModel.swift
├── Models/
│   ├── ProgressAlbum.swift
│   ├── ProgressPhoto.swift
│   └── PhotoAngle.swift
├── Services/
│   ├── CameraManager.swift
│   ├── VoiceCaptureManager.swift
│   ├── PhotoStorageManager.swift
│   ├── HealthKitManager.swift
│   ├── TimelapseGenerator.swift
│   ├── PrivacyLockManager.swift
│   ├── SyncManager.swift
│   └── PurchaseManager.swift
├── Persistence/
│   ├── CoreDataStack.swift
│   └── SnapShift.xcdatamodeld
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

---

## Implementation Flow

### Phase 1: Project Setup & Data Layer
1. Create Xcode project with SwiftUI, Core Data, and minimum iOS 17.0
2. Add Picture-Comparison-View-SwiftUI via Swift Package Manager
3. Define Core Data model (ProgressAlbum, ProgressPhoto entities)
4. Implement CoreDataStack with CloudKit optional sync
5. Create PhotoAngle enum and data model extensions

### Phase 2: Camera System
1. Implement CameraManager with AVFoundation (session, photo capture, front/back switch)
2. Build CameraPreview UIViewRepresentable for live camera feed
3. Add Ghost Overlay layer (semi-transparent previous photo)
4. Implement VoiceCaptureManager with Speech framework
5. Add countdown timer (3s, 5s, 10s options)
6. Add grid overlay toggle
7. Add opacity slider for ghost overlay

### Phase 3: Photo Management
1. Implement PhotoStorageManager (save/load/delete photos to app sandbox)
2. Build album creation and editing views
3. Implement photo import via PHPickerViewController
4. Add angle grouping (Front/Back/Side/Custom)
5. Build timeline view with chronological photo display

### Phase 4: Comparison System
1. Integrate Picture-Comparison-View-SwiftUI for slider comparison
2. Build side-by-side comparison view
3. Build overlay/onion-skin comparison view
4. Add metric badges (date, weight, body fat)
5. Add difference badges (weight change, body fat change, days elapsed)
6. Add pinch-to-zoom on comparison views

### Phase 5: Advanced Features
1. Implement TimelapseGenerator using AVAssetWriter
2. Add HealthKit integration (read weight, body fat percentage)
3. Implement PrivacyLockManager with LocalAuthentication (Face ID/Touch ID)
4. Add iCloud sync via CloudKit
5. Add privacy blur for export (face blur option)

### Phase 6: Monetization & Polish
1. Implement PurchaseManager with StoreKit 2 (non-consumable)
2. Build Pro upgrade sheet UI
3. Add free tier limits (1 album, 3 photos/week, side-by-side only)
4. Add onboarding flow (3 pages)
5. Add app icon and launch screen
6. Final testing and bug fixes

---

## UI/UX Design Specifications

### Color Scheme
| Role | Dark Mode | Light Mode |
|------|-----------|------------|
| Background | #0A0A0A | #F2F2F7 |
| Card | #1C1C1E | #FFFFFF |
| Accent | #00D4AA (vibrant teal) | #00B894 (deep teal) |
| Positive Change | #FF6B6B (warm red) | #FF6B6B |
| Text Primary | #FFFFFF | #000000 |
| Text Secondary | #8E8E93 | #8E8E93 |

### Typography
- Headlines: SF Pro Display, Bold, 28pt
- Subheadlines: SF Pro Display, Semibold, 20pt
- Body: SF Pro Text, Regular, 17pt
- Captions: SF Pro Text, Regular, 12pt
- Metric values: SF Pro Display, Bold, 16pt (monospaced numbers)

### Layout Rules
- Photos occupy 80%+ of screen space
- Tab bar: Camera (center), Albums (left), Settings (right)
- Cards use 16pt corner radius with subtle shadow
- Safe area insets respected on all edges
- Bottom controls have 50pt bottom padding for reachability

### Animations
| Interaction | Animation | Duration |
|-------------|-----------|----------|
| Page transition | iOS native slide | 0.35s |
| Photo selection | Scale + fade in | 0.25s |
| Ghost overlay opacity | Smooth transition | 0.15s |
| Shutter capture | White flash + scale | 0.1s |
| Slider drag | Real-time response | 0ms |
| Pro upgrade sheet | Bottom sheet slide up | 0.3s |

### Accessibility
- VoiceOver: All controls have accessibility labels and hints
- Dynamic Type: Supports user font size preferences
- Color Contrast: WCAG AA standard (4.5:1 minimum)
- Reduce Motion: Respects system "Reduce Motion" setting
- Voice Shutter: Alternative input for users with motor impairments

---

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- MVVM architecture with SwiftUI + ObservableObject ViewModels
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI, AVFoundation, Core Data, StoreKit 2
- Open source first: integrate Picture-Comparison-View-SwiftUI for comparison slider
- Swift 6.0 strict concurrency compliance
- All data stored on-device; no network requests except optional iCloud sync
- Zero third-party analytics; zero ad SDKs
- Face ID lock protects app launch and photo access
- Free tier: 1 album, 3 photos/week, side-by-side comparison only
- Pro tier: Unlimited everything, all comparison modes, timelapse, HealthKit, iCloud sync

---

## Build & Deployment Checklist

1. Verify Xcode project targets iOS 17.0+ with Swift 5.9+
2. Add Picture-Comparison-View-SwiftUI SPM dependency
3. Configure Info.plist permissions: NSCameraUsageDescription, NSPhotoLibraryUsageDescription, NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription, NSHealthShareUsageDescription, NSFaceIDUsageDescription
4. Enable HealthKit capability in Signing & Capabilities
5. Enable iCloud capability with CloudKit
6. Configure StoreKit non-consumable product: com.zzoutuo.SnapShift.pro
7. Test Face ID on physical device (simulator has limited support)
8. Test camera and ghost overlay on physical device
9. Verify Core Data model migration path
10. Test free tier limits and Pro unlock flow
11. Generate app icon (1024x1024) with Wanx API
12. Create App Store Connect listing with metadata
13. Submit for review with privacy policy URL
