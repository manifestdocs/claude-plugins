#!/bin/bash
# RocketIndex wrapper - auto-downloads latest binary
# Self-updating: queries GitHub for latest release

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RKT_BIN="$SCRIPT_DIR/rkt"
REPO="rocket-tycoon/rocket-index"
VERSION_FILE="$SCRIPT_DIR/.version"

# Detect platform
case "$(uname -s)" in
    Darwin)
        case "$(uname -m)" in
            arm64) PLATFORM="aarch64-apple-darwin" ;;
            x86_64) PLATFORM="x86_64-apple-darwin" ;;
            *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
        esac
        ;;
    Linux)
        case "$(uname -m)" in
            x86_64) PLATFORM="x86_64-unknown-linux-gnu" ;;
            aarch64) PLATFORM="aarch64-unknown-linux-gnu" ;;
            *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
        esac
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac

# Get latest version from GitHub API
get_latest_version() {
    if command -v curl &> /dev/null; then
        curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/'
    elif command -v wget &> /dev/null; then
        wget -qO- "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/'
    fi
}

# Get installed version
get_installed_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "none"
    fi
}

# Check if we need to download
NEED_DOWNLOAD=false
INSTALLED_VERSION=$(get_installed_version)

if [ ! -x "$RKT_BIN" ]; then
    NEED_DOWNLOAD=true
    LATEST_VERSION=$(get_latest_version)
else
    # Check for updates (cache check for 24 hours to avoid API rate limits)
    CHECK_FILE="$SCRIPT_DIR/.last_check"
    CURRENT_TIME=$(date +%s)

    if [ -f "$CHECK_FILE" ]; then
        LAST_CHECK=$(cat "$CHECK_FILE")
        TIME_DIFF=$((CURRENT_TIME - LAST_CHECK))
    else
        TIME_DIFF=999999
    fi

    # Check every 24 hours (86400 seconds)
    if [ $TIME_DIFF -gt 86400 ]; then
        LATEST_VERSION=$(get_latest_version)
        echo "$CURRENT_TIME" > "$CHECK_FILE"

        if [ -n "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "$INSTALLED_VERSION" ]; then
            echo "Updating RocketIndex from $INSTALLED_VERSION to $LATEST_VERSION..." >&2
            NEED_DOWNLOAD=true
        fi
    fi
fi

if [ "$NEED_DOWNLOAD" = true ]; then
    if [ -z "$LATEST_VERSION" ]; then
        LATEST_VERSION=$(get_latest_version)
    fi

    if [ -z "$LATEST_VERSION" ]; then
        echo "Error: Could not determine latest version" >&2
        if [ -x "$RKT_BIN" ]; then
            echo "Using existing binary" >&2
        else
            exit 1
        fi
    else
        echo "Downloading RocketIndex $LATEST_VERSION for $PLATFORM..." >&2

        DOWNLOAD_URL="https://github.com/$REPO/releases/download/v${LATEST_VERSION}/rocketindex-v${LATEST_VERSION}-${PLATFORM}.tar.gz"

        # Create temp directory
        TMP_DIR=$(mktemp -d)
        trap "rm -rf $TMP_DIR" EXIT

        # Download and extract
        if command -v curl &> /dev/null; then
            curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/rkt.tar.gz"
        elif command -v wget &> /dev/null; then
            wget -q "$DOWNLOAD_URL" -O "$TMP_DIR/rkt.tar.gz"
        else
            echo "Error: curl or wget required" >&2
            exit 1
        fi

        tar -xzf "$TMP_DIR/rkt.tar.gz" -C "$TMP_DIR"

        # Move binary to plugin bin directory
        mv "$TMP_DIR/rkt" "$RKT_BIN"
        chmod +x "$RKT_BIN"

        # Record installed version
        echo "$LATEST_VERSION" > "$VERSION_FILE"

        echo "RocketIndex $LATEST_VERSION installed successfully" >&2
    fi
fi

# Execute rkt with all arguments
exec "$RKT_BIN" "$@"
