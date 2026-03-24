#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Error: Version argument is required."
  exit 1
fi

# Detect shell profile (macOS uses zsh by default)
detect_profile() {
  if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
    echo "$HOME/.zshrc"
  elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
    # macOS bash uses .bash_profile, not .bashrc
    echo "$HOME/.bash_profile"
  else
    echo "$HOME/.profile"
  fi
}

PROFILE=$(detect_profile)

# Cleanup any previous partial download
rm -rf "emsdk-$1" emcc.zip

# Download
curl -L "https://github.com/emscripten-core/emsdk/archive/refs/tags/$1.zip" -o emcc.zip

# Extract
unzip emcc.zip || { echo "Error: Failed to extract zip file" >&2; exit 1; }

# Install to $HOME/emsdk
rm -rf "$HOME/emsdk"
cp -r "emsdk-$1" "$HOME/emsdk"

# Make emsdk executable (sometimes lost after cp)
chmod +x "$HOME/emsdk/emsdk"

"$HOME/emsdk/emsdk" install "$1"
"$HOME/emsdk/emsdk" activate "$1" > /dev/null

# Add to shell profile (only once)
if ! grep -q '#emcc_setup' "$PROFILE"; then
  {
    echo ''
    echo '#emcc_setup'
    echo 'export PATH="$PATH:$HOME/emsdk"'
    echo 'export PATH="$PATH:$HOME/emsdk/upstream/emscripten"'
    echo "export PATH=\"\$PATH:\$HOME/emsdk/node/20.18.0_64bit/bin\""
  } >> "$PROFILE"
  echo "Added emcc paths to $PROFILE"
fi

# Source the profile in current session
# shellcheck disable=SC1090
source "$PROFILE"

echo "Emscripten $1 installed and activated successfully."
echo "Run 'source $PROFILE' or open a new terminal to use emcc."

# Cleanup
rm -rf emcc.zip "emsdk-$1"
