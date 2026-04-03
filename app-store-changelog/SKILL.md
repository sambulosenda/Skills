---
name: app-store-changelog
description: Create user-facing App Store release notes by collecting and summarizing all user-impacting changes since the last git tag (or a specified ref). Use when asked to generate a comprehensive release changelog, App Store "What's New" text, or release notes based on git history or tags.
user-invocable: true
---

# App Store Changelog

Generate user-facing App Store / Play Store release notes from git history since the last tag.

## Workflow

### 1) Collect changes

Run the collection script from the repo root:

```bash
bash ~/.claude/skills/app-store-changelog/scripts/collect_release_changes.sh
```

To specify a custom range:

```bash
bash ~/.claude/skills/app-store-changelog/scripts/collect_release_changes.sh v1.2.3 HEAD
```

If no tags exist, falls back to full history.

### 2) Triage for user impact

Scan commits and touched files. Identify user-visible changes only.

**Include:**
- New features, screens, or flows
- UI changes (layout, styling, animations)
- Behavior changes users would notice
- Bug fixes users would encounter
- Performance improvements with visible impact (scroll, load times)
- Accessibility improvements

**Exclude:**
- Refactors, dependency bumps, CI changes
- Developer tooling, internal logging
- Analytics changes (unless affecting user privacy/behavior)
- NativeWind/styling-only refactors with no visual change
- Expo SDK upgrades (unless they unlock new user-facing capability)

Group changes by theme: **New**, **Improved**, **Fixed**.

### 3) Draft release notes

Write short, benefit-focused bullets for each user-facing change.

**Rules:**
- One sentence per bullet, starting with a verb
- Plain language, no jargon (no "refactor", "nil", "crash log", "dependency", "API")
- Translate RN/Expo internals into user language
- 5-10 bullets unless user requests different length
- Present tense or past tense: "Added", "Improved", "Fixed"

**React Native translation examples:**

| Raw commit | App Store bullet |
|---|---|
| `fix(auth): resolve token refresh race condition on iOS 17` | Fixed a login issue that could leave some users unexpectedly signed out. |
| `feat(search): add voice input to search bar` | Search hands-free with the new voice input option. |
| `perf(timeline): lazy-load images in FlashList` | Scrolling through your feed is now smoother and faster. |
| `feat(notifications): add push notification deep linking` | Tap a notification to jump straight to the relevant content. |
| `fix(keyboard): KeyboardAvoidingView not respecting safe area` | Fixed input fields being hidden behind the keyboard on newer iPhones. |
| `feat(camera): add photo filters using expo-image-manipulator` | Apply filters to your photos before sharing. |
| `perf(navigation): preload screens with expo-router` | Screens now load instantly when you navigate. |

**Commits to drop (no user impact):**
- `chore: upgrade expo SDK to 52`
- `refactor(network): extract axios wrapper`
- `ci: add EAS build workflow`
- `chore: migrate from StyleSheet to NativeWind`
- `test: add jest snapshots for profile screen`

### 4) Validate

- Every bullet maps back to a real change in the range
- No duplicate bullets describing the same change
- No internal jargon or file paths
- Fits App Store text limits if storefront specified (4000 chars for App Store, 500 chars for Play Store short description)

### 5) Present to user

Show the draft and ask:
- Any bullets to add, remove, or reword?
- Target storefront (iOS App Store / Google Play / both)?
- Version number to include in the title?

## Example Output

```
What's New in Version 2.1

- Search hands-free with the new voice input option.
- Tap a notification to jump straight to the relevant content.
- Scrolling through your feed is now smoother and faster.
- Fixed a login issue that could leave some users unexpectedly signed out.
- Fixed input fields being hidden behind the keyboard on newer iPhones.
- Apply filters to your photos before sharing.
```

## Resources
- `scripts/collect_release_changes.sh` — Collect commits and touched files since last tag
- `references/release-notes-guidelines.md` — Language, filtering, and QA rules
