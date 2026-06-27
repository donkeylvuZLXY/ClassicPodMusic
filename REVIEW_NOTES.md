# ClassicPod Music Review Notes

## Visual target

- Target device: iPhone 16 Pro portrait.
- Reference viewport used for local review: 402 pt wide.
- Visual direction: iOS 26 Liquid Glass style with translucent control surfaces, edge highlights, background color refraction, and large touch targets.

## Local preview checks

Checked in the in-app browser at 402 pt width:

- No horizontal overflow.
- No vertical overflow in the constrained browser viewport.
- Main player width: 376 pt.
- Screen size: 328 x 241 pt.
- Click wheel size: 258 x 258 pt.
- Button touch areas:
  - MENU: 86 x 52 pt.
  - Previous: 66 x 66 pt.
  - Next: 66 x 66 pt.
  - Play/Pause: 86 x 52 pt.
  - Select: 100 x 100 pt.
- List text clipping check: passed.
- MENU, Select, Next, and Play/Pause interactions: passed.

Screenshots:

- `../ClassicPodPreview/iphone16pro-liquid-glass.png`
- `../ClassicPodPreview/iphone16pro-liquid-glass-list.png`

## iOS project checks

- `Info.plist` XML parse: passed.
- Entitlements XML parse: passed.
- Asset catalog JSON parse: passed.
- MusicKit usage description present: `NSAppleMusicUsageDescription`.
- MusicKit entitlement present: `com.apple.developer.music-kit`.
- iOS source uses native `glassEffect` behind iOS 26 availability checks.

## IPA limitation

This Windows machine cannot create an installable iOS IPA because the IPA must contain an iOS `arm64` Mach-O executable linked with Apple's iOS SDK. That requires Apple's macOS toolchain. A zip renamed to `.ipa` without that binary will not install through iTunes, AltStore, Sideloadly, or i4Tools/Aisi Assistant.

Use `NO_XCODE_IPA_BUILD.md` to build an unsigned IPA on a macOS runner without opening Xcode, then re-sign it with your own certificate/profile.
