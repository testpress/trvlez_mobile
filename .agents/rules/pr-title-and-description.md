---
trigger: model_decision
description: When I ask for give me PR title and description for the ongoing or implemented changes.
---

PR Subject & Description Guidelines

PR Subject

Format

<type>: <user-facing change>

Common Types

    fix: → Bug fixes
    feat: → New features
    perf: → Performance improvements
    refactor: → Internal code improvements without behavior changes
    chore: → Maintenance or tooling changes
    test: → Test-related updates
    ui: → Visual/styling changes


Guidelines

    Keep it concise and specific.
    Describe the visible outcome, not the implementation.
    Prefer user/business impact over technical wording.
    Avoid vague subjects like:
        fix issue
        update logic
        changes for screen


Good Examples

fix: Users unable to proceed after payment confirmation

feat: Add hotel search with location-based filtering

perf: Reduce hotel list scroll jank on older devices

ui: Update booking confirmation screen layout


Avoid

fix: Handle payment state callback

Why this is weaker:

    It describes internal logic instead of the actual user problem.

PR Description

Goal

A PR description should help reviewers quickly understand:

    What problem existed
    Why it happened
    What behavior changed after the fix


The description should focus on behavior and impact, not implementation details.

Recommended Structure

1. Issue

What problem did users face?

Users were unable to proceed to the next step after completing payment.

2. Cause

Why did the issue happen?

The payment callback was not correctly updating the booking state, leaving the UI in a loading state.

3. Fix

How is the issue resolved?

Payment callbacks now correctly transition the booking state, and the UI reflects the updated status immediately.

Full Example

Subject

fix: Users unable to proceed after payment confirmation

Description

- Users were unable to proceed to the next step after completing payment on Android.
- The payment callback was not correctly updating the booking state.
- Payment callbacks now correctly transition the booking state, and the UI reflects the updated status immediately.

Additional Guidelines

Focus on Behavior, Not Code

Avoid mentioning:

    widget names
    class names
    state variables
    internal implementation details


Reviewers can already see those in the diff.

Instead, explain:

    user impact
    system behavior
    business effect


Keep Descriptions Easy to Scan

Use:

    short paragraphs
    bullet points
    whitespace between sections


Large dense paragraphs reduce readability.


Mention Scope When Relevant

If the PR has limitations or only affects certain flows, mention it.

Example:
This only affects Android payment flow and does not change iOS behavior.


Mention Risk When Relevant

Example:
This change affects the booking state machine and navigation flow.

This helps reviewers know where to pay attention.

Optional Enhancement (Very Useful)

You can introduce a lightweight template:

## Issue
...

## Cause
...

## Fix
...


This improves consistency across the team and makes PRs much easier to review.

Try to keep the PR concise as possible.
