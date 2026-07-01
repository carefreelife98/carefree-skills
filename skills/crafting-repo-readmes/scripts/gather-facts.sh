#!/usr/bin/env bash
# Automates the repetitive fact-gathering commands from references/repo-analysis.md.
# Usage: gather-facts.sh <repo-path>
set -uo pipefail

repo="${1:?usage: gather-facts.sh <repo-path>}"
cd "$repo" || { echo "error: cannot cd into $repo" >&2; exit 1; }

section() { printf '\n=== %s ===\n' "$1"; }
PRUNE='-not -path */node_modules/* -not -path */.git/* -not -path */vendor/* -not -path */dist/* -not -path */build/* -not -path */target/*'

section "Manifests"
for f in package.json pyproject.toml setup.py setup.cfg requirements.txt go.mod Cargo.toml \
         pom.xml build.gradle build.gradle.kts Gemfile composer.json mix.exs \
         wrangler.toml wrangler.jsonc; do
  if [ -e "$f" ]; then
    echo "--- $f ---"
    cat "$f"
  fi
done
for f in *.csproj *.sln; do
  [ -e "$f" ] && { echo "--- $f ---"; cat "$f"; }
done 2>/dev/null

section "Top-level structure (3 levels)"
find . -maxdepth 3 $PRUNE | sort

section "Largest source files (top 20 by line count)"
find . -type f \
  \( -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.py' \
     -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.rb' -o -name '*.php' \) \
  $PRUNE -exec wc -l {} + 2>/dev/null | sort -rn | head -20

section "Tests"
find . -type d \( -iname 'test*' -o -iname 'spec*' -o -iname '__tests__' \) $PRUNE | sort
echo -n "test-ish files: "
find . -type f \( -iname '*test*' -o -iname '*spec*' \) $PRUNE | wc -l | tr -d ' '

section "CI"
for d in .github/workflows .gitlab-ci.yml Jenkinsfile .circleci; do
  if [ -e "$d" ]; then
    echo "found: $d"
    find "$d" -type f 2>/dev/null
  fi
done

section "License"
find . -maxdepth 1 -iname 'license*' -exec cat {} \; 2>/dev/null

section "Env vars referenced in code"
grep -rEho \
  '(process\.env\.[A-Z_][A-Z0-9_]*|os\.environ(\.get)?\(?"'"'"'?[A-Z_][A-Z0-9_]*|os\.Getenv\("[A-Z_][A-Z0-9_]*"\)|ENV\["'"'"'?[A-Z_][A-Z0-9_]*)' \
  --include='*.js' --include='*.ts' --include='*.py' --include='*.go' --include='*.rb' \
  . 2>/dev/null | sort -u | head -50

section "Docs already present"
find . -maxdepth 2 \
  \( -iname 'contributing*' -o -iname 'code_of_conduct*' -o -iname 'security.md' -o -iname 'docs' \) \
  2>/dev/null

section "Language breakdown"
if command -v tokei >/dev/null 2>&1; then
  tokei .
elif command -v cloc >/dev/null 2>&1; then
  cloc . --quiet
else
  echo "(tokei/cloc not installed — skipping; install either for a precise per-language line-count breakdown)"
fi
