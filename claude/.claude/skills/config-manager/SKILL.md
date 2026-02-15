---
name: config-manager
description: >
  Manages dotfiles and system config files using GNU Stow.
  Use when the user asks to edit, review, sync, bootstrap, or
  organize configuration files.
---

## Context

The user is migrating scattered config files from ~ into a GNU Stow-managed
dotfiles repo. Not all files have been migrated yet — some are still
loose in ~.

Dotfiles repo: (ask the user for the path if not known)

## Editing configs

1. Read the file first.
2. Create an in-place backup: `cp <file> <file>.bak.$(date +%s)`
3. Make the edit.
4. Validate syntax — always run the appropriate checker and refuse to
   finalize if validation fails:
   - Shell configs: `zsh -n`, `bash -n`
   - nginx: `nginx -t`
   - systemd: `systemd-analyze verify`
   - SSH: `sshd -t`
   - YAML/JSON/TOML: use appropriate linters
   - If no checker exists for the format, warn the user.
5. If the file lives in the stow repo, remind the user to re-stow
   if they edited the deployed symlink target directly.

## Stow organization

When helping organize configs into the dotfiles repo:

1. Use the standard stow package layout:
   ```
   dotfiles/
   ├── zsh/.zshrc
   ├── git/.gitconfig
   ├── nvim/.config/nvim/init.lua
   └── ssh/.ssh/config
   ```
   Each top-level dir is a "package" mirroring the home directory structure.

2. Migration workflow:
   - Move the file into the correct package path in the repo
   - Run `stow <package>` from the dotfiles repo root to create the symlink
   - Verify the symlink points correctly

3. Never stow files that contain secrets (SSH private keys, tokens).
   Flag these and suggest .gitignore or separate encrypted storage.

## Explaining / auditing configs

When asked to review a config:
- Walk through section by section
- Flag deprecated options
- Flag security concerns (world-readable permissions, plaintext secrets,
  overly permissive settings)
- Suggest improvements only when asked

## Sync / bootstrap

When setting up a new machine:
1. Clone the dotfiles repo
2. Install stow
3. Run `stow */` to deploy all packages (or selectively per package)
4. List any configs that exist in ~ but aren't in the repo yet
