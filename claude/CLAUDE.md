# Personal preferences

## General

Never assume you know the answer to a question. Research and find concrete answers. If that is not possible, admit the gap immediately.

Never waffle, over-describe or add narrative. Keep all answers short and to the point.

Bulleted lists are preferred over paragraphs.

## Formatting long replies and plans

A reading disorder makes dense text hard to parse. Apply these rules to plan
files, ExitPlanMode summaries, and any chat reply longer than 6 lines or with
more than one section.

Replies of 6 lines or fewer stay plain.

The rules:

- **One idea per bullet.** Never bury a second point in the same line.
- **Short bullets.** Aim for under ~15 words. Split long ones.
- **Bold the subject** at the start of each bullet so the eye has an anchor.
- **Headings every 4–6 bullets.** Give the eye places to land and rest.
- **Blank line between sections.** White space is not wasted space.
- **Heavy separator between top-level sections.** Use a `===` line of ~60
  characters above a `---` line of ~60 characters. Two stacked rules give
  the eye an unmissable horizontal stop. Example:

  ```
  ============================================================
  ------------------------------------------------------------
  ```

  Do not use the single-line `---` separator for top-level sections.
  A single `---` is still fine inside a section if you need a soft break.

- **No nested bullets deeper than one level.** Flatten or split instead.
- **No long paragraphs.** If it would be 3+ sentences, make it a bulleted list.
- **Lead with a 1–2 line TL;DR** at the top of any plan or reply over 10 lines.
- **Avoid parenthetical asides and em-dash subclauses.** They fragment sentences
  and make the eye double back. Use a separate bullet instead.

## ExamTrack branch workflow

Applies only when the session's repo matches both checks below. Otherwise ignore
this section.

- **Worktree layout:** `git rev-parse --git-common-dir` ends in `/.bare`.
- **Support branches:** `git branch -r --list origin/support origin/support-staging`
  prints at least one branch.

When both match, invoke the `fixing-live-and-staging` skill before creating a
branch or worktree, opening or retargeting a PR, promoting, releasing, or
handling a backport or sync PR. If the skill is not installed on this machine,
say so and carry on.