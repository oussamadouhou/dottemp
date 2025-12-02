# Testing Guide voor Dotfiles Repository

Deze guide helpt je om de dotfiles repository te testen voordat je deze uitrolt naar je team.

---

## 🧪 Lokale testing

### 1. Syntax validatie

Test of alle templates correct zijn:

```bash
cd dotfiles-template

# Test template syntax (vereist chezmoi)
chezmoi execute-template < .chezmoi.toml.tmpl

# Test alle templates
for file in $(find . -name "*.tmpl"); do
    echo "Testing: $file"
    chezmoi execute-template < "$file" || echo "ERROR in $file"
done
```

### 2. Dry-run test

Test wat er zou gebeuren zonder daadwerkelijk toe te passen:

```bash
# Clone de repo
chezmoi init --dry-run <your-github-username>/dotfiles

# Bekijk wat er zou gebeuren
chezmoi diff

# Apply in dry-run mode
chezmoi apply --dry-run --verbose
```

### 3. Test in tijdelijke directory

Test zonder je eigen system te beïnvloeden:

```bash
# Maak een test home directory
export TEST_HOME=$(mktemp -d)
export HOME=$TEST_HOME

# Initialize chezmoi
chezmoi init --apply <your-github-username>/dotfiles

# Controleer resultaten
ls -la $TEST_HOME
cat $TEST_HOME/.bashrc

# Cleanup
rm -rf $TEST_HOME
unset TEST_HOME
```

---

## 🐳 Docker testing

### Ubuntu 22.04

```bash
# Start Ubuntu container
docker run -it --rm \
    -v $(pwd):/workspace \
    ubuntu:22.04 \
    bash

# In container
apt update && apt install -y curl git sudo
useradd -m -s /bin/bash testuser
su - testuser

# Test installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles

# Verify
source ~/.bashrc
which mise
mise --version
git --version

# Test mise installation
mise install
mise ls

# Exit container
exit
```

### Arch Linux

```bash
docker run -it --rm \
    -v $(pwd):/workspace \
    archlinux:latest \
    bash

# In container
pacman -Syu --noconfirm
pacman -S --noconfirm curl git sudo base-devel
useradd -m -s /bin/bash testuser
su - testuser

# Test installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles

# Verify
source ~/.bashrc
which mise
```

### Debian 12

```bash
docker run -it --rm \
    -v $(pwd):/workspace \
    debian:12 \
    bash

# In container
apt update && apt install -y curl git sudo
useradd -m -s /bin/bash testuser
su - testuser

# Test installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles
```

---

## 🍎 macOS testing

### Test op schone gebruiker account

```bash
# Maak test user (vereist admin rechten)
sudo dscl . -create /Users/testuser
sudo dscl . -create /Users/testuser UserShell /bin/zsh
sudo dscl . -create /Users/testuser RealName "Test User"
sudo dscl . -create /Users/testuser UniqueID 1001
sudo dscl . -create /Users/testuser PrimaryGroupID 20
sudo dscl . -create /Users/testuser NFSHomeDirectory /Users/testuser
sudo dscl . -passwd /Users/testuser testpass123

# Maak home directory
sudo createhomedir -c -u testuser

# Switch naar test user
su - testuser

# Test installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles

# Cleanup (als admin)
sudo dscl . -delete /Users/testuser
sudo rm -rf /Users/testuser
```

### Test met Homebrew

Als je Homebrew al hebt:

```bash
# Backup huidige config
chezmoi init --source=/tmp/chezmoi-backup ~/.config

# Test nieuwe config
chezmoi init --apply <your-username>/dotfiles

# Als iets fout gaat, restore backup
chezmoi init --apply /tmp/chezmoi-backup
```

---

## 🪟 Windows testing

### Test in PowerShell

```powershell
# Start als Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Test in tijdelijke directory
$TestHome = New-Item -ItemType Directory -Path $env:TEMP -Name "chezmoi-test-$(Get-Random)"
$env:USERPROFILE = $TestHome
$env:HOME = $TestHome

# Test installation
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply <your-username>/dotfiles"

# Verify
Get-ChildItem $TestHome
Get-Content "$TestHome\.gitconfig"

# Cleanup
Remove-Item -Recurse -Force $TestHome
```

### Test in WSL2

```bash
# In WSL2
export TEST_HOME=$(mktemp -d)
export HOME=$TEST_HOME

# Test installation
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles

# Cleanup
rm -rf $TEST_HOME
```

---

## 🔐 Age encryption testing

### Test encryptie/decryptie

