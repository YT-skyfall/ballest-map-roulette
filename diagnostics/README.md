# Author-time source diagnostic (developer-only)

**Status: independent research. Not an installable v0.1.6 release. No upstream maintainer request or submission is planned before the mod is ready.**

## Why this exists

Map Roulette v0.1.5 correctly accepts Ballistic Banzai (author time **27.581 seconds**) with **Max 1:00**, and rejects it with **Max 0:20**, **after loading the map**. The missing functionality is getting that time for unplayed Workshop maps.

Ballest's native Hub list view displays **27.581** without loading Ballistic Banzai. Plugin Manager currently retrieves Steam UGC metadata on workshop searches but does not expose it through the script API.

## Completed test: public Steam details (October 18, 2026)

**Result: No author-time field exposed.** The Windows diagnostic returned the correct published Workshop item and title:

- Steam Workshop published file ID: **3818396644**
- Title: **Ballistic Banzai**
- Independently verified author time in Ballest Hub: **27.581 seconds**
- Steam endpoint tested: `ISteamRemoteStorage/GetPublishedFileDetails/v1/` (no API key)
- Returned fields: `ban_reason`, `banned`, `consumer_app_id`, `creator`, `creator_app_id`, `description`, `favorited`, `file_size`, `file_url`, `filename`, `hcontent_file`, `hcontent_preview`, `lifetime_favorited`, `lifetime_subscriptions`, `preview_url`, `publishedfileid`, `result`, `subscriptions`, `tags`, `time_created`, `time_updated`, `title`, `views`, `visibility`.

There was **no explicit `metadata`, `author_time`, medal, or goal-time field** in this response. We therefore **cannot** use this endpoint alone to drive the author-time filter. The output did not inspect every possible value in the description/tags; it specifically established that the API response has no author-time or developer-metadata field.

**Next test:** Inspect the raw `ISteamUGC::GetQueryUGCMetadata` value the native Steam client returns, or the `WBP_HubListEntry` value displayed by Ballest. The currently installed host caches UGC metadata internally but cannot expose it to a normal AngelScript plugin. We can perform this investigation ourselves with a **temporary, backed-up local test host**; neither the public plugin nor the user’s working v0.1.5 baseline should require such a host.

An official-host-compatible alternative remains necessary for public Plugin Manager distribution. Do not claim the field is accessible until tested.

## First test: unmodified Plugin Manager and public Steam data

The fastest safe test requires **no C++ patch, no extra game plugin, and no Steam API key**.

1. Keep Map Roulette **v0.1.5** installed. If you haven't already, open **Ballistic Banzai** once so the plugin learns its **27.581-second** author time.
2. In this branch, download [`Check-Steam-Author-Time.ps1`](Check-Steam-Author-Time.ps1) to a folder on your Windows PC.
3. Open PowerShell in the same folder and run:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\Check-Steam-Author-Time.ps1
   ```

4. The script checks your local Plugin Manager `host.log` for a map whose observed author time was **27.581**, automatically extracts the public Workshop ID, and sends a **form-encoded POST request** to Steam's keyless `ISteamRemoteStorage/GetPublishedFileDetails/v1/` endpoint.
5. **Share only the printed field names and the RESULT/Potential fields lines.** There is no need to share your full game log.

If the log was reset since you played, reopen Ballistic Banzai and rerun, or give the published Workshop ID explicitly: `-WorkshopId "..." `.

**Interpretation:** The keyless Steam endpoint has been documented to supply item details, but is **not guaranteed to supply developer metadata or author time**. If it does not return an author-time field, that rules out this specific endpoint, *not* other Steamworks/native Hub data sources. The diagnostic uses the **normal installed Plugin Manager** and does not change game files.

## Experimental host patch — only if the first test fails

## Experiment with a custom host (optional, not for normal users)

1. In upstream Plugin Manager source (`AnythingGoes-ballest/ballest-plugin-manager`), **review** and, only in a test build, apply [`workshop-metadata-api.patch`](workshop-metadata-api.patch) to `src/host/api.cpp`. It adds one read-only AngelScript binding, `Workshop::Metadata(id)`.
2. Build and test the custom host using the upstream project's documented developer process. **Do not replace the working host in a production Ballest install without a proper backup and review.**
3. With the custom host, install the separate `workshop-metadata-probe` test plugin under `Ballest/Binaries/Win64/plugins/workshop-metadata-probe`.
4. Start Ballest with Steam online. Open **plugins → console** or inspect `%LOCALAPPDATA%\Ballest\Saved\PluginManager\host.log`.
5. Look for `[author-time-probe]` log entries for the exact map title **Ballistic Banzai**. Compare metadata with the Hub's **27.581 seconds**. Be alert to milliseconds and decimal encodings; merely finding a plausible number is not sufficient.
6. Repeat with at least two other never-opened Workshop maps and compare against their visible Hub times. Check one map updated after its author time was cached.
7. Remove the diagnostic plugin after the test; return to the official host before playing normally.

**Do not install this probe with the current official host.** It will fail compilation because `Workshop::Metadata` does not yet exist. **Do not place it in Map Roulette's own plugin folder.** Main-branch v0.1.5 is unchanged.

## What different results mean

- **Exact author-time field present and consistent:** implement and test the parsing independently. A patched Plugin Manager host is useful for local investigation, **but cannot be a requirement for the normal public plugin unless its API is available in the released host**. Prioritize a solution that works with the unmodified public API. If an upstream host change proves unavoidable, develop the patch ourselves and defer any discussion of compatibility until final mod submission.
- **No time field or inconsistent values:** inspect how `WBP_HubListEntry` renders author time. The host already reads this widget's Workshop ID in `src/host/hub.cpp`; a dedicated host API may be needed. **Do not guess widget properties** without runtime inspection.
- **Metadata empty:** cannot conclude author time is inaccessible; the game may retrieve it through other data, e.g. leaderboard or track metadata.

No time estimates are fabricated or inferred from play counts, ratings, tags or personal bests.

## Source references

- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/src/host/steam.cpp
- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/src/host/api.cpp
- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/src/host/hub.cpp
- https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/docs/host/index.md

Track progress in [Map Roulette issue #1](https://github.com/YT-skyfall/ballest-map-roulette/issues/1).

## Standalone-first investigation

1. Check which pre-launch author-time information is exposed by **existing** Plugin Manager Workshop, Hub, Race, and Net APIs.
2. Investigate whether Steam's keyless `ISteamRemoteStorage/GetPublishedFileDetails/v1/` response provides the genuine author target. It is documented as a public POST endpoint, but **the metadata/time fields have not been verified** and should not be assumed.
3. Do **not** rely on `IPublishedFileService/GetDetails/v1/` directly inside the plugin: its documented API requires a Steam Web API key. Never ship a private key inside AngelScript source.
4. Only if stock APIs cannot expose the data, use our own temporary host fork to instrument the Hub widget or metadata for research, keeping the working official host unchanged for normal gameplay. A local fork by itself is **not a deployable Plugin Manager marketplace solution**.
5. Keep the plugin accurate: accept only author times proven equivalent to the game's Hub display; do not manufacture estimated times from unrelated Workshop fields.

Contact with AnythingGoes is reserved for **final plugin submission**, per project decision.
