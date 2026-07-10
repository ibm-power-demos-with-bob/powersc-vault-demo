# AIX Terminal Copy/Paste Tips

## Problem
Copy/paste into AIX terminals can be problematic, especially with large scripts or multi-line content.

## Solutions

### Option 1: Use SCP/SFTP (Recommended)
Transfer files directly instead of copy/paste:

```bash
# From Windows to RHEL
scp generate-old-certificates.sh cecuser@<VAULT_HOST>:/home/cecuser/

# From RHEL to AIX
scp generate-old-certificates.sh cecuser@<AIX_HOST>:/home/cecuser/
```

### Option 2: Use `cat` with Here Document
If you must paste, use this method:

```bash
# On AIX, create file with cat
cat > generate-old-certificates.sh << 'EOF'
# Paste your script content here
# Press Enter after pasting
EOF

# Make executable
chmod +x generate-old-certificates.sh
```

### Option 3: Use `vi` or `nano` Line-by-Line
For smaller edits:

```bash
vi generate-old-certificates.sh
# Press 'i' for insert mode
# Paste content (may need to paste in chunks)
# Press ESC, then :wq to save
```

### Option 4: Disable Terminal Flow Control
Sometimes Ctrl+S/Ctrl+Q interfere with paste:

```bash
# Disable flow control
stty -ixon

# Now try pasting
```

### Option 5: Use Base64 Encoding (For Large Files)
Encode on source, decode on target:

```bash
# On Windows/RHEL - encode the file
base64 generate-old-certificates.sh > script.b64

# Copy the base64 text (smaller, single line)
# On AIX - decode
base64 -d > generate-old-certificates.sh
# Paste the base64 text, press Ctrl+D
```

### Option 6: HTTP Transfer (If Available)
```bash
# On source machine, serve file
python3 -m http.server 8000

# On AIX, download
curl http://<VAULT_HOST>:8000/generate-old-certificates.sh -o generate-old-certificates.sh
```

## Best Practice for This Demo
**Use SCP** - it's the most reliable method for transferring scripts between systems.

## Terminal Settings
Some terminal emulators work better than others:
- **PuTTY**: Right-click to paste, but may have line length limits
- **MobaXterm**: Better paste support, has built-in SCP
- **Windows Terminal**: Good paste support with Ctrl+Shift+V
- **VSCode Terminal**: Can use Ctrl+V, but may need adjustment

## Quick Reference
```bash
# Password for all systems
8-P5VO+NT3UR5!g

# RHEL IP
<VAULT_HOST>

# AIX IP  
<AIX_HOST>

# Transfer script
scp generate-old-certificates.sh cecuser@<AIX_HOST>:/home/cecuser/
