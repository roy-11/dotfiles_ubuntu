# dotfiles

## Bootstrap

### 1. Install mise

```bash
curl https://mise.run | sh
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
```

This `export` is only needed for the current session during bootstrap:
`~/.local/bin` is for mise itself, and `~/.local/share/mise/shims` is for
tools installed by mise (chezmoi, herdr, etc.). After `chezmoi apply`,
`~/.zshrc` sets `PATH` and runs `mise activate zsh`, so new terminals
don't need it.

Verify:

```bash
mise --version
```

### 2. Install chezmoi

```bash
mise use --global chezmoi@latest
```

Verify:

```bash
chezmoi --version
```

### 3. Clone dotfiles

```bash
chezmoi init git@github.com:roy-11/dotfiles_ubuntu.git
```

Review:

```bash
chezmoi diff
```

Apply:

```bash
chezmoi apply -v
```

`chezmoi apply` runs `mise install` automatically (`run_onchange_after_900`)
before installing herdr plugins (`run_onchange_after_980`), and re-runs it
whenever `~/.config/mise/config.toml` changes.
