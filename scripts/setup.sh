#!/bin/bash
# scripts/setup.sh - Main setup script

set -e

echo "🚀 Starting VPS setup..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential tools
echo "🔧 Installing essential tools..."
sudo apt install -y \
    curl wget git vim nano \
    htop neofetch tree jq \
    zip unzip rar unrar \
    net-tools iputils-ping \
    build-essential software-properties-common \
    ca-certificates gnupg lsb-release \
    ffmpeg imagemagick \
    sqlite3 postgresql-client mysql-client

# Install development tools
echo "💻 Installing development tools..."

# Install latest Git
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt install git -y

# Install GitHub CLI
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# Install Node.js ecosystem
echo "🟢 Setting up Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# Install global npm packages
npm install -g \
    pm2 nodemon live-server \
    typescript ts-node \
    @angular/cli @vue/cli create-react-app \
    express-generator \
    http-server serve

# Install Python packages
echo "🐍 Setting up Python..."
pip install --upgrade pip setuptools wheel
pip install \
    flask fastapi uvicorn \
    requests beautifulsoup4 selenium \
    pandas numpy matplotlib seaborn \
    jupyter notebook \
    django djangorestframework \
    sqlalchemy psycopg2-binary pymongo \
    celery redis \
    pytest black flake8

# Install Rust
echo "🦀 Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Install Go tools
echo "🐹 Setting up Go..."
go install github.com/air-verse/air@latest
go install github.com/gin-gonic/gin@latest

# Install databases
echo "🗄️ Installing databases..."

# MongoDB
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt update
sudo apt install -y mongodb-org

# Redis
sudo apt install redis-server -y

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Setup aliases
echo "⚙️ Setting up aliases..."
cat >> ~/.bashrc << 'EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias cls='clear'
alias h='history'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias ports='netstat -tuln'
alias myip='curl ifconfig.me'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
EOF

# Setup Git configuration
echo "🔐 Setting up Git..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p ~/projects ~/downloads ~/backups ~/scripts ~/logs

# Setup cron jobs (if needed)
echo "⏰ Setting up scheduled tasks..."
(crontab -l 2>/dev/null; echo "0 */6 * * * /workspaces/$(basename $PWD)/scripts/auto-commit.sh") | crontab -

# Final system info
echo "✅ Setup completed!"
echo ""
echo "🎉 VPS Information:"
echo "=================="
neofetch
echo ""
echo "📊 System Resources:"
echo "CPU: $(nproc) cores"
echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $2 " total, " $4 " available"}')"
echo ""
echo "🌐 Network:"
echo "Public IP: $(curl -s ifconfig.me || echo 'Unable to fetch')"
echo ""
echo "🛠️ Installed tools:"
echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
echo "Python: $(python3 --version 2>/dev/null || echo 'Not installed')"
echo "Go: $(go version 2>/dev/null | awk '{print $3}' || echo 'Not installed')"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not installed')"
echo ""
echo "🎯 Ready to use! Happy coding!"