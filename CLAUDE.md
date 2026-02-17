# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hugo static site for a personal blog, served at `https://blog.fredcy.com/`. Uses the **Indigo** theme (a forked copy at `github.com/fredcy/indigo`, included as a git submodule).

## Commands

```bash
# Setup (after clone)
# The submodule uses an SSH URL (git@github.com:...). In environments without SSH
# (e.g. Claude Code on the web), switch to HTTPS before initializing:
git config submodule.themes/indigo.url https://github.com/fredcy/indigo.git
git submodule update --init

# Dev server (includes draft posts)
hugo server -D

# Create a new post
hugo new posts/my-page-name.md

# Build and deploy to production
make publish
```

`make publish` cleans `public/`, runs `hugo`, then rsyncs to `repo.fredcy.com:/var/www/fredcy`.

## Architecture

### Content
All blog posts live in `content/posts/` as Markdown files with YAML front matter. Older posts (imported from WordPress) have `url:` overrides and `categories:` in front matter; recent posts use minimal front matter (title, date, draft).

### Theme Customization
The site overrides three theme partials in `layouts/partials/`:

- **head.html** — Adds IndieWeb `rel="me"` links, auth/webmention endpoint `<link>` tags, and conditional loading of `css/custom.css`
- **header.html** — Swaps the theme's SVG site logo for a PNG (`content/images/site-logo.png`)
- **social.html** — Adds an RSS icon link and GitLab support not present in the upstream theme

There are no custom shortcodes or layout overrides beyond these three partials.

### Config
`config.toml` contains all site configuration including social profile links and IndieWeb/Webmention endpoints. Goldmark's `unsafe` renderer is enabled to allow raw HTML in Markdown content.

### Static Assets
- `static/css/custom.css` — minimal custom styling
- `static/icons/rss.png` — RSS icon used by social.html partial
