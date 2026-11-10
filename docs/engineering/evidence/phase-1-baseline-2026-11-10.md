# Phase 1 baseline evidence — 2026-11-10

## Scope and integrity

This record captures the environment before the engineering-playbook integration. It does not change application source, dependencies, generated platform files, or existing instructions. A non-terminal test run is explicitly reported as incomplete; it is not treated as a passing baseline.

## Executable toolchain

| Area | Evidence | Result |
| --- | --- | --- |
| Flutter | `flutter --version` | Flutter `3.44.4` stable; Dart `3.12.2`; DevTools `2.57.0` |
| Java | `java -version` | OpenJDK `25.0.4.1` |
| Android build | `android/settings.gradle.kts` | Android Gradle Plugin `9.0.1`; Gradle wrapper `9.1.0` |
| iOS project | `ios/Runner.xcodeproj/project.pbxproj` | iOS deployment target `13.0` |
| Android devices | `adb devices -l` | `adb` `37.0.0p1` installed; no attached device |
| Android virtual devices | `avdmanager` | Command unavailable on this host |
| Apple tooling | `xcrun`, `xcodebuild` | Unavailable on this Linux host; iOS simulator and device validation cannot run here |

The project must therefore validate Android and iOS separately. Emulator-only evidence must not be described as physical-device verification.

## Skills CLI and installation readiness

The requested `skills` package was inspected before installation:

| Item | Evidence | Result |
| --- | --- | --- |
| Default Node.js | `node --version` | `v20.20.2` |
| Supported Node.js | `fnm list` | `v24.21.0` installed and usable with `fnm exec --using 24.21.0 -- …` |
| npm | `npm --version` | `10.8.2` |
| `skills` package | npm registry metadata | `1.7.6`, MIT, repository `vercel-labs/skills` |
| Package engine | upstream `package.json` | Node `>=22.20.0` required |
| Universal repository target | official Skills documentation | `.agents/skills/` |
| CLI verification | `fnm exec --using 24.21.0 -- npx skills --help` | Package `1.7.6`; `add`, `--skill`, `--agent`, `--list`, and `--yes` supported |
| Catalog verification | Read-only `skills add <source> --list --agent universal` | Reviewed official Flutter/Dart skill names confirmed |

**Decision:** do not install skills in this phase. Although the default Node is too old, the installed FNM Node `24.21.0` is a supported CLI runtime and has now verified the exact command surface and catalogs. Installation remains intentionally deferred because the canonical repository playbook is the chosen authority, `flutter-build-responsive-layout` already exists locally, and no additional candidate has yet passed the no-duplication/migration decision. A future approved install must use the FNM runtime, a reviewed subset, and a repository-local target.

## Skill provenance and selection evidence

The following source revisions were inspected, rather than relying on repository descriptions:

| Source | Revision inspected | Initial disposition |
| --- | --- | --- |
| `flutter/agent-plugins` | `b7d5a0be4195b82fe073620fb52f594b0809eacf` | Candidate: selectively install current, official skills after Node remediation |
| `dart-lang/skills` | `fa691671fda391ea1d1f8c7ae61bddc03348ec85` | Candidate: selectively install current, official skills after Node remediation |
| `thienqo/flutter-skills` | `b0d83939271850927be9e85826288a5026b4c60f` | Reject as a bulk source: no validated Agent Skill contract found in the inspected source |
| `zakariaf/Flutter-Skills` | `e073e5ea10c963d2c52ab1e423bd314c28a56154` | Reject as a bulk source: broad overlap and opinionated Riverpod-oriented conventions conflict with the project’s need for a concise canonical playbook |

The locally installed `flutter-build-responsive-layout` content is byte-identical to the inspected upstream official skill at the recorded Flutter revision (`SHA-256 c7a5d18071c625137cad2def9b13f3579d9bdf0aae29621a1825f12b560394c0`). Its existing `skills-lock.json` computed hash does not match that checksum and does not record a source revision. Treat the lock as insufficient provenance until Phase 3 records source, revision, licence, and checksum consistently.

`flutter-add-integration-test` is not an installation candidate at this revision: its setup includes legacy `flutter_driver` directions alongside modern integration-test guidance. The engineering standard will use current official integration-test documentation instead. `flutter-fix-layout-issues`, `flutter-add-widget-test`, and focused Dart analysis/test skills remain candidates for a later, source-reviewed installation.

## Agent-host discovery

| Host | Local evidence | Discovery conclusion |
| --- | --- | --- |
| Codex | Current session lists the three `.agents/skills/*/SKILL.md` files as available skills | Repository `.agents/skills/` works for the active host |
| Claude Code | CLI `2.1.199` available | Executable availability confirmed; prompt-time repository discovery requires a controlled manual acceptance check |
| Cursor | CLI `3.24.12` available | Executable availability confirmed; prompt-time repository discovery requires a controlled manual acceptance check |
| Antigravity | CLI `1.107.0` available | Executable availability confirmed; prompt-time repository discovery requires a controlled manual acceptance check |

No claim is made that `.agents/rules/` is automatically applied by every host. Phase 3 will add the smallest compatible discovery bridge only after the canonical documentation index is in place and each host’s behaviour is verified.

### Bridge compatibility research (after baseline capture)

- Cursor official documentation supports a root `AGENTS.md` as a plain-Markdown project instruction file.
- Google Antigravity official documentation supports root `AGENTS.md`/`GEMINI.md` as always-active workspace rules and `.agents/skills/` for workspace skills.
- Claude Code official documentation uses root `CLAUDE.md` for project instructions and supports `@path` imports. The repository therefore uses a two-line `CLAUDE.md` that imports the one canonical `AGENTS.md`, avoiding copied policy.

The bridge files have been added, but actual prompt-time loading remains a manual acceptance test for each host; documentation compatibility and a CLI version alone are not proof of a loaded session.

## Design-reference availability

Only `web/index.html` was found in the repository. No approved HTML/CSS mobile-screen reference set is versioned here. Existing documentation points to an external path (`/home/kumaraguhan/Downloads/trvlez_app`), which is not a repository input or an approved source of truth.

**Blocker:** provide or approve a versioned design-reference location before visual parity can be assessed. The future playbook may define the implementation and validation method without claiming reference-design parity.

## Current quality baseline

| Command | Result | Notes |
| --- | --- | --- |
| `flutter analyze --fatal-infos` | Pass | `No issues found` |
| `python3 scripts/verify_layout_tokens.py` | Pass | 100% compliance across 308 `lib/` files |
| `dart format --output=none --set-exit-if-changed .` | Fails baseline | Reports 75 files would change; `--output=none` did not modify files |
| `flutter test --reporter compact` | Incomplete | Reached test 456 at 1:48 in `passport_image_processor_test.dart` without a terminal success/failure summary before the bounded run ended |

The full test suite needs a separate diagnosis or a deliberately longer CI execution before it can be considered green. Its verbose output is retained only in temporary local capture (`/tmp/trvlez-flutter-test-baseline.log`) and is not a project artifact because it can contain test HTTP logging.

## Phase 1 conclusion

The repository is suitable for documentation-first consolidation, but it is not ready for cross-platform visual-parity claims. Prerequisites are: a versioned design-reference input, device/simulator access for the respective platforms, and a resolved terminal test baseline. Skill installation is technically available through FNM Node `24.21.0` but remains a deliberate, reviewed choice rather than a prerequisite.
