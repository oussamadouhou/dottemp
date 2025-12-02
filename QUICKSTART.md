# Quick Start Guide

De snelste manier om je dotfiles op een nieuwe machine te krijgen.

## 🚀 One-liner installatie

### Linux/macOS
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles
```

### Windows (PowerShell als Admin)
```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply <your-username>/dotfiles"
```

## ✅ Na installatie

1. **Herstart je terminal**
2. **Verify installatie:**
   ```bash
   chezmoi doctor
   mise doctor
   ```

3. **Test je tools:**
   ```bash
   git --version
   mise --version
   nvim --version
   ```

## 📝 Basis commando's

```bash
# Update van repository
chezmoi update

# Bewerk configuratie
chezmoi edit ~/.bashrc

# Bekijk wijzigingen
chezmoi diff

# Pas wijzigingen toe
chezmoi apply
```

## 🔐 Secrets setup

```bash
# Genereer je age key
chezmoi age-keygen --output="$HOME/.config/chezmoi/key.txt"
chmod 600 ~/.config/chezmoi/key.txt

# Voeg encrypted files toe
chezmoi add --encrypt ~/.ssh/id_ed25519
```

## 🆘 Problemen?

Zie de volledige [README.md](README.md) voor troubleshooting!
