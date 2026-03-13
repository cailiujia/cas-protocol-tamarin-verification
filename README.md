# CAS Single Sign-On Protocol - Formal Verification

> **⚠️ OS Heads-Up:**  
> This project works best on **Ubuntu/Debian-based Linux** (Ubuntu 18.04+, Debian 10+).  
> Our handy `install_dependencies.sh` script uses `apt-get`. Running CentOS, Fedora, or another flavor? No worries—just follow the manual installation steps below!

This repository contains the formal specification and security analysis of the CAS Single Sign-On protocol. The verification was carried out using the Tamarin prover, a tool for the symbolic analysis of security protocols. Our analysis follows a systematic workflow, depicted in the diagram below: 
<img width="5369" height="1319" alt="Tamarin" src="https://github.com/user-attachments/assets/ebf901d8-726b-4893-9ea3-8ff78db6c8d9" />
*Figure 1: The iterative workflow of formal verification with Tamarin.*

We found some interesting attacks—keep reading!

## 📖 Reference

**Paper**: *Trust Erosion Attack in Zero-Trust: Formal Verification of the CAS Protocol under Component Compromise*

## 📁 Repository Structure

```
CAS/
├── README.md                      # This file
├── CAS_SSO.spthy                  # Tamarin model
├── install_dependencies.sh        # Automated dependency installation ⭐
├── verify_all.sh                  # Automated verification script ⭐
├── result/                        # All attack traces (all solutions mode)
│   ├── README.md
│   └── [verification results]
└── resultsam/                     # Sample traces (single path mode)
    ├── README.md
    └── [verification results]
```

## 🔧 Prerequisites

### Quick Installation (The Easy Way!)

We've got you covered with an automated script that does all the heavy lifting:

```bash
chmod +x install_dependencies.sh
./install_dependencies.sh
```

