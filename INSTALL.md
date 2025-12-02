# Installatie Instructies

Deze guide legt uit hoe je deze dotfiles template kunt gebruiken en aanpassen voor jouw team.

---

## 📦 Wat heb je gedownload?

Dit archief bevat een complete, production-ready chezmoi + mise dotfiles setup met:

- ✅ Cross-platform ondersteuning (Linux, macOS, Windows)
- ✅ Automatische tool installatie via mise
- ✅ Age encryptie voor secrets
- ✅ Shell configuraties (bash, zsh)
- ✅ Git, SSH, Neovim configuraties
- ✅ Starship prompt
- ✅ Complete documentatie

---

## 🚀 Snelstart (5 minuten)

### Stap 1: Extract het archief

```bash
tar -xzf dotfiles-template.tar.gz
cd dotfiles-template
```

### Stap 2: Voer setup script uit

```bash
chmod +x setup.sh
./setup.sh
```

Kies optie **8** (Alles) voor een complete setup, of kies individuele stappen.

### Stap 3: Pas aan naar je wensen

Belangrijkste bestanden om aan te passen:

1. **`.chezmoi.toml.tmpl`** - Prompts en age recipients
2. **`dot_gitconfig.tmpl`** - Git defaults
3. **`dot_config/mise/config.toml.tmpl`** - Development tools
4. **`.chezmoiscripts/`** - Installatie scripts

### Stap 4: Push naar GitHub

```bash
# Initialiseer Git (als nog niet gedaan)
git init
git add .
git commit -m "Initial commit: Custom dotfiles"

# Voeg remote toe
git remote add origin git@github.com:<jouw-username>/dotfiles.git

# Push
git branch -M main
git push -u origin main
```

### Stap 5: Test de installatie

Op een schone machine (of Docker container):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <jouw-username>/dotfiles
```

---

## 📋 Gedetailleerde setup instructies

### Voor individueel gebruik

1. **Fork de template op GitHub**
   - Klik "Use this template" of fork de repository
   - Clone je fork: `git clone git@github.com:<jouw-username>/dotfiles.git`

2. **Personaliseer de configuratie**
   - Update `.chezmoi.toml.tmpl` met je voorkeuren
   - Pas tool configuraties aan in `dot_config/`
   - Verwijder wat je niet nodig hebt

3. **Test lokaal**
   ```bash
   chezmoi init --source=. --dry-run
   chezmoi diff
   chezmoi apply
   ```

4. **Commit en push**
   ```bash
   git add .
   git commit -m "Personalized dotfiles"
   git push
   ```

### Voor team gebruik

1. **Repository aanmaken**
   - Maak een team repository: `team/dotfiles-template`
   - Push deze template daarheen

2. **Team Age keys setup**
   
   Elk teamlid:
   ```bash
   # Genereer persoonlijke key
   chezmoi age-keygen --output="$HOME/.config/chezmoi/key.txt"
   chmod 600 ~/.config/chezmoi/key.txt
   
   # Deel public key met team lead
   grep "public key:" ~/.config/chezmoi/key.txt
   ```
   
   Team lead:
   ```bash
   # Update .chezmoi.toml.tmpl met alle public keys
   recipients = [
       "age1ql3z...(alice)",
       "age1xyz...(bob)",
       "age1abc...(charlie)"
   ]
   
   # Commit en push
   git add .chezmoi.toml.tmpl
   git commit -m "Add team age keys"
   git push
   ```

3. **Team configuratie aanpassen**
   - Update tool versies in `dot_config/mise/config.toml.tmpl`
   - Pas package installatie aan per platform
   - Voeg team-specifieke aliases toe

4. **Rollout plan**
   - Start met pilot groep (2-3 mensen)
   - Documenteer issues
   - Fix en iterate
   - Rollout naar volledige team

---

## 🔧 Aanpassingen maken

### Tools toevoegen

Voeg toe aan `dot_config/mise/config.toml.tmpl`:

```toml
[tools]
node = "lts"
python = "3.12"
mijn-nieuwe-tool = "latest"  # <-- Hier
```

### Packages toevoegen

Update `.chezmoiscripts/run_once_before_00-install-prerequisites.sh.tmpl`:

```bash
# Voor Arch Linux
sudo pacman -S --noconfirm mijn-package

# Voor Ubuntu/Debian
sudo apt install -y mijn-package

