---
name: conventional-commits
description: Write, validate, and organise Git commit messages that follow the Conventional Commits 1.0.0 specification, with context-rich bodies that explain WHY a change was made. Use this whenever the user wants to write a commit message, asks "what should I commit this as", describes code changes they're about to commit, pastes a git diff or git status and wants a message, asks how to split or group changes into commits, or asks whether an existing commit message is valid/correct. Also use when the user mentions "conventional commits", "commitlint", "semantic versioning from commits", "changelog from commits", or wants to fix/rewrite a non-conforming message. Trigger even when they don't say "conventional commits" by name — if they describe a change and want a commit message, default to this format.
---

# Conventional Commits

Produce, check, and organise Git commit messages that conform to the Conventional
Commits 1.0.0 specification. A conforming message gives both humans and tooling
(changelog generators, semantic-version bumpers, CI triggers) an explicit, parseable
record of what changed — and a good body explains *why*, so the message still makes
sense to a teammate, or to an AI agent tracing a bug, six months later.

This skill does three jobs:

1. **Generate** — turn a description of changes (or a diff) into a valid commit message.
2. **Validate / fix** — check an existing message against the spec and rewrite it.
3. **Organise** — when there are many uncommitted changes, decide how to split or group them into clean, single-responsibility commits.

## Message structure

```
<type>[optional scope][optional !]: <description>

[optional body — context paragraph + bullet points]

[optional Decision line]

[optional footer(s) — BREAKING CHANGE, Closes #issue]
```

- **type** — a noun classifying the change (see type list). Required.
- **scope** — a noun in parentheses naming the affected area, e.g. `feat(auth):`. Optional.
- **!** — placed right before the colon to flag a breaking change, e.g. `feat(api)!:`. Optional.
- **description** — a short imperative summary on the same line, after `: `. Required.
- **body** — longer explanation, one blank line after the description. Optional but strongly encouraged for `feat`/`fix` (see "Context-rich commits").
- **footer(s)** — metadata such as `Closes #12` or a `BREAKING CHANGE:` note, one item per line, one blank line after the body. Optional.

## Types

