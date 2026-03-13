# Context Engineering Strategy

The context window is a finite resource. When it fills, prior conversation is compressed in ways that silently degrade editorial guardrails and collaboration agreements. This document defines strategies for managing context intentionally rather than letting the system compress it unpredictably.

---

## Why This Matters

Context loss is not just a technical inconvenience. It's a specific risk to the integrity of the writing process:

- Editorial rules negotiated earlier in the conversation can silently disappear
- Stylistic corrections the author made may be forgotten, causing the AI to revert to defaults
- Working agreements about tone, emphasis, and approach erode without either party noticing
- The compression preserves what was decided but not how — dropping the disagreements, corrections, and iterations that constitute the real collaborative dynamic

This risk compounds every other risk in AI-assisted writing. The mitigations for literature bias, confirmation bias, and hallucination all depend on continuous collaboration. If that collaboration degrades silently, the safeguards stop working without anyone realizing it.

---

## Strategy 1: Section Isolation

Each writing session focuses on one section. Load only what's needed:

- That section's outline entry
- Its triaged references and per-reference notes
- The project style guide
- The skill's process rules (SKILL.md)
- The section's state file

**Do NOT load** unless specifically needed:
- The full outline (only the current section's entry)
- Other sections' drafts
- Unrelated project files
- Previous sections' reference discussions

The exception is the cross-section flow review, which is its own session type with its own minimal context load.

## Strategy 2: Per-Section State Files

For each section, maintain a state file capturing:

- **References reviewed:** Which ones, key extractions, relevance assessment
- **Drafting decisions:** What was decided and why
- **Open gaps:** Unresolved questions, missing evidence, weak claims
- **Current draft status:** Which passages are approved, which need revision

This is the section's memory. When returning to a section after working on something else (or after a context reset), reload its state file instead of trying to reconstruct from transcript.

**Update the state file proactively.** Don't wait until session end — update it after each significant decision or completed passage. If context gets compressed, the state file is the restore point.

## Strategy 3: Reference Review as Isolated Passes

When the author reads and extracts key points from references:

1. Load the reference (or the author's notes on it)
2. Author shares extractions, AI confirms/adds
3. Write a structured summary to a per-reference notes file or the section state file
4. The drafting session loads the summary, not the full discussion

This compresses reference material intentionally and transparently rather than letting the context window do it silently — which is the exact problem this strategy exists to prevent.

## Strategy 4: Explicit Compression Boundaries

Before any step that will burn heavy context:
- Reviewing a long reference
- Iterating extensively on a complex paragraph
- Doing a multi-reference comparison

Save a section checkpoint first. Write the current state of everything to the section state file. If compression happens mid-step, we have a clean restore point from before the lossy work.

**Trigger:** If you estimate that the next piece of work will consume more than the project's `context_checkpoint_threshold` percentage (default: 30%) of remaining context, save state first. Check `project-config.yaml` for the configured value.

## Strategy 5: Cross-Section Flow as Separate Phase

The whole-paper flow review gets its own session with minimal prior context:

- Compiled draft only
- Style guide
- Outline (for structural reference)

No section-level drafting debates. No reference review context. No accumulated editorial discussion from individual sections.

The point is a clean read — the kind of perspective that only comes from not being deep in the weeds of any one section.

## Strategy 6: Session Transcript as External Memory

Raw session transcripts, archived to the project's transcript directory, serve as the authoritative record of what happened. They capture:

- The actual back-and-forth, not a summary
- Disagreements, corrections, and iterations
- The collaborative dynamic, not just the outcomes
- Decision rationale that may not make it into the decision log

When the context window compresses these away, the transcripts preserve them. This is why transcript archival is mandatory, not optional — it's the primary defense against the context loss risk.

---

## Compaction Recovery Protocol

When context compaction occurs mid-session (or when resuming from a compacted conversation summary), the AI must recover state before continuing any writing work. Compaction summaries preserve *what was decided* but lose *how to work* — guardrails, voice calibration, and editorial agreements all evaporate.

**Recovery steps (in order):**

1. **Re-read SKILL.md** — Restores the process gates, phase requirements, and guardrail checks. Without this, the AI will default to generic writing assistance with no process enforcement.
2. **Re-read the current section's state file** (`state/<section>.md`) — Restores editorial agreements, reference notes, draft status, and open gaps for the section in progress.
3. **Re-read `style-guide.md`** — Restores voice and tone calibration. This is the first thing lost in compaction; without it, output drifts toward generic academic prose.
4. **Check recent decision log entries** (`process/decision-log.md`) — Restores context on active editorial decisions and any guardrail overrides.
5. **Confirm with the author** — State what was recovered and where we were. Ask: "Does this match where you want to continue?" Do not silently resume.

**Why this matters:** Compaction creates a specific failure mode where the AI continues writing fluently but without guardrails. The output looks fine, but the process protections (bias checks, confirmation bias gates, citation verification) are gone. The author may not notice because the AI is still producing plausible prose. The recovery protocol exists to prevent this silent degradation.

**Proactive save:** If you estimate that the next piece of work will push context close to compaction, save a section checkpoint *before* doing the work. A clean restore point from before compaction is worth more than trying to recover after.

---

## Key Principle

We control when and how context gets compressed rather than letting the system do it silently. Every piece of context that enters the window should have a persistent backup that we explicitly wrote, not a system-generated summary we can't inspect.

If a piece of information matters enough to influence the writing, it matters enough to be written down somewhere the context window can't touch.
