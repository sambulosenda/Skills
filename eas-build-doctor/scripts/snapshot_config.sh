#!/usr/bin/env bash
set -euo pipefail

# Snapshot local project config for build diagnosis.
# Run from repo root.

repo_root="$(git rev-parse --show-toplevel)"
cd "${repo_root}"

echo "== Node / npm =="
node --version 2>/dev/null || echo "node not found"
npm --version 2>/dev/null || echo "npm not found"

echo ""
echo "== Expo SDK =="
if [ -f package.json ]; then
  node -e "
    const pkg = require('./package.json');
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };
    console.log('expo:', deps['expo'] || 'not found');
    console.log('react-native:', deps['react-native'] || 'not found');
    console.log('expo-dev-client:', deps['expo-dev-client'] || 'not found');
  " 2>/dev/null
fi

echo ""
echo "== eas.json =="
if [ -f eas.json ]; then
  cat eas.json
else
  echo "eas.json not found"
fi

echo ""
echo "== app.json / app.config (plugins) =="
if [ -f app.json ]; then
  node -e "
    const config = require('./app.json');
    const expo = config.expo || config;
    console.log('name:', expo.name);
    console.log('slug:', expo.slug);
    console.log('version:', expo.version);
    console.log('sdkVersion:', expo.sdkVersion);
    console.log('ios.bundleIdentifier:', expo.ios?.bundleIdentifier);
    console.log('android.package:', expo.android?.package);
    console.log('plugins:', JSON.stringify(expo.plugins || [], null, 2));
  " 2>/dev/null
elif [ -f app.config.js ] || [ -f app.config.ts ]; then
  echo "(dynamic config — cannot parse statically)"
  head -30 app.config.* 2>/dev/null
fi

echo ""
echo "== Potentially problematic .gitignore entries =="
if [ -f .gitignore ]; then
  grep -E '(src/|\.js$|\.ts$|\.tsx$|assets/|\.env)' .gitignore 2>/dev/null || echo "(none found)"
fi

echo ""
echo "== .easignore =="
if [ -f .easignore ]; then
  cat .easignore
else
  echo ".easignore not found"
fi

echo ""
echo "== Native dirs =="
[ -d ios ] && echo "ios/ exists" || echo "ios/ not found (managed workflow)"
[ -d android ] && echo "android/ exists" || echo "android/ not found (managed workflow)"

echo ""
echo "== expo-doctor =="
npx expo-doctor 2>&1 || echo "(expo-doctor failed)"
