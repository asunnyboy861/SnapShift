# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities are required:

| Requirement | Keywords Found | Capability |
|-------------|---------------|------------|
| Camera for ghost overlay photos | "相机", "拍照", "Ghost Overlay" | Camera + Photo Library |
| Voice-activated shutter | "语音", "快门", "Speech" | Speech Recognition + Microphone |
| Health data integration | "HealthKit", "健康", "体重" | HealthKit |
| Cloud sync | "iCloud", "同步", "CloudKit" | iCloud (CloudKit) |
| Biometric lock | "Face ID", "锁定", "隐私" | Face ID (LocalAuthentication) |
| Pro upgrade purchase | "购买", "Pro", "买断" | In-App Purchase |
| Photo reminders | "通知", "提醒" | Push Notifications |

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Camera Usage | ✅ Info.plist key needed | NSCameraUsageDescription |
| Photo Library | ✅ Info.plist key needed | NSPhotoLibraryUsageDescription |
| Microphone | ✅ Info.plist key needed | NSMicrophoneUsageDescription |
| Speech Recognition | ✅ Info.plist key needed | NSSpeechRecognitionUsageDescription |
| Face ID | ✅ Info.plist key needed | NSFaceIDUsageDescription |
| In-App Purchase | ✅ StoreKit 2 | Non-consumable: com.zzoutuo.SnapShift.pro |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| HealthKit | ⏳ Pending | 1. Add HealthKit capability in Xcode Signing & Capabilities 2. Check "Read" for HKQuantityTypeIdentifierBodyMass and HKQuantityTypeIdentifierBodyFatPercentage 3. Add NSHealthShareUsageDescription to Info.plist |
| iCloud (CloudKit) | ⏳ Pending | 1. Add iCloud capability in Xcode Signing & Capabilities 2. Check CloudKit 3. Create CloudKit container: iCloud.com.zzoutuo.SnapShift 4. Enable Core Data with CloudKit sync |
| Push Notifications | ⏳ Pending | 1. Add Push Notifications capability in Xcode Signing & Capabilities 2. Register for remote notifications in AppDelegate |

## No Configuration Needed
- Apple Watch: Not required for this app
- Sign in with Apple: Not required
- Background Modes: Not required (no background processing needed)
- Location Services: Not required
- Siri: Not required

## Info.plist Permission Descriptions
| Key | Value |
|-----|-------|
| NSCameraUsageDescription | SnapShift needs camera access to take progress photos with ghost overlay alignment. |
| NSPhotoLibraryUsageDescription | SnapShift needs photo library access to import existing progress photos. |
| NSMicrophoneUsageDescription | SnapShift needs microphone access for voice-activated shutter functionality. |
| NSSpeechRecognitionUsageDescription | SnapShift needs speech recognition to detect voice commands like "Now" for hands-free photo capture. |
| NSFaceIDUsageDescription | SnapShift uses Face ID to protect your private progress photos. |
| NSHealthShareUsageDescription | SnapShift reads your weight and body fat data from Health to display alongside your progress photos. |

## Verification
- Build succeeded after configuration: Pending (will verify after code generation)
- All entitlements correct: Pending
