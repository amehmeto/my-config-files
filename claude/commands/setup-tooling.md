---
description: Set up dev tooling for a new repo (inspired by TiedSiren). Adapts linting, testing, hooks, CI, and Claude Code config for the project's stack.
---

## Dev Tooling Setup

Adapt the following tooling for THIS project. Not a blind copy — adjust for the project's stack (no React rules for a CLI, no Next.js build for a library, etc).

Look at the TiedSiren repo at `~/Development/tied-siren-project/tied-siren-web` for reference implementations of each tool. Read the relevant config files before adapting.

### Execution rules

- **Each tool = one commit** for easy `git bisect`
- **Run `prettier --write .` on ALL existing files** before the first commit
- **Verify at each step**: `tsc --noEmit` + `vitest run` + `node build.js` (or equivalent)
- Create a feature branch, push, and create a PR at the end

### 1. Package management

- `only-allow npm` preinstall script in package.json
- `.nvmrc` with current Node version
- `is-ci` guard on prepare script: `"prepare": "is-ci || husky"`
- If yarn.lock exists, remove it and run `npm install`

### 2. Linting & formatting

- Install oxlint + `eslint-plugin-clean-arch` (from `github:amehmeto/eslint-plugin-clean-arch`)
- Create `.oxlintrc.json` with clean-arch rules — adapt overrides per folder (domain, infra, specs, legacy)
- prettier: install if missing, create `.prettierignore`, format ALL files
- lint-staged in package.json: oxlint --fix + prettier on staged `.ts/.js`, prettier on `.json/.md/.css`

### 3. TypeScript

- Strict tsconfig: `noUnusedLocals`, `noUnusedParameters`, `noImplicitReturns`, `noFallthroughCasesInSwitch`
- Add `"types": ["vitest/globals"]` if installing vitest
- Adapt `target`, `module`, `moduleResolution`, `paths` for the project's bundler
- Fix any new TS errors from strict mode (unused vars, missing returns, etc)

### 4. Testing

- Replace jest with vitest if present (migrate `jest.fn()` → `vi.fn()`, `jest.mock` → `vi.mock`)
- Create `vitest.config.ts` with path alias and globals
- Exclude broken/legacy test files in vitest config
- Delete jest.config.js and uninstall jest + ts-jest + @types/jest

### 5. Git hooks (husky) — 3-layer feedback loop

Install husky, create `.husky/scripts/` with guard scripts:
- `no-commits-on-main.sh` — block direct commits to main
- `no-commits-on-merged-branch.sh` — block commits on already-merged branches (skip fresh branches)
- `no-direct-push-main.sh` — block push to main
- `uncommitted-files-check.sh` — only check tracked files (ignore untracked/gitignored)

Hook configuration:
1. **Pre-commit** (fast): branch guards → `tsc --noEmit` → `lint-staged`
2. **Pre-push** (comprehensive): branch guard → uncommitted check → build → vitest

### 6. CI/CD (GitHub Actions)

- `ci.yml` on pull_request: lint + typecheck + `prettier --check .` + test + build
- `post-merge.yml` on push to main: typecheck + test + build
- Use `.nvmrc` for `node-version-file` (single source of truth)
- Set `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` env

### 7. Claude Code

**Settings** (`.claude/settings.local.json`):
- `env`: `{ "CLAUDE_CODE": "1" }`
- `permissions.allow`: git, gh, npm, npx (tsc/vitest/oxlint/prettier), node, common bash, Edit, Read, Write, WebSearch, Skills (commit-push, sync-main, fix-review, ralph-wiggum), MCP tools
- `permissions.deny`: force push, husky bypass, --no-verify, --amend, rebase, sudo, eval, npm publish, destructive gh ops
- `permissions.ask`: curl, chmod, gh api mutations, git merge/restore/revert, edits to .claude/hooks/.husky/.github

**Hooks**:
- `PreToolUse` on `Bash(gh pr create/edit)` → `.claude/hooks/validate-pr.sh` (require ## Summary + ## Test plan)
- `PostToolUse` on `Edit|Write` → `.claude/hooks/validate-edit.sh` (oxlint --fix + prettier per file)
- `Notification` → `afplay /System/Library/Sounds/Purr.aiff`

**Commands** (`.claude/commands/`):
- `commit-push.md` (model: haiku) — git add -A, conventional commit, push, create/update PR
- `sync-main.md` — fetch + merge origin/main, resolve conflicts, push
- `fix-review.md` — fetch PR comments, fix actionable feedback, commit-push

**Project guide** (`CLAUDE.md`):
- Architecture overview (folders, dependency flow)
- Available commands (build, test, lint, typecheck)
- Key files and config locations
- Anti-patterns (NEVER yarn, NEVER eslint, NEVER commit .env, NEVER push to main)

**Ralph Wiggum** — add skills to permissions (built-in, no install needed):
- `Skill(ralph-wiggum:ralph-loop)`, `Skill(ralph-wiggum:help)`, `Skill(ralph-wiggum:cancel-ralph)`