```bash
# Genereer test keys
age-keygen -o /tmp/test-key.txt

# Get public key
TEST_PUBKEY=$(grep "public key:" /tmp/test-key.txt | cut -d: -f2 | tr -d ' ')

# Test encryptie
echo "secret data" | age -e -r "$TEST_PUBKEY" > /tmp/test.age

# Test decryptie
age -d -i /tmp/test-key.txt /tmp/test.age

# Cleanup
rm /tmp/test-key.txt /tmp/test.age
```

### Test met chezmoi

```bash
# Setup test environment
export CHEZMOI_TEST_DIR=$(mktemp -d)
cd $CHEZMOI_TEST_DIR

# Initialize
chezmoi init

# Generate age key
mkdir -p ~/.config/chezmoi
chezmoi age-keygen --output="~/.config/chezmoi/key.txt"

# Add public key to config
PUBKEY=$(grep "public key:" ~/.config/chezmoi/key.txt | cut -d: -f2 | tr -d ' ')
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipients = ["$PUBKEY"]
EOF

# Test encrypted file
echo "secret" > /tmp/secret.txt
chezmoi add --encrypt /tmp/secret.txt

# Verify encryption
cat $(chezmoi source-path)/encrypted_private_tmp/secret.txt.age

# Verify decryption
chezmoi cat /tmp/secret.txt

# Cleanup
rm -rf $CHEZMOI_TEST_DIR
```

---

## ✅ Pre-deployment checklist

Controleer deze punten voordat je uitrolt:

### Repository

- [ ] Alle templates hebben correcte syntax
- [ ] Geen hardcoded secrets in plain text
- [ ] README is up-to-date
- [ ] .chezmoiignore is correct voor alle platforms
- [ ] Age recipients lijst is compleet (voor team setup)

### Scripts

- [ ] Alle scripts hebben juiste shebangs
- [ ] Unix scripts zijn executable
- [ ] Scripts hebben error handling
- [ ] Scripts geven duidelijke output

### Platform tests

- [ ] Getest op Ubuntu 22.04
- [ ] Getest op Arch Linux
- [ ] Getest op macOS (Intel of Apple Silicon)
- [ ] Getest op Windows 11

### Functionaliteit

- [ ] Chezmoi installeert correct
- [ ] Mise installeert correct
- [ ] Prerequisites installeren correct
- [ ] Templates renderen correct
- [ ] Encrypted files decrypten correct
- [ ] Shell configuratie laadt correct
- [ ] Git configuratie werkt
- [ ] SSH configuratie werkt

### Post-install verificatie

```bash
# Voer uit na installatie
chezmoi doctor
mise doctor
git config --list
ssh -T git@github.com
which mise
which starship
nvim --version
```

---

## 🚨 Common issues tijdens testing

### Issue: Template syntax errors

```bash
# Debug template
chezmoi execute-template --init --promptString name=Test < .chezmoi.toml.tmpl
```

### Issue: Scripts worden niet uitgevoerd

```bash
# Check permissions
chezmoi cd
ls -la .chezmoiscripts/

# Fix permissions
chmod +x .chezmoiscripts/run_*.sh*
git add . && git commit -m "Fix script permissions"
```

### Issue: Age decryptie faalt

```bash
# Check age key
cat ~/.config/chezmoi/key.txt

# Check recipients in config
chezmoi data | jq .age

# Re-encrypt files
chezmoi cd
# Update .chezmoi.toml.tmpl with correct recipients
chezmoi apply --force
```

### Issue: Mise tools installeren niet

```bash
# Check mise installation
which mise
mise --version

# Check config
mise config

# Force install
mise install --force
```

---

## 📊 Performance testing

### Measure installation time

```bash
time sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-username>/dotfiles
```

Typical times:
- Ubuntu (container): 2-5 minuten
- macOS (clean): 5-10 minuten
- Windows: 10-15 minuten

### Measure chezmoi apply time

```bash
time chezmoi apply
```

Should be < 5 seconds for subsequent runs.

---

## 🔄 Continuous testing

### GitHub Actions (voorbeeld)

```yaml
name: Test Dotfiles

on: [push, pull_request]

jobs:
  test-ubuntu:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Test installation
        run: |
          sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ${{ github.repository }}
          chezmoi doctor
          
  test-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Test installation
        run: |
          sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ${{ github.repository }}
          chezmoi doctor
```

---

## 📝 Test rapportage

Gebruik deze template voor test resultaten:

```markdown
# Test Resultaten

**Datum**: YYYY-MM-DD
**Tester**: Naam
**Commit**: abc123

## Platform: Ubuntu 22.04

- [ ] Installatie succesvol
- [ ] Chezmoi werkt
- [ ] Mise werkt
- [ ] Scripts uitgevoerd
- [ ] Templates correct
- [ ] Performance acceptabel

**Notities**: 
- ...

**Issues gevonden**:
- #123: Script permission issue

## Platform: macOS

...
```

---

**Happy Testing! 🎉**
