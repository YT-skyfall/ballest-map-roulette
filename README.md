<div align="center">

<img src="icon.png" alt="Map Roulette icon" width="96">

# Ballest Map Roulette

**Not sure what to play next? Let the roulette choose.**

A free, unofficial map picker for **Ballest of Them All**, powered by real Steam Workshop maps.

**Version 0.1.8** · Windows / Steam · Requires Ballest Plugin Manager

</div>

> [!IMPORTANT]
> **Not listed in Plugin Manager yet.** The project is being prepared for review. When the plugin is accepted into the in-game browser, you'll be able to install it there. The repository is private during this preparation stage; no public release or registry submission has been made.

## What is Map Roulette?

Map Roulette searches maps from Ballest's **Hub / Steam Workshop**, applies any filters you choose, then draws a random map. It shows real map thumbnails during the spin and lets you play the result, spin again, or return to your search. **Every eligible map has the same chance of winning**, regardless of its position in the Workshop search results.

### What you can do

- **Search the Workshop:** Search by map title, description, or tags, or leave the search empty for a broad pool.
- **Fine-tune your pool:** On **MORE FILTERS**, adjust sort order, included/excluded tags, minimum rating, minimum play sessions, and whether you've already finished a map.
- **Watch the roulette:** A five-thumbnail reel spins and gradually slows onto a randomly chosen map. With only one eligible map, the spin can only choose that map.
- **Pick what happens next:** Click **PLAY THIS MAP**, **SPIN AGAIN**, or go back to filters.
- **Customize the sound:** Turn music off, keep it quiet (default), or use normal volume. Spinning clicks and the reveal sound can be toggled.
- **Play manually or automatically:** With auto-open on, the winner starts loading after a roughly **6-second** reveal countdown. Closing the roulette before loading starts cancels it.
- **Open quickly:** Use the main menu, the footer, or **F7**.

## What you need

