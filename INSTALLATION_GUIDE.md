# CAS Protocol Verification - Installation Guide

> **⚠️ Heads Up!**  
> This guide is tailored for **Ubuntu/Debian-based Linux** (Ubuntu 18.04+, Debian 10+).  
> Our scripts rely on `apt-get`, so if you're rocking CentOS, Fedora, or another distro, you'll need to install dependencies manually. Don't worry though—it's still straightforward!

##  Quick Start (Two Steps)

### Step 1: Install Dependencies

Fire up the automated installation script:

```bash
chmod +x install_dependencies.sh
./install_dependencies.sh
```

Sit back and relax while it installs:
- ✅ **Maude** - The symbolic execution engine Tamarin needs
- ✅ **Tamarin Prover** - Your formal verification powerhouse
- ✅ **GraphViz** - Optional eye candy for visualizing attack traces

### Step 2: Run Verification

Once everything's installed, you're ready to roll:

```bash
chmod +x verify_all.sh
./verify_all.sh
```

That's it! Grab a coffee ☕ while it verifies all 20 security properties. Results land in `verification_output/`.

---

## 📖 Want the Full Story?

Check out **README.md** for:
- Detailed manual installation (for the hands-on folks)
- Advanced verification techniques  
- Deep dive into security properties
- How to generate those cool attack traces

---

**Questions? Ideas? Found a attack?**  
Reach out anytime: cailiuj@163.com, 080lusiqi@sina.com  
We'd love to hear from you!
