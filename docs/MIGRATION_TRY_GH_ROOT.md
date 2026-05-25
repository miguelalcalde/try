# Migration: `GH_PATH` → `TRY_GH_ROOT`

## Why

`try` previously used `GH_PATH` as the root directory for GitHub clones (`~/github/owner/repo`).

That name collides with [GitHub CLI's official `GH_PATH` env var](https://cli.github.com/manual/gh_help_environment), which means **the path to the `gh` binary**. Tools like `gh-dash` shell out to `$GH_PATH auth token ...` when it is set, so exporting `GH_PATH=~/github` breaks GitHub CLI extensions even when `gh auth login` works.

## What changed

- **New env var:** `TRY_GH_ROOT` — root folder for GitHub repos in try's owner/repo layout
- **Removed:** `GH_PATH` — no longer read by `try`
- **No change:** `TRY_PATH` (local tries/experiments directory)

## Update your shell

Replace:

```bash
export GH_PATH=~/github
```

With:

```bash
export TRY_GH_ROOT=~/github
unset GH_PATH
```

Or set `TRY_GH_ROOT` only when invoking try:

```bash
TRY_GH_ROOT=~/github try
```

## Verify

```bash
# should be empty or point to the gh binary, not ~/github
echo "GH_PATH=${GH_PATH-<unset>}"

# should print your repos root
echo "TRY_GH_ROOT=$TRY_GH_ROOT"

gh auth status
gh dash
TRY_GH_ROOT=~/github try
```

## PR checklist

- [ ] Rename env var in docs/specs
- [ ] Add `TryGhRoot` helper for `TRY_GH_ROOT`
- [ ] Remove duplicate `gh_path_*` methods in `try.rb`
- [ ] Note breaking change in release notes (`GH_PATH` is ignored)