# Voor macOS
brew install mijn-package
```

### Nieuwe dotfile toevoegen

```bash
# Voeg toe aan chezmoi tracking
chezmoi add ~/.mijn-nieuwe-config

# Of maak een template
chezmoi add --template ~/.mijn-nieuwe-config
```

### Platform-specifieke configuratie

Gebruik conditionals in templates:

```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS-only configuratie
{{- else if eq .chezmoi.os "linux" }}
# Linux-only configuratie
{{- end }}
```

---

## 🔐 Secrets management

### Gevoelige bestanden toevoegen

```bash
# Encrypt bij toevoegen
chezmoi add --encrypt ~/.ssh/id_ed25519
chezmoi add --encrypt ~/.aws/credentials
chezmoi add --encrypt ~/.config/gcloud/credentials.json

# Bestaand bestand encrypten
chezmoi cd
git mv dot_example encrypted_dot_example.asc
git commit -m "Encrypt example file"
chezmoi apply --force
```

### Team member toevoegen

```bash
# Nieuwe member genereert key en deelt public key
# Team lead update .chezmoi.toml.tmpl met nieuwe public key

# Re-encrypt alle secrets
chezmoi cd
chezmoi apply  # Decrypt lokaal
chezmoi managed --include encrypted | while read -r file; do
    target=$(chezmoi target-path "$file")
    chezmoi forget "$file"
    chezmoi add --encrypt "$target"
done

git add .
git commit -m "Add new team member to secrets"
git push
```

### Team member verwijderen

```bash
# Verwijder public key uit .chezmoi.toml.tmpl
# Re-encrypt alle secrets (zie boven)
# Communiceer naar team: "chezmoi update" uitvoeren
```

---

## ✅ Verificatie checklist

Na setup, controleer deze punten:

### Lokaal testen
- [ ] `chezmoi doctor` - Geen errors
- [ ] `mise doctor` - Geen errors
- [ ] `git config --list` - Correcte configuratie
- [ ] `ssh -T git@github.com` - SSH werkt
- [ ] Templates renderen correct
- [ ] Scripts zijn executable

### Platform tests
- [ ] Test op Linux (Ubuntu in Docker)
- [ ] Test op macOS (als beschikbaar)
- [ ] Test op Windows (als nodig)

### Functionaliteit tests
- [ ] Nieuwe machine bootstrap werkt
- [ ] Encrypted files decrypten correct
- [ ] Mise tools installeren correct
- [ ] Shell configuratie laadt correct

---

## 🐛 Common issues

### "Permission denied" op scripts

```bash
cd dotfiles-template
chmod +x .chezmoiscripts/*.sh.tmpl
git add .chezmoiscripts/
git commit -m "Fix script permissions"
```

### Templates renderen niet

```bash
# Test individuele template
chezmoi execute-template < .chezmoi.toml.tmpl

# Check voor syntax errors
chezmoi init --dry-run "$(pwd)"
```

### Age decryptie faalt

```bash
# Controleer key
cat ~/.config/chezmoi/key.txt

# Controleer permissions
chmod 600 ~/.config/chezmoi/key.txt

# Test encryptie/decryptie
echo "test" | age -e -r $(grep "public key:" ~/.config/chezmoi/key.txt | cut -d: -f2) | age -d -i ~/.config/chezmoi/key.txt
```

### Git push rejected

```bash
# Zorg dat je een remote hebt
git remote add origin git@github.com:<username>/dotfiles.git

# Force push als nodig (eerste keer)
git push -u origin main --force
```

---

## 📚 Volgende stappen

1. **Lees de documentatie**
   - [README.md](README.md) - Complete guide
   - [QUICKSTART.md](QUICKSTART.md) - Snelle referentie
   - [TESTING.md](TESTING.md) - Test strategieën
   - [CONTRIBUTING.md](CONTRIBUTING.md) - Bijdragen

2. **Customize voor jouw workflow**
   - Pas tool versies aan
   - Voeg je favoriete aliases toe
   - Configureer je editor

3. **Test grondig**
   - Test op alle platforms die je gebruikt
   - Test met nieuwe team members
   - Documenteer edge cases

4. **Maintain**
   - Update tools regelmatig
   - Review team feedback
   - Iterate en verbeter

---

## 🆘 Hulp nodig?

- **Chezmoi docs**: https://www.chezmoi.io/
- **Mise docs**: https://mise.jdx.dev/
- **Age docs**: https://github.com/FiloSottile/age

---

**Succes met je dotfiles setup! 🎉**
