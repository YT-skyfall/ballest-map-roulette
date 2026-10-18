# Author-time source diagnostic (developer-only)

**Status: experimental source inspection. Not an installable v0.1.6 release.**

## Why this exists

Map Roulette v0.1.5 correctly accepts Ballistic Banzai (author time **27.581 seconds**) with **Max 1:00**, and rejects it with **Max 0:20**, **after loading the map**. The missing functionality is getting that time for unplayed Workshop maps.

Ballest's native Hub list view displays **27.581** without loading Ballistic Banzai. Plugin Manager currently retrieves Steam UGC metadata on workshop searches but does not expose it through the script API.

## Experiment

1. In upstream Plugin Manager source (`AnythingGoes-ballest/ballest-plugin-manager`), **review** and, only in a test build, apply [`workshop-metadata-api.patch`](workshop-metadata-api.patch) to `src/host/api.cpp`. It adds one read-only AngelScript binding, `Workshop::Metadata(id)`.
2. Build and test the custom host using the upstream project's documented developer process. **Do not replace the working host in a production Ballest install without a proper backup and review.**
3. With the custom host, install the separate `workshop-metadata-probe` test plugin under `Ballest/Binaries/Win64/plugins/workshop-metadata-probe`.
4. Start Ballest with Steam online. Open **plugins → console** or inspect `%LOCALAPPDATA%\Ballest\Saved\PluginManager\host.log`.
5. Look for `[author-time-probe]` log entries for the exact map title **Ballistic Banzai**. Compare metadata with the Hub's **27.581 seconds**. Be alert to milliseconds and decimal encodings; merely finding a plausible number is not sufficient.
6. Repeat with at least two other never-opened Workshop maps and compare against their visible Hub times. Check one map updated after its author time was cached.
7. Remove the diagnostic plugin after the test; return to the official host before playing normally.

**Do not install this probe with the current official host.** It will fail compilation because `Workshop::Metadata` does not yet exist. **Do not place it in Map Roulette's own plugin folder.** Main-branch v0.1.5 is unchanged.

## What different results mean

- **Exact author-time field present and consistent:** ask the upstream Plugin Manager maintainer to review exposing a dedicated `Workshop::AuthorTime(id)` (prefer parsed/validated by the host) or metadata read-only accessor. Then implement v0.1.6's pre-spin selection using that exact field.
- **No time field or inconsistent values:** inspect how `WBP_HubListEntry` renders author time. The host already reads this widget's Workshop ID in `src/host/hub.cpp`; a dedicated host API may be needed. **Do not guess widget properties** without runtime inspection.
- **Metadata empty:** cannot conclude author time is inaccessible; the game may retrieve it through other data, e.g. leaderboard or track metadata.

No time estimates are fabricated or inferred from play counts, ratings, tags or personal bests.

## Source references

- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/src/host/steam.cpp
- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/src/host/api.cpp
- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/src/host/hub.cpp
- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/docs/host/index.md

Track progress in [Map Roulette issue #1](https://github.com/YT-skyfall/ballest-map-roulette/issues/1).
