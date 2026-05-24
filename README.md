# Skills

Custom Claude Code skills for React Native / Expo development and Git workflow.

## Installation

Clone this repo and symlink each skill into `~/.claude/skills/`:

```bash
git clone https://github.com/sambulosenda/Skills.git ~/Skills

# Symlink an individual skill
ln -s ~/Skills/conventional-commits ~/.claude/skills/conventional-commits

# Or symlink them all at once
for d in ~/Skills/*/; do
  name=$(basename "$d")
  ln -s "$d" "$HOME/.claude/skills/$name"
done
```

Restart Claude Code to pick up newly-linked skills.

## Skills

| Skill | Description |
|---|---|
| [app-onboarding-questionnaire](./app-onboarding-questionnaire) | Design and build a high-converting questionnaire-style onboarding flow for your app, modelled on proven conversion patterns from top subscription apps |
| [app-store-changelog](./app-store-changelog) | Generate user-facing App Store / Play Store release notes from git history since the last tag |
| [conventional-commits](./conventional-commits) | Write, validate, and organise Git commit messages per the Conventional Commits 1.0.0 spec, with context-rich bodies that explain WHY a change was made |
| [eas-build-doctor](./eas-build-doctor) | Diagnose failed EAS builds — parse logs, identify root causes (CocoaPods, Gradle, signing, Metro, OOM, native deps), suggest targeted fixes |
| [expo-production-patterns](./expo-production-patterns) | Production patterns for React Native apps with Expo: navigation, native modules, offline-first React Query, platform-specific code, EAS Build |
