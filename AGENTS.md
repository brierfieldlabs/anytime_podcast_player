# Brierfield Labs fork working rules

Before coding, read this file, the upstream README and CONTRIBUTING.md, accepted fork decisions in docs/FORK-DECISIONS.md, current GitHub issues/PRs, and the [Brierfield Labs Coding House Rules](https://github.com/brierfieldlabs/infrastructure/blob/main/procedures/coding-house-rules.md).

Build the smallest maintainable change, reuse upstream Flutter/Dart services and UI, preserve the BSD-3-Clause licence and original attribution. Do not confuse brainstorming with approved scope, add unnecessary security/services/tests, or change production behaviour beyond the authorised fork features.

This repository tracks [amugofjava/anytime_podcast_player](https://github.com/amugofjava/anytime_podcast_player), upstream `master`. The Brierfield Labs fork uses `main`, with short-lived work branches and reviewed pull requests. GitHub is authoritative: capture work in issues, commit/push source and docs, reconcile PRs, record the next step.

CT140 workbenches handle Git and source edits, **not CI**. Use a designated existing Android CI runner, with exact-head checks, before merging or releasing. Do not run CI on personal devices or silently establish a new runner. Preserve signing/app identity, data, and release gates. No release exists merely because a source commit exists.

Upstream uses Dart/Flutter and a 120-character formatting convention. Respect its accessibility and localisation conventions.