Use this set (the Angular convention that commitlint's `config-conventional` is based on):

| Type | Use for | SemVer effect |
|------|---------|---------------|
| `feat` | A new feature | MINOR |
| `fix` | A bug fix | PATCH |
| `docs` | Documentation only | none |
| `style` | Formatting/whitespace, no code-meaning change | none |
| `refactor` | Code change that neither fixes a bug nor adds a feature | none |
| `perf` | A performance improvement | PATCH (often) |
| `test` | Adding or correcting tests | none |
| `build` | Build system or dependency changes (npm, gradle, pods, EAS) | none |
| `ci` | CI configuration and scripts | none |
| `chore` | Other changes that don't touch src or tests | none |
| `revert` | Reverts a previous commit | none |

A change is `feat` only if it adds user-facing capability; tidying existing code is
`refactor`; bumping a dependency is `build`.

## Writing the description (subject line)

- Imperative mood, as if completing "This commit will…": `add`, `fix`, `remove` — not `added`, `fixes`, `removing`.
- No trailing period.
- Lowercase first word (unless a proper noun like `Android`, `Expo`, `RevenueCat`).
- Keep the whole subject under ~72 characters; aim for ≤ 50.
- Describe the *what/why*, not the mechanics of the code.

## Context-rich commits (the important part)

For `feat` and `fix` commits, include a body unless the change is trivial. A good body
has two parts: a **context paragraph** and (when a real trade-off was made) a
**Decision line**. This is what separates a useful commit history from a useless one.

### 1. Context paragraph

Explain **why** the problem exists or the feature is needed — not what the code does.
Write for someone who has never seen this codebase.

**The paragraph must answer: "What breaks if this commit is reverted, and why?"**

Sentence starters that force causal thinking:
- `<X> causes <Y> because <mechanism>.`
- `Without this change, <failure mode> when <trigger>.`
- `<Component> requires <constraint> — <reason>.`

**Include real symbol names** (`useEffect`, `FlatList`, `onEndReached`, `AccountType`)
rather than paraphrasing ("the flag", "the list"). This helps human reasoning and gives
agents grep terms when investigating related bugs.

**State-machine / flag fixes must state the recovery condition.** If a fix sets a flag
or mode for the duration of some condition, the body must also say what restores normal
state afterwards and under what guard. The most common source of follow-on regressions
is a missing exit path.

**Three anti-patterns to reject:**

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Describes-what | "Replace X with Y in function Z." | Just repeats the diff |
| Too-abstract | "Improves scroll performance." | No mechanism |
| Copies-subject | "Fix blank frame on button tap." | Restates the title |

**Mechanical self-check:** cover the diff, read only the context paragraph, and ask
*"if I broke this code right now, would this paragraph predict the failure?"* If no,
rewrite starting from the failure mode, not the fix.

**Trivial exception:** if the subject line *is* the full context — no mechanism to
explain — omit the paragraph rather than writing filler. Test: "Does the paragraph say
anything the subject doesn't?"

| Trivial (omit body) | Non-trivial (body required) |
|---------------------|-----------------------------|
| `fix: correct typo in error message` | `fix(auth): token refresh fails on 401 retry` |
| `fix: remove debug console.log` | `fix(list): blank frame on pull-to-refresh` |
| `feat(ui): add copy button to message row` | `feat(api): wrap getSessions in response object` |

### 2. Decision line

When you chose between two real implementation options, record it and **name the
rejected alternative explicitly**. Format: `Decision: <chosen> (not <rejected>) — <why>`.
If you genuinely considered only one approach, omit it — don't invent a trade-off.

### When to include what

| Type | Context paragraph | Decision line |
|------|:-----------------:|:-------------:|
| `feat` | required unless trivial | if a trade-off was made |
| `fix` | required unless trivial | if a trade-off was made |
| `refactor` | if non-obvious | if non-obvious |
| `perf` | recommended | recommended |
| `docs`, `style`, `chore`, `build`, `ci` | optional | omit |

### Body formatting

- Wrap body lines at ~72 columns (git log, GitHub, and terminals assume it).
- Context paragraph first (prose), then optional `- ` bullets for file-level changes, then the Decision line.

## Breaking changes

A breaking change can accompany any type and triggers a MAJOR bump. Indicate it both ways:

- Append `!` before the colon: `feat(api)!: remove deprecated v1 endpoints`
- Add a footer: `BREAKING CHANGE: ` (literal, uppercase) followed by what changed and what consumers must do.

`BREAKING CHANGE` is the only case-sensitive token — it must be uppercase. Everything
else is case-insensitive, though lowercase type/scope is the consistent norm.

## Organising changes into commits

When the user has many uncommitted changes (or pastes a broad `git status`/`git diff`),
don't cram them into one message. Aim for single-responsibility commits: each does ONE
thing, touches ONE scope where possible, and is independently revertable.

**Always split:** different features; different types (a `feat` and a `chore`);
independent bug fixes; generated/build output vs hand-written logic.

**Always group:** an implementation and its tests; tightly-coupled layers of one feature
(e.g. API client + hook + screen) where reverting one breaks the others; a breaking
change that spans several files.

**When uncertain, default to splitting** — it's easier to squash later than to split
after the fact.

If one file contains changes belonging to two commits, stage the relevant hunks with
`git add -p` rather than the whole file.

**Confirmation rule — based on user intent:**

- **Intent is clear** (user said "commit", "commit this", "ship it", "go ahead and commit", or similar imperative): pick the messages, split into atomic commits, and run them. Report what you did after. No plan-and-wait.
- **Intent is ambiguous** (user pasted a diff or `git status` without an instruction, asked "what should I commit this as", or there are 3+ unrelated changes where the split is non-obvious): present a plan, wait for confirmation.
- **Always confirm regardless** if a commit would: include files that look sensitive (`.env`, credentials, keys), span >5 commits, or rewrite history (amend, rebase, force-push).

When in plan mode, format like:

```
## Commit plan

### 1. feat(booking): add pull-to-refresh to bookings list
Files: BookingsList.tsx, useBookings.ts
Reason: user-facing feature, independently revertable

### 2. build: upgrade Expo SDK 52 → 53
Files: package.json, package-lock.json, app.json
Reason: dependency change, unrelated to the feature

Proceed? (y / n / edit)
```

## Generating a single message

1. Identify the single primary change. If the work spans unrelated changes, switch to "Organising changes" above.
2. Pick the most specific applicable type.
3. Add a scope if it clarifies (a module/feature area); omit if it just repeats the type.
4. If breaking, add `!` and a `BREAKING CHANGE:` footer.
5. Write the imperative description.
6. Add a context paragraph (and Decision line) per the table above.
7. Add footers for issue refs (`Closes #N`).
8. Output the message in a fenced code block so it's easy to copy.

## Validating / fixing a message

Check in order: valid type → optional `(scope)` → optional `!` → `: ` (colon + single
space) → non-empty imperative description, no trailing period → if breaking, `!` and/or
`BREAKING CHANGE:` footer → body separated by one blank line → footers one per line. For
a `feat`/`fix` whose body is missing or just restates the subject, flag it and supply a
context paragraph. Report what's wrong in plain language, then give the corrected message
in a code block. A type outside the set won't break anything but will be ignored by
spec-based tools — suggest the closest standard type.

## Examples

**Example 1 — trivial feature, no body**
Input: Added a copy button to each message row
Output:
```
feat(ui): add copy button to message row
```

**Example 2 — fix with context paragraph**
Input: The bookings list flashed blank when you pulled to refresh
Output:
```
fix(booking): blank frame on pull-to-refresh

Calling scrollToOffset and setRefreshing in the same render starts the
refresh before FlatList has laid out its rows, so the viewport paints
positions that were never measured → a blank frame. Deferring the scroll
to onMomentumScrollEnd lets layout settle first.

- Move scrollToOffset into onMomentumScrollEnd
- Set refreshing flag synchronously, drop the setTimeout
```

**Example 3 — feature with a decision**
Input: getSessions used to return a raw array; wrapped it in a response object so the hook can tell "empty" from "not loaded yet"
Output:
```
feat(api): wrap getSessions in a response object

A raw ChatSession[] gave the hook no way to distinguish "no sessions
yet" from "request not made". A response wrapper carries a typed status
without adding a separate flag to component state.

- Change getSessions return type to ChatSessionListResponse
- Update useSessions to read the wrapper's status

Decision: response object (not a nullable array) — null has ambiguous
semantics; a named factory makes the loaded/empty intent explicit.
```

**Example 4 — breaking change**
Input: Removed the deprecated v1 API endpoints from the client
Output:
```
feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: callers using /v1/* must migrate to /v2/*; the v1
client methods have been deleted.
```

**Example 5 — dependency bump**
Input: Upgraded Expo from SDK 52 to 53
Output:
```
build: upgrade Expo SDK 52 → 53
```

**Example 6 — validation**
Input: "Is this valid? `Added: new login screen.`"
Output: Not conforming. `Added` isn't a valid type, there's a stray colon, the
description isn't imperative, and it ends with a period. Corrected:
```
feat(auth): add new login screen
```

## Notes

- This is a convention on top of plain Git — nothing here needs special tooling, but consistency is what lets commitlint, semantic-release, and standard-version work.
- When the user just wants the message mid-workflow, lead with the code block and keep commentary short. Save the longer reasoning for when they're asking *whether* something is correct or *which* type fits.
- If the user has explicitly signalled intent to commit ("commit", "ship it", "commit this"), treat that as the confirmation — pick atomic messages and run the commits, then report. Only fall back to plan-and-wait when intent is genuinely ambiguous or the action carries extra risk (sensitive files, history rewrites, large multi-commit splits). See the "Confirmation rule" above.
