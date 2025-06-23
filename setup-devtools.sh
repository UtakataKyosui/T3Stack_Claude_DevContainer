#!/bin/bash

# Development Tools Setup Script
echo "🛠️ Setting up development tools..."

# Update package lists
echo "📦 Updating package lists..."
sudo apt-get update >/dev/null 2>&1

# Install essential development tools
echo "🔧 Installing essential tools..."
sudo apt-get install -y \
    tmux \
    fzf \
    tree \
    curl \
    wget \
    git-extras \
    ripgrep \
    fd-find \
    bat \
    exa \
    htop \
    vim \
    nano \
    unzip \
    zip \
    jq \
    >/dev/null 2>&1 || echo "  → Some packages may need manual installation"

# Install npm global packages
echo "📦 Installing npm global packages..."
npm install -g \
    ccmanager \
    @aku11i/phantom \
    >/dev/null 2>&1 || echo "  → npm global packages installation pending"

# Setup aliases and shell improvements
echo "🐚 Setting up shell improvements..."
cat >> ~/.bashrc << 'EOF'

# Development tools aliases
alias ll='exa -la --icons'
alias ls='exa --icons'
alias cat='batcat --paging=never'
alias find='fd'
alias grep='rg'
alias top='htop'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

# tmux aliases
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'

# Project specific aliases
alias dev='npm run dev'
alias build='npm run build'
alias test='npm run test'
alias check='npm run check'

# fzf setup
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi
EOF

# Setup tmux configuration
echo "⚙️ Setting up tmux configuration..."
cat > ~/.tmux.conf << 'EOF'
# Basic settings
set -g default-terminal "screen-256color"
set -g mouse on
set -g history-limit 10000

# Key bindings
bind r source-file ~/.tmux.conf \; display "Config reloaded!"
bind | split-window -h
bind - split-window -v

# Status bar
set -g status-bg colour235
set -g status-fg colour250
set -g status-left '[#S] '
set -g status-right '%Y-%m-%d %H:%M'

# Window navigation
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
EOF

# Verify installations
echo "🔍 Verifying tool installations..."
tools=(tmux fzf tree curl wget rg fd batcat exa htop jq)
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: installed"
    else
        echo "  ❌ $tool: not found"
    fi
done

# Check npm global tools
npm_tools=(ccmanager phantom)
for tool in "${npm_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: installed"
    else
        echo "  ❌ $tool: not found"
    fi
done

echo "✅ Development tools setup completed!"
echo "💡 Restart your shell or run 'source ~/.bashrc' to apply changes"