This little helper installs:
- ✅ Maude (Tamarin's brain for symbolic execution)
- ✅ Tamarin Prover (the star of the show)
- ✅ GraphViz (optional, but makes pretty pictures)

**What it does:**
1. Checks what's already installed
2. Grabs Maude via apt-get
3. Downloads and sets up Tamarin Prover
4. Adds GraphViz for those visualization needs
5. Double-checks everything works

After running this script, you can directly run `./verify_all.sh` for verification.

---

### Manual Installation

If you prefer to install dependencies manually:

The `verify_all.sh` script will automatically check for these dependencies:

### Required Dependencies

#### 1. Maude (version 3.0+)

**Required by Tamarin for symbolic execution** - Critical dependency (Tamarin will not work without it)

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install maude

# Verify installation
maude --version
```

#### 2. Tamarin Prover (version 1.6.1+, tested with 1.8.0 and 1.10.0)

**Core formal verification tool**

**Option A: Install from pre-built binary (Recommended)**

If you have `tamarin-prover-1.10.0-linux64-ubuntu.tar.gz`:

```bash
# Extract the archive
tar -xzf tamarin-prover-1.10.0-linux64-ubuntu.tar.gz

# Install system dependencies (if needed)
sudo apt-get install libgmp-dev libreadline-dev

# Copy binary to system path
sudo cp -r tamarin-prover /usr/local/bin/
sudo chmod +x /usr/local/bin/tamarin-prover

# Verify installation
tamarin-prover --version
```

Or download directly:

```bash
wget https://github.com/tamarin-prover/tamarin-prover/releases/download/1.10.0/tamarin-prover-1.10.0-linux64-ubuntu.tar.gz
tar -xzf tamarin-prover-1.10.0-linux64-ubuntu.tar.gz
sudo cp -r tamarin-prover /usr/local/bin/
sudo chmod +x /usr/local/bin/tamarin-prover
tamarin-prover --version
```

**Option B: Install via package manager**

```bash
# Homebrew (macOS/Linux)
brew install tamarin-prover/tap/tamarin-prover

# Arch Linux
pacman -S tamarin-prover

# Nixpkgs
nix-env -i tamarin-prover

# NixOS (add to environment.systemPackages)
tamarin-prover
```

**Option C: Build from source**

See: https://tamarin-prover.github.io/manual/book/002_installation.html

### Optional Dependencies

#### 3. GraphViz (for visualization)

```bash
sudo apt-get install graphviz
```

Not required for verification, but useful for visualizing attack traces.

##  Quick Start

### Option 1: Automated Verification (Recommended)

The `verify_all.sh` script automatically:
- ✅ Checks all dependencies (Tamarin, Maude, GraphViz)
- ✅ Provides installation instructions if dependencies are missing
- ✅ Verifies all 20 security properties
- ✅ Saves detailed results to `verification_output/` directory (as `*_proof.spthy` files)
- ✅ Shows real-time progress with colored status indicators

**Usage:**

```bash
chmod +x verify_all.sh
./verify_all.sh
```

**Expected runtime:** ~18-20 minutes for all 20 lemmas

**Verify only falsified lemmas:**

Edit `verify_all.sh` and modify the `lemmas` array:

```bash
lemmas=(
    "None_compromise_security_jesssionID"
    "None_compromise_security_source"
    "SP_compromise_security_password"
    "SP_compromise_security_jesssionID"
    "SP_compromise_security_Source"
    "SP_compromise_SP_authentication"
)
```

Then run:
```bash
./verify_all.sh
```

### Option 2: Manual Verification (Command Line)

**Verify everything at once:**
```bash
tamarin-prover --prove CAS_SSO.spthy
```

**Check just one property:**
```bash
tamarin-prover --prove=SP_compromise_SP_authentication CAS_SSO.spthy
```

**Verify and save the proof:**
```bash
tamarin-prover --prove=SP_compromise_SP_authentication CAS_SSO.spthy \
    > SP_compromise_SP_authentication_proof.spthy
```

**Advanced verification options:**
```bash
# Generate .dot file for graph visualization
tamarin-prover --prove=SP_compromise_SP_authentication \
    --output-dot=SP_compromise_SP_authentication.dot CAS_SSO.spthy

# Convert .dot to PNG using GraphViz
dot -Tpng SP_compromise_SP_authentication.dot -o SP_compromise_SP_authentication.png
```

### Option 3: Interactive Mode (Pretty GUI Edition)

Fire up the web interface:

```bash
tamarin-prover interactive CAS_SSO.spthy
```

Then point your browser to: `http://localhost:3001`

Perfect for exploring attack traces and generating those files in `result/` and `resultsam/`!



## 📊 Verification Results Summary

### Threat Models

The protocol is analyzed under two threat models:

1. **Standard Dolev-Yao Model** (`None_compromise_*`)
   - Network adversary can intercept, modify, and inject messages
   - All protocol participants are honest

2. **Extended Model with Malicious SP** (`SP_compromise_*`)
   - Service Providers can be compromised
   - Models zero-trust scenarios

### Security Properties (20 total)

| # | Property Name | None_compromise | SP_compromise |
|---|---------------|-----------------|---------------|
| 1 | security_password | ✅ Verified (7.77s) | ❌ Falsified |
| 2 | security_jesssionID | ❌ Falsified | ❌ Falsified |
| 3 | security_ST | ✅ Verified (9.72s) | ✅ Verified (10.66s) |
| 4 | security_tgt | ✅ Verified (7.81s) | ✅ Verified (8.14s) |
| 5 | security_source | ❌ Falsified | ❌ Falsified |
| 6 | injective_agree_ST | ✅ Verified (6.20s) | ✅ Verified (7.17s) |
| 7 | injective_agree_TGT | ✅ Verified (6.24s) | ✅ Verified (7.42s) |
| 8 | injective_agree_JID | ✅ Verified (11.58s) | ✅ Verified (20.26s) |
| 9 | injective_agree_source | ✅ Verified (32.16s) | ✅ Verified (44.05s) |
| 10 | SP_authentication | ✅ Verified (20.44s) | ❌ **Falsified (Trust Erosion Attack)** ⚠️ |

**Key Findings:**

- ✅ **14 properties verified** under standard model
- ❌ **6 properties falsified** (4 in both models, 2 additional in SP compromise)
- ⚠️ **Critical vulnerability**: Trust Erosion Attack in zero-trust deployments

### Falsified Properties (Attack Scenarios)

| Property | Attack Description | Impact |
|----------|-------------------|---------|
| `None_compromise_security_jesssionID` | Session hijacking via network interception | Medium |
| `None_compromise_security_source` | Unauthorized resource access | Medium |
| `SP_compromise_security_password` | Malicious SP extracts user passwords | **High** |
| `SP_compromise_security_jesssionID` | Malicious SP session forgery | High |
| `SP_compromise_security_Source` | Malicious SP resource manipulation | Medium |
| `SP_compromise_SP_authentication` | **Trust Erosion Attack** ⭐ | **Critical** |

### Trust Erosion Attack (Critical Finding)

**Property:** `SP_compromise_SP_authentication`

**What's happening:** A compromised Service Provider can covertly redirect users who are attempting to access it to other Service Providers without their knowledge.

<img width="4206" height="3175" alt="CASattack6" src="https://github.com/user-attachments/assets/3ffd9394-dce8-4e57-8141-fd57fed021b8" />

**Attack Scenarios:**

1. **Low-value to High-value Service Escalation**
   - User intends to request low-value services from a malicious SP
   - Gets deceived into requesting services from a high-value SP instead
   - The zero-trust TA algorithm detects this unauthorized access escalation and dynamically downgrades the user's trust value
    
2. **Low-risk to High-risk System Operation**
   - User sends operation commands to a low-risk system (compromised as malicious SP)
   - Gets deceived into sending these operations to a high-risk system
   - Operations that are harmless in low-risk system may have severe consequences in high-risk system

**Why this matters:** 
- One bad apple (compromised SP) can fool users into accessing other SPs
- Trust silently erodes—users won't even realize they've been redirected
- Ripple effect across the whole SSO ecosystem
- We caught it in a 26-step attack trace (check out `result/SP_compromise_SP_authentication_case_1.png`)

## 📂 Result Folders

### `result/` - Every Possible Attack Path

Contains **ALL possible attack paths** for each falsified lemma.

- Generated using Tamarin's interactive mode with **"all solutions"** strategy
- Complete attack space enumeration
- Useful for comprehensive security analysis

**How to generate:**
1. Start interactive mode: `tamarin-prover interactive CAS_SSO.spthy`
2. Open browser to `http://localhost:3001`
3. Navigate: Click "CAS" → Select lemma → Click "sorry"
4. Click **"for all solutions"** button
5. Save generated traces to `result/` folder

### `resultsam/` - Sample Attack Traces

Contains **ONE representative trace** for each lemma (verified or falsified).

- Generated using **"dfs"** or **"sorry"** strategy
- Quick reference for demonstrations
- Faster to generate than full attack space

**How to generate:**
1. Start interactive mode: `tamarin-prover interactive CAS_SSO.spthy`
2. Open browser to `http://localhost:3001`
3. Navigate: Click "CAS" → Select lemma → Click "sorry"
4. Click **"autoprove"** button
5. Save generated trace to `resultsam/` folder


## 🔗 Useful Links

- **Tamarin Prover**: https://tamarin-prover.github.io/
- **Tamarin Manual**: https://tamarin-prover.github.io/manual/
- **Maude System**: http://maude.cs.illinois.edu/
- **CAS Protocol Specification**: https://apereo.github.io/cas/

## 👥 Get In Touch

Need help?

- **Liujia Cai**: cailiuj@163.com
- **Siqi Lu**: 080lusiqi@sina.com

  Let's explore Tamarin together!
---

**Last Updated:** 2025-11-19  
**Tamarin Version:** 1.10.0  
