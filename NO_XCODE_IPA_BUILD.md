# Build an unsigned IPA without opening Xcode

You cannot create a working iOS IPA on Windows alone. The IPA must contain an iOS `arm64` Mach-O app binary built with Apple's iOS SDK. This project includes a GitHub Actions workflow so you can build the unsigned IPA on a cloud macOS runner without opening Xcode.

## Steps

1. Put this `ClassicPodMusic` folder in a GitHub repository.
2. Open the repository on GitHub.
3. Go to `Actions`.
4. Run `Build unsigned iOS IPA`.
5. Download the `ClassicPodMusic-unsigned-ipa` artifact.
6. Re-sign `ClassicPodMusic-unsigned.ipa` with your own iOS certificate/provisioning profile.

## Important

- Your provisioning profile must support the app bundle identifier you sign with.
- Apple Music access requires the MusicKit capability. If your signing method removes or cannot provide the MusicKit entitlement, the app may install but Apple Music library access can fail.
- If you use a free Apple ID signing flow, the installed app can expire and need reinstalling.
- The iOS 26 native Liquid Glass implementation requires an Apple SDK that includes SwiftUI `glassEffect`.

## Local macOS command

If you ever use a Mac terminal without opening Xcode:

```bash
chmod +x scripts/build_unsigned_ipa.sh
scripts/build_unsigned_ipa.sh
```

The output will be:

```text
dist/ClassicPodMusic-unsigned.ipa
```
