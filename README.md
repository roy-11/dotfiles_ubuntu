# dotfiles

## Bootstrap

### 1. Install mise

```bash
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
```

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
chezmoi init git@github.com:USERNAME/dotfiles.git
```

Review:
```bash
chezmoi diff
```

Apply:
```bash
chezmoi apply -v
```

### 4. Install mise-managed tools

```bash
mise install
```
