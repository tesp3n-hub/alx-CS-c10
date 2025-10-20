#!/bin/bash

# Fix Broken Shell Script - Restores system to working state
# Run this script if the practice shell setup broke your terminal

set -e

# Setup logging
LOG_DIR="/var/log"
LOG_FILE="${LOG_DIR}/shell-fix-$(date +%Y%m%d_%H%M%S).log"

# Create log file
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/shell-fix-$(date +%Y%m%d_%H%M%S).log"
chmod 644 "$LOG_FILE"

# Logging functions
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] $1" | tee -a "$LOG_FILE"
}

print_message() {
    log_message "\033[1;32m$1\033[0m"
}

log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ERROR: $1" | tee -a "$LOG_FILE" >&2
}

handle_error() {
    log_error "$1"
    log_message "Fix script failed. See log file: $LOG_FILE"
    exit 1
}

# Start
print_message "=========================================="
print_message "Shell Fix Script Started"
print_message "Log file: $LOG_FILE"
print_message "=========================================="

# Get the username
SUDO_USER="${SUDO_USER:-$(whoami)}"
log_message "Target user: $SUDO_USER"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    handle_error "Please run this script as root (sudo ./fix-shell.sh)"
fi

# Step 1: Reset user's default shell to bash
print_message "Step 1: Resetting default shell to /bin/bash..."
log_message "Running: chsh -s /bin/bash $SUDO_USER"
chsh -s /bin/bash "$SUDO_USER" >> "$LOG_FILE" 2>&1 || handle_error "Failed to change shell back to bash"
log_message "Default shell reset to bash successfully"

# Step 2: Verify the change
print_message "Step 2: Verifying shell change..."
CURRENT_SHELL=$(grep "^$SUDO_USER:" /etc/passwd | cut -d: -f7)
log_message "Current shell for $SUDO_USER: $CURRENT_SHELL"
if [ "$CURRENT_SHELL" != "/bin/bash" ]; then
    handle_error "Shell verification failed - shell is still $CURRENT_SHELL"
fi
print_message "✓ Shell verified as /bin/bash"

# Step 3: Create safe alias for practice shell
print_message "Step 3: Creating safe alias for practice shell..."
log_message "Adding 'prac' alias to ~/.bashrc"

# Check if bashrc exists
if [ ! -f "/home/$SUDO_USER/.bashrc" ]; then
    log_message "Creating ~/.bashrc for user $SUDO_USER"
    touch "/home/$SUDO_USER/.bashrc"
fi

# Add alias if it doesn't exist
if ! grep -q "alias prac=" "/home/$SUDO_USER/.bashrc"; then
    cat >> "/home/$SUDO_USER/.bashrc" << 'EOF'

# Practice Shell Alias (Added by fix-shell script)
alias prac='rlwrap --no-warnings -f /usr/local/bin/training_shell_completion /usr/local/bin/training_shell'
alias prac-help='echo "Usage: prac - Starts the practice shell. Type help once inside for commands."'
EOF
    log_message "Alias 'prac' added to ~/.bashrc"
else
    log_message "Alias 'prac' already exists in ~/.bashrc"
fi

# Fix ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.bashrc" >> "$LOG_FILE" 2>&1
log_message "Fixed bashrc ownership"

# Step 4: Remove practice shell from /etc/shells (optional but safe)
print_message "Step 4: Cleaning up /etc/shells..."
log_message "Removing prac_shell_wrapper from /etc/shells"
if grep -q "prac_shell_wrapper" /etc/shells; then
    sed -i '/prac_shell_wrapper/d' /etc/shells >> "$LOG_FILE" 2>&1
    log_message "prac_shell_wrapper removed from /etc/shells"
else
    log_message "prac_shell_wrapper not found in /etc/shells"
fi

# Step 5: Verify practice shell files exist
print_message "Step 5: Verifying practice shell files..."
if [ -f "/usr/local/bin/training_shell" ]; then
    log_message "✓ training_shell found"
    [ -x "/usr/local/bin/training_shell" ] || chmod +x "/usr/local/bin/training_shell"
else
    log_error "Warning: training_shell not found at /usr/local/bin/training_shell"
fi

if [ -f "/usr/local/bin/training_shell_completion" ]; then
    log_message "✓ training_shell_completion found"
else
    log_error "Warning: training_shell_completion not found"
fi

if [ -f "/usr/local/bin/prac_shell_wrapper" ]; then
    log_message "✓ prac_shell_wrapper found"
else
    log_message "prac_shell_wrapper not found (this is okay)"
fi

# Step 6: Verify Docker is working
print_message "Step 6: Verifying Docker installation..."
log_message "Checking Docker status"
if command -v docker &> /dev/null; then
    log_message "✓ Docker command found"
    if docker info >/dev/null 2>&1; then
        log_message "✓ Docker is running"
    else
        log_message "⚠ Docker is installed but not running"
        log_message "To start Docker, run: sudo systemctl start docker"
    fi
else
    log_message "⚠ Docker not found"
fi

# Step 7: Test bashrc
print_message "Step 7: Testing bashrc configuration..."
log_message "Sourcing ~/.bashrc to verify syntax"
su - "$SUDO_USER" -c "source ~/.bashrc && echo 'bashrc is valid'" >> "$LOG_FILE" 2>&1 || handle_error "bashrc has syntax errors"
log_message "✓ bashrc syntax is valid"

# Final summary
print_message "=========================================="
print_message "✓ Fix completed successfully!"
print_message "=========================================="
print_message ""
print_message "What was fixed:"
print_message "  1. Reset your default shell to /bin/bash"
print_message "  2. Created 'prac' alias to safely run practice shell"
print_message "  3. Cleaned up /etc/shells"
print_message "  4. Verified practice shell files"
print_message ""
print_message "Next steps:"
print_message "  1. Log out and log back in (or open a new terminal)"
print_message "  2. Type: prac (to start the practice shell)"
print_message "  3. Type: help (inside prac shell for commands)"
print_message ""
print_message "Log file: $LOG_FILE"
print_message "=========================================="

log_message "Fix script completed successfully"
