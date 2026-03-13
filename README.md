# Academic Writing Process Skill

A process enforcement skill for responsible AI-assisted academic writing. Designed for use with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [Cowork](https://claude.ai).

## Quick Start

**1. Install** (Claude Code):
```bash
/plugin install https://github.com/jayweiler/academic-writing-skill
```

**2. Initialize a project:**
```bash
# Find the skill (plugin install puts it in ~/.claude/plugins/<repo-name>/)
~/.claude/plugins/academic-writing-skill/skills/academic-writing/scripts/init-project.sh \
  ~/my-paper "My Paper Title" --outline ~/my-paper/outline.md
```

**3. Add your name** to `my-paper/project-config.yaml`:
```yaml
author: "Your Name"     # only field you need to fill in — init handles the rest
```

**4. Start writing:**
> "Let's work on my paper"

The skill finds your project automatically and walks you through the rest.

## Why This Exists

AI-assisted academic writing introduces risks that aren't obvious until you're deep in the process. An AI assistant can draft fluent prose, summarize literature, and structure arguments — but it does all of this through the lens of its training data, which overrepresents Western, English-language, highly-cited scholarship. It defaults to smooth, consensus-seeking language that can quietly flatten your sharpest arguments. It confirms your framing rather than challenging it. And when context windows compress, editorial agreements made three sessions ago can silently disappear.

These aren't hypothetical concerns. They were documented during the development of this skill, which was built while writing a paper on bias in AI safety measures. The process of writing the paper revealed the need for the tool, and the tool became a contribution of the paper.

The core problem: **without deliberate process enforcement, the convenience of AI assistance systematically degrades the qualities that make academic writing valuable — intellectual rigor, diverse perspectives, distinctive voice, and transparent reasoning.**

This skill doesn't solve that problem completely. What it does is make the risks visible, create structural checkpoints where the author's judgment is required, and maintain an honest record of how the AI was used.

For an honest assessment of where each mitigation is strong and where it falls short, see [EFFECTIVENESS.md](EFFECTIVENESS.md).

## What It Does

The skill enforces a structured, transparent process across the full lifecycle of writing an academic paper with AI assistance. It addresses eight documented risks:

| Risk | What Happens Without Mitigation | How the Skill Responds |
|------|--------------------------------|----------------------|
| **Literature bias** | AI surfaces predominantly Western, English-language, highly-cited work, creating a reference list that reflects training data demographics rather than the field | Representation audits during reference triage, deliberate counter-searches, source diversity as an explicit criterion |
| **Confirmation bias** | AI reinforces the author's existing framing rather than challenging it, producing agreeable drafts that feel productive but aren't rigorous | Mandatory "challenge the framing" step before any drafting begins — the AI must articulate counterarguments before writing supporting prose |
| **Theme downweighting** | AI-assisted drafting smooths nuanced, contested, or provocative arguments toward safer consensus positions | Post-draft comparison against the original outline, checking whether sharp edges survived the drafting process |
| **Language homogenization** | AI defaults to dominant academic English patterns (passive voice, hedging, buzzwords), erasing the author's distinctive voice | Voice calibration against a project style guide that accumulates specific preferences over time |
| **Temporal gaps** | AI training has a knowledge cutoff; recent developments, retractions, or superseding work may be missing | Recency verification for foundational references, flagging potential staleness |
| **Citation bias** | AI preferentially surfaces well-cited sources from high-impact journals, reinforcing existing citation hierarchies | Representation lens during triage that explicitly elevates underrepresented but relevant scholarship |
| **Hallucination** | AI generates plausible but fabricated citations, details, or claims that look authoritative | Independent verification gate — no citation enters a draft without author verification, tiered by reference importance |
| **Context/continuity loss** | During long sessions, the AI quietly summarizes older conversation to free memory — silently dropping your editorial agreements, style corrections, and guardrail rules without warning (see [The Silent Reset Problem](#the-silent-reset-problem-context-compaction)) | Persistent state files that survive resets, mandatory recovery protocol before resuming work, proactive checkpoints, session transcript archival |

## Installation

### Claude Code (Plugin — Recommended)

Install directly from GitHub as a Claude Code plugin:

```bash
/plugin install https://github.com/jayweiler/academic-writing-skill
```

The skill becomes available as `/academic-writing:academic-writing` in any Claude Code session.

### Cowork (Claude Desktop)

Cowork doesn't support plugin install yet, so clone and symlink manually. The skill directory inside the repo is what Cowork needs:

```bash
git clone https://github.com/jayweiler/academic-writing-skill.git \
  ~/path/to/your/working/copy

mkdir -p ~/Documents/Claude/.skills/skills
ln -s ~/path/to/your/working/copy/skills/academic-writing \
  ~/Documents/Claude/.skills/skills/academic-writing
```

The skill will appear in the available skills list on your next session.

### Claude Code (Manual)

If you prefer manual installation over the plugin method:

```bash
git clone https://github.com/jayweiler/academic-writing-skill.git \
  ~/path/to/your/working/copy

mkdir -p ~/.claude/skills
ln -s ~/path/to/your/working/copy/skills/academic-writing \
  ~/.claude/skills/academic-writing
```

### Project-Local Installation

You can also install the skill into a specific project's `.skills/` directory:

```bash
ln -s ~/path/to/your/working/copy/skills/academic-writing \
  /path/to/your/project/.skills/academic-writing
```

### Initialize a New Paper Project

Once installed, scaffold a new paper project using the init script:

```bash
# Find the skill location (depends on install method)
# Plugin install: ~/.claude/plugins/academic-writing-skill/skills/academic-writing/
# Manual install: wherever you cloned/linked it

# Basic setup
path/to/skills/academic-writing/scripts/init-project.sh /path/to/your/paper "My Paper Title"

# With auto-generated section states from an existing outline
path/to/skills/academic-writing/scripts/init-project.sh /path/to/your/paper "My Paper Title" \
  --outline /path/to/outline.md
```

The `--outline` flag parses `## Heading` lines from your outline file and generates per-section state files and a section status tracker automatically.

### Minimum Viable Setup (No Init Script)

If you can't run bash or prefer manual setup, the only file you strictly need is `project-config.yaml`. Create it in your paper's directory with at least these fields:

```yaml
project_name: "My Paper"
author: "Your Name"
working_directory: "."
```

The skill will create missing directories and files as needed during sessions. The init script saves time by scaffolding everything upfront, but it's not required.

## Usage

### How the skill gets invoked

The skill triggers automatically based on what you say. In Cowork, the system matches your request against skill descriptions — phrases like "let's work on my paper," "paper session," "next section," or "resume writing" will load the skill. In Claude Code, the plugin registers as `/academic-writing:academic-writing` and can also be triggered by natural language.

You don't need to remember a command. Just talk about your paper and the skill should load. If it doesn't auto-trigger, you can invoke it explicitly:

- **Cowork:** `/academic-writing`
- **Claude Code (plugin):** `/academic-writing:academic-writing`

### Multiple projects

The skill supports multiple concurrent paper projects. Each project is a separate directory with its own `project-config.yaml`, state files, and decision log.

When you start a session, the skill scans your workspace for `project-config.yaml` files. If it finds one project, it loads automatically. If it finds multiple, it presents a list and asks which one you want to work on. If the skill can tell from context which project you mean (e.g., "let's work on the SFSU paper" when one project is named "Bias in AI Safety Measures"), it'll load that one directly.

Once a project is selected for a session, the skill stays on it unless you say otherwise.

### Returning to a project

One of the skill's key strengths is continuity across sessions. When you come back days or weeks later:

1. The skill loads your section status and tells you where you left off
2. It reads your decision log for open questions or recent editorial choices
3. It loads the current section's state file — which has reference notes, draft status, and open gaps from previous sessions
4. It asks you to confirm before continuing: "We were working on Section 3 in the drafting phase. Pick up here, or work on something else?"

All of this survives between sessions because the skill writes everything to files on disk — not just the AI's memory. Even if you switch between Cowork and Claude Code, or use a different computer, the project state follows you as long as the project directory is accessible.

### What a typical session looks like

1. You say something like "let's do a paper session" or "pick up where we left off on the thesis"
2. The skill loads your project config and section status
3. It tells you where you left off, what the natural next step is, and any open items from the decision log
4. You confirm or redirect, and the phase-gated workflow takes over from there

The skill tracks which phase each section is in (orientation, reference work, drafting, integration) and loads only the guidance relevant to that phase — so the AI's context window isn't cluttered with instructions for phases you aren't in yet.

## Examples

### Outline format

The `--outline` flag expects `## Heading` lines for top-level sections. Deeper headings (`###`, `####`) are ignored — only `##` lines become tracked sections.

```markdown
## Introduction
Background on the problem and why it matters.

## Literature Review
### Historical Context
### Current Approaches
Summary of existing work in the field.

## Methodology
How the analysis was conducted.

## Results
What was found.

## Discussion
What it means and where it falls short.

## Conclusion
```

This would generate 6 section state files (`introduction.md` through `conclusion.md`) and a section status tracker. The subsections under Literature Review are part of that section's content, not separate tracked sections.

### What init generates

After running `init-project.sh`, your paper directory looks like this:

```
your-paper/
├── project-config.yaml       ← Project settings (add your name — init fills the rest)
├── outline.md                 ← Paper outline (placeholder, or copied from --outline)
├── section-status.md          ← Section progress tracker (auto-populated from outline)
├── style-guide.md             ← Writing voice/preferences (starts empty, grows over time)
├── drafts/                    ← Section drafts and compiled draft (compiled-draft.md)
├── state/                     ← Per-section state files (refs, decisions, gaps, history)
│   ├── introduction.md
│   ├── literature-review.md
│   └── ...
├── references/                ← Your reference notes and extracted summaries
├── process/                   ← Process documentation
│   ├── decision-log.md        ← Editorial decision log
│   ├── process-journal.md     ← Process documentation for genai disclosure
│   └── genai-disclosure.md    ← AI use disclosure statement template
├── context/                   ← Project-specific context files (interaction patterns, etc.)
└── session_transcripts/       ← Archived session logs
```

If any of these files already exist (e.g., you have an existing decision log), init won't overwrite them.

### Decision log entries

The decision log is a chronological record of editorial choices. Each entry captures the decision, alternatives considered, who drove it, and reasoning. Here's what real entries look like:

```markdown
## Mar 11, 2026 — Section 1: Defining Bias

### Framing — Lead with values monoculture, not technical definition
- **Decision:** Section opens with who builds AI and who defines "safe,"
  then flows into linguistic bias and identity suppression.
- **Alternatives:** Claude initially proposed leading with a technical
  taxonomy of bias types. Author reordered.
- **Reasoning:** Values monoculture is the structural argument that
  explains *why* the specific failures happen. Technical taxonomy is
  descriptive; this is causal.
- **Who drove it:** Author directed the reorder; AI restructured.

### Guardrail override — Skipped representation audit for Section 1
- **Decision:** [guardrail-override] Proceeded to drafting without
  completing the representation audit for this section's references.
- **Reasoning:** Section 1 is definitional/introductory — the primary
  references are well-established frameworks (Buolamwini, Noble, Benjamin),
  not empirical work where representation gaps would be most harmful.
  Full audit will be done for Sections 2-4.
- **Who drove it:** Author decision, logged per skill protocol.
```

Every guardrail override is tagged `[guardrail-override]` so overrides are searchable across the full log. The principle: an override with documented reasoning is better than a guardrail quietly ignored.

### Section state files

Each section gets a persistent state file that tracks references (tiered as Foundational / Supporting / Contextual with verification status), a representation audit checklist, drafting decisions, open gaps, and a session history table. The session history is particularly important for continuity — it logs what happened in each work session so context isn't lost when the AI's context window resets:

```markdown
## Session History

| Date       | Phase          | What happened                          | Key decisions              |
|------------|----------------|----------------------------------------|----------------------------|
| 2026-03-11 | orientation    | Reviewed outline, ran bias check       | Reframed opening argument  |
| 2026-03-11 | reference-work | Triaged 8 refs, verified 5             | Dropped 2 weak sources     |
| 2026-03-12 | drafting       | Drafted 3 passages, author approved 2  | Sharpened para 2 language   |
```

See `skills/academic-writing/templates/section-state.md` for the full template.

## How It Works

### Four-Phase Writing Workflow

Each section of your paper follows four phases:

1. **Orientation** — Review the outline, discuss the argument, run the confirmation bias check, identify gaps
2. **Reference Work** — Triage references (Foundational / Supporting / Contextual), apply bias guardrails, verify citations, extract key points
3. **Drafting** — Write iteratively (AI drafts a passage, author reacts, refine together, author approves), check for theme downweighting and voice drift
4. **Integration** — Add approved prose to compiled draft, log decisions, debrief on the collaboration

The skill detects which phase you're in based on project state and loads only the relevant guidance — keeping the context window lean.

### Session Protocol

Every session starts with orientation (where did we leave off, what's next) and ends with state persistence (save transcript, log decisions, update section status). This ensures continuity across sessions even when the context window resets.

### The Silent Reset Problem (Context Compaction)

AI assistants have a limited working memory called a "context window." Think of it as the AI's desk — it can only hold so many pages at once. During a long conversation, the system quietly summarizes older parts of the conversation to make room for new ones. This is called **context compaction**, and it happens automatically, without warning.

Here's why that matters for writing: when compaction happens, it preserves *what was decided* — "we're writing about bias in safety measures" — but loses *how we agreed to work*. The specific editorial rules you negotiated ("don't hedge this argument," "always check for non-Western sources," "match my voice, not generic academic prose") get compressed into a summary that doesn't include them. The AI keeps writing fluently, but the guardrails are gone.

This is the most dangerous failure mode in AI-assisted writing, because **it's invisible**. The output still looks polished. The AI doesn't announce that it lost your agreements. You might not notice that your carefully calibrated voice drifted back to generic academic prose, or that the bias checks stopped happening, or that the AI started confirming your framing instead of challenging it. Everything that made the collaboration rigorous quietly evaporates, and what's left is a fluent but unguarded text generator.

**What this skill does about it:**

The skill treats compaction as a first-class risk with multiple layers of defense:

1. **Persistent state files** — Every editorial agreement, reference decision, and drafting choice is written to files on disk that survive compaction. The AI's working memory is temporary; these files are not.
2. **Recovery protocol** — When compaction occurs, the skill requires the AI to reload its instructions, your style guide, the current section's state, and recent editorial decisions *before writing another word*. Then it confirms with you: "Here's what I recovered — does this match where you want to continue?"
3. **Proactive checkpoints** — Before any work that might push the conversation toward compaction (reviewing a long reference, iterating on a complex passage), the skill saves a clean checkpoint. A restore point from *before* compaction is more reliable than trying to recover after.
4. **Session transcripts** — Raw conversation logs are archived to your project folder, preserving the actual back-and-forth (disagreements, corrections, iterations) that summaries flatten.

The goal: you should never have to wonder whether the AI is still following the rules you set. If compaction happens, the recovery is explicit and visible, not silent. For the full technical strategy, see `references/context-engineering.md`.

### Guardrail Modes

Three levels of guardrail enforcement, set in `project-config.yaml`:

- **`standard`** (default) — Flags issues, recommends action, allows overrides with logged reasoning
- **`strict`** — Blocks progression past reference work until representation audit passes and citations are verified; overrides require explicit reasoning
- **`advisory`** — Mentions gaps without blocking; notes issues in the process journal without interrupting workflow

### Guardrail Overrides

All guardrails can be overridden — but overrides are always logged. The skill uses a `[guardrail-override]` tag in the decision log so that any override is traceable. The principle: an override with documented reasoning is better than a guardrail quietly ignored.

### Permissions and Platform Detection

The skill auto-detects whether it's running in Cowork, Claude Code, or a manual environment and adjusts defaults accordingly. Features like session transcript access and decision auto-extraction are enabled by default but use a prompt-once permission model — you're asked once, the answer is persisted to your project config. Every automated feature degrades gracefully to a manual equivalent if permissions are denied.

## Project Structure

### Repository layout

```
academic-writing-skill/
├── .claude-plugin/
│   └── plugin.json                     # Plugin manifest for Claude Code
├── skills/
│   └── academic-writing/
│       ├── SKILL.md                    # Main skill file (process engine)
│       ├── references/
│       │   ├── writing-workflow.md     # Detailed phase-by-phase instructions
│       │   ├── bias-guardrails.md      # Literature bias guardrails + reference triage
│       │   └── context-engineering.md  # Context window management strategies
│       ├── templates/
│       │   ├── project-config.yaml     # Project configuration schema
│       │   ├── section-state.md        # Per-section state file template
│       │   ├── decision-log.md         # Editorial decision logging template
│       │   ├── process-journal.md      # Process documentation template
│       │   ├── section-status.md       # Project-wide section tracking
│       │   └── genai-disclosure.md     # AI use disclosure statement template
│       └── scripts/
│           └── init-project.sh         # Project scaffolding (with --outline support)
├── EFFECTIVENESS.md                    # Honest assessment of mitigation strengths/limits
├── README.md
└── LICENSE
```

## Background

This skill was developed while writing an academic paper collaboratively with AI. The process of writing the paper revealed the need for systematic guardrails against the risks listed above — the tool emerged from direct experience with the failure modes it addresses.

The skill is both a process used during the paper's development and a standalone contribution — a concrete, reusable artifact that other researchers can adopt when doing AI-assisted academic writing.

## License

MIT. See [LICENSE](LICENSE).

## Contributing

Issues and pull requests welcome. This is a process tool, so the most valuable contributions are:

- Reports of risks or failure modes not currently addressed
- Improvements to the bias guardrails based on lived experience
- Adaptations for different academic disciplines or writing workflows
- Translations or adaptations for non-English academic contexts
