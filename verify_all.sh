#!/bin/bash
# Automated verification script for all CAS security properties
# Usage: ./verify_all.sh

set -e  # Exit on error

THEORY_FILE="CAS_SSO.spthy"
OUTPUT_DIR="verification_output"
TAMARIN_ARCHIVE="tamarin-prover-1.10.0-linux64-ubuntu.tar.gz"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "CAS Protocol Verification Script"
echo "========================================"
echo ""

# ===== ENVIRONMENT CHECKS =====
echo "🔍 Checking dependencies..."
echo ""

DEPENDENCIES_OK=true

# Check 1: Tamarin Prover
echo -n "  [1/4] Tamarin Prover... "
if command -v tamarin-prover &> /dev/null; then
    TAMARIN_VERSION=$(tamarin-prover --version 2>&1 | head -n 1 || echo "unknown")
    echo -e "${GREEN}✓${NC} Found: $TAMARIN_VERSION"
else
    echo -e "${RED}✗${NC} Not found"
    DEPENDENCIES_OK=false
    MISSING_TAMARIN=true
fi

# Check 2: Maude (required by Tamarin)
echo -n "  [2/4] Maude... "
if command -v maude &> /dev/null; then
    MAUDE_VERSION=$(maude --version 2>&1 | grep -oP "Version \K[0-9.]+" || echo "unknown")
    echo -e "${GREEN}✓${NC} Found: Version $MAUDE_VERSION"
else
    echo -e "${RED}✗${NC} Not found"
    DEPENDENCIES_OK=false
    MISSING_MAUDE=true
fi

# Check 3: GraphViz (for visualization)
echo -n "  [3/4] GraphViz (dot)... "
if command -v dot &> /dev/null; then
    DOT_VERSION=$(dot -V 2>&1 | grep -oP "version \K[0-9.]+" || echo "unknown")
    echo -e "${GREEN}✓${NC} Found: Version $DOT_VERSION"
else
    echo -e "${YELLOW}⚠${NC}  Not found (optional, for graph visualization)"
fi

# Check 4: Theory file exists
echo -n "  [4/4] Theory file ($THEORY_FILE)... "
if [ -f "$THEORY_FILE" ]; then
    echo -e "${GREEN}✓${NC} Found"
else
    echo -e "${RED}✗${NC} Not found"
    echo ""
    echo -e "${RED}ERROR: Theory file '$THEORY_FILE' not found in current directory!${NC}"
    echo "Please run this script from the CAS directory."
    exit 1
fi

echo ""

