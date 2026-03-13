#!/usr/bin/env bash
#
# init-project.sh — Scaffold a new academic writing project
#
# Usage:
#   ./init-project.sh <project-directory> [project-name] [--outline path/to/outline.md]
#
# Creates the directory structure, copies templates, and optionally
# auto-generates section state files from an existing outline.

set -euo pipefail

# --- Argument parsing ---

OUTLINE_PATH=""
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --outline)
            OUTLINE_PATH="$2"
            shift 2
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

if [ ${#POSITIONAL_ARGS[@]} -lt 1 ]; then
    echo "Usage: $0 <project-directory> [project-name] [--outline path/to/outline.md]"
    echo ""
    echo "  project-directory  Path where the project will be created"
    echo "  project-name       Human-readable name (optional, defaults to directory name)"
    echo "  --outline FILE     Path to existing outline; generates section state files"
    exit 1
fi

PROJECT_DIR="${POSITIONAL_ARGS[0]}"
PROJECT_NAME="${POSITIONAL_ARGS[1]:-$(basename "$PROJECT_DIR")}"

# --- Locate skill root (where templates live) ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$SKILL_ROOT/templates"

if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "Error: Templates directory not found at $TEMPLATES_DIR"
    echo "Make sure this script is in the skill's scripts/ directory."
    exit 1
fi

# --- Portable sed -i (macOS vs Linux) ---

sed_inplace() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# --- Check if directory already exists ---

if [ -d "$PROJECT_DIR" ] && [ "$(ls -A "$PROJECT_DIR" 2>/dev/null)" ]; then
    echo "Warning: $PROJECT_DIR already exists and is not empty."
    read -p "Continue anyway? Files won't be overwritten. [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# --- Create directory structure ---

echo "Creating project: $PROJECT_NAME"
echo "Location: $PROJECT_DIR"
echo ""

mkdir -p "$PROJECT_DIR"/{drafts,state,references,process,session_transcripts,context}

echo "  Created directories:"
echo "    drafts/              — Section drafts and compiled draft"
echo "    state/               — Per-section state files"
echo "    references/          — Reference notes and extractions"
echo "    process/             — Decision log and process journal"
echo "    session_transcripts/ — Archived session logs"
echo "    context/             — Project-specific context files"
echo ""

# --- Copy templates (don't overwrite existing files) ---

copy_if_missing() {
    local src="$1"
    local dest="$2"
    if [ -f "$dest" ]; then
        echo "  Skipped (exists): $(basename "$dest")"
    else
        cp "$src" "$dest"
        echo "  Created: $(basename "$dest")"
    fi
}

echo "Copying templates:"
copy_if_missing "$TEMPLATES_DIR/project-config.yaml" "$PROJECT_DIR/project-config.yaml"
copy_if_missing "$TEMPLATES_DIR/section-status.md" "$PROJECT_DIR/section-status.md"
copy_if_missing "$TEMPLATES_DIR/decision-log.md" "$PROJECT_DIR/process/decision-log.md"
copy_if_missing "$TEMPLATES_DIR/process-journal.md" "$PROJECT_DIR/process/process-journal.md"
copy_if_missing "$TEMPLATES_DIR/genai-disclosure.md" "$PROJECT_DIR/process/genai-disclosure.md"
echo ""

# --- Inject project name into config ---

if [ -f "$PROJECT_DIR/project-config.yaml" ]; then
    sed_inplace "s/^project_name: \"\"/project_name: \"$PROJECT_NAME\"/" "$PROJECT_DIR/project-config.yaml"
    sed_inplace "s|^working_directory: \"\"|working_directory: \".\"|" "$PROJECT_DIR/project-config.yaml"
fi

# --- Auto-detect platform and set recommended defaults ---

detect_platform() {
    if [ -n "${CLAUDE_CODE_SESSION:-}" ] || [ -d "$HOME/.claude" ]; then
        echo "claude-code"
    elif [ -n "${COWORK_SESSION:-}" ] || [ -d "/sessions" ]; then
        echo "cowork"
    else
        echo "manual"
    fi
}

DETECTED_PLATFORM=$(detect_platform)
if [ -f "$PROJECT_DIR/project-config.yaml" ]; then
    sed_inplace "s/^platform: \"manual\"/platform: \"$DETECTED_PLATFORM\"/" "$PROJECT_DIR/project-config.yaml"
    echo "Detected platform: $DETECTED_PLATFORM"
fi

# --- Auto-generate section state files from outline ---

generate_section_states() {
    local outline_file="$1"
    local state_dir="$2"
    local status_file="$3"
    local section_template="$TEMPLATES_DIR/section-state.md"
    local today
    today=$(date +%Y-%m-%d)

    if [ ! -f "$section_template" ]; then
        echo "  Warning: section-state.md template not found, skipping state generation"
        return
    fi

    echo "Generating section state files from outline:"

    # Extract ## headings from the outline (top-level sections)
    local section_num=0
    local status_entries=""

    while IFS= read -r line; do
        # Match lines starting with ## (but not ### or deeper)
        if [[ "$line" =~ ^##[[:space:]]+ ]] && [[ ! "$line" =~ ^### ]]; then
            local section_name="${line#\#\# }"
            # Clean the section name for use as filename
            local safe_name
            safe_name=$(echo "$section_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

            local state_file="$state_dir/${safe_name}.md"

            if [ ! -f "$state_file" ]; then
                cp "$section_template" "$state_file"
                # Replace placeholder with actual section name
                sed_inplace "s/\[Section Name\]/$section_name/g" "$state_file"
                sed_inplace "s/\[DATE\]/$today/g" "$state_file"
                echo "  Created: state/${safe_name}.md"
            else
                echo "  Skipped (exists): state/${safe_name}.md"
            fi

            # Build status table entry
            status_entries="${status_entries}| ${section_num} | ${section_name} | not-started | | |\n"
            section_num=$((section_num + 1))
        fi
    done < "$outline_file"

    # Update section-status.md with actual sections
    if [ -f "$status_file" ] && [ -n "$status_entries" ]; then
        # Write new status file with actual sections
        cat > "$status_file" << STATUSEOF
# Section Status

Overview of all sections and their current phase. Updated at the end of each session.

## Status Key

| Phase | Meaning |
|-------|---------|
| \`not-started\` | Section exists in outline but work hasn't begun |
| \`orientation\` | Reviewing outline, discussing argument, confirmation bias check |
| \`reference-work\` | Triaging references, reading, extracting, verifying citations |
| \`drafting\` | Writing prose iteratively with author |
| \`integration\` | Approved prose being added to compiled draft, decisions logged |
| \`complete\` | Section finished and integrated |
| \`revision-needed\` | Completed but flagged for revision (from flow review or other feedback) |

---

## Sections

| # | Section | Phase | Last Worked | Notes |
|---|---------|-------|-------------|-------|
$(echo -e "$status_entries")
---

## Flow Review

| Date | Status | Notes |
|------|--------|-------|
| | [not-done / in-progress / complete] | |
STATUSEOF
        echo ""
        echo "  Updated section-status.md with $section_num sections from outline"
    fi
}

# If --outline was provided, copy it and generate state files
if [ -n "$OUTLINE_PATH" ]; then
    if [ ! -f "$OUTLINE_PATH" ]; then
        echo "Error: Outline file not found at $OUTLINE_PATH"
        exit 1
    fi

    # Copy outline to project if not already there
    if [ ! -f "$PROJECT_DIR/outline.md" ]; then
        cp "$OUTLINE_PATH" "$PROJECT_DIR/outline.md"
        echo "Copied outline from: $OUTLINE_PATH"
    fi

    generate_section_states "$PROJECT_DIR/outline.md" "$PROJECT_DIR/state" "$PROJECT_DIR/section-status.md"
    echo ""
else
    # Create placeholder outline
    if [ ! -f "$PROJECT_DIR/outline.md" ]; then
        cat > "$PROJECT_DIR/outline.md" << 'OUTLINE'
# Paper Outline

## Introduction

[Your introduction outline here]

## Section 1: [Title]

[Section outline]

## Section 2: [Title]

[Section outline]

## Conclusion

[Conclusion outline]
OUTLINE
        echo "Created: outline.md (placeholder — replace with your outline)"
        echo ""
        echo "Tip: Re-run with --outline to auto-generate section state files:"
        echo "  $0 $PROJECT_DIR --outline path/to/your/outline.md"
    fi
fi

# Create style guide placeholder
if [ ! -f "$PROJECT_DIR/style-guide.md" ]; then
    cat > "$PROJECT_DIR/style-guide.md" << 'STYLE'
# Style Guide

This file captures your writing voice and preferences. It starts empty and grows as preferences emerge during the drafting process.

## Voice and Tone

[Will be filled in as drafting reveals your preferences]

## Formatting Conventions

[Citation style, heading conventions, etc.]

## Things to Avoid

[Patterns you've flagged during revision — passive voice, hedging, buzzwords, etc.]
STYLE
    echo "Created: style-guide.md (placeholder — builds during drafting)"
fi

echo ""
echo "--- Project scaffolded successfully ---"
echo ""
echo "Your project directory:"
echo ""
echo "  $PROJECT_NAME/"
echo "  ├── project-config.yaml   ← Project settings (edit this first)"
echo "  ├── outline.md             ← Paper outline"
echo "  ├── section-status.md      ← Section progress tracker"
echo "  ├── style-guide.md         ← Writing voice/preferences (grows over time)"
echo "  ├── drafts/                ← Section drafts and compiled draft"
echo "  ├── state/                 ← Per-section state files"
echo "  ├── references/            ← Your reference notes and extractions"
echo "  ├── process/               ← Decision log, process journal, AI disclosure"
echo "  ├── context/               ← Project-specific context files"
echo "  └── session_transcripts/   ← Archived session logs"
echo ""
echo "Next steps:"
echo "  1. Edit project-config.yaml with your project details"
if [ -z "$OUTLINE_PATH" ]; then
    echo "  2. Replace outline.md with your actual paper outline"
    echo "     Then re-run: $0 $PROJECT_DIR --outline $PROJECT_DIR/outline.md"
    echo "  3. Start a session and say: 'Let's work on my paper'"
else
    echo "  2. Start a session and say: 'Let's work on my paper'"
fi
echo "     The skill will find your project-config.yaml automatically."
echo ""
