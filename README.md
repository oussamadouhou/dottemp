# Dotfiles met Chezmoi + Mise

Complete cross-platform dotfiles configuratie met automatische tool versie management.

## 🚀 Snelle start

### Vereisten

- Git
- Terminal/PowerShell toegang
- Internettoegang

### Installatie

**Linux/macOS:**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>/dotfiles
```

**Windows (PowerShell als Administrator):**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply <your-github-username>/dotfiles"
```

### Eerste keer configuratie

Bij de eerste run word je gevraagd naar:

1. **Volledige naam** - Voor git commits
2. **Email adres** - Voor git commits
3. **GPG key ID** - Optioneel, voor signed commits
4. **Is dit een persoonlijke machine?** - Voor persoonlijke vs werk configuratie
5. **Is dit een ephemeral machine?** - Voor containers/VMs (skip secrets sync)
6. **Is dit een development machine?** - Voor extra dev tools

Herstart je terminal na installatie!

---

## 📚 Wat wordt er geïnstalleerd?

### Package Managers

- **macOS**: Homebrew
- **Arch Linux**: pacman
- **Debian/Ubuntu**: apt
- **Windows**: winget

### Basis Tools

- **Git** - Version control
- **Neovim** - Modern text editor
- **Starship** - Cross-shell prompt
- **mise** - Development tool version manager
- **age** - Modern encryption tool
- **ripgrep** (rg) - Fast grep replacement
- **fd** - Fast find replacement
- **bat** - Modern cat replacement
- **eza** - Modern ls replacement
- **fzf** - Fuzzy finder
- **delta** - Better git diffs
- **jq** - JSON processor
- **htop** - Process viewer

### Development Tools (alleen op dev machines)

Via mise worden automatisch geïnstalleerd:
- **Node.js** (LTS)
- **Python** (3.12)
- **Terraform** (latest)
- **kubectl** (latest)
- **Helm** (latest)
- **Go** (latest)
- **Rust** (stable)

### Shell Configuraties

- **Bash** (.bashrc)
- **Zsh** (.zshrc) met Oh My Zsh
  - Powerlevel10k theme
  - zsh-autosuggestions
  - zsh-syntax-highlighting

---

## 📖 Dagelijks gebruik

### Basis commando's

```bash
# Wijzigingen ophalen van de repository
chezmoi update

# Bekijk wat er zou veranderen
chezmoi diff

# Pas wijzigingen toe
chezmoi apply

# Bewerk een bestand
chezmoi edit ~/.bashrc

# Voeg een nieuw bestand toe
chezmoi add ~/.config/nieuwe-app/config

# Ga naar de source directory
chezmoi cd

# Verwijder een bestand uit chezmoi tracking
chezmoi forget ~/.some-file
```

### Git workflow

```bash
# Naar source directory
chezmoi cd

# Bekijk status
git status

# Commit wijzigingen
git add .
git commit -m "Update config"
git push

# Terug naar home
exit  # of Ctrl+D
```

### Mise tool management

```bash
# Bekijk geïnstalleerde tools
mise ls

# Installeer een tool
mise use node@20

# Update tools
mise upgrade

# Bekijk beschikbare versies
mise ls-remote node

# Lokale .mise.toml aanmaken voor project
cd ~/mijn-project
mise use node@20 python@3.11
```

---

## 🔐 Secrets Management met Age

### Age keys genereren

```bash
# Genereer je persoonlijke age keypair
chezmoi age-keygen --output="$HOME/.config/chezmoi/key.txt"

# Beveilig de private key
chmod 600 ~/.config/chezmoi/key.txt

# Bekijk je public key
grep "# public key:" ~/.config/chezmoi/key.txt
```

**BELANGRIJK**: Bewaar je private key (`key.txt`) veilig en backup hem!

### Gevoelige bestanden toevoegen

```bash
# Encrypt een bestand direct
chezmoi add --encrypt ~/.ssh/id_ed25519

# Of mark een bestaand bestand als encrypted
chezmoi cd
git mv dot_example encrypted_dot_example.asc
chezmoi apply --force

# Bewerk encrypted bestanden
chezmoi edit --apply ~/.aws/credentials
```

### Team secrets sharing

Voor team gebruik, voeg public keys toe aan `.chezmoi.toml.tmpl`:

```toml
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipients = [
        "age1ql3z...(alice)",
        "age1xyz...(bob)",
        "age1abc...(charlie)"
    ]
```

Herencrypt alle secrets na toevoegen van een nieuwe recipient:

```bash
chezmoi cd
# Update .chezmoi.toml.tmpl met nieuwe public key
chezmoi apply  # Decrypt alles lokaal
# Re-add alle encrypted files
chezmoi managed --include encrypted | while read -r file; do
    target=$(chezmoi target-path "$file")
    chezmoi forget "$file"
    chezmoi add --encrypt "$target"
done
git add . && git commit -m "Add new team member" && git push
```

---

## 🛠️ Aanpassen voor je eigen gebruik

### Repository forken

1. Fork deze repository op GitHub
2. Clone je fork lokaal:
   ```bash
   chezmoi init --apply <your-github-username>/dotfiles
   ```