# ===== HANDLE MISSING DEPENDENCIES =====
if [ "$DEPENDENCIES_OK" = false ]; then
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}❌ MISSING DEPENDENCIES DETECTED${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}⚡ Quick Install:${NC}"
    echo ""
    echo "  Run the automated installation script:"
    echo -e "    ${GREEN}./install_dependencies.sh${NC}"
    echo ""
    echo "  This script will automatically install:"
    echo "    • Maude (required)"
    echo "    • Tamarin Prover (required)"
    echo "    • GraphViz (optional)"
    echo ""
    echo "=========================================="
    echo ""
    
    if [ "$MISSING_TAMARIN" = true ]; then
        echo -e "${YELLOW}📦 Tamarin Prover is NOT installed${NC}"
        echo ""
        echo "Manual Installation Options:"
        echo ""
        echo "Option A: Install from pre-built binary (Recommended)"
        echo "  1. Download the archive:"
        echo "     wget https://github.com/tamarin-prover/tamarin-prover/releases/download/1.10.0/tamarin-prover-1.10.0-linux64-ubuntu.tar.gz"
        echo ""
        echo "  2. Extract the archive:"
        echo "     tar -xzf tamarin-prover-1.10.0-linux64-ubuntu.tar.gz"
        echo ""
        echo "  3. Install system dependencies (if needed):"
        echo "     sudo apt-get install libgmp-dev libreadline-dev"
        echo ""
        echo "  4. Copy binary to system path:"
        echo "     sudo cp -r tamarin-prover /usr/local/bin/"
        echo "     sudo chmod +x /usr/local/bin/tamarin-prover"
        echo ""
        echo "  5. Verify installation:"
        echo "     tamarin-prover --version"
        echo ""
        echo "Option B: Install via package manager"
        echo "  Homebrew (macOS/Linux):"
        echo "    brew install tamarin-prover/tap/tamarin-prover"
        echo ""
        echo "  Arch Linux:"
        echo "    pacman -S tamarin-prover"
        echo ""
        echo "  Nixpkgs:"
        echo "    nix-env -i tamarin-prover"
        echo ""
        echo "Option C: Build from source (Advanced)"
        echo "  See: https://tamarin-prover.github.io/manual/book/002_installation.html"
        echo ""
        
        # Check if archive exists in current directory
        if [ -f "$TAMARIN_ARCHIVE" ]; then
            echo -e "${GREEN}✓ Found $TAMARIN_ARCHIVE in current directory!${NC}"
            echo ""
            echo "Quick install (run these commands):"
            echo "  tar -xzf $TAMARIN_ARCHIVE"
            echo "  sudo apt-get install libgmp-dev libreadline-dev"
            echo "  sudo cp -r tamarin-prover /usr/local/bin/"
            echo "  sudo chmod +x /usr/local/bin/tamarin-prover"
            echo "  tamarin-prover --version"
            echo ""
        fi
    fi
    
    if [ "$MISSING_MAUDE" = true ]; then
        echo -e "${YELLOW}📦 Maude is NOT installed${NC}"
        echo ""
        echo "Maude is REQUIRED by Tamarin Prover for symbolic execution."
        echo ""
        echo "Installation:"
        echo "  Ubuntu/Debian:"
        echo "    sudo apt-get update"
        echo "    sudo apt-get install maude"
        echo ""
        echo "  From source:"
        echo "    wget http://maude.cs.illinois.edu/w/images/d/d7/Maude-3.1-linux.zip"
        echo "    unzip Maude-3.1-linux.zip"
        echo "    sudo mv maude.linux64 /usr/local/bin/maude"
        echo "    sudo chmod +x /usr/local/bin/maude"
        echo ""
        echo "  Test installation:"
        echo "    maude --version"
        echo ""
    fi
    
    echo -e "${RED}========================================${NC}"
    echo -e "${YELLOW}Please install missing dependencies and run this script again.${NC}"
    echo ""
    echo -e "Recommended: ${GREEN}./install_dependencies.sh${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All dependencies satisfied!${NC}"
echo ""

# Create output directory
mkdir -p $OUTPUT_DIR

# List of all 20 lemmas to verify
lemmas=(
    "None_compromise_security_password"
    "None_compromise_security_jesssionID"
    "None_compromise_security_ST"
    "None_compromise_security_tgt"
    "None_compromise_security_source"
    "None_compromise_injective_agree_ST"
    "None_compromise_injective_agree_TGT"
    "None_compromise_injective_agree_JID"
    "None_compromise_injective_agree_source"
    "None_compromise_SP_authentication"
    "SP_compromise_security_password"
    "SP_compromise_security_jesssionID"
    "SP_compromise_security_ST"
    "SP_compromise_security_TGT"
    "SP_compromise_security_Source"
    "SP_compromise_injective_agree_ST"
    "SP_compromise_injective_agree_TGT"
    "SP_compromise_injective_agree_JID"
    "SP_compromise_injective_agree_source"
    "SP_compromise_SP_authentication"
)

echo "========================================"
echo "Starting CAS Protocol Verification"
echo "Total lemmas: ${#lemmas[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "========================================"
echo ""

# Verify each lemma and save results
for lemma in "${lemmas[@]}"; do
    echo "[$(date +%H:%M:%S)] Verifying: $lemma"
    tamarin-prover --prove=$lemma $THEORY_FILE > "$OUTPUT_DIR/${lemma}_proof.spthy" 2>&1
    
    # Check if verification succeeded
    if grep -q "verified" "$OUTPUT_DIR/${lemma}_proof.spthy"; then
        echo -e "  ${GREEN}✅ VERIFIED${NC}"
    elif grep -q "falsified" "$OUTPUT_DIR/${lemma}_proof.spthy"; then
        echo -e "  ${RED}❌ FALSIFIED${NC}"
    else
        echo -e "  ${YELLOW}⚠️  UNKNOWN${NC}"
    fi
done

echo ""
echo "========================================"
echo "All verifications complete!"
echo "Results saved to: $OUTPUT_DIR/"
echo "========================================"
