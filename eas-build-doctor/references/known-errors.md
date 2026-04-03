# Known EAS Build Errors

Pattern-matched error database. Search build logs for these patterns.

## Metro / JS Bundle

| Pattern | Cause | Fix |
|---|---|---|
| `Metro encountered an error` | JS syntax or import error | Run `npx expo export` locally |
| `Unable to resolve module` | Missing file or wrong path | Check case sensitivity, `.gitignore` |
| `bundleReleaseJsAndAssets FAILED` | Android JS bundling failed | Same as Metro errors — run export locally |
| `SyntaxError:` in build log | Invalid JS/TS syntax | Fix syntax, check babel config |
| `Require cycle:` | Circular imports | Refactor circular dependency |

## CocoaPods (iOS)

| Pattern | Cause | Fix |
|---|---|---|
| `CDN: trunk URL couldn't be downloaded` | CocoaPods CDN outage or cache | Retry, or add explicit source to Podfile |
| `Unable to find a specification for` | Pod not found or version yanked | Check pod name/version, run `pod repo update` |
| `Specs satisfying the dependency were found but they required a higher minimum deployment target` | iOS deployment target too low | Raise `ios.deploymentTarget` in Podfile or app.json |
| `The following build commands failed: CompileC` | Native compilation error | Check Xcode version, pod compatibility |
| `use_frameworks!` related errors | Static/dynamic linking conflict | Check if conflicting pods need `use_frameworks! :linkage => :static` |
| `Multiple commands produce` | Duplicate resource files | Add `install!` config or exclude duplicate resources |

## Gradle (Android)

| Pattern | Cause | Fix |
|---|---|---|
| `Could not resolve` dependency | Missing or misconfigured maven repo | Check `allprojects.repositories` in `build.gradle` |
| `Execution failed for task ':app:` | Generic task failure — read the next line | Check specific task error message |
| `Duplicate class` | Transitive dependency conflict | Use `exclude group:` or `resolutionStrategy.force` |
| `AAPT2 error` | Resource processing error | Check for malformed XML in `res/`, duplicate resource names |
| `daemon disappeared unexpectedly` | OOM during Gradle build | Set `"resourceClass": "large"` in `eas.json` |
| `Unsupported class file major version` | Java version mismatch | Set correct Java version in `eas.json` image |
| `Namespace not specified` | AGP 8+ requires namespace | Add `namespace` to `android/app/build.gradle` |

## Code Signing (iOS)

| Pattern | Cause | Fix |
|---|---|---|
| `No signing certificate` | Missing or expired cert | `eas credentials --platform ios` |
| `Provisioning profile .* doesn't match` | Bundle ID mismatch | Regenerate profile with correct bundle ID |
| `Code Sign error` | General signing failure | Clear and re-setup: `eas credentials --platform ios` |
| `exportArchive: No profiles for` | Missing distribution profile | Create via `eas credentials` or Apple Developer portal |
| `Certificate has expired` | Cert expired | Regenerate via `eas credentials --platform ios` |

## Keystore (Android)

| Pattern | Cause | Fix |
|---|---|---|
| `keystore file not found` | Missing keystore | `eas credentials --platform android` to generate |
| `jarsigner: key not found` | Wrong key alias | Check keystore alias in `eas.json` or credentials |

## Native Module

| Pattern | Cause | Fix |
|---|---|---|
| `Undefined symbols for architecture` | Missing native library linkage | Check pod/framework linking, run `pod install` |
| `No such module` | Swift module not found | Check Xcode version, bridging header |
| `cannot find -l` | Missing Android native lib | Check `build.gradle` for native dep |
| `Autolinking` errors | Module not autolinked | Run `npx expo-doctor`, check `react-native.config.js` |

## OOM / Resources

| Pattern | Cause | Fix |
|---|---|---|
| `SIGKILL` / `Killed` | Process killed by OS (OOM) | `"resourceClass": "large"` in `eas.json` |
| `JavaScript heap out of memory` | Node OOM | Increase Node memory or reduce bundle size |
| `heap` errors | Memory exhaustion | Check for large imports, use `npx expo-atlas` |

## Config / Prebuild

| Pattern | Cause | Fix |
|---|---|---|
| `Config plugin .* not found` | Plugin package not installed | `npx expo install <plugin>` |
| `Cannot find module` in plugin context | Plugin missing from deps | Move from devDeps to deps |
| `Invalid eas.json` | Malformed config | Validate JSON syntax |
| `mods.ios` / `mods.android` errors | Config plugin mod failure | Run `npx expo prebuild --clean` locally |

## Missing Files

| Pattern | Cause | Fix |
|---|---|---|
| `None of these files exist` | File in `.gitignore` or not committed | Check `.gitignore`, `git ls-files` |
| `ENOENT: no such file or directory` | File missing from build | Commit the file or remove the import |
| `Asset not found` | Missing asset file | Check `assets/` is committed and not in `.easignore` |