- **Ballest of Them All** on **Windows through Steam**
- **[Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager#install)** (host **0.26.0 or newer**)
- Steam online and working Workshop access for searches and downloads

Map Roulette is a **Plugin Manager plugin**, not a UE4SS mod. You **do not** need to install UE4SS or copy anything into a `Mods` directory.

## How to install (once it is listed)

1. Install [Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager#install), if you haven't already.
2. Start Ballest and open **plugins** on the main menu.
3. In Plugin Manager's browser, find **Map Roulette**.
4. Select it and press **install**.
5. Open **map roulette** from the main menu or footer, or press **F7** (some keyboards require **Fn + F7**).

**You cannot find Map Roulette in the public browser yet.** These are the installation steps *after* approval. If you are an authorized tester with the private files, use [Private test installation](docs/DEVELOPMENT.md#private-test-installation) instead.

## How to play

1. Open **Map Roulette** while on Ballest's main menu.
2. Type a Workshop search if you like, or leave the search field blank. **MORE FILTERS** is optional.
3. Click **FIND MAPS** and wait for the full search to finish. Large searches can take longer.
4. Look at the number of eligible maps in **YOUR RESULTS**. If no maps qualify, adjust your filters and search again.
5. Choose **SPIN THE ROULETTE**. The map shown at the center of the reel is the current candidate; the spin stops on the winner.
6. On the winner screen, choose **PLAY THIS MAP**, **SPIN AGAIN**, or **FILTERS**. If auto-open is enabled, the map will open automatically after the countdown unless you close the UI.

**MORE FILTERS:** Tag fields accept comma-separated names. Leave any field empty to avoid adding that restriction. Filtering options are applied when you click **FIND MAPS**, so run a fresh search after changing them. **RESET FILTERS** clears search/filter choices without changing sound or auto-open preferences.

**STOP SPIN:** Ends the animation without selecting a winner. You can return to the search and spin again. **Close** or **Escape** dismisses the UI. You can open Map Roulette with **F7**.

## Filters explained

| Option | What it changes |
| --- | --- |
| Workshop search | Finds maps using Steam Workshop search. Blank = broad search. |
| Sort | Controls Workshop result ordering, **not** which map is more likely to win. |
| Minimum rating | Excludes maps below the selected Workshop star-rating threshold. |
| Minimum plays | Excludes maps with fewer than the selected play sessions. |
| Include tags (all) | Requires all listed tags. Separate with commas. |
| Exclude tags | Excludes maps with listed tags. Separate with commas. |
| Only maps I haven't finished | Excludes maps with a recorded personal completion time. |
| Author time (experimental) | **Only works for maps whose true author time has previously been learned by loading them.** Leave blank for normal use. |

> [!CAUTION]
> **Author-time limitation:** Ballest's Hub can show author times for unplayed maps, but the current Plugin Manager API doesn't supply them to Map Roulette's Workshop search. With a Min or Max author-time limit, maps whose times aren't known are excluded, even when they would otherwise qualify. **Leave both author-time fields blank** for unrestricted searches. This work is postponed to a later version; see [issue #1](https://github.com/YT-skyfall/ballest-map-roulette/issues/1).

## Updating or removing it

After Map Roulette is listed in Plugin Manager, open **plugins**, select Map Roulette, then use **update**, **turn off**, or **remove** as needed. Updates become available when a new version is reviewed and entered in Plugin Manager's registry—not merely when a GitHub commit appears.

Private testers who installed files manually can replace or remove only their `plugins/map-roulette/` test folder; see the [development guide](docs/DEVELOPMENT.md#private-test-installation). Don't delete Plugin Manager or other plugins.

## Troubleshooting

**Can't find Map Roulette in the browser?** It has **not been listed yet**. After it is added, restart Ballest or reopen the plugin browser if necessary.

**Nothing happens when opening it?** Confirm Plugin Manager is running and the plugin isn't turned off. For a manual test install, double-check the folder layout and open **plugins → console** for AngelScript errors.

**Search returns no maps?** Check Steam connectivity, clear the search and advanced filters, and search again. Author-time Min/Max fields should normally be empty.

**A search finds over 10,000 maps?** Narrow it with search terms or tags. The mod doesn't choose winners from an incomplete subset of a much larger search.

**Images are blank or show placeholders?** Steam may still be fetching previews; give them a moment to load. If a map fails to open, check Steam and try another result.

**Audio continues briefly after stopping?** The current Plugin Manager audio API cannot instantly stop a sound segment that has already begun. A short tail is a known limitation.

**Unexpected issue?** In Ballest, open **plugins → console** or check:

```text
%LOCALAPPDATA%\Ballest\Saved\PluginManager\host.log
```

Include the plugin version, a brief description of the problem, and relevant error lines in a [GitHub issue](https://github.com/YT-skyfall/ballest-map-roulette/issues). Don't upload unrelated private information from your logs.

### Known limitations and tracked improvements

- [#1 Author-time prefiltering for unplayed maps](https://github.com/YT-skyfall/ballest-map-roulette/issues/1) — deferred until a later update.
- [#2 Searches above 10,000 results](https://github.com/YT-skyfall/ballest-map-roulette/issues/2) — intentionally require narrower filters.
- [#3 Workshop thumbnails may load asynchronously](https://github.com/YT-skyfall/ballest-map-roulette/issues/3).
- [#4 Very short sound tail after stopping](https://github.com/YT-skyfall/ballest-map-roulette/issues/4).
- [#5 Reel advances in steps, not a continuous slide](https://github.com/YT-skyfall/ballest-map-roulette/issues/5).

## About

Created by **Sky.** Map Roulette is an independent, unofficial community plugin. It uses Ballest Plugin Manager's supported AngelScript API; it doesn't require a modified host, a Steam API key, or an external account.

The spin music is a newly synthesized arrangement inspired by Edvard Grieg's public-domain work *In the Hall of the Mountain King*. No third-party commercial recording is included.

For changes across versions see [CHANGELOG.md](CHANGELOG.md). The [license](LICENSE) covers the repository's original project material. See [release preparation](docs/RELEASE.md) for the private review process.

**Not affiliated with, endorsed by, or an official feature of Ballest of Them All or AnythingGoes.**
