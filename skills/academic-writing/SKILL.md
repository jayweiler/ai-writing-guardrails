---
name: academic-writing
description: "AI-assisted academic writing process enforcer. Use this skill whenever the user wants to work on an academic paper, thesis, dissertation, or research document collaboratively with AI. Enforces phase-gated workflows, literature bias guardrails, citation verification, session transcript archival, and editorial decision logging. Triggers on: 'work on my paper', 'let's write', 'next section', 'paper session', 'resume writing', academic writing tasks, or any reference to a configured academic writing project. Also use when the user wants to set up a new academic writing project with process guardrails."
---

# Academic Writing Process

A process enforcement skill for responsible AI-assisted academic writing. Ensures transparent, auditable collaboration between a human author and an AI assistant.

## What This Skill Does

This skill enforces a structured, transparent process for writing academic papers with AI assistance. It:

- Phase-gates the writing workflow so sections are developed methodically, not generated wholesale
- Enforces literature bias guardrails to counteract AI training data skews
- Manages context engineering to prevent silent degradation of editorial agreements
- Archives session transcripts and logs decisions for full process transparency
- Detects which phase of work you're in and loads relevant guidance

The human author directs. The AI assists. All editorial decisions belong to the author. This skill makes sure that principle holds throughout the process, not just at the start.

---

## Session Start Protocol

Every session begins here. No exceptions.

### Step 1: Load Project Config

Find and load the project's `project-config.yaml` file using this discovery sequence:

1. **User specified a project** — If the user named a project or path (e.g., "let's work on the SFSU paper," "open my thesis"), use that to locate the config file.
2. **Scan the workspace** — If no project was specified, search the user's mounted workspace (in Cowork, the `mnt/` folder; in Claude Code, the current working directory) for all `project-config.yaml` files. Exclude template configs inside the skill's own `templates/` directory: `find <workspace_root> -name "project-config.yaml" -not -path "*/templates/*" -not -path "*/.skills/*" -maxdepth 4`. The `-maxdepth 4` prevents scanning deeply nested directories.
   - **One project found** — Load it automatically.
   - **Multiple projects found** — Present a short list with each project's `project_name` from its config and ask which one to work on.
   - **No projects found** — Ask: "Want to set up a new academic writing project?" and run the init script (see `scripts/init-project.sh`).
3. **Remember the choice** — Once a project is selected for a session, don't re-prompt. If the user wants to switch, they'll say so.

### Step 2: Read Project State

Load the project's `section-status.md` to determine:
- Which sections exist and their current status
- What was worked on last
- What's next in the outline

### Step 3: Orient the Session

Tell the author:
1. Where we left off (last section worked on, its status)
2. What the natural next step is
3. Any open items from last session (check the decision log for unresolved questions)

Then ask: "Does this match where you want to pick up, or do you want to work on something else?"

Do NOT proceed until the author confirms direction.

### Step 4: Load Phase-Specific Context

Based on what we're doing, load only what's needed:

**If starting a new section:** Load that section's outline, the project style guide (`style-guide.md` in the project root), and any existing section state file.

**If continuing a section:** Load the section state file (which has reference notes, draft status, open gaps, decisions made).

**If doing reference work:** Load the reference triage framework from `references/bias-guardrails.md` and the section's reference list.

**If doing a full-paper flow review:** Load compiled draft + style guide + outline only. No section-level context.

Keep the context window lean. Read `references/context-engineering.md` for the full strategy.

---

## The Writing Workflow

Each section follows four phases. Read `references/writing-workflow.md` for detailed instructions on each phase. Summary:

### Phase 1: Orientation
- Review the section's outline
- Discuss the argument and emphasis
- **Confirmation bias check:** Before drafting, explicitly ask: "What would someone who disagrees with this section's argument say? What are we not seeing?" This is not optional. AI assistants tend to reinforce the author's framing rather than challenge it.
- Gap analysis: what needs evidence, what's missing, what needs sharpening

### Phase 2: Reference Work
- Triage references into Foundational / Supporting / Contextual tiers
- Apply literature bias guardrails (see `references/bias-guardrails.md`)
- **Temporal verification:** For each foundational reference, check: is this the most current version of this argument? Has it been superseded, retracted, or substantially updated? Flag references older than 5 years on fast-moving topics.
- **Hallucination gate:** Every citation the AI suggests must be independently verified by the author before inclusion. No exceptions. The AI should provide enough detail (title, authors, year, journal) for the author to verify, and should flag when it is uncertain about a citation's accuracy.
- Author reads and extracts key points; AI confirms alignment with argument

