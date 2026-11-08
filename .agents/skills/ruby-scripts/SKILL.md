---
name: ruby-scripts
description: Constraints when editing the Ruby, Bash, and AppleScript scripts in this repository, including Ruby 2.7 compatibility, RuboCop rules, shellcheck expectations, and per-script dependencies.
license: MIT
compatibility: opencode
---

# Scripting constraints

- **Ruby 2.7 target.** CI lints with Ruby 2.7 and several shebangs point at
  `ruby@2.7`. Avoid newer syntax and APIs (`Hash#except`, endless methods,
  newer pattern matching features).
- **No shared dependency layer.** Each script directory owns its
  `Gemfile`/`Gemfile.lock`. Add a dependency only to the `Gemfile` of the
  script that needs it, and run `bundle install` / `bundle exec` there.
- **Use `require_relative` for local modules.** The Ruby scripts are CLI entry
  points that load their own `lib/`; do not turn them into gems.
- **Keep `rubocop` clean** (no new offenses). Fix cops instead of adding
  inline disables; if a rule genuinely cannot apply, configure it in
  `.rubocop.yml`/`.rubocop_todo.yml` with a short reason.
- **Bash:** keep `#!/usr/bin/env bash`, `set -o errexit`, quote variables
  (`"${file}"`), and use `[[ ... ]]` for conditionals. Keep `shellcheck`
  clean; the one existing `# shellcheck disable=SC2002` in
  `src/gource_combinator/combine.sh` is grandfathered, not a pattern to copy.
- **AppleScript:** preserve tab indentation and macOS-only assumptions.
  There is no CI validation beyond `osacompile` on a Mac.
- **Shebangs and permissions:** entry points that are executable use a
  shebang. Do not add a hard-coded Homebrew Ruby path to new files; prefer
  `#!/usr/bin/env ruby`.
- **Avoid destructive defaults.** Scripts that move, delete, retag, or
  re-date files must require explicit arguments and print a clear usage
  message when they are missing.
- **Commit messages:** terse, imperative, no "the user" references.
