
#!/usr/bin/env bash

set -e

# ---------------------------------------------------------
# CONFIG
# ---------------------------------------------------------
ADMIN_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0c+TD4tLxuTLDaktGKmF4Ps+Ax8WCTOoZPIPAe6RNd your_email@example.com"

# Automatically detect currently logged-in user
CURRENT_USER="$(whoami)"
HOME_DIR="$HOME"

echo "[*] Current user detected: $CURRENT_USER"
echo "[*] Home directory: $HOME_DIR"

# ---------------------------------------------------------
# UTILITY
# ---------------------------------------------------------
run() {
    echo "[*] $*"
    eval "$@"
}

# ---------------------------------------------------------
# OS DETECTION
# ---------------------------------------------------------
detect_os() {
    local kernel="$(uname -s)"

    case "$kernel" in
        Linux)
            if grep -qi "microsoft" /proc/version 2>/dev/null; then
                echo "WSL"
            else
                echo "Linux"
            fi
            ;;
        Darwin)
            echo "macOS"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "Windows"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# ---------------------------------------------------------
# LINUX / WSL
# ---------------------------------------------------------
setup_linux() {
    echo "== Linux detected =="

    # Install OpenSSH server if missing
    if ! command -v sshd >/dev/null 2>&1; then
        if command -v apt-get >/dev/null 2>&1; then
            run "sudo apt-get update"
            run "sudo apt-get install -y openssh-server"
        elif command -v dnf >/dev/null 2>&1; then
            run "sudo dnf install -y openssh-server"
        elif command -v yum >/dev/null 2>&1; then
            run "sudo yum install -y openssh-server"
        fi
    fi

    # Enable and start SSH
    run "sudo systemctl enable sshd || true"
    run "sudo systemctl start sshd || true"

    setup_ssh_keys
}

# ---------------------------------------------------------
# MACOS
# ---------------------------------------------------------
setup_macos() {
    echo "== macOS detected =="

    # Enable Remote Login
    if command -v systemsetup >/dev/null 2>&1; then
        run "sudo systemsetup -setremotelogin on"
    fi

    setup_ssh_keys
}

# ---------------------------------------------------------
# WINDOWS (Git Bash / MSYS / Cygwin)
# ---------------------------------------------------------
setup_windows() {
    echo "== Windows detected (Git Bash/MSYS/Cygwin) =="

    echo "[!] Note: true Windows service installation requires PowerShell."
    echo "[!] This script will ONLY install your SSH key."

    setup_ssh_keys
}

# ---------------------------------------------------------
# SSH KEY SETUP (common for all OS)
# ---------------------------------------------------------
setup_ssh_keys() {
    local ssh_dir="$HOME_DIR/.ssh"
    local auth_file="$ssh_dir/authorized_keys"

    echo "[*] Installing SSH key for user: $CURRENT_USER"

    mkdir -p "$ssh_dir"
    echo "$ADMIN_PUBKEY" > "$auth_file"

    chmod 700 "$ssh_dir"
    chmod 600 "$auth_file"

    echo "[+] SSH key installed successfully in: $auth_file"
}

# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------
OS="$(detect_os)"
echo "[*] Detected OS: $OS"

case "$OS" in
    Linux|WSL)
        setup_linux
        ;;
    macOS)
        setup_macos
        ;;
    Windows)
        setup_windows
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "[DONE] Universal SSH setup completed."

