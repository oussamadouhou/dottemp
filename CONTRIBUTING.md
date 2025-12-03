# Contributing Guide

Bedankt voor je interesse in het verbeteren van deze dotfiles! Deze guide helpt je om bij te dragen.

## 🔄 Workflow voor bijdragen

### 1. Fork de repository

Klik op de "Fork" button op GitHub.

### 2. Clone je fork

```bash
git clone git@github.com:<jouw-username>/dotfiles.git
cd dotfiles
```

### 3. Maak een feature branch

```bash
git checkout -b feature/mijn-verbetering
```

### 4. Maak je wijzigingen

Volg deze best practices:

#### Template syntax
```bash
# Test template syntax
chezmoi execute-template < .chezmoi.toml.tmpl
```

#### Script testing
```bash
# Maak scripts executable
chmod +x .chezmoiscripts/run_*.sh*

# Test scripts
bash -n .chezmoiscripts/run_once_before_00-install-prerequisites.sh.tmpl
```

#### Platform conditionals
```bash
# Gebruik deze patterns voor OS detection
{{- if eq .chezmoi.os "darwin" }}
# macOS
{{- else if eq .chezmoi.os "linux" }}
# Linux
{{- else if eq .chezmoi.os "windows" }}
# Windows
{{- end }}
```

### 5. Test je wijzigingen

Zie [TESTING.md](TESTING.md) voor complete test instructies.

Minimaal:
```bash
# Test in Docker container
docker run -it --rm ubuntu:22.04 bash
# In container:
apt update && apt install -y curl git
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles
```

### 6. Commit je wijzigingen

```bash
git add .
git commit -m "feat: beschrijving van je wijziging"
```

Gebruik deze commit prefixes:
- `feat:` - Nieuwe feature
- `fix:` - Bug fix
- `docs:` - Documentatie wijziging
- `style:` - Code style (formatting)
- `refactor:` - Code refactoring
- `test:` - Test wijzigingen
- `chore:` - Maintenance

### 7. Push naar je fork

```bash
git push origin feature/mijn-verbetering
```

### 8. Maak een Pull Request

Op GitHub, klik "New Pull Request" en vul de template in.

## 📋 Pull Request Checklist

- [ ] Code is getest op minimaal één platform
- [ ] Templates hebben correcte syntax
- [ ] Scripts zijn executable
- [ ] Geen secrets in plain text
- [ ] README/docs zijn bijgewerkt indien nodig
- [ ] Commit messages volgen conventie
- [ ] PR beschrijving is compleet

## 🎯 Areas voor bijdragen

### High priority
- [ ] Windows-specifieke verbeteringen
- [ ] Additional platform support (FreeBSD, NixOS)
- [ ] More development tool presets
- [ ] Better error handling in scripts

### Medium priority
- [ ] Additional shell themes
- [ ] More editor configurations (emacs, vscode)
- [ ] Container/Docker-specific optimizations
- [ ] CI/CD integration examples

### Low priority
- [ ] Documentation translations
- [ ] Example configurations
- [ ] Video tutorials

## 🚫 Wat NIET toe te voegen

- **Geen secrets**: Geen passwords, tokens, keys in plain text
- **Geen vendor files**: Geen grote binaries of vendored dependencies
- **Geen personal info**: Geen persoonlijke email, namen in templates (gebruik variables)
- **Geen breaking changes**: Zonder discussie in een issue

## 🔒 Security concerns

Als je een security issue vindt:

1. **Maak GEEN public issue**
2. Email naar: [security email hier]
3. Beschrijf het probleem en potentiële impact
4. Wacht op response voordat je publiceert

## 💬 Communicatie

- **Issues**: Voor bugs en feature requests
- **Discussions**: Voor vragen en algemene discussie
- **Pull Requests**: Voor code bijdragen

## 🏆 Code of Conduct

- Wees respectvol
- Wees constructief in feedback
- Help anderen
- Vraag om hulp als je het nodig hebt

## 📚 Nuttige resources

- [Chezmoi documentation](https://www.chezmoi.io/)
- [Mise documentation](https://mise.jdx.dev/)
- [Go templates syntax](https://pkg.go.dev/text/template)
- [Bash scripting guide](https://www.gnu.org/software/bash/manual/)

---

**Bedankt voor je bijdrage! 🙌**
