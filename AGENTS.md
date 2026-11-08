# AGENTS.md — Scripts

A collection of small, independent automation scripts for macOS: Ruby CLIs,
Bash utilities, and AppleScript snippets under `src/`. There is no shared
runtime or application; each directory is its own tool with its own
dependencies. Only macOS is tested and supported.

## Repo layout

- `src/<name>/` — one self-contained script or utility. Some have their own
  `Gemfile`/`Gemfile.lock` and a local `lib/` (for example
  `src/gource_combinator/lib/gource_combinator.rb`).
  - Ruby entry points: `src/github-stats/stats.rb`,
    `src/gource_combinator/combine.rb`, `src/gmail/import.rb`,
    `src/music/love_importer.rb`, `src/photos/dater.rb`.
  - Bash entry points: `src/fader/fader.sh`,
    `src/gource_combinator/combine.sh`,
    `src/gource_combinator/commit_counter.sh`, `src/photos/reduce.sh`.
  - AppleScript: `src/address-book/`, `src/finder/`, `src/music/`.
- `test/` — bats suites (`test/fader.bats`). The `bats-support` and
  `bats-assert` helpers live in `test/test_helper/`; CI supplies them and they
  are not committed.
- `.github/workflows/test.yml` — CI: `shellcheck`, `bats`, and `rubocop`.
- `.github/dependabot.yml` and `.github/mergify.yml` — dependency updates and
  merge automation. Do not edit them unless the task is about that automation.
- `.agents/skills/` — coding-agent skills for this repo. Load the relevant
  one before testing or rewriting history.
- `readme.md` (lowercase) is the project readme.

## Worktrees and branches

- **Never commit on `main`.** `main` only points at `origin/main`; all work
  belongs on a branch.
- The primary checkout is `~/Dev/scripts`. It may hold long-lived or
  in-progress work (for example `duplicate-file-compressor`); do not switch it
  to another branch or discard its uncommitted files.
- Create each new branch in its **own worktree** from `origin/main`:
  `git worktree add <path> -b <branch> origin/main`. Use `git worktree list`
  to find authoritative paths. Do not check out one branch in two worktrees.
- Before editing anything, run `git worktree list` and
  `git status --short --branch` in the directory you intend to edit. If it has
  uncommitted changes unrelated to your task, stop and tell the user.
- Worktrees are separate directories, not symlinks. Changes in one do not
  affect another.
- Clean up only worktrees you created, and only after the user confirms.

## Languages and compatibility

- **Ruby 2.7 target.** Several shebangs point at `ruby@2.7` and
  `.rubocop.yml` sets `TargetRubyVersion: 2.7`. Do not introduce syntax or
  APIs newer than Ruby 2.7. CI lints with a newer Ruby while keeping the
  2.7 target.
- **Bash on macOS.** Scripts use `#!/usr/bin/env bash` and
  `set -o errexit`; keep them shellcheck-clean.
- **AppleScript is macOS-only** and has no CI coverage.
- Do not add a root `Gemfile` or a shared dependency layer. Install and run
  dependencies inside the relevant `src/<name>/` directory.
- See the `ruby-scripts` skill (`.agents/skills/ruby-scripts/SKILL.md`) for
  language-specific rules.

## Commit / git rules

- **GPG-sign every commit** (`git commit -S`). `commit.gpgsign` and
  `user.signingkey` are configured locally; do not disable them.
- Before committing, run the checks that match the change:
  - `shellcheck` on changed `.sh` files.
  - `ruby -c` on changed `.rb` files.
  - `bats test` when shell behaviour or bats tests change.
  - `rubocop` and confirm you added no new offenses.
  - `git diff --check`.
- Commit every meaningful change, ensuring that each commit represents a
  logical unit of work.
- When fixing code that was added in a previous commit on the same branch,
  perform a "fixup" and squash the fix into the original commit.
- Keep commit message headers shorter than 50 characters. If more detail is
  needed, repeat the full header in the commit message body. Wrap the body
  at 70 characters per line.
- Do not merge, deploy, or delete branches unless requested.
- Before every `git commit`, re-run `git status --short --branch` and confirm
  the branch is not `main`.

## Tests and verification

Detailed, load-on-demand. See the `scripts-tests` skill
(`.agents/skills/scripts-tests/SKILL.md`) for exact run commands, local
prerequisites, the accepted baseline, and the limits of the bats coverage.
`bats` needs the CI helper libraries in `test/test_helper/`; the skill shows
how to install them locally without committing them.

## PR review feedback

After addressing review comments on a pull request, close the loop on the
review itself, not just in the code:

- **Resolve** every thread you actually fixed; leave threads you did not
  address open for a human.
- **Hide** (minimize) each addressed comment with the `resolved` classifier
  so it stops cluttering the PR.
- Only touch threads/comments you addressed; never resolve or hide ones you
  left unresolved.

Both need GraphQL node ids from `pullRequest.reviewThreads` (`PRRT_...` for
the thread, `PRRC_...` for each comment):

```bash
gh api graphql -f query='{repository(owner:"asbjornu",name:"scripts"){pullRequest(number:N){reviewThreads(first:50){nodes{id isResolved comments(first:5){nodes{id databaseId}}}}}}}'
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id=PRRT_...
gh api graphql -f query='mutation($id:ID!){minimizeComment(input:{subjectId:$id,classifier:RESOLVED}){minimizedComment{isMinimized}}}' -f id=PRRC_...
```
