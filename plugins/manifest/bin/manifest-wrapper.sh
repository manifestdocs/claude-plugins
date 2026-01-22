#!/bin/bash
# Manifest wrapper - delegates to system-installed manifest binary
# Prompts for Homebrew installation if not found

set -e

# Check for system-installed manifest (via Homebrew or other package manager)
if command -v manifest &> /dev/null; then
    exec manifest "$@"
fi

# manifest not found - prompt user to install via Homebrew
cat >&2 << 'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Manifest server not found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Install via Homebrew:

    brew tap rocket-tycoon/tap
    brew install manifest

  Then restart Claude Code.

  For other installation methods, see:
  https://github.com/rocket-tycoon/manifest#installation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

exit 1
