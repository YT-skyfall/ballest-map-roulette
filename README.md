# Ballest Map Roulette

A roulette-style map picker for **Ballest of Them All**, created by **Sky.** Search community Hub maps, spin a reel of real map thumbnails, and play the selected map.

> **Private development repository — v0.1.5.** The roulette and audio have been tested by the creator. **Author-time filtering is currently unreliable**, especially for maps that have never been opened. Do not depend on a maximum time limit yet. No public release has been made.

## Features

- Search community Hub / Steam Workshop maps with real thumbnails
- Filter by search text, tags, rating, play count, and whether you've finished a map
- Five-map roulette with a clearly displayed winner, spin again, and optional automatic map launch
- Optional quiet dramatic spin music, reel clicks, and winner sound
- Experimental Min/Max Author Time fields (**not reliably working**)

## Requirements

- **Ballest of Them All** on Windows through Steam
- [AnythingGoes Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager) installed and working (host **0.26.0 or newer**)

**Important:** Map Roulette is a Plugin Manager plugin, *not* a UE4SS mod. It belongs in the `plugins` folder, not `Mods`.

## Install manually on Windows

**The repository's full source and assets are being prepared. Do not attempt installation from this README until `main.as`, `icon.png`, `placeholder.png`, and the `sounds` folder are all present.**

1. Close Ballest completely.
2. Open your **Steam Library**. Right-click **Ballest of Them All** → **Manage** → **Browse local files**.
3. Open `Ballest` → `Binaries` → `Win64` → `plugins`. If `plugins` is missing, confirm Plugin Manager is installed properly first.
4. Create a new folder named **`map-roulette`** inside `plugins`.
5. Copy these items into `map-roulette` so the layout is:

   ```text
   plugins/
   └── map-roulette/
       ├── info.toml
       ├── main.as
       ├── icon.png
       ├── placeholder.png
       └── sounds/
           ├── music_00.wav ... music_15.wav
           ├── reveal.wav
           └── tick.wav
   ```

6. Restart Ballest. Open **Map Roulette** from the game's menu, Plugin Manager's footer, or press **F7**.

**Example Steam path:** `C:\Program Files (x86)\Steam\steamapps\common\Ballest of Them All\Ballest\Binaries\Win64\plugins\map-roulette`. Your game may be installed on another drive. **Avoid a nested `map-roulette\map-roulette` folder.**

## Use

1. Open Map Roulette and select your Workshop filters.
2. **Leave the author-time fields empty until that feature is fixed.**
3. Click **FIND MAPS**, wait for the search, then click **SPIN ROULETTE**.
4. Choose **PLAY THIS MAP** or **SPIN AGAIN**. Alternatively, enable automatic launch.
5. Audio settings include **Off**, **Quiet** (default), and **Normal**, plus independent spin/winner sound effects.

## Update / uninstall

**Update:** Close Ballest, replace the plugin's files with the new version, then restart. Keep the folder named `map-roulette`.

**Uninstall:** Close Ballest, then delete only `plugins\map-roulette`. Do not delete Plugin Manager or other plugins. Some saved plugin settings may remain elsewhere.

## Troubleshooting

- **No entry in the menu?** Confirm Plugin Manager is running, and `info.toml` and `main.as` are directly in `plugins\map-roulette`. Restart the game.
- **No music?** Confirm the `sounds` folder includes all WAV files. Try Normal music volume, and check your game's sound settings.
- **Search or loading error?** Confirm Steam is online. If needed, open **Plugins → Console** or inspect `%LOCALAPPDATA%\Ballest\Saved\PluginManager\host.log`. Review logs before sharing them publicly.

## Known limitations

- **Author-time limits are experimental and not reliable yet.** The public Workshop API used by this plugin doesn't expose every map's true author-medal target before launch. No workaround has been validated for all Hub maps. This is being investigated.
- Very large searches can take time (up to 200 pages / approximately 10,000 Workshop results).
- The reel advances in visible image steps rather than continuous per-pixel movement.
- New thumbnails may temporarily display a placeholder, and a currently playing audio segment may take a moment to finish after stopping.

## Development

This independent AngelScript plugin uses the [AnythingGoes Plugin Manager API](https://anythinggoes-ballest.github.io/ballest-plugin-manager/). It is **not** part of Ballest Practice Mode.

Author-time debugging notes and a public-release checklist will be kept in `docs/DEVELOPMENT.md`. The bundled music is a newly synthesized arrangement of the public-domain composition *In the Hall of the Mountain King*; it is not a commercial recording.

**License:** Public redistribution terms have not been chosen. This repository remains private until the creator explicitly approves publication.
