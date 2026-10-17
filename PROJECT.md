# Project charter: Podcast Anytime

- **Purpose:** Personal Brierfield Labs Android fork of the BSD-licensed Anytime Podcast Player, incorporating approved PodcastGPT-style library workflows.
- **Users/problem:** One personal listener wants better oldest-first listening, a compact library and predictable queue controls without a sluggish interface.
- **Smallest useful deliverable:** A distinct, installable Podcast Anytime v1.0.0 Android app, followed by the approved podcast library and long-press enhancements.
- **Out of scope:** New backend/services, advertising, folder management, porting an unrelated platform, speculative performance rewrites, new test infrastructure.
- **Reuse:** Upstream Flutter/Dart, existing BLoCs, settings, Sembast database, downloader, audio and existing CT142 infrastructure.
- **Stack:** Flutter/Dart, native Android build with upstream Android/Gradle configuration.
- **Canonical repository:** https://github.com/brierfieldlabs/anytime_podcast_player ; main protected by reviewed PRs.
- **Validation:** Existing Flutter checks plus Android build on the designated repo-registered CT142 CI runner; actual phone startup, playback, queue, sorting and update acceptance before release.
- **Risks:** Losing user subscriptions or downloads during installation or changing package ID; preserve official Anytime separately, document OPML migration and do not claim private app data is shared.
- **Approval:** Owner approval for production behaviour changes and release; semantic version v1.0.0 initially, no prerelease/test/RC labels.
- **Reference:** docs/FORK-DECISIONS.md on the identity PR, GitHub issues #1-#4, AGENTS.md, and infrastructure house rules.
