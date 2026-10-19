# Audio provenance — Map Roulette v0.1.8

This file records how the audio shipped in Map Roulette originated. It is included to make third-party licensing and review straightforward.

## Music

- The music is a **newly synthesized, short rendition** of Edvard Grieg's *In the Hall of the Mountain King* (from *Peer Gynt*). The underlying historical composition is in the public domain, including in the United States.
- **Map Roulette's own 16 music segments** (`sounds/music_00.wav` to `music_15.wav`) were **generated programmatically for this project** as 16-bit PCM WAV audio. The original v0.1.5 AUDIO TEST BUILD notes explicitly record that no existing artist's recording or commercial sample was used.
- The `sounds/tick.wav` and `sounds/reveal.wav` sound effects were also newly generated for the plugin.
- All **18** audio files in the v0.1.8 candidate were compared against the original v0.1.5 AUDIO TEST BUILD archive and are **byte-for-byte identical** (SHA-256 for `music_00.wav`: `797e006ba75e2c985e28e68859832eb5d3e2cc0f4376f3bd2ce513a5cf75c448`).
- The source-generation code is **not retained** in this repository. The original build's contemporaneous notes are the evidence for the synthesis method; the byte comparison confirms the candidate audio files were not replaced later.

**Composition credit:** Edvard Grieg — *In the Hall of the Mountain King* (*Peer Gynt*). This credit does not imply Grieg or any third-party recording artist endorses the plugin.

**Rights distinction:** The public-domain composition and its specific sound recording are separate works. Map Roulette includes its **own programmatically synthesized audio**, not a copied modern performance or recording. No third-party sample or recording license is required on the basis of the documented creation method.

The project distributes its original materials under the root `LICENSE`; no ownership of Grieg's public-domain musical composition is claimed. This note documents provenance, not a legal opinion for every jurisdiction.

## Other assets

The project creator confirmed the right to publish `icon.png` and `placeholder.png` in October 2026.

## Technical format

- 16 music segments: mono, 16-bit PCM, 22,050 Hz; **0.86 seconds per segment**.
- `tick.wav`: mono, 16-bit PCM, 22,050 Hz; **0.048 seconds**.
- `reveal.wav`: mono, 16-bit PCM, 22,050 Hz; **0.8 seconds**.

The Plugin Manager plays these WAVs as one-shot sounds; a short already-playing segment may continue after stopping a spin.
