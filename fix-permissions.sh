#!/bin/bash

# DevContainer initialization script
echo "🚀 Setting up DevContainer environment..."

# 1. Fix workspace permissions
echo "📁 Fixing workspace permissions..."
if [ ! -d "/workspace/node_modules" ]; then
    mkdir -p /workspace/node_modules
fi

# Safe permission fix - only if we're not already the owner
if [ "$(stat -c '%U' /workspace 2>/dev/null || stat -f '%Su' /workspace 2>/dev/null)" != "node" ]; then
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        echo "  → Fixing ownership with sudo..."
        sudo chown -R node:node /workspace 2>/dev/null || true
    else
        echo "  → Setting permissions without sudo..."
        chmod -R u+w /workspace 2>/dev/null || true
    fi
else
    echo "  → Permissions already correct"
fi

# 2. Install uv if not present
echo "🐍 Setting up Python package manager (uv)..."
if ! command -v uv >/dev/null 2>&1; then
    echo "  → Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
else
    echo "  → uv already installed"
fi

# 3. Setup Claude Code
echo "🤖 Setting up Claude Code..."
if [ ! -d "/home/node/.anthropic" ]; then
    mkdir -p /home/node/.anthropic
    echo "  → Created Claude Code config directory"
fi

# Ensure Claude Code has proper permissions
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    sudo chown -R node:node /home/node/.anthropic 2>/dev/null || true
fi

# Ensure .mcp.json is readable
if [ -f "/workspace/.mcp.json" ]; then
    chmod 644 /workspace/.mcp.json 2>/dev/null || true
    echo "  → .mcp.json permissions set"
fi

# Install Claude Code via npm
if ! command -v claude >/dev/null 2>&1; then
    echo "  → Installing Claude Code CLI via npm..."
    # Install official Claude Code package
    npm install -g @anthropic-ai/claude-code@latest || {
        echo "  → Trying alternative installation methods..."
        # Alternative method: direct download
        curl -sSL https://claude.ai/cli/install.sh | bash
    }
    
    # Ensure npm global bin is in PATH
    NPM_GLOBAL_BIN=$(npm config get prefix)/bin
    echo "export PATH=\"$NPM_GLOBAL_BIN:\$PATH\"" >> ~/.bashrc
    export PATH="$NPM_GLOBAL_BIN:$PATH"
else
    echo "  → Claude Code already available"
fi

# 4. Setup development tools directory
echo "🛠️ Preparing development tools setup..."
if [ -f "/workspace/.devcontainer/setup-devtools.sh" ]; then
    chmod +x /workspace/.devcontainer/setup-devtools.sh
    echo "  → Development tools script ready"
else
    echo "  → Development tools script not found, will run via npm script"
fi

# 5. Verify core installations
echo "🔍 Verifying core installations..."
echo "  → Node.js: $(node --version 2>/dev/null || echo 'Not found')"
echo "  → npm: $(npm --version 2>/dev/null || echo 'Not found')"
echo "  → Python: $(python3 --version 2>/dev/null || echo 'Not found')"
echo "  → uv: $(uv --version 2>/dev/null || echo 'Not found')"
echo "  → Claude Code: $(claude --version 2>/dev/null || echo 'Available via npm')"
echo "💡 Additional development tools will be installed via setup:devtools script"

echo "✅ DevContainer setup completed!"