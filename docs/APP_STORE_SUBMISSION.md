# App Store Submission Notes
## Kurdish Sorani Keyboard — Version 1.0

**Submitted for review:** June 1, 2026  
**Current status:** In Review

---

## App Details

| Field | Value |
|---|---|
| App name | Kurdish Sorani Keyboard |
| Bundle ID | com.kurdish.sorani.inputmethod.KurdishSorani |
| Version | 1.0 |
| Build | 1 |
| Category | Utilities |
| Price | Free |
| Age rating | 4+ |
| Deployment target | macOS 14 Sonoma |
| Author | Nafeh Muhammed Mahmoud (نافع محمد محمود) |
| Contact email | (see Apple Developer account) |

---

## App Store Connect URLs

- **Privacy Policy:** https://github.com/NafehM/kurdish-keyboard/blob/main/PRIVACY.md
- **Screenshots:** `screenshot1-appstore.png`, `screenshot2-appstore.png` (2560×1600)

---

## Technical Architecture

**Single Xcode target** — IMK input method + status bar app in one bundle.

| File | Purpose |
|---|---|
| `main.swift` | Starts IMKServer, runs NSApplication |
| `InputController.swift` | `IMKInputController` subclass — handles key events via `KurdishKeyMap` |
| `KurdishKeyMap.swift` | Full Sorani mapping: base / shift / option / option+shift |
| `KeyboardViewer.swift` | Floating `NSPanel` showing full layout, shift-synced with IMK |
| `AppDelegate.swift` | Status bar menu (ک), onboarding trigger |
| `OnboardingWindowController.swift` | First-launch setup instructions |
| `Info.plist` | Merged IMK registration + UI keys |
| `KurdishSoraniKeyboard.entitlements` | App Sandbox + IMK mach exceptions |
| `PrivacyInfo.xcprivacy` | Privacy manifest (no data collected, UserDefaults CA92.1) |
| `Assets.xcassets/AppIcon.appiconset/` | App icon — ک on blue gradient, all 10 sizes |

---

## Critical Config Values

These strings must match exactly across files or IMKServer will fail to register:

- **IMK connection name:** `com.kurdish.sorani.inputmethod.KurdishSorani_Connection`
  - In `Info.plist` → `InputMethodConnectionName`
  - In `Info.plist` → `main.swift` IMKServer init
  - In `KurdishSoraniKeyboard.entitlements` → both mach exceptions
- **IMK controller class:** `KurdishSoraniInputController`
  - In `Info.plist` → `InputMethodServerControllerClass`
  - In `InputController.swift` → `@objc(KurdishSoraniInputController)`
- **Input source ID:** `com.kurdish.sorani.Sorani`
  - In `Info.plist` → `ComponentInputModeDict`

---

## xcodegen Resource Syntax (important gotcha)

xcodegen 2.45.4 silently drops `.keylayout` and `.xcassets` when listed under a top-level `resources:` block. Use `buildPhase: resources` inside the `sources:` array instead:

```yaml
sources:
  - path: KurdishSoraniKeyboard
    excludes:
      - "Info.plist"
      - "*.entitlements"
      - "*.keylayout"
      - "Assets.xcassets"
      - "*.xcprivacy"
  - path: KurdishSoraniKeyboard/KurdishSorani.keylayout
    buildPhase: resources
  - path: KurdishSoraniKeyboard/Assets.xcassets
    buildPhase: resources
  - path: KurdishSoraniKeyboard/PrivacyInfo.xcprivacy
    buildPhase: resources
```

---

## Test Suite

14 tests, all passing:
- `KurdishKeyMapTests` (11) — verifies character mappings for key codes
- `OnboardingTests` (3) — verifies UserDefaults onboarding flag logic

Run with:
```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild test \
  -project KurdishSoraniKeyboard/KurdishSoraniKeyboard.xcodeproj \
  -scheme KurdishSoraniKeyboard \
  -destination 'platform=macOS'
```

---

## Key Git Commits (App Store readiness)

```
f87ef4f Updated README.md and added PRIVACY.md files
5be4190 fix: resolve merge conflict in README.md
642488e fix: add LSApplicationCategoryType to Info.plist (required for App Store)
6cb13fb fix: add KurdishSorani.keylayout and Assets.xcassets to xcodeproj Resources
ce43ac9 test: all 14 unit tests pass, clean build verified, bundle assets confirmed
62d7462 feat: add PrivacyInfo.xcprivacy (required for App Store, no data collected)
caa5c36 feat: add app icon (all 10 required sizes, ک on blue background)
b1f93af fix: add GENERATE_INFOPLIST_FILE to test target so tests build and run
```

---

## Known Limitation

Keyboard Viewer click-to-type uses `CGEvent.post(tap: .cgAnnotatedSessionEventTap)`. 
This works for the IMK process but may be silently dropped in some sandbox contexts.
The viewer remains fully functional as a visual layout reference regardless.

---

## Next Version Checklist (future reference)

When submitting version 1.1 or later:
1. Increment `CFBundleShortVersionString` in `Info.plist`
2. Increment `CFBundleVersion` in `Info.plist`
3. Archive → Product → Archive in Xcode
4. Distribute App → App Store Connect → Upload
5. In App Store Connect: select new build, fill "What's New", submit for review
