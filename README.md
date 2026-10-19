<div align="center">

<img src="icon.png" alt="Map Roulette icon" width="96">

# Ballest Map Roulette

**Can't decide what map to play? Let the roulette choose.**

A free, community-made plugin for **Ballest of Them All** that picks a random Steam Workshop map from your chosen filters.

**Windows · Steam · Plugin Manager 0.26.0+ · Version 0.1.8**

</div>

> [!NOTE]
> **Map Roulette isn't in Plugin Manager's in-game browser yet.** Once it's listed, you can install it with one click. In the meantime, you can install it manually if you have access to the plugin files. Instructions for both methods are below.

## What does it do?

Map Roulette searches community-created tracks in Ballest's **Hub (Steam Workshop)**, filters the results, and randomly selects what you'll play next. Watch the map previews roll by, see which track wins, then play it or spin again.

**Features**

- **Random map selection** — Each eligible Workshop map has an equal chance of being selected.
- **Search and filters** — Search for maps or narrow your choices by tags, rating, play count, and whether you've finished them.
- **Animated roulette** — Spin through real map thumbnails, with the current selection highlighted in the center.
- **Map preview and reveal** — See the winner's thumbnail and title before opening it.
- **Manual or automatic play** — Play the selected map yourself, or let it open after a short countdown.
- **Music and effects** — Choose a music volume and toggle spinning clicks and the winner sound.
- **Quick access** — Open Map Roulette from the game's menu, footer, or with **F7**.

## Requirements

- **Ballest of Them All** on **Windows via Steam**
- **[Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager)**, host version **0.26.0 or newer**
- An internet connection and access to the Steam Workshop

Map Roulette is a Plugin Manager plugin. **You do not need UE4SS**, and it does not belong in a `Mods` folder.

## Installation

### Recommended: Install through Plugin Manager

*Available once Map Roulette is added to the in-game plugin browser.*

