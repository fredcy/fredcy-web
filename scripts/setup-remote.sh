#!/bin/bash
# Setup script for Claude Code remote (web) sessions.
# Installs Hugo and initializes the theme submodule.

# Only run in remote environments
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi

# Install Hugo if not already present
if ! command -v hugo &> /dev/null; then
  HUGO_VERSION="0.142.0"
  wget -q "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" \
    -O /tmp/hugo.deb && sudo dpkg -i /tmp/hugo.deb && rm /tmp/hugo.deb
fi

# Initialize theme submodule
git submodule update --init
