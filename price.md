# Pricing Configuration

## Monetization Model: Freemium + One-Time Purchase (Non-Consumable IAP)

The app is free to download with limited features. Users can unlock all features with a one-time purchase of $9.99. No subscriptions, no recurring charges.

## Pricing Rationale
- Users suffer from subscription fatigue (Pain Point #4 in guide)
- All competitors charge $29-99 for lifetime or require subscriptions
- $9.99 is 82% cheaper than competitor average lifetime price
- 100% on-device processing means no API/server costs to justify subscriptions
- One-time purchase is the strongest competitive differentiator

## Free Tier (Forever Free)
| Feature | Free | Pro |
|---------|------|-----|
| Albums | 1 | Unlimited |
| Photos per week | 3 | Unlimited |
| Comparison modes | Side-by-side only | All 3 (Slider, Side-by-side, Overlay) |
| Ghost Overlay camera | ✅ | ✅ |
| Voice shutter | ✅ | ✅ |
| Timer | ✅ | ✅ |
| Face ID lock | ✅ | ✅ |
| Ads | Never | Never |
| Timelapse video | ❌ | ✅ |
| HealthKit integration | ❌ | ✅ |
| iCloud sync | ❌ | ✅ |
| Privacy blur export | ❌ | ✅ |
| Batch photo import | ❌ | ✅ |

## In-App Purchase

### Non-Consumable: SnapShift Pro
- **Reference Name**: SnapShift Pro
- **Product ID**: `com.zzoutuo.SnapShift.pro`
- **Price**: $9.99 (one-time purchase)
- **Display Name**: SnapShift Pro
- **Description**: Unlock unlimited albums, photos, all comparison modes, timelapse, HealthKit, and iCloud sync
- **Family Sharing**: Supported

## App Store Connect Pricing
- **App Price**: Free (Tier 0)
- **IAP Price**: Tier 9 ($9.99)

## Conversion Funnel Estimate
- Free download → Use 1 week: 60%
- Use 1 week → Hit free tier limit: 35%
- Hit limit → Pro conversion: 15-20%
- Overall conversion rate estimate: 5-7% (above industry avg 3-5% due to low price)

## Revenue Estimate
| Scenario | Monthly Downloads | Conversion | Price | Monthly Revenue |
|----------|------------------|------------|-------|-----------------|
| Conservative | 2,000 | 5% | $9.99 | $999 |
| Moderate | 5,000 | 6% | $9.99 | $2,997 |
| Optimistic | 15,000 | 7% | $9.99 | $10,489 |

## Policy Pages Required
- Support Page: ✅ (must include IAP/restore info)
- Privacy Policy: ✅
- Terms of Use: ✅ (required for IAP apps)

## Apple IAP Compliance Checklist
- [x] One-time purchase clearly stated (no auto-renewal)
- [x] Restore purchases functionality implemented
- [x] Family Sharing supported
- [x] No dark patterns or misleading pricing
- [x] Free tier provides genuine value (not just a trial)
- [x] Pro features clearly listed before purchase