### Eigen configuraties toevoegen

```bash
# Voeg bestanden toe
chezmoi add ~/.my-custom-config

# Maak templates voor machine-specifieke configuratie
chezmoi add --template ~/.gitconfig

# Bewerk en pas toe
chezmoi edit ~/.gitconfig
chezmoi apply
```

### Platform-specifieke configuratie

Gebruik chezmoi templates:

```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific config
{{- else if eq .chezmoi.os "windows" }}
# Windows-specific config
{{- end }}
```

### Lokale overrides

Maak `.local` bestanden die NIET worden getracked:

- `~/.bashrc.local`
- `~/.zshrc.local`
- `~/.gitconfig.local`
- `~/.ssh/config.local`

Deze worden automatisch geladen maar blijven privé.

---

## 🐛 Troubleshooting

### Linux

**"Permission denied" op scripts**
```bash
chezmoi cd
chmod +x .chezmoiscripts/run_*.sh*
git add . && git commit -m "Fix permissions" && git push
chezmoi apply
```

**"Bad interpreter" error**
Gebruik `#!/usr/bin/env bash` in plaats van `#!/bin/bash`

### macOS

**Homebrew niet gevonden na installatie**
```bash
# Intel Mac
eval "$(/usr/local/bin/brew shellenv)"

# Apple Silicon Mac
eval "$(/opt/homebrew/bin/brew shellenv)"

# Herstart terminal
```

**XCode Command Line Tools vereist**
```bash
xcode-select --install
```

### Windows

**Script execution disabled**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Path niet bijgewerkt**
```powershell
# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Algemeen

**Chezmoi apply mislukt**
```bash
# Dry-run om te zien wat er zou gebeuren
chezmoi apply --dry-run --verbose

# Force apply (overschrijft lokale wijzigingen)
chezmoi apply --force
```

**Age decryptie mislukt**
```bash
# Controleer of key bestaat
ls -la ~/.config/chezmoi/key.txt

# Controleer permissions
chmod 600 ~/.config/chezmoi/key.txt

# Test encryptie
echo "test" | age -e -r $(grep "public key:" ~/.config/chezmoi/key.txt | cut -d: -f2) | age -d -i ~/.config/chezmoi/key.txt
```

**Mise tools installeren niet**
```bash
# Update mise
mise self-update

# Forceer herinstallatie
mise install --force

# Debug mode
mise doctor
```

---

## 📁 Repository structuur

```
dotfiles/
├── .chezmoi.toml.tmpl              # Hoofdconfiguratie met prompts
├── .chezmoiignore                  # Platform-specifieke excludes
├── .chezmoiexternal.toml           # Externe dependencies
├── .chezmoitemplates/              # Herbruikbare snippets
│   ├── shell_aliases
│   └── shell_functions
├── .chezmoiscripts/                # Setup scripts
│   ├── run_once_before_00-install-prerequisites.sh.tmpl
│   ├── run_once_before_00-install-prerequisites.ps1.tmpl
│   ├── run_once_before_01-install-mise.sh.tmpl
│   └── run_once_before_01-install-mise.ps1.tmpl
├── dot_bashrc.tmpl                 # Bash configuratie
├── dot_zshrc.tmpl                  # Zsh configuratie
├── dot_gitconfig.tmpl              # Git configuratie
├── dot_config/
│   ├── mise/
│   │   └── config.toml.tmpl        # Mise global config
│   ├── nvim/
│   │   └── init.lua                # Neovim config
│   └── starship.toml.tmpl          # Starship prompt
├── private_dot_ssh/
│   └── config.tmpl                 # SSH config
└── README.md                       # Deze file
```

---

## 🔄 Update strategie

### Tools updaten

```bash
# Update chezmoi zelf
chezmoi upgrade

# Update mise
mise self-update

# Update alle mise tools
mise upgrade

# Update package managers
# macOS
brew update && brew upgrade

# Arch
sudo pacman -Syu

# Debian/Ubuntu
sudo apt update && sudo apt upgrade

# Windows
winget upgrade --all
```

### Dotfiles updaten

```bash
# Pull latest changes
chezmoi update

# Of handmatig
chezmoi cd
git pull
exit
chezmoi apply
```

---

## 🎯 Testing op clean machine

### Linux (Docker)

```bash
docker run -it --rm ubuntu:22.04 bash
apt update && apt install -y curl git
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles
```

### macOS (VM)

Use a tool like UTM or Parallels to create a clean macOS VM.

### Windows (VM)

Use Hyper-V or VirtualBox to create a clean Windows VM.

---

## 📚 Meer informatie

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Mise Documentation](https://mise.jdx.dev/)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Starship Prompt](https://starship.rs/)

---

## 📝 Licentie

MIT License - Voel je vrij om te gebruiken en aan te passen!

---

## 🤝 Contributing

Pull requests zijn welkom! Voor grote wijzigingen, open eerst een issue om te bespreken wat je wilt veranderen.

---

**Gemaakt met ❤️ voor cross-platform development**
# dottemp
# dottemp
