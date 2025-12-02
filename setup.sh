#!/usr/bin/env bash
# Setup script voor dotfiles-template
# Dit script helpt je om de repository te initialiseren en te testen

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Dotfiles Setup Script${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f ".chezmoi.toml.tmpl" ]; then
    echo -e "${RED}Error: Dit script moet worden uitgevoerd in de dotfiles-template directory${NC}"
    exit 1
fi

# Menu
echo "Wat wil je doen?"
echo ""
echo "1) Test lokaal (dry-run)"
echo "2) Initialiseer Git repository"
echo "3) Test template syntax"
echo "4) Maak executable scripts"
echo "5) Genereer Age keypair"
echo "6) Push naar GitHub"
echo "7) Test in Docker (Ubuntu)"
echo "8) Alles (volledige setup)"
echo "9) Exit"
echo ""

read -p "Kies een optie [1-9]: " choice

case $choice in
    1)
        echo -e "${YELLOW}Testing lokaal (dry-run)...${NC}"
        if command -v chezmoi &> /dev/null; then
            chezmoi init --dry-run "$(pwd)"
            echo -e "${GREEN}Dry-run succesvol!${NC}"
        else
            echo -e "${RED}Chezmoi is niet geïnstalleerd. Installeer het eerst.${NC}"
            exit 1
        fi
        ;;
    
    2)
        echo -e "${YELLOW}Initialiseer Git repository...${NC}"
        if [ ! -d ".git" ]; then
            git init
            git add .
            git commit -m "Initial commit: Complete dotfiles setup"
            echo -e "${GREEN}Git repository geïnitialiseerd!${NC}"
            echo ""
            echo "Volgende stappen:"
            echo "1. Maak een nieuwe repository op GitHub"
            echo "2. Voer uit: git remote add origin git@github.com:<username>/dotfiles.git"
            echo "3. Voer uit: git push -u origin main"
        else
            echo -e "${YELLOW}Git repository bestaat al.${NC}"
        fi
        ;;
    
    3)
        echo -e "${YELLOW}Test template syntax...${NC}"
        errors=0
        for file in $(find . -name "*.tmpl"); do
            echo -n "Testing: $file ... "
            if chezmoi execute-template < "$file" > /dev/null 2>&1; then
                echo -e "${GREEN}OK${NC}"
            else
                echo -e "${RED}ERROR${NC}"
                errors=$((errors + 1))
            fi
        done
        
        if [ $errors -eq 0 ]; then
            echo -e "${GREEN}Alle templates zijn geldig!${NC}"
        else
            echo -e "${RED}$errors template(s) hebben errors${NC}"
            exit 1
        fi
        ;;
    
    4)
        echo -e "${YELLOW}Maak scripts executable...${NC}"
        find .chezmoiscripts -name "*.sh.tmpl" -exec chmod +x {} \;
        echo -e "${GREEN}Scripts zijn nu executable!${NC}"
        ;;
    
    5)
        echo -e "${YELLOW}Genereer Age keypair...${NC}"
        if command -v age-keygen &> /dev/null || command -v age &> /dev/null; then
            mkdir -p test-keys
            chezmoi age-keygen --output="test-keys/key.txt" || age-keygen -o test-keys/key.txt
            echo ""
            echo -e "${GREEN}Age keypair gegenereerd in test-keys/key.txt${NC}"
            echo ""
            echo "Public key:"
            grep "public key:" test-keys/key.txt
            echo ""
            echo -e "${YELLOW}Voeg deze public key toe aan .chezmoi.toml.tmpl recipients!${NC}"
        else
            echo -e "${RED}age is niet geïnstalleerd.${NC}"
            exit 1
        fi
        ;;
    
    6)
        echo -e "${YELLOW}Push naar GitHub...${NC}"
        
        if [ ! -d ".git" ]; then
            echo -e "${RED}Git repository niet gevonden. Voer eerst optie 2 uit.${NC}"
            exit 1
        fi
        
        read -p "GitHub username: " github_user
        read -p "Repository naam [dotfiles]: " repo_name
        repo_name=${repo_name:-dotfiles}
        
        # Check if remote exists
        if ! git remote | grep -q "origin"; then
            git remote add origin "git@github.com:${github_user}/${repo_name}.git"
        fi
        
        # Push
        git push -u origin main || git push -u origin master
        
        echo -e "${GREEN}Gepusht naar GitHub!${NC}"
        echo ""
        echo "Je dotfiles zijn nu beschikbaar op:"
        echo "https://github.com/${github_user}/${repo_name}"
        echo ""
        echo "Test de installatie met:"
        echo "sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply ${github_user}/${repo_name}"
        ;;
    
    7)
        echo -e "${YELLOW}Test in Docker (Ubuntu)...${NC}"
        
        if ! command -v docker &> /dev/null; then
            echo -e "${RED}Docker is niet geïnstalleerd.${NC}"
            exit 1
        fi
        
        # Check if we have a Git remote
        if git remote | grep -q "origin"; then
            remote_url=$(git remote get-url origin)
            if [[ $remote_url == *"github.com"* ]]; then
                # Extract username/repo from GitHub URL
                repo_path=$(echo "$remote_url" | sed -E 's/.*github\.com[:/](.+)\.git/\1/')
                
                echo "Testing met repository: $repo_path"
                echo ""
                
                docker run -it --rm ubuntu:22.04 bash -c "
                    apt update && apt install -y curl git sudo
                    useradd -m -s /bin/bash testuser
                    su - testuser -c 'sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply ${repo_path}'
                    su - testuser -c 'chezmoi doctor'
                "
            else
                echo -e "${YELLOW}Geen GitHub remote gevonden. Test met lokaal path.${NC}"
                docker run -it --rm -v "$(pwd):/dotfiles" ubuntu:22.04 bash
            fi
        else
            echo -e "${YELLOW}Geen Git remote gevonden. Push eerst naar GitHub (optie 6).${NC}"
        fi
        ;;
    
    8)
        echo -e "${YELLOW}Volledige setup...${NC}"
        echo ""
        
        # 1. Test templates
        echo -e "${BLUE}[1/6] Test template syntax...${NC}"
        bash "$0" <<< "3"
        
        # 2. Make scripts executable
        echo -e "${BLUE}[2/6] Maak scripts executable...${NC}"
        bash "$0" <<< "4"
        
        # 3. Init Git
        echo -e "${BLUE}[3/6] Initialiseer Git...${NC}"
        if [ ! -d ".git" ]; then
            bash "$0" <<< "2"
        else
            echo -e "${YELLOW}Git repository bestaat al, skip...${NC}"
        fi
        
        # 4. Generate Age key
        echo -e "${BLUE}[4/6] Genereer Age keypair...${NC}"
        if [ ! -f "test-keys/key.txt" ]; then
            bash "$0" <<< "5"
        else
            echo -e "${YELLOW}Age key bestaat al, skip...${NC}"
        fi
        
        # 5. Push to GitHub
        echo -e "${BLUE}[5/6] Push naar GitHub...${NC}"
        read -p "Wil je nu pushen naar GitHub? (y/n): " push_now
        if [[ $push_now == "y" ]]; then
            bash "$0" <<< "6"
        fi
        
        # 6. Summary
        echo ""
        echo -e "${GREEN}================================${NC}"
        echo -e "${GREEN}  Setup compleet!${NC}"
        echo -e "${GREEN}================================${NC}"
        echo ""
        echo "Volgende stappen:"
        echo "1. Review de gegenereerde age key in test-keys/key.txt"
        echo "2. Update .chezmoi.toml.tmpl met je team's public keys"
        echo "3. Test de installatie op een schone machine"
        echo ""
        ;;
    
    9)
        echo -e "${BLUE}Goodbye!${NC}"
        exit 0
        ;;
    
    *)
        echo -e "${RED}Ongeldige optie${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Klaar!${NC}"