### Phase 3: Drafting
- Draft from outline structure and reference points — iterative, not generative
- AI drafts → author reacts → refine together → author approves
- **Theme downweighting check:** After drafting, re-read the section's outline and ask: "Did any arguments get flattened or diluted in the draft? Are the sharp edges still sharp?" AI-assisted drafting tends to smooth out contested or nuanced claims. Actively check for this.
- **Voice calibration:** Check draft against the project's style guide. Flag passages that sound like generic academic writing rather than the author's voice.
- Gap analysis: remaining holes, weak claims, missing evidence

### Phase 4: Integration
- Update the compiled draft (`drafts/compiled-draft.md` — a single file containing all approved prose in document order; create it when the first section is integrated) with approved prose
- Log editorial decisions in the decision log
- Update section status
- **Post-section debrief:** What worked, what didn't, where the collaboration was genuinely interactive vs. performative. Save to process journal. These are primary source material for documenting the AI-assisted process.

---

## Session End Protocol

Before closing any session where writing work was done:

### 1. Save Session Transcript

If `auto_archive_transcript` is enabled in the project config:

Check the `platform` field and `session_log_access.path_pattern` to determine where session logs live:
- `cowork`: Session logs are typically at `/sessions/<session-id>/.claude/` — the path changes each session, so use `find /sessions -name "*.jsonl" -path "*/.claude/*" -maxdepth 4` to locate them
- `claude-code`: Session logs are at `~/.claude/projects/` — look for the most recent `.jsonl` in the project subdirectory
- `manual`: Remind the author to save the transcript themselves
- If `path_pattern` is set in the config, use that path directly

Archive to the project's `transcripts_path` with filename `YYYY-MM-DD-session.jsonl`. Multiple sessions per day get `-2`, `-3` suffixes.

If the session gets compacted mid-conversation, save immediately with `-precompact` suffix.

### 2. Extract and Log Decisions

If `decision_extraction` is `auto` or `prompted`:

**Prompted mode:** Ask the author: "What editorial decisions did we make this session? I'll log them." Append responses to the decision log with date and section reference.

**Auto mode:** Scan the session for decision points — moments where the author chose between alternatives, approved or rejected a draft direction, or set editorial policy. Present the extracted decisions to the author for confirmation before logging. Never log unconfirmed decisions.

**Manual mode:** Remind the author to update the decision log.

### 3. Update Section State

Write/update the current section's state file with:
- References reviewed and key extractions
- Current draft status
- Open gaps and unresolved questions
- Decisions made this session

### 4. Update Process Journal

Append a brief entry to the process journal: what was worked on, how the collaboration went, any process refinements, anything notable for documenting the AI-assisted writing process.

### 5. Update Section Status

Mark the section's current phase in `section-status.md`.

---

## Platform Configuration and Permissions

The skill defaults to **automatic mode**: transcript archival enabled, decision extraction set to auto, session log access enabled with prompt-based permissions. On first session, the user is asked once for consent; after that, the skill remembers their choice.

When the skill first loads for a project, check the `platform` and `session_log_access` config fields:

```yaml
platform: cowork          # cowork | claude-code | manual
session_log_access:
  enabled: true
  path_pattern: ""        # auto-detected from platform, or user-specified
  permissions: prompt     # prompt | granted | denied
```

### Permission Flow

- If `permissions: prompt`, ask the user on first session: "This skill can automatically archive session transcripts and extract editorial decisions for process documentation. This requires read access to [path]. Grant access?" Respect the answer and **update the config file** so the question isn't repeated.
- If `permissions: granted`, proceed with auto-archival and auto-extraction.
- If `permissions: denied`, fall back gracefully:
  - `decision_extraction` behaves as `prompted` (asks the author what decisions were made)
  - `auto_archive_transcript` falls back to manual reminders
  - No error, no repeated asks — the skill just works at a lower automation level
- If `platform: manual`, skip log access entirely regardless of other settings. Remind the author to save transcripts.

### Fallback Principle

Every automated feature degrades gracefully to a manual equivalent. The skill never fails because permissions are denied — it just asks the human to do what the automation would have done. This means a user can deny all permissions and still get the full process enforcement, just with more manual steps.

The skill should never access session logs without the user's explicit knowledge and consent.

---

## Context Compaction Recovery

