# Academic Writing Process Skill

A process enforcement skill for responsible AI-assisted academic writing. Designed for use with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [Cowork](https://claude.ai).

## Why This Exists

AI-assisted academic writing introduces risks that aren't obvious until you're deep in the process. An AI assistant can draft fluent prose, summarize literature, and structure arguments — but it does all of this through the lens of its training data, which overrepresents Western, English-language, highly-cited scholarship. It defaults to smooth, consensus-seeking language that can quietly flatten your sharpest arguments. It confirms your framing rather than challenging it. And when context windows compress, editorial agreements made three sessions ago can silently disappear.

These aren't hypothetical concerns. They were documented during the development of this skill, which was built while writing a paper on bias in AI safety measures. The process of writing the paper revealed the need for the tool, and the tool became a contribution of the paper.

The core problem: **without deliberate process enforcement, the convenience of AI assistance systematically degrades the qualities that make academic writing valuable — intellectual rigor, diverse perspectives, distinctive voice, and transparent reasoning.**

This skill doesn't solve that problem completely. What it does is make the risks visible, create structural checkpoints where the author's judgment is required, and maintain an honest record of how the AI was used.

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
| **Context/continuity loss** | Context window compression silently drops editorial agreements, style preferences, and section-specific decisions from earlier sessions | Persistent state files, section isolation, transcript archival, explicit checkpoint protocol |

## How Effective Are These Mitigations?

Honest assessment — these mitigations are not all equally strong.

### Structurally reliable (will fire if the skill is followed at all)

**Hallucination prevention** is the hardest gate in the skill. It's a binary check — the author verifies each citation exists — not a judgment call the AI can get wrong. The residual risk is author fatigue on lower-tier references, which the skill addresses with explicit triage tiers (verify foundational refs carefully, spot-check supporting refs, skim contextual refs).

**Context/continuity loss prevention** is infrastructure, not behavior. Persistent state files, session start/end protocols, and transcript archival work because they're built into the workflow structure. If you follow the skill at all, this fires.

### Strong process, dependent on author engagement

**Confirmation bias mitigation** is well-positioned (before drafting, not after) and mandatory. But its effectiveness depends on whether the author genuinely engages with the counterarguments or treats the step as a checkbox. This is the best structural mitigation possible — you can't do better without a separate human adversarial reviewer — but it's fundamentally a prompt to think, not a gate that blocks.

**Literature bias mitigation** has real teeth. In strict mode, you can't proceed to drafting without diverse sources — that's a genuine gate. In standard mode (the default), gaps are flagged but overridable with logged reasoning. The honest limit: the AI's ability to suggest underrepresented sources is constrained by the same training data that creates the bias. The skill can flag *absences*, but it can't populate them with scholarship the AI doesn't know about. The genai-disclosure template acknowledges this structural limit rather than pretending the guardrail eliminates it.

### Useful checks, dependent on AI judgment quality

**Theme downweighting detection** asks the right question at the right time (post-draft: "are the sharp edges still sharp?"). But detecting whether an argument got flattened requires the AI to understand the *intended* sharpness — a subtle judgment call. The author is the real backstop; the skill's role is to remind them to look.

**Language homogenization prevention** improves over time as the style guide accumulates specific preferences, but early in a project, the AI is pattern-matching against vague descriptions. The iterative drafting protocol (one passage at a time, author reacts, iterate) is actually the stronger defense — homogenization gets caught in the revision loop even if the voice check misses it.

**Temporal gap detection** catches obvious staleness in foundational references but is limited by the AI's own knowledge cutoff. A paper retracted after the AI's training date won't be flagged.

**Citation bias mitigation** uses the same mechanism as literature bias (the representation lens during triage). Same strengths, same structural limits around training data.

### The irreducible gap

Nothing in this skill can fully compensate for biases in the AI's training data. The representation audit can flag *absences* in your reference list, but it can't suggest sources the AI doesn't know about. Counter-searches help, but the AI searches with the same biased training data. The skill's honest response to this is transparency: the genai-disclosure template puts the limitation on the record, the process journal documents where the AI's suggestions were and weren't sufficient, and the decision log captures where the author overrode the AI's framing.

### Why the decision log matters

The decision log is arguably the most important artifact the skill produces. Every editorial choice — framing decisions, reference inclusion/exclusion, argument structure, guardrail overrides — gets recorded with what was decided, what alternatives were considered, who drove the decision (author or AI), and why. This serves multiple purposes: it prevents relitigating settled decisions when context windows reset between sessions, it provides raw material for the genai-disclosure statement, and it creates an auditable record that editorial judgment remained with the author throughout. Combined with session history tracking in each section's state file (which logs what happened in every work session, phase by phase), the decision log means no part of the writing process is a black box. If a reviewer asks "how did you arrive at this framing?" or "why did you exclude that perspective?", the answer is in the log — not reconstructed after the fact.

This is by design. A tool that claimed to eliminate AI bias in academic writing would be dishonest. A tool that makes AI bias visible, creates checkpoints for human judgment, and maintains a transparent record of the collaboration — that's a credible contribution.

## Installation

Clone the repo somewhere on your machine, then link or copy it into the appropriate skills directory.

```bash
git clone https://github.com/jayweiler/academic-writing-skill.git \
  ~/path/to/your/working/copy
```

### Cowork (Claude Desktop)

Skills live in `~/Documents/Claude/.skills/skills/`. Symlink is recommended if you plan to develop or update the skill:

```bash
mkdir -p ~/Documents/Claude/.skills/skills
ln -s ~/path/to/your/working/copy ~/Documents/Claude/.skills/skills/academic-writing
```

The skill will appear in the available skills list on your next session.

### Claude Code

Skills live in `~/.claude/skills/`:

```bash
mkdir -p ~/.claude/skills
ln -s ~/path/to/your/working/copy ~/.claude/skills/academic-writing
```

### Project-Local Installation

You can also install the skill into a specific project's `.skills/` directory:

```bash
ln -s ~/path/to/your/working/copy /path/to/your/project/.skills/academic-writing
```

### Initialize a New Paper Project

Once installed, scaffold a new paper project:

```bash
# Basic setup
./scripts/init-project.sh /path/to/your/paper "My Paper Title"

# With auto-generated section states from an existing outline
./scripts/init-project.sh /path/to/your/paper "My Paper Title" --outline /path/to/outline.md
```

The `--outline` flag parses `## Heading` lines from your outline file and generates per-section state files and a section status tracker automatically.

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

After running `init-project.sh`, your paper directory gets this structure:

```
your-paper/
  project-config.yaml       # Author, institution, skill settings, file paths
  section-status.md         # All sections with phase tracking (auto-populated from outline)
  state/
    introduction.md         # Per-section state: refs, drafting decisions, gaps, session history
    literature-review.md
    methodology.md
    ...
  process/
    decision-log.md         # Editorial decision log (see below)
    process-journal.md      # Process documentation for genai disclosure
    genai-disclosure.md     # AI use disclosure statement template
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

See `templates/section-state.md` for the full template.

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

### Guardrail Overrides

All guardrails can be overridden — but overrides are always logged. The skill uses a `[guardrail-override]` tag in the decision log so that any override is traceable. The principle: an override with documented reasoning is better than a guardrail quietly ignored.

### Permissions and Platform Detection

The skill auto-detects whether it's running in Cowork, Claude Code, or a manual environment and adjusts defaults accordingly. Features like session transcript access and decision auto-extraction are enabled by default but use a prompt-once permission model — you're asked once, the answer is persisted to your project config. Every automated feature degrades gracefully to a manual equivalent if permissions are denied.

## Project Structure

```
academic-writing/
  SKILL.md                          # Main skill file (process engine)
  references/
    writing-workflow.md             # Detailed phase-by-phase instructions
    bias-guardrails.md              # Literature bias guardrails + reference triage
    context-engineering.md          # Context window management strategies
  templates/
    project-config.yaml             # Project configuration (defaults + permissions)
    section-state.md                # Per-section state file template
    decision-log.md                 # Editorial decision logging template
    process-journal.md              # Process documentation template
    section-status.md               # Project-wide section tracking
    genai-disclosure.md             # AI use disclosure statement template
  scripts/
    init-project.sh                 # Project scaffolding (with --outline support)
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
