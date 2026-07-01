# Repo Analysis Checklist

Polyglot fact-gathering — run this regardless of what language you expect. Use `scripts/gather-facts.sh <repo-path>` to automate most of it in one pass; read the output rather than re-deriving each command by hand.

## 1. Manifests

Check for whichever of these exist, and read them fully (name, description, scripts/commands, dependencies, entry point fields):

| Language/ecosystem | Manifest(s) |
|---|---|
| Node/JS/TS | `package.json` |
| Python | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt` |
| Go | `go.mod` |
| Rust | `Cargo.toml` |
| Java/Kotlin | `pom.xml`, `build.gradle(.kts)` |
| Ruby | `Gemfile`, `*.gemspec` |
| PHP | `composer.json` |
| .NET | `*.csproj`, `*.sln` |
| Elixir | `mix.exs` |
| Cloudflare Workers | `wrangler.toml` / `wrangler.jsonc` (in addition to `package.json`) |

The manifest's `scripts`/`Makefile`/`justfile` targets are the source of truth for install/build/test commands — don't invent commands that "seem standard" for the language.

## 2. Directory structure

Top 2-3 levels, excluding `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`, `target/`. Note where source, tests, docs, and config live relative to each other.

## 3. Entry points

- Node: `main`/`exports`/`bin` fields in `package.json`
- Python: `if __name__ == "__main__"`, `console_scripts` in `pyproject.toml`/`setup.py`
- Go: files with `package main`, `cmd/*/main.go`
- Rust: `src/main.rs` (binary) vs `src/lib.rs` (library)
- Containers: `Dockerfile` `CMD`/`ENTRYPOINT`

## 4. Tests & CI

- Test directories/files (`test/`, `spec/`, `__tests__/`, `*_test.go`, `*_test.py`) and roughly how many
- CI config: `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/` — what does it actually run (lint/test/build/deploy)?

## 5. License

`LICENSE`/`LICENSE.md`/`license` file, or the `license` field in the manifest. Use the real SPDX identifier found — don't guess "MIT" by default.

## 6. Env vars & configuration

Grep for `process.env.`, `os.environ`, `os.Getenv(`, `ENV[` etc. across source. Cross-reference with any `.env.example` file. These become the README's configuration section, if any exist.

## 7. Existing docs & community health files

`docs/`, wiki links in the manifest, and GitHub's standard [community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file): `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `SUPPORT.md`, `GOVERNANCE.md`, `FUNDING.yml`, `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md` (also check the org-wide `.github` repo if this one doesn't have them locally). Read whichever exist — they often contain the real usage detail that belongs in the README, and the README's contributing/license sections should link to them rather than duplicate their content. Note which ones are *absent* too: for a public-facing OSS repo, that's worth mentioning to the user at the approval gate (see `readme-best-practices.md`'s Companion artifacts section) — but don't create them unasked.

## 7a. Security posture (presence only)

Check for `SECURITY.md`, `.github/dependabot.yml` / `renovate.json`, and whether CI config references required status checks. This is a lightweight presence check, not a security audit — don't attempt to reproduce a full tool like OpenSSF Scorecard; just note what exists so the README (or the companion-artifacts note) can mention it accurately.

## 7b. Commit rationale (optional, use with care)

If you need "why was this built this way" context for the Overview section and the code/docs alone don't explain it, skim `git log` on the key files identified in step 3. Only use rationale that's **explicitly stated** in a commit message or PR description. If nothing explicit turns up, don't infer or guess a rationale from sparse commit messages — leave the "why" out rather than fabricating one. This step is optional and repo-dependent; skip it for repos where the code is self-explanatory.

## 8. Package registry metadata (if published)

`npm view <name>`, `pip show <name>`, `cargo search <name>`, etc. — homepage, current published version, download stats if relevant.

## 9. GitHub-specific metadata (if applicable)

`gh repo view <owner>/<repo> --json description,stargazerCount,forkCount,licenseInfo,repositoryTopics,homepageUrl,latestRelease,defaultBranchRef`

---

## Architecture / project-type signal table

Use these signals to classify the project — this determines which README sections apply (see `readme-best-practices.md`).

| Signal | Likely project type |
|---|---|
| `app/` + `page.tsx`/`layout.tsx` | Next.js App Router web app |
| `pages/` + `next.config.*` | Next.js Pages Router web app |
| `src/routes/`, `routes/` + express/fastify/koa in deps | Node REST API/service |
| FastAPI/Flask/Django in Python deps | Python web/REST API |
| `Cargo.toml` + `src/main.rs` | Rust binary/CLI |
| `Cargo.toml` + `src/lib.rs` only | Rust library |
| Single `main.go`, no `cmd/` | Go single-binary program |
| `cmd/*/main.go` (multiple) | Go multi-binary / CLI toolkit |
| `bin` field in `package.json` | Node CLI tool |
| No `bin`, has `main`/`exports`, published to npm | Node library |
| `packages/` or `apps/` + workspace config (`pnpm-workspace.yaml`, `turbo.json`, lerna) | Monorepo |
| `docker-compose.yml` with 2+ services | Multi-service / microservices |
| `k8s/`, `helm/`, `terraform/`, `*.tf` | Infrastructure as Code |
| `wrangler.toml`/`wrangler.jsonc` | Cloudflare Workers app |
| `.claude-plugin/plugin.json` or top-level `skills/*/SKILL.md` | Claude Code plugin / agent skills collection |
| Prisma/Drizzle/TypeORM schema files | ORM-backed service with a real database |
| `*.podspec`, `Podfile`, `*.xcodeproj` | iOS app/library |
| `AndroidManifest.xml`, `build.gradle` with Android plugin | Android app |
| No `main`/`bin`/entry point, mostly `.md` files | Documentation-only repo |

A repo can match more than one row (e.g. a monorepo containing a Next.js app and a Cloudflare Worker) — note all that apply rather than forcing a single label.
