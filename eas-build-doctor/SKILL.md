---
name: eas-build-doctor
description: Diagnose failed EAS builds by parsing build logs, identifying root causes (CocoaPods, Gradle, signing, Metro, OOM, native deps), and providing targeted fixes. Use when an EAS build fails, user pastes build logs, or asks why their build broke.
user-invocable: true
---

# EAS Build Doctor

Diagnose failed EAS builds and provide targeted fixes.

## Workflow

### 1) Gather build context

First, collect info. Ask the user for whichever is missing:

- **Build URL or ID** — run `eas build:view` or ask user to paste the URL
- **Platform** — iOS or Android?
- **Build profile** — development, preview, or production?

Then run these in parallel:

```bash
# Get build logs (if build ID available)
bash ~/.claude/skills/eas-build-doctor/scripts/fetch_build_log.sh <BUILD_ID>

# Snapshot local config
bash ~/.claude/skills/eas-build-doctor/scripts/snapshot_config.sh
```

If the user pastes logs directly, skip the fetch step.

### 2) Parse and classify the error

Scan the build log **bottom-up** (errors are at the end). Classify into one of these categories:

| Category | Log patterns |
|---|---|
| **Metro / JS Bundle** | `Metro encountered an error`, `Unable to resolve module`, `bundleReleaseJsAndAssets FAILED`, `SyntaxError` |
| **CocoaPods** | `pod install` failed, `CDN: trunk`, `Unable to find a specification`, `The following build commands failed: CompileC`, `Specs satisfying the dependency were found but they required a higher minimum deployment target` |
| **Gradle** | `Build failed with an exception`, `Could not resolve`, `Execution failed for task`, `AAPT2`, `daemon disappeared unexpectedly` |
| **Code Signing (iOS)** | `No signing certificate`, `Provisioning profile`, `Code Sign error`, `exportArchive`, `No profiles for team` |
| **Keystore (Android)** | `keystore`, `jarsigner`, `signing config` |
| **Native Module** | `Undefined symbols for architecture`, `linker command failed`, `No such module`, `cannot find -l` |
| **Xcode Version** | `Unsupported Swift version`, `SDK does not contain`, `The linked library is missing` |
| **OOM / Resources** | `daemon disappeared unexpectedly`, `Killed`, `SIGKILL`, `out of memory`, `heap` |
| **EAS Config** | `Invalid eas.json`, `Missing build profile`, `incompatible SDK version` |
| **Credentials** | `No credentials set up`, `Certificate has expired`, `Provisioning profile does not match` |
| **Prebuild / Config Plugin** | `Config plugin`, `Cannot find module`, `mods.ios`, `mods.android` |
| **Gitignore / Missing Files** | `None of these files exist`, `ENOENT`, `File not found` |

### 3) Diagnose root cause

For each category, follow the diagnostic path:

#### Metro / JS Bundle
1. Ask user to run `npx expo export` locally — does it reproduce?
2. Check for case-sensitive filename mismatches (`git ls-files` vs actual)
3. Check `.gitignore` for accidentally excluded source files
4. Check `metro.config.js` for custom resolvers that may differ locally vs CI
5. Look for circular imports or missing peer deps

#### CocoaPods
1. Check `ios/Podfile` — does deployment target match what native deps need?
2. Run `npx expo-doctor` locally
3. Check if specific pod version is yanked or CDN is stale
4. Verify Xcode version in `eas.json` matches pod requirements
5. Check for `use_frameworks!` conflicts with static/dynamic linking

#### Gradle
1. Check `android/build.gradle` — `compileSdkVersion`, `targetSdkVersion`, `minSdkVersion`
2. Check for conflicting dependency versions in `android/app/build.gradle`
3. Look for duplicate class errors (usually transitive deps)
4. If OOM: suggest `"resourceClass": "large"` in `eas.json`
5. Check Java version compatibility

#### Code Signing (iOS)
1. Run `eas credentials` to check current state
2. Check if cert expired: `eas credentials --platform ios`
3. Verify bundle identifier matches provisioning profile
4. Check `eas.json` for `distribution` type mismatch (store vs internal vs simulator)
5. Suggest `eas credentials --platform ios --clear` + re-setup if corrupted

#### Native Module
1. Identify which native module is failing
2. Check if it needs a config plugin that's missing from `app.json`
3. Check if the module version is compatible with current Expo SDK
4. Look for autolinking issues — run `npx expo-doctor`
5. Check if module requires manual native code (incompatible with managed workflow)

#### OOM / Resources
1. Run `npx expo-atlas` locally to check bundle size
2. Check for large assets being bundled (fonts, images, JSON files)
3. Suggest `"resourceClass": "large"` or `"resourceClass": "m-large"` in `eas.json`
4. Check for accidentally imported large data files

#### Prebuild / Config Plugin
1. Run `npx expo prebuild --clean` locally — does it reproduce?
2. Check plugin is installed and version matches Expo SDK
3. Check `app.json` / `app.config.js` for typos in plugin config
4. Verify plugin supports current Expo SDK version

#### Gitignore / Missing Files
1. Compare `git ls-files` with imports
2. Check `.easignore` and `.gitignore`
3. Look for files generated at dev time but not committed (codegen, env files)

### 4) Present diagnosis

Format the response as:

```
## Build Diagnosis

**Error:** [one-line summary]
**Category:** [from table above]
**Root Cause:** [specific explanation]

## Fix

[numbered steps to resolve]

## Verify

[command to verify the fix locally before re-triggering build]
```

### 5) Verify fix locally

Before re-triggering, always suggest local verification:

```bash
# General health check
npx expo-doctor

# JS bundle check
npx expo export

# iOS prebuild check
npx expo prebuild --platform ios --clean

# Android prebuild check  
npx expo prebuild --platform android --clean
```

### 6) Re-trigger build

Once verified locally:

```bash
eas build --platform <ios|android> --profile <profile>
```

## Common Quick Fixes Reference

| Symptom | Quick Fix |
|---|---|
| Pod install CDN error | Add `source 'https://cdn.cocoapods.org/'` to Podfile, or clear pod cache |
| Gradle OOM | Add `"resourceClass": "large"` to build profile in `eas.json` |
| Metro can't resolve module | Run `npx expo export` locally, fix import, check `.gitignore` |
| Expired certificate | `eas credentials --platform ios` → regenerate |
| Wrong Xcode version | Set `"image"` in `eas.json` build profile (e.g., `"image": "macos-ventura-14.2-xcode-15.1"`) |
| Config plugin not found | `npx expo install <plugin-package>` — make sure it's in dependencies, not devDependencies |
| Duplicate classes (Android) | Add `packagingOptions { exclude }` or resolve transitive dep conflict |
| Swift version mismatch | Update Xcode image in `eas.json` or pin pod to compatible version |
| Provisioning profile mismatch | `eas credentials --platform ios` → re-select or regenerate profile |
| `expo-dev-client` in production build | Remove from production profile or guard with build profile |

## Resources
- `scripts/fetch_build_log.sh` — Fetch and extract build logs via EAS CLI
- `scripts/snapshot_config.sh` — Snapshot local config for comparison
- `references/known-errors.md` — Pattern-matched error database