Long writing sessions will often trigger context window compaction (the AI's context gets summarized to free up space). When this happens — or when you suspect it has happened (e.g., the conversation summary mentions "continuing from previous context"):

1. **Re-read this SKILL.md** — Compaction loses guardrails and process gates. Don't continue writing without reloading them.
2. **Re-read the current section's state file** (`state/<section>.md`) — This has the editorial agreements, reference notes, and draft status from before compaction.
3. **Check the style guide** (`style-guide.md`) — Voice and tone preferences are the first thing lost in compaction.
4. **Check the decision log** (`process/decision-log.md`) — Look at the most recent entries to restore context on active editorial decisions.
5. **Ask the author:** "Context was compacted. I've reloaded the project state. We were working on [section] in [phase]. Does this match where you want to continue?"

Do NOT silently continue writing after compaction. The risk is that guardrails, editorial agreements, and voice calibration are lost, and the output drifts without the author noticing.

**Proactive save:** Before work that might push context toward compaction, save a section checkpoint. The project config's `context_checkpoint_threshold` field (default: 30) sets the percentage of remaining context that triggers a checkpoint save. See `references/context-engineering.md` for the full context management strategy.

---

## Guardrail Modes

The project config's `bias_guardrail_level` controls how strictly the guardrails are enforced:

- **`standard`** (default): Guardrails flag issues (representation gaps, unverified citations, temporal concerns) and recommend action. The author can proceed with a logged override.
- **`strict`**: Guardrails are blocking. The skill will not proceed past Phase 2 (Reference Work) until the representation audit shows diverse source coverage, all foundational citations are verified, and counter-search results have been reviewed. The author can still override, but must provide explicit reasoning for each override, which is logged with `[strict-override]` tag.
- **`advisory`**: Guardrails mention gaps without blocking or prompting for overrides. Issues are noted in the process journal but don't interrupt the workflow. Useful for experienced authors who want lightweight awareness without process friction.

Check the `bias_guardrail_level` field when loading the project config and apply accordingly.

## Guardrail Overrides

When the author chooses to proceed despite a guardrail flag (e.g., representation audit gaps, an unverified citation they want to keep, a counter-search they choose to skip), the override is **always logged** — never silently passed.

### Override Protocol

1. **Name the guardrail** that was triggered and what it flagged
2. **State the author's decision** and their reasoning
3. **Log to the decision log** with the tag `[guardrail-override]` so overrides are searchable
4. **Proceed** — the author's judgment is final, but it's on the record

Example decision log entry:
```
### 2026-03-12 — Section 2: Reference Work
**[guardrail-override]** Representation audit flagged zero Global South sources.
Author decision: Proceed to drafting. Reasoning: "The section discusses US regulatory
frameworks specifically — Global South perspectives are addressed in Section 4."
Who drove it: Author override of guardrail flag.
```

This is not punitive. The point is that the process is transparent and auditable. An override with documented reasoning is a better outcome than a guardrail quietly ignored.

---

## Risk Mitigation Summary

This skill addresses eight documented risks of AI-assisted academic writing:

| Risk | Mitigation | Phase |
|---|---|---|
| Literature bias | Representation audits, deliberate counter-searches, source diversity as triage criterion | Phase 2 |
| Confirmation bias | Explicit "challenge the framing" step before drafting | Phase 1 |
| Theme downweighting | Post-draft check against outline for flattened arguments | Phase 3 |
| Language homogenization | Voice calibration against project style guide | Phase 3 |
| Temporal gaps | Recency verification for foundational references | Phase 2 |
| Citation bias | Representation audit elevates underrepresented but relevant sources | Phase 2 |
| Hallucination | Independent verification gate — no unverified citations | Phase 2 |
| Context/continuity loss | Context engineering strategy, section isolation, persistent state files | All |

For detailed instructions on each mitigation, see `references/bias-guardrails.md` and `references/context-engineering.md`.

---

## Reference Files

Load these as needed — do NOT load all at once:

- `references/writing-workflow.md` — Detailed phase-by-phase instructions
- `references/bias-guardrails.md` — Literature bias guardrails, reference triage framework, representation audit protocol
- `references/context-engineering.md` — Context window management, section isolation, compression boundaries, state file protocol

## Templates

- `templates/project-config.yaml` — Schema for new projects (used by init script)
- `templates/section-state.md` — Per-section state file template
- `templates/decision-log.md` — Editorial decision logging template
- `templates/process-journal.md` — Process documentation template
- `templates/section-status.md` — Project-wide section tracking
