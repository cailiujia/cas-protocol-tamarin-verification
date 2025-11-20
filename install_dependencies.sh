#!/bin/bash
# Dependency installation script for CAS Protocol Verification
# Installs Maude and Tamarin Prover required for running verify_all.sh
# Usage: ./install_dependencies.sh

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TAMARIN_ARCHIVE="tamarin-prover-1.10.0-linux64-ubuntu.tar.gz"
TAMARIN_URL="https://github.com/tamarin-prover/tamarin-prover/releases/download/1.10.0/tamarin-prover-1.10.0-linux64-ubuntu.tar.gz"

echo "========================================"
echo "CAS Dependencies Installation Script"
echo "========================================"
echo ""
echo "This script will install:"
echo "  1. Maude (required by Tamarin)"
echo "  2. Tamarin Prover"
echo "  3. GraphViz (optional, for visualization)"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${YELLOW}Warning: Running as root. This is not recommended.${NC}"
    echo "Press Ctrl+C to cancel, or Enter to continue..."
    read
fi

# ===== INSTALL MAUDE =====
echo -e "${BLUE}[Step 1/3] Installing Maude...${NC}"
echo ""

if command -v maude &> /dev/null; then
    MAUDE_VERSION=$(maude --version 2>&1 | grep -oP "Version \K[0-9.]+" || echo "unknown")
    echo -e "${GREEN}✓ Maude already installed: Version $MAUDE_VERSION${NC}"
else
    echo "Installing Maude via apt-get..."
    sudo apt-get update
    sudo apt-get install -y maude
    
    if command -v maude &> /dev/null; then
        echo -e "${GREEN}✓ Maude installed successfully${NC}"
        maude --version
    else
        echo -e "${RED}✗ Failed to install Maude${NC}"
        echo "Please install manually: sudo apt-get install maude"
        exit 1
    fi
fi

echo ""

# ===== INSTALL TAMARIN PROVER =====
echo -e "${BLUE}[Step 2/3] Installing Tamarin Prover...${NC}"
echo ""

if command -v tamarin-prover &> /dev/null; then
    TAMARIN_VERSION=$(tamarin-prover --version 2>&1 | head -n 1)
    echo -e "${GREEN}✓ Tamarin Prover already installed: $TAMARIN_VERSION${NC}"
else
    echo "Tamarin Prover not found. Installing..."
    echo ""
    
    # Check if archive exists locally first
    if [ -f "$TAMARIN_ARCHIVE" ]; then
        echo -e "${GREEN}✓ Found local archive: $TAMARIN_ARCHIVE${NC}"
        echo "Using local file instead of downloading..."
    else
        echo "Local archive not found. Downloading Tamarin Prover binary..."
        wget -q --show-progress "$TAMARIN_URL" || {
            echo -e "${RED}✗ Failed to download Tamarin Prover${NC}"
            echo "Please download manually from: $TAMARIN_URL"
            echo "And place it in the current directory as: $TAMARIN_ARCHIVE"
            exit 1
        }
        echo -e "${GREEN}✓ Download completed${NC}"
    fi
    
    echo ""
    echo "Extracting archive..."
    tar -xzf "$TAMARIN_ARCHIVE" || {
        echo -e "${RED}✗ Failed to extract archive${NC}"
        exit 1
    }
    
    echo "Installing system dependencies..."
    sudo apt-get install -y libgmp-dev libreadline-dev || {
        echo -e "${YELLOW}⚠ Warning: Failed to install some dependencies${NC}"
    }
    
    echo "Copying Tamarin binary to /usr/local/bin/..."
    sudo cp -r tamarin-prover /usr/local/bin/
    sudo chmod +x /usr/local/bin/tamarin-prover
    
    # Verify installation
    if command -v tamarin-prover &> /dev/null; then
        echo -e "${GREEN}✓ Tamarin Prover installed successfully${NC}"
        tamarin-prover --version
    else
        echo -e "${RED}✗ Failed to install Tamarin Prover${NC}"
        echo "Binary copied but not found in PATH"
        exit 1
    fi
fi

echo ""

# ===== INSTALL GRAPHVIZ (Optional) =====
echo -e "${BLUE}[Step 3/3] Installing GraphViz (optional)...${NC}"
echo ""

if command -v dot &> /dev/null; then
    DOT_VERSION=$(dot -V 2>&1 | grep -oP "version \K[0-9.]+" || echo "unknown")
    echo -e "${GREEN}✓ GraphViz already installed: Version $DOT_VERSION${NC}"
else
    echo "Installing GraphViz..."
    sudo apt-get install -y graphviz
    
    if command -v dot &> /dev/null; then
        echo -e "${GREEN}✓ GraphViz installed successfully${NC}"
    else
        echo -e "${YELLOW}⚠ GraphViz installation failed (optional, can skip)${NC}"
    fi
fi

echo ""
echo "========================================"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo "========================================"
echo ""
echo "Installed components:"
echo ""

# Summary
if command -v maude &> /dev/null; then
    MAUDE_VERSION=$(maude --version 2>&1 | grep -oP "Version \K[0-9.]+" || echo "unknown")
    echo -e "  ${GREEN}✓${NC} Maude: Version $MAUDE_VERSION"
else
    echo -e "  ${RED}✗${NC} Maude: Not installed"
fi

if command -v tamarin-prover &> /dev/null; then
    TAMARIN_VERSION=$(tamarin-prover --version 2>&1 | head -n 1)
    echo -e "  ${GREEN}✓${NC} Tamarin Prover: $TAMARIN_VERSION"
else
    echo -e "  ${RED}✗${NC} Tamarin Prover: Not installed"
fi

if command -v dot &> /dev/null; then
    DOT_VERSION=$(dot -V 2>&1 | grep -oP "version \K[0-9.]+" || echo "unknown")
    echo -e "  ${GREEN}✓${NC} GraphViz: Version $DOT_VERSION"
else
    echo -e "  ${YELLOW}⚠${NC}  GraphViz: Not installed (optional)"
fi

echo ""
echo "You can now run the verification script:"
echo "  ./verify_all.sh"
echo ""
