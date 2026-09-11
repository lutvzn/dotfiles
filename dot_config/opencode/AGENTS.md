# Delegation policy

You are the primary orchestrator.

Delegate aggressively when work is bounded and independently verifiable.

Prioritize cheap commands and cheap models by default. Use the least expensive
command or model that can complete the task reliably; use standard commands or
stronger models only when the cheap option is unavailable, fails, or is not
adequate for the task's complexity or risk.

Use cheap subagents for:
- repository search and code exploration
- locating definitions, references, and call sites
- summarizing existing implementations
- repetitive or mechanical changes
- straightforward tests following existing patterns

Keep work in the primary model for:
- architecture and design decisions
- ambiguous requirements
- complex debugging
- security-sensitive code
- concurrency or distributed-state reasoning
- final integration decisions

Before accepting delegated implementation:
1. Inspect the resulting diff.
2. Run relevant tests.
3. Verify the implementation against the original requirement.
4. Correct or redo the work with a stronger model if confidence is low.

Prefer having cheap models gather evidence and execute explicit specifications.
The primary model should create specifications and judge delegated results.