1. [Install Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager#install).
2. Launch **Ballest of Them All**.
3. Open **plugins** from the main menu.
4. Find **Map Roulette** in the plugin browser and select **install**.
5. Open **map roulette** from the menu or footer, or press **F7**.

Plugin Manager handles downloading and installing the required files.

### Manual installation

*Use this method if Map Roulette is not listed in Plugin Manager and you have the plugin files.*

1. Install **Ballest Plugin Manager** using the link above.
2. In Ballest, open **plugins → open plugins folder** to find the correct installation directory.
3. **Close Ballest** before copying files.
4. Get the Map Roulette files from this repository using **Code → Download ZIP**, then extract the ZIP.
5. Create a folder called `map-roulette` inside the `plugins` directory, if it doesn't exist.
6. Copy `main.as`, `info.toml`, `icon.png`, `placeholder.png`, and the entire `sounds` folder into `map-roulette`.
7. Start Ballest again. Map Roulette should appear in the menu, footer, or when you press **F7**.

Your installation should look like this:

```text
plugins/
└── map-roulette/
    ├── info.toml
    ├── main.as
    ├── icon.png
    ├── placeholder.png
    └── sounds/
        ├── music_00.wav ... music_15.wav
        ├── tick.wav
        └── reveal.wav
```

**Do not** copy the entire GitHub repository into the plugins folder or modify Plugin Manager's `version.dll`.

## How to use Map Roulette

1. **Open Map Roulette** from Ballest's main menu, the footer, or **F7**.
2. **Search for maps.** Type a name or keyword under **WORKSHOP SEARCH**, or leave it blank to search broadly.
3. **Choose your options.** Select **MORE FILTERS** if you want to narrow the results. You can also set music, sounds, and automatic map opening on the main screen.
4. **Click FIND MAPS.** Wait for Steam Workshop results to finish loading.
5. **Click SPIN THE ROULETTE.** The thumbnails roll through your matching maps and stop on a winner.
6. **Choose what happens next:** **PLAY THIS MAP**, **SPIN AGAIN**, or **FILTERS** to search again.

The selected map does **not** have to be installed ahead of time; Steam handles Workshop content when the game opens it.

### Controls and options

| Control | What it does |
| --- | --- |
| **WORKSHOP SEARCH** | Searches Workshop maps by name, description, or other matching text. |
| **MORE FILTERS** | Opens the additional search options shown below. |
| **FIND MAPS** | Starts a fresh Workshop search using the current settings. |
| **RESET FILTERS** | Clears search restrictions without resetting your music or auto-open preferences. |
| **Auto-open selected map** | Opens the winning map automatically about **6 seconds** after the reveal. |
| **Music** | Off, quiet (default), or normal volume. |
| **Click + reveal sounds** | Toggles spinning and winner sound effects. |
| **STOP SPIN** | Cancels the current spin without picking a winner. |
| **SPIN AGAIN** | Selects another random winner from the same eligible map pool. |
| **FILTERS** | Returns to the search screen. |

**Closing the window before auto-open begins cancels the countdown.** Changing a filter does not change the current pool until you click **FIND MAPS** again.

### Advanced filters

| Filter | How it works |
| --- | --- |
| **Sort** | Changes the order of Workshop search results. It does **not** make particular maps more likely to win. |
| **Minimum rating** | Includes only maps that meet the selected rating threshold. |
| **Minimum plays** | Includes only maps with at least the selected number of recorded play sessions. |
| **Include all tags** | Only maps containing **all** entered tags qualify. Separate multiple tags with commas. |
| **Exclude tags** | Maps containing the entered tags are excluded. Separate multiple tags with commas. |
| **Only maps I haven't finished** | Removes maps for which Ballest has a recorded completed time. |
| **Author time** | **Experimental.** See the limitation below before using this filter. |

> [!WARNING]
> **Author-time filters are limited in this version.** Map Roulette can check an author's target time after a map has been opened, but it can't reliably retrieve that time for *every unplayed Workshop map*. Adding a minimum or maximum author time excludes maps whose times are unknown, even if they would otherwise qualify. For normal random selection, **leave both author-time fields blank**. This is tracked in [issue #1](https://github.com/YT-skyfall/ballest-map-roulette/issues/1).

## Updating and uninstalling

**Installed through Plugin Manager?** Open **plugins** in Ballest, find Map Roulette, and select **update**, **turn off**, or **remove** as needed. New versions appear when they've been added to the Plugin Manager registry.

**Installed manually?** Close Ballest, then replace the files inside `plugins/map-roulette/` to update, or delete **only that folder** to uninstall. Don't delete the entire `plugins` directory.

## Troubleshooting

<details>
<summary><strong>Map Roulette doesn't appear</strong></summary>

Make sure Ballest Plugin Manager is installed and up to date. If you installed Map Roulette manually, verify the `plugins/map-roulette/` folder structure above and restart the game. You can check **plugins → console** for loading errors.

</details>

<details>
<summary><strong>No maps show up</strong></summary>

Check your Steam connection, clear the search or advanced filters, and run **FIND MAPS** again. Leave author-time limits blank unless you specifically want to use previously checked maps.

If a search contains **more than 10,000 Workshop results**, narrow it with keywords or tags. Map Roulette deliberately avoids drawing from an incomplete search.

</details>

<details>
<summary><strong>Thumbnails are blank or a map won't open</strong></summary>

Steam may take a moment to download map previews. A temporary placeholder is normal. For map-loading failures, check that Steam is online, then try another map.

</details>

<details>
<summary><strong>The music continues briefly after stopping</strong></summary>

A short sound segment may finish playing after you stop a spin or close the window. This is a limitation of the available sound API, not an endless music loop.

</details>

If you're still having trouble, open **plugins → console** or check the Plugin Manager log at:

```text
%LOCALAPPDATA%\Ballest\Saved\PluginManager\host.log
```

You can [report a bug or suggest an improvement](https://github.com/YT-skyfall/ballest-map-roulette/issues). Include the plugin version, what happened, and any relevant errors. Avoid sharing personal information or unrelated log entries.

## Known limitations

- **[Author-time filtering](https://github.com/YT-skyfall/ballest-map-roulette/issues/1):** Only dependable for previously checked maps. Leave both fields blank for ordinary searches.
- **[Very large searches](https://github.com/YT-skyfall/ballest-map-roulette/issues/2):** Searches above 10,000 results require narrower filters.
- **[Thumbnail loading](https://github.com/YT-skyfall/ballest-map-roulette/issues/3):** Preview images may temporarily show placeholders.
- **[Sound stopping](https://github.com/YT-skyfall/ballest-map-roulette/issues/4):** A sound already playing may have a brief tail.
- **[Roulette animation](https://github.com/YT-skyfall/ballest-map-roulette/issues/5):** The reel moves in steps rather than a continuous slide.

## Credits and license

Created by **Sky.** for the Ballest community.

Map Roulette uses the [Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager). Its music is a newly synthesized arrangement inspired by Edvard Grieg's public-domain composition *In the Hall of the Mountain King*; it is not a commercial recording.

The project is available under the [MIT License](LICENSE). See the [changelog](CHANGELOG.md) for version history.

**Map Roulette is an independent, unofficial community project and is not affiliated with or endorsed by the developers of Ballest of Them All or the Plugin Manager.**
