# Map Roulette v0.1.8 — Private release preparation

**This is a checklist, not authorization to publish.** Keep the repo private until the creator explicitly approves making it public. Do not create a public GitHub Release, push a release tag, or submit the plugin to AnythingGoes yet.

## 1. Files and packaging audit

- [x] The original v0.1.8 visual test is preserved (Git blob `b5b1f36658467714880cf33534058f8f0f46625f`). The live-input fix was user-tested (blob `fff3cf3b8e3a99675342a7fb9e31ea06ee59335c`). Final source in `main` is Git blob `f97783ac40cb3900fc353523e7f18564f5dd8a8e`; since that test it only changes the main heading to `Can't decide what to play?` and removes the `BETA` label. Those last two text changes have not been separately tested in-game.
- [x] A regular Plugin Manager `info.toml` identifies the `main.as` entry point, the icon, the preview image, all sound WAVs, and minimum host version.
- [x] Both PNGs and all **18** WAV assets in the private repository match the v0.1.8 test ZIP Git blob hashes.
- [x] No built `.dll`, `.exe`, `.pak`, or compiled container is required or distributed as plugin source.
- [x] No `Console::` use or third-party network API key.
- [x] README explains what the plugin does, how users will install/operate/update/remove it, and known limitations.
- [x] MIT LICENSE and CHANGELOG included; original WAV synthesis provenance and creator's PNG ownership confirmation documented in [AUDIO-PROVENANCE.md](AUDIO-PROVENANCE.md).
- [x] v0.1.5 stable code kept on a separate private archive branch.

## 2. Before calling it release-ready

- [ ] **Confirm final v0.1.8 on the intended installed Plugin Manager host:** no AngelScript errors or warnings in `plugins → console` or `host.log`.
- [x] **Workshop text-field fix verified in-game:** Search, include tags, and exclude tags now use the live typed field value when FIND MAPS is clicked; tester confirms the fix and remaining features work normally. See [issue #6](https://github.com/YT-skyfall/ballest-map-roulette/issues/6).
- [ ] **Complete final regression**, using the matrix below. Creator reports normal use and confirms search/tags/spins function, but some edge cases haven't been individually signed off.
- [ ] **Extended stability:** Creator reports the plugin runs normally, but an approximately one-hour error-free session has not been explicitly confirmed. Keep this test open until confirmed.
- [x] Added three actual v0.1.8 in-game screenshots to the public-facing README: `screenshots/search.jpg`, `screenshots/roulette.jpg`, and `screenshots/winner.jpg`. They were cropped/resized for readability; the original images remain in the conversation.
- [x] Public-facing CHANGELOG and README cleaned up, and the current branch removes the BETA UI badge.
- [x] Creator confirmed publishing rights for both PNGs. Original v0.1.5 build notes document that all 18 WAVs were newly synthesized/generated for Map Roulette, without outside recordings or samples; all 18 candidate WAVs match the original byte-for-byte. See [AUDIO-PROVENANCE.md](AUDIO-PROVENANCE.md).
- [ ] Creator approves public repository visibility and GitHub version/tag **separately**.
- [ ] Only after approved public tagging, request addition to Plugin Manager's registry.

### Final regression matrix

| Test | Expected result |
| --- | --- |
| Fresh manual install on normal host | Plugin loads without warnings/errors; visible in footer/main menu; F7 opens/closes it. |
| No filters or blank search | Live Steam Workshop results, all pages scan, eligible count appears. |
| Search/title and include/exclude tags | Correctly narrows to matching maps; new search replaces old pool. |
| Rating / min plays / unfinished | Filters exclude inappropriate maps; counts update. |
| Advanced filters and reset | Advanced screen works; **RESET FILTERS** clears search constraints, preserves sound/auto-open settings. |
| Invalid author-time input | Helpful validation message; no spin using invalid state. |
| Known-time restriction | Known checked maps satisfy/reject correctly; unknown excluded, with clear warning. Leave blank for regular use. |
| Zero, one, many eligible maps | No spin for zero; single-map selection handled; many-map pool is randomized. |
| Spin / stop / back / spin again | Navigation and sounds don't get stuck; center thumbnail and winner correspond. |
| Images, loading, sound | Real Workshop previews populate; Off/Quiet/Normal work; previews may load asynchronously. |
| Manual play | Selected Workshop map opens only when `PLAY THIS MAP` is selected. |
| Auto-open / close | ~6 seconds before opening; closing before countdown cancels; no surprise map load. |
| Steam offline / missing or deleted map | Clear error handling; no crash or unrecoverable UI state. |
| Long-run stability | Several searches and spins, including game transitions, no plugin stop or runaway resource usage. |

## 3. How to submit to Plugin Manager — when approved

The authoritative guidance is [AnythingGoes' official publishing guide](https://github.com/AnythingGoes-ballest/ballest-plugin-manager/blob/main/docs/guides/publishing.md).

1. **Creator approves making the repository public.** Plugin Manager fetches plugin source and assets by commit from GitHub, so a private repository is not a viable public browser source.
2. Confirm the repository root has `info.toml`, `main.as`, `icon.png`, `placeholder.png`, `sounds/`, `README.md`, and `LICENSE`. No binaries or compiled archives should be checked in for browser distribution.
3. When the plugin has passed final review, create an **immutable** git tag matching the manifest version: `v0.1.8` for `version = "0.1.8"`. This is **not yet done**.
4. Open an **issue** in the [Ballest Plugin Manager repository](https://github.com/AnythingGoes-ballest/ballest-plugin-manager/issues) requesting addition of **`YT-skyfall/ballest-map-roulette`** at **`v0.1.8`**. The maintainer reviews it and adds its pinned commit and per-file SHA-256 hashes to `registry.json` (via `python tools/registry.py add ../ballest-map-roulette v0.1.8`).
5. Once the reviewed registry entry is merged, the plugin appears in the in-game browser; players can click **install**. Future updates use a new manifest version, a new immutable tag, and a new registry request.
6. A GitHub Release page/asset ZIP is **optional** for registry publication. A tag alone is sufficient under the official guide. Do not conflate this with a public GitHub Release or automatic distribution.

Suggested issue text (send only **after** approval):

> **Request: Add Map Roulette v0.1.8 to Plugin Manager**
>
> Repository: `https://github.com/YT-skyfall/ballest-map-roulette`
>
> Tag: `v0.1.8`
>
> Author: Sky.
>
> Map Roulette is an optional Steam Workshop map picker for Ballest. It has filters, a randomized thumbnail reel, manual/automatic map opening, and adjustable spin audio. It requires host 0.26.0+. The author-time prefilter is experimental for previously checked maps and documented. The repository includes the source, icon, audio assets, README, and license.

**Important:** No contact with the maintainer is required until this final request. Do not open the issue until the creator asks to submit.
