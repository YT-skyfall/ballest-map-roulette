# Development notes

## Working baseline

- **Map Roulette v0.1.5** is the creator-tested gameplay and audio baseline.
- Keep Map Roulette separate from the **Ballest Practice Mode** project.
- The intended installation directory is `Ballest/Binaries/Win64/plugins/map-roulette/`.
- Requires Plugin Manager host **0.26.0+** (creator used host 0.28.0).

## Manual setup for private testing

**This section is only for unreleased test builds.** Normal players should install, update, and remove Map Roulette through Plugin Manager after its registry listing has been approved.

1. Install the [AnythingGoes Ballest Plugin Manager](https://github.com/AnythingGoes-ballest/ballest-plugin-manager#install).
2. Start Ballest. Use **plugins → open plugins folder** to open the correct directory in File Explorer, then close Ballest.
3. In this private repository, choose **Code → Download ZIP** and extract the ZIP.
4. Rename the extracted `ballest-map-roulette-main` folder to `map-roulette`.
5. Copy the full folder to the opened `plugins` directory.

Expected structure:

```text
plugins/
  map-roulette/
    info.toml
    main.as
    icon.png
    placeholder.png
    sounds/
      music_00.wav ... music_15.wav
      reveal.wav
      tick.wav
```

Start Ballest again. The plugin should load from the folder and be accessible from the main menu, footer, or **F7**. Check Plugin Manager's console if there is a compilation error.

For a **private manual update**, close Ballest and replace the files in `plugins/map-roulette/`; then restart. To **remove a private test build**, use Plugin Manager's **remove** action when available, or close Ballest and delete **only** `plugins/map-roulette/`. Do not delete the entire `plugins` folder.

Once Map Roulette is accepted into Plugin Manager's public registry, use the built-in **install / update / remove** buttons instead. Installing a local test folder alone does not make it a registry-managed release.

## Open issue: author-time filtering

The creator reports that the minimum/maximum author-time fields appear ineffective. Map author medal time is **not** the player's best time, an estimated completion duration, or a rating/plays proxy.

`Workshop::Find` currently exposes Workshop metadata such as title, tags, rating, plays, preview, and updated timestamp, but no trustworthy public author-medal time accessor. `Race::AuthorTime()` reads the real author goal only for the currently loaded track.

The Plugin Manager C++ host already retrieves Steam UGC developer metadata internally (`steam::Details.metadata`), but doesn't expose it to AngelScript. It is *not established* whether it includes author time.

### Research and fix plan

1. Inspect Ballest's in-game Hub author-time UI, if displayed for unplayed Workshop tracks, and identify the underlying data source.
2. Expose Steam UGC developer metadata through a narrowly scoped read-only experimental host API, then examine multiple actual maps.
3. Verify any candidate field against the game's author-goal display, including never-played and recently updated maps.
4. Only if verification succeeds, add parsing and a strict filter **before spin selection**. Unknown times must not be treated as zero.
5. If no reliable pre-launch source exists, remove or clearly limit the author-time filter before public release. Do not invent times.

Research upstream: https://github.com/AnythingGoes-ballest/ballest-plugin-manager

## Public release checklist

- [ ] Author-time filtering resolved or removed / clearly marked unavailable
- [ ] All files, assets and source checked into the private repository
- [ ] Fresh install tested with Plugin Manager
- [ ] Search / filters / random spin / winner loading tested
- [ ] Sound off / quiet / normal and cancellation tested
- [ ] Repeated spins and extended gameplay tested without compile errors or timeouts
- [ ] A current real in-game screenshot uploaded
- [ ] Public redistribution license chosen
- [ ] Version and release notes verified
- [ ] Creator explicitly approves making the repository public
- [ ] For Plugin Manager browser distribution, follow maintainer's reviewed registry workflow
