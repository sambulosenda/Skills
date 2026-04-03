


# App Store Release Notes Guidelines

## Goals
- User-facing release notes describing visible changes since last tag
- Include all user-impacting changes; omit internal work
- Plain, short, benefit-focused language

## Output Shape
- 5-10 bullets for most releases
- Group by theme if needed: New, Improved, Fixed
- One sentence per bullet, starting with a verb
- No internal codenames, ticket IDs, or file paths

## React Native / Expo Filtering

### Include
- New features, screens, flows
- UI/UX changes (layout, animations, navigation)
- Bug fixes users would encounter
- Performance improvements with visible impact (scroll perf, load times, app size)
- Accessibility improvements
- New platform support (e.g., iPad, Android tablet)

### Exclude
- Expo SDK upgrades (unless unlocking user-visible capability)
- NativeWind/styling refactors with no visual change
- EAS Build/CI configuration changes
- Jest/testing changes
- TypeScript type-only changes
- Developer tooling (metro config, babel plugins)
- Internal state management refactors (Zustand store restructuring)
- Dependency bumps

## Language Guidance
- Translate technical terms into user descriptions
- Never mention: "API", "refactor", "nil", "crash log", "dependency", "FlashList", "Reanimated", "NativeWind", "Expo", "React Native", "Zustand", "metro"
- Prefer: "Added", "Improved", "Fixed", "Updated" or action verbs
- Keep tense present or past

## Examples
- "Added account switching from the profile menu."
- "Improved feed loading speed on slow connections."
- "Fixed media not opening in full screen."
- "Screens now load instantly when navigating."
- "Fixed input fields being hidden behind the keyboard."

## QA Checklist
- Every bullet ties to a real change in the range
- No duplicate bullets for the same change
- No internal jargon or file paths
- Fits storefront limits (App Store: 4000 chars, Play Store short: 500 chars)
