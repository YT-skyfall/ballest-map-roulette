# Map Roulette v0.1.6 — private UI test

**Status:** UI-only candidate. Not released, compiled, or tested in Ballest yet. Main remains the creator-tested v0.1.5 baseline.

## Changes

- Clear **X** controls in each text input (search, include/exclude tags, minimum/maximum author time).
- **RESET FILTERS** clears the search, tags, sort, rating, play count, author-time ranges and unfinished-only flag. It intentionally **preserves** music, sound effects and auto-play preferences. Clears stale search results; you must click **FIND MAPS** afterward.
- Cleaner search status for no results, one eligible map and larger eligible pools. Single-map spins still work as before; the message explains the inevitable outcome.
- Winner page now shows play-session count reported by Workshop (when available), a more compact selection summary, and a clearer automatic/manual play status.
- Author-time input labeled as **advanced**, with a warning that previously unchecked maps cannot qualify. Author-time implementation remains deferred.

The map matching criteria, random selection, page scanning, sounds, reel behavior, map loading, author-time observation, and auto-play delay have **not** been intentionally altered.

## Installing for private testing

The easiest option is to use the separate private test ZIP supplied with this build. **Do not install a GitHub source ZIP from this development branch into your game folder**; that ZIP includes research/docs and is not arranged as a deployable package.

1. **Close Ballest** completely.
2. Use **plugins → open plugins folder** if unsure of your game directory. The intended path ends in `Ballest/Binaries/Win64/plugins/map-roulette/`.
3. Back up your working **v0.1.5** `main.as` **and** `info.toml` outside the plugins directory.
4. From the private UI-test ZIP, copy **only** `map-roulette/main.as` and `map-roulette/info.toml` into your existing `plugins/map-roulette/` folder. Leave `sounds/`, `icon.png` and `placeholder.png` untouched.
5. Start Ballest and open Map Roulette (F7). Confirm the plugin compiles in Plugin Manager's console.

To roll back, close Ballest and restore both v0.1.5 files from your backup; keep the rest of the assets intact.

## Short test plan

1. Search for a few maps normally; confirm thumbnails, map counts and **SPIN ROULETTE** still work.
2. Type into the search and tag fields. Test their X buttons; confirm they clear.
3. Apply rating, play-count, author-time and unfinished filters; click **RESET FILTERS**. Check all search filters clear while auto-play/music/sound choices remain as selected.
4. Search again; confirm the results are fresh and not from the previous filter state.
5. Search for one eligible map; verify the results explicitly warn that the spin is deterministic.
6. Spin with auto-play **off**. Check that the winner displays the correct actual map, preview, matching-map count and a play-session count when Steam reports one. Click Play.
7. Spin with auto-play **on**. Verify the countdown still waits ~6 seconds, and closing the window cancels the automatic launch.
8. Try the STOP button, spinning again, and back-to-filters. Confirm all 18 sound assets still work.
9. If an AngelScript compilation error occurs, send the **exact error text and line number** before rolling back.

## Deferred

The author-time filter still only works for a map whose genuine author time was learned after it was loaded. Keep Min/Max blank for unrestricted searches. No new host API or Steam request was added.

## Release policy

Do not merge this branch into `main` or publish a registry entry until the creator finishes real in-game testing.
