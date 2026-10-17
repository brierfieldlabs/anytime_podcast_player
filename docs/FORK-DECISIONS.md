# Anytime Brierfield Labs fork: approved scope and state

Upstream: https://github.com/amugofjava/anytime_podcast_player (BSD-3-Clause)
Fork: https://github.com/brierfieldlabs/anytime_podcast_player

## Identity / release decision (17 October 2026)

Approved launcher and in-app name: **Podcast Anytime**.
Initial fork semantic version: **v1.0.0**, with no `test`, `rc` or other pre-release suffix.
Increment according to SemVer (PATCH fixes, MINOR backwards-compatible features,
MAJOR incompatible changes). Android package: `uk.co.brierfieldlabs.podcastanytime`.
Flutter `pubspec.yaml` is `1.0.0+1`: `+1` is an Android build counter, not a
user-facing prerelease label. The About screen displays `v1.0.0` only.
Keep original upstream application independently installable. Do not claim a
signed/released APK exists until exact-head CI, signing and phone acceptance.

Canonical default branch: `main`; upstream tracking ref: `upstream/master`.

## Authorised behaviour

Port relevant personal-use PodcastGPT customisations into Flutter, not Kotlin:
- Hide podcasts with zero unfinished episodes, and restore them automatically when new unfinished episodes appear.
- Retain Anytime's existing true unplayed-count badge and existing unplayed-count library sort.
- Add reverse order for all existing library sorts.
- Default *new subscriptions* to oldest episodes first without changing saved choices in old subscriptions.
- Compact edge-to-edge library artwork grid.
- Expand the existing long-press podcast menu following PodcastGPT PR #6: enqueue all unfinished oldest first, play oldest unfinished next, download unfinished, mark all played, settings, share, unsubscribe. Confirm destructive actions.
- Keep original ad-free and avoid unnecessary folder features.
- Fork-specific Android ID, **Podcast Anytime** launcher/name, SemVer starting at v1.0.0; original app remains installable.

## Do not treat ideas as released features

Performance: original library triggers broad rebuilds/reloads, artwork uses animated transitions and 480px cache decode. These are candidate hotspots, **not measured causes**. Profile on a physical Android phone and only change a measured bottleneck. No additional tracking or diagnostic service.

Existing upstream features mean no code is needed to add a count badge, the unplayed library sort, or ad removal; none of those should be duplicated.

Issues: #1 library behaviour, #2 long-press, #3 performance, #4 fork identity/build/upstream workflow.

## Acceptance and next action

The identity PR #5 now specifies CT142-local Android CI; do not treat CI as passed until an exact-head run completes. No fork Android build or on-phone performance result has been verified yet. Do not claim an APK is available. Use one existing designated Android runner with a suitable Flutter toolchain, then exact-head source checks, package/signature verification and on-phone acceptance before release. Never auto-merge upstream, publish an APK, or alter published tags without approval.

Immediate next step: register one additional **repo-scoped listener on existing Hamblett CT142** (no new CT), run exact-head Android CI for identity PR #5, then reconcile library PR #6. Keep the long-press menu and phone-measured performance work separate.
