# Development and private testing

This file is for the creator and private testers. For ordinary users, start with the [README](../README.md).

## Versions and repository status

- **v0.1.8** is the current release candidate on the private `main` branch.
- The creator-tested **v0.1.5** baseline is preserved on `archive/v0.1.5-tested`. This is a Git branch, **not** a public version tag.
- No public GitHub Release or Plugin Manager registry entry has been created.
- This project is **Map Roulette**, separate from Ballest Practice Mode.

## Private test installation

1. Install the regular [Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager#install).
2. Start Ballest and select **plugins → open plugins folder**. Close Ballest entirely.
3. Back up your existing `map-roulette` folder **outside** the Plugin Manager `plugins` directory.
4. Download this private repository via **Code → Download ZIP**. Extract it and locate the **repository root**, containing `main.as`, `info.toml`, `icon.png`, `placeholder.png`, and `sounds/`.
5. Copy only the required plugin files into `plugins/map-roulette/` (see the tree below). Do **not** copy `.git`, `docs`, license notes, or the whole repository into the plugin folder.
6. Start Ballest and open Map Roulette with **F7** or from the main menu. Look in **plugins → console** if AngelScript compilation fails.

```text
plugins/
  map-roulette/
    main.as
    info.toml
    icon.png
    placeholder.png
    sounds/
      music_00.wav ... music_15.wav
      tick.wav
      reveal.wav
```

**Private test update:** Close Ballest, back up the old folder, replace the files with the newer test build, and reopen the game. **Private test removal:** Close Ballest, then delete **only** `plugins/map-roulette/`. Do not remove the entire plugins directory or modify `version.dll`. When the plugin eventually appears in the in-game browser, install/update/remove using Plugin Manager instead.

## Internal implementation notes

- Host requirement in `info.toml`: **0.26.0+**.
- Source entry point: `main.as`. Supporting assets: `icon.png`, `placeholder.png`, and 18 WAV files.
- Steam Workshop results can be paginated through `Workshop::Find`. A query yielding more than **10,000** results requires narrower filters rather than silently sampling a subset.
- The winner is selected from filtered IDs using the mod's pseudorandom generator; Workshop sorting does not weight its selection.
- Author-time Min/Max fields are **experimental**. After loading a map, `Race::AuthorTime()` can be cached with the Workshop revision timestamp. An unchecked/unopened map is deliberately excluded when author-time filters are active. Leave limits blank for ordinary use. The upstream host internally retrieves Steam UGC metadata but does not expose the author-time field via the current script API. Investigation deferred to a later version.
- Sound uses short one-shot WAV segments; a currently playing segment may trail briefly after cancellation.
- The current reel scrolls in steps using the supported widget API.

Research and remaining work are tracked in [Issues](https://github.com/YT-skyfall/ballest-map-roulette/issues). Do not silently introduce altered host binaries or external Steam API keys.

## Before public review

See [RELEASE.md](RELEASE.md) for the complete gate checklist, upstream publishing process, and a suggested submission template. The MIT [LICENSE](../LICENSE) is prepared in this private repo; the creator should approve licensing original art/audio before the repository is made public.
