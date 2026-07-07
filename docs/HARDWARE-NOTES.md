# Hardware Notes

Practical findings from building DMGARP on real DMG hardware. These are
things not covered in Pan Docs or standard GB tutorials — register quirks,
perception rules, and architecture patterns that only surfaced through testing
a real instrument.

## Sound Registers

### Envelope (NR12/NR22): VVVV DPPP
- Period 0 = sustained (volume stays constant). Use $F0 for full vol sustained.
- `and $0F | $20` does NOT reliably set quiet volume — the D bit from attack presets causes ramp-up. Fix: use complete fixed bytes ($60 = vol 6 sustained, $10 = vol 1 sustained).
- Vol 1 ($10) is audible but barely. Vol 6 ($60) is a usable "medium quiet."
- Writing $00 to NR22/NR12 silences the channel (gate off).

### Frequency Register (NR13-14/NR23-24)
- 11-bit register (0-2047). `freq_hz = 131072 / (2048 - register_value)`.
- FreqTable: 60 entries C2-B6, 2 bytes each (little-endian).
- Between semitones: ~50-100 register steps at low octaves, ~3-7 at high octaves. Enough for quarter-tones across full range.
- Detune: add small offset (1-14) to low byte for chorus/beating effect. Offset 1-2 = subtle, 8-14 = aggressive.

### Duty Cycle (NR11/NR21 bits 7-6)
- 00 = 12.5%, 01 = 25%, 10 = 50%, 11 = 75%
- 50% is the "standard" square wave. 12.5% is thin/nasal. 25% has hollow character.

### Wave Channel (CH3: NR30-NR34, Wave RAM $FF30-$FF3F)
- Wave RAM = 32 samples × 4 bits, packed into 16 bytes (high nibble = first sample of each byte).
- NR30 bit 7 must be OFF before writing Wave RAM, then turned back ON. Writes while NR30 is on produce garbage waveforms.
- NR32 volume encoding is non-intuitive: bits 6-5 = 00 (mute), 01 (100%), 10 (50%), 11 (25%). Only 4 levels, no envelope.
- CH3 has no envelope register — no attack/decay. Volume is fixed at whatever NR32 says until changed.
- CH3 uses the same 11-bit frequency formula as CH1/CH2. Existing FreqTable works directly via NR33/NR34.
- Gate-silence CH3 via NR32=$00 (volume mute), NOT NR30=$00 (channel off). Toggling NR30 off requires reloading Wave RAM before the next note.
- **CH3 trigger pop**: Writing NR34 with bit 7 (trigger) restarts the wave from position 0, causing an audible phase-discontinuity click. On DMG, the first fetched sample after trigger may be index 1, and the trigger can corrupt Wave RAM reads. Fix: track a "running" flag and skip trigger on subsequent notes — just write NR33/NR34 without bit 7. Frequency updates take effect at the next wave period (imperceptible latency). Trigger only on first note, after waveform change, or after pause. Use mute→trigger→unmute sequence for clean initial trigger.

### Waveform Presets
- All presets should use sustained envelope ($F0) when gate is the sole note-length control. Fast-decay presets ($F1) sound staccato even at full gate because they decay in ~234ms.

### Envelope vs Gate-Off Window Mismatch (CH4 noise fill)
- Hardware envelope min step = 1 × (1/64)s ≈ 16ms, max range traverse = 15 × 16ms ≈ 240ms (step=1, fastest).
- Typical arp gate-off windows are 30-70ms — only ~2-4 envelope steps fit before the next note-on cuts the channel. A "per-burst envelope" (init at 0, ramp up; or init at 15, ramp down) is therefore inaudible: each burst sounds like a constant volume because the envelope barely moves.
- Three workable shape strategies for a multi-burst noise/fill channel:
  1. **Software volume table indexed by cycle phase** (multi-hit shapes like UPC/UPW): every gate-off retriggers CH4 with a precomputed volume nibble + step=0 (envelope off). Curve shape lives in a 16-byte LUT, not in hardware. Works at any tempo.
  2. **Per-cycle hardware envelope** (one swell or decay per cycle): trigger once per cycle, skip the note-on mute, let the envelope tick across multiple notes. Audible but loses the "rhythmic, multi-hit" character — the channel becomes one continuous tone.
  3. **Constant volume per burst** (FLT): NR42 high nibble = volume, step=0. Always works, no shape.
- The user-facing shape variety on a per-burst channel is best built from #1 + #3, not from per-burst hardware envelopes.

### Multi-Step Sounds Must Outlive the Gate-Off Mute
- An arpeggiator's gate-off path typically writes `DAC_ON_SILENT` ($08) to NR12/NR22 and retriggers NR14/NR24 to silence melody channels at gate expiry.
- Any audio feature whose body is *supposed* to ring across step boundaries (a kick drum on CH1 with NR12=$F2 ~260ms decay, a layered pad, an across-cycle envelope) gets clipped by this mute unless the gate-off path checks for it.
- Pattern: store an "audio feature active" countdown in HRAM (frames remaining), tick down in VBlank, and guard the per-channel mute with `ldh a, [hFeatureFrames]; and a; jr nz, .skip<channel>Mute`. One byte per feature, decrement-with-saturate is 4 instructions.
- Symptom of a missed guard: the feature sounds like a thin click instead of a full hit (the body got cut after one frame).

## Perception & UX

### Speed/Tempo
- Human tempo perception is logarithmic. Linear frame steps sound uneven: fast end changes feel huge (50-100% per step), slow end changes are imperceptible (~3%).
- Solution: lookup table with exponential spacing (~15-20% per step). 32 entries from 1-250 frames covers the full range with even perception.
- Display as `32 - index` (higher = faster) for intuitive numbering.

### Tap Tempo
- 60fps gives ~17ms resolution. At 120 BPM (30 frames), accuracy is ~3.3% — good enough for band sync.
- BPM = 3600 / frame_count. Use 16-by-8 shift-and-subtract division (16 iterations, very fast).
- Phase sync: after tempo stabilizes (~5 taps), force hStepReady=1 on each tap so arp notes land on beats.
- Subdivisions (divide by 2, 3, 4) let users tap at comfortable rate for fast arpeggios. Pre-compute effective interval to keep VBlank ISR division-free.
- Timeout at 255 frames (~4.25s) resets tap session.

### Volume
- Vol 15 is max. Vol 6 = usable "medium." Vol 1 = barely audible texture.
- For dual-channel detune, progressive volume reduction works well: DT1-2 full, DT3 vol 10, DT4 vol 6, DT5 vol 3.

### CH1 OFFSET dead zone below ~25% (V34 perception finding)
- OFFSET is a pure timing delay; it never touches CH1's volume or envelope registers. FireCH1Now retriggers the envelope fresh every fire — the note is always at the programmed wCH1Volume.
- Small offsets (06–19%) nonetheless *sound* weak because of two stacked effects:
  1. **Frame quantization.** offset_frames = (speed × mult) >> 5 with mult 2/4/6. At most tempos this rounds to 0–1 frames (at speed 12: 06%→0, 12%→1, 19%→2). A result of 0 is treated as "fire immediately" — identical to OFFSET=OFF.
  2. **Temporal masking.** A CH1 onset within 1–2 frames of CH2's note-on fuses perceptually; CH1 thickens CH2 but doesn't register as a separate, "louder" hit. Past ~25% the two onsets separate enough to be heard distinctly.
- Both effects are limitations of the deferred-fire design, not bugs. Useful range starts around 25% (index 4, mult 8). Documenting rather than adjusting the multiplier table because the "dead zone" doesn't hurt anything — OFFSET=OFF is a clearer choice for the same result.

## Architecture Patterns

### VBlank-Safe VRAM Writes
- VRAM only accessible during VBlank (~1.1ms) or when LCD is off.
- For small updates (2-3 tiles): write directly in UpdateHUD after `halt` (within VBlank window).
- For full-page redraws: disable LCD (`ld a, 0 / ldh [rLCDC], a`), write freely, re-enable (`ld a, $91 / ldh [rLCDC], a`). Use deferred redraw flag (wPageRedraw) processed at MainLoop start.

### Deferred Page Redraw
- Set wPageRedraw flag in TogglePage. Process after `halt` in MainLoop (skip UpdateHUD on that frame).
- DisableLCD -> BlankPageRows -> DrawData with new page data -> re-enable.
- Prevents HUD corruption from partial writes during VBlank.
- All pages call BlankPageRows before drawing their control labels (added to page 1 in V18 after stale row 5 corruption). Value columns (cols 17-19) are NOT cleared by BlankPageRows — each page's UpdateHUD must explicitly write or blank every value cell it owns.

### Input System
- Read buttons -> diff with previous -> new presses in `c`, held in `b`.
- Modifier combos: check held modifier (A, B, START) then check new directional press.
- Auto-repeat: delay counter (26 frames) then repeat rate (5 frames). Reset counter on new press.
- Page-aware routing: check wCurrentPage early, branch to page-specific handlers.
- **Modifier check ordering in page dispatchers**: If all branches within a page handler `ret` or `jp` early (e.g., A-alone jumps away, AB/B both `ret`), a new modifier check tacked on at the end is dead code. New modifier branches must be placed before existing early-return branches, or the paths must be restructured to fall through to a shared tail.
- Subroutines called from input handlers must preserve `b` and `c` registers. If a subroutine uses b/c internally (e.g., copy loops), add `push bc`/`pop bc`. Corrupted button state causes phantom releases and missed inputs for the rest of that frame.
- **The b/c contract is transitive and easy to break in a chain**. If `Foo` is input-callable and `Foo` `jp`s or `call`s `Bar`, then `Bar` must also preserve b/c — even if `Bar` looks like a pure compute helper. Symptom of a leak: pressing one modifier+direction combo also triggers an unrelated parameter change whose `bit n, c` mask happens to align with the corrupted scratch value. Audit any helper that mutates state from input by: does it touch b or c? does anything it tail-calls?
- Worth tagging input-callable routines with a one-line comment like `; preserves b, c` at the entry, so future edits don't silently grow a divisor loop in the wrong register.

### Phase Counter for Cycle-Length Ramps
- "Volume varies across the arp cycle" features (across-cycle ramp, accent on cycle-start) need a stable phase signal independent of `wArpPosition` — that variable bounces in PINGPONG and has no meaning in RANDOM.
- Pattern: dedicated `wCyclePhase` counter (1 byte). Reset to 0 at every cycle-start event in `AdvanceArp` (ASC wrap, DESC wrap, PINGPONG top + bottom reversals). Increment by 1 per played step elsewhere. Read in the gate-off fill path or wherever phase is needed.
- **Reset timing matters**: arming the reset *after* the boundary note has played means the boundary note consumes a phase slot before the reset fires. Steady-state PINGPONG segments are therefore `wNoteCount - 1` notes long, not `wNoteCount` — the only ramp dividing by `wNoteCount` will undershoot. Cache `wFillCycleStep = 16 / (wNoteCount - 1)` for PINGPONG, `16 / wNoteCount` for ASC/DESC.
- The first cold-start segment is one note longer than steady-state segments. Slight oversampling on cycle 1 is preferable to undershooting all subsequent cycles.
- For RANDOM: phase is undefined — use a sentinel (`wFillCycleStep = 0`) and fall back to a constant level in the consumer.

### Interrupt-Driven Timing
- VBlank ISR decrements hSpeedCounter. When 0: set hStepReady flag, reload counter.
- MainLoop checks hStepReady, processes one step, clears flag.
- Swing: modify reload value (speed +/- offset) at step processing time, not in ISR.
- Keep ISR minimal — no division, no WRAM writes beyond counter/flag.

### DrawData Format
- Entries: low_addr, high_addr, length, tile_bytes...
- Terminator: $00, $00, 0
- Reusable for any tilemap region. Called with `ld hl, DataLabel / call DrawData`.

### BG Map Row Width vs Visible Width
- The DMG BG tile map is **32 tiles wide** but only the first **20 tiles per row are visible** (screen is 160 px = 20 × 8). Row N starts at `$9800 + 32*N` (i.e. `$9800`, `$9820`, `$9840`, … `$9A20` for row 17).
- A linear `ld [hli]` loop that walks past 20 tiles silently bleeds into the off-screen tail of the same row, then the visible part of the next row. Bug shape: the loop "looks like it clears rows 7-10" (4 × 20 = 80) but actually clears row 7 cols 0-19, off-screen cols 20-31, row 8 cols 0-19, off-screen cols 20-31, row 9 cols 0-19, … so cols 20-31 of "row 9" are actually cols 8-19 of row 10, and "row 10" stops mid-row 10.
- **Rule:** when blanking N rows, step the base by `0x20` per row and run a fresh ≤ 20-byte loop at each base. Never let one loop count exceed 20.
- Same trap when computing a value-cell address: `$98F1` is *row 7 col 17*, not "row 6 col 17 + a few" — if you're aiming at row 6's value column, that's `$98D1`. Off-by-one-row writes are easy to miss because both rows scroll past in normal play.

### Single-Purpose VBlank Countdowns
- Multi-frame countdowns ticked by the VBlank ISR (`hAccentTailFrames`, `hHelpFrames`) are convenient but easy to misread as a same-step gate signal. They aren't: they stay non-zero for many frames after a trigger, across multiple arp steps at common speeds.
- **Rule:** never branch on `[hXxxFrames] != 0` from any code path that runs once per arp step or once per gate event. If you need a "this just happened" flag, use a separate one-shot byte that you clear before the next step's compute path runs.
- Concrete failure mode (V22 KIK accent): the gate-off branch read `hAccentTailFrames` to decide whether to mute CH1, intending "skip mute right after a kick fires." Because the countdown was still nonzero on subsequent steps, every later gate-off skipped the mute too — gating broke whenever ACCENT=KIK.

## RGBDS Assembler

### Local Label Scope
- Local labels (`.foo`) are scoped to the nearest preceding **global** label, not to logical blocks or `if`/`for` constructs within a routine.
- In a large routine like `UpdateHUD`, two logically separate sections that both use `.ncX` as a carry-skip label will conflict at link time. RGBDS reports "already defined" with both line numbers.
- Fix: use unique suffixes per usage site (`.ncCH1WN`, `.ncWNb`) or pick names reflecting their purpose rather than a generic pattern.



### CH1 Sweep Overflow (NR10)
- If sweep is enabled and frequency calculation overflows 2047, channel silences permanently until NR10 is reset.
- Safe default: NR10 = $00 (sweep off) for arpeggiator use.

### Sound Enable
- Must write $80 to NR52 before any sound register writes.
- NR51 ($FF25) controls stereo panning — $FF = both channels to both speakers.
- NR50 ($FF24) sets master volume — $77 = max both sides.

### Gate Silencing & DAC Toggle Pop
- Writing $00 to NR22/NR12 silences the channel but also disables the DAC. Writing a non-zero envelope value re-enables the DAC — this on/off transition produces an audible click/pop at each note start.
- The pop volume varies with the envelope value being written (louder envelope = bigger pop). Happens on real GB hardware, not just emulators.
- Fix: write $08 (vol=0, direction=up, period=0) instead of $00, then retrigger with $80 to NRx4. The $08 keeps the DAC alive (bit 3 set). The retrigger restarts the envelope at vol 0, giving immediate silence. Without retrigger, zombie mode on DMG can leave the channel audible at an unpredictable volume.
- Applied in DMGARP V16: gate expiry, CH1 inactive/OOR, CH3 replace/skipCH2, SilenceSound. Eliminates note-start pops in emulator testing. Real hardware verification pending.
- **Gate-end pops (hardware-limited)**: CH1/CH2 with sustained high-volume presets (STD/LNG at $F0 = vol 15): writing $08 to NRx2 while channel plays triggers DMG zombie mode, briefly modifying volume before retrigger overrides it. Not present on CGB. CH3: NR32=$00 instant mute from any level is an abrupt step — CH3 has only 4 volume levels and no envelope, so smooth fade-out is impossible.

## Tile Generation

### Runtime XOR-inverted tiles
- The DMG has 256 tile slots ($8000-$97FF) but a typical font uses 30-50 of them, so the upper half of pattern table 0 is wasted.
- Build inverted-color copies at boot by reading the existing tiles back from VRAM and `cpl`-XOR-ing each byte to a higher tile index. Cost: ~16 bytes of code, no extra ROM tile data.
- Constraint: VRAM source reads only return real data with the LCD disabled (or during HBlank/VBlank). Run the routine after `LoadTiles` and before `ldh [rLCDC], a` re-enables the display.
- Used in DMGARP V23+ for inverted-color title bars on pages 1–5: source at $8000 (51 tiles × 16 B = 816 B), destination at $8400 (base index 64).
- The runtime invert covers **all 51 source tiles**, so an inverted version of every A-Z letter (and digits) already exists in VRAM at index 64+TILE_X. The `INV_TILE_*` DEF aliases are opt-in — adding a missing one (e.g., `INV_TILE_O`) is a single source line, no new tile data, no extra VRAM. The "no inverted O exists" assumption that led to the V20 page subtitle reading "METAL" instead of "TONAL" was wrong on this point.

## Gameplay Logic Patterns

### Trigger counters and per-step suppression
- DMGARP CH4 has three time-shared instruments (Tonal Noise, Accent, Fill) plus pattern-gated triggers (HLF=every 2nd note, Q4=every 4th). Each Tonal trigger advances `wTonalTrigCount`; the pattern gate reads the **pre-increment** value so the downbeat fires on counter == 0.
- **Bug shape (V24): per-step suppression that returns before the increment.** When `hAccentTailFrames > 0` (the kick body is still decaying), the original code returned early without ticking the counter. Each kick effectively paused the HLF/Q4 sequencer for several notes, so when tonal resumed it was no longer aligned to the metric grid.
- **Fix shape (V25): one shared post-gate increment site.** Route every non-feature-off exit (accent-tail, pattern-fail, pattern-pass) through a single `.advance` label that increments and rets. MODE=OFF / LEVEL=0 still bypass the increment — those mean the feature is genuinely off.
- Generalizes: any per-step counter that drives pattern timing must advance on every step where the feature is enabled, not only on the steps that successfully fire. Otherwise per-step suppression sources (here: drum tails) leak into the cadence.

### Modular index spaces vs clamped index spaces
- DMGARP Tonal Noise uses three mapping tables: TRK (60 entries, tracks the 5-octave note range), GML (12 entries, gamelan voicing folded by note % 12), INV (60 entries, contrarian shadow).
- **Bug shape (V24): clamp before mod.** The transposition path computed `note + transp - 12`, clamped to `[0, 59]`, then took `% 12` for the GML lookup. Edge transposes (note 0, transp = -1) clamped to 0 before the mod, collapsing the wrap that GML semantically wants (the right answer is index 11, the highest GML pitch).
- **Fix shape (V25): branch on map mode before any clamp.** GML uses `(note + transp + 48) mod 12` (the +48 keeps the input non-negative across the full transp range, so the unsigned mod loop works without sign branching). TRK/INV keep the clamp — they want a deliberate floor/ceiling at the melody range edges.
- Lesson: when the same input feeds multiple semantically distinct lookups, branch on the dispatch *before* the index transform, not after. Clamp-then-mod and mod-then-clamp are not equivalent.

## DMGARP-Specific Tuning Notes

### CH4 Tonal Noise GML floor (NR43 clock-shift)
- NR43's high nibble is the LFSR clock-shift; **higher value = lower frequency**. Clock-shift 4 (`$4x`) sits below the audible "pitched" range with the 7-bit LFSR, producing sub-tonal rumble instead of a metallic ping.
- DMGARP V24 GML seed had entry 0 = `$44` for the descending block-of-3 pattern, which read as rumble in 7B mode at the lowest melody note.
- V25 lifted entry 0 to `$36` (clock-shift 3, divider 6) — sits between the next block (`$35..$31`) and clear of all other entries. The audible threshold for "metallic ping" vs "rumble" with 7B sat right at the `$3x`/`$4x` boundary.
- Note: `TonalMap_GML` is shared between 7B and 15-bit width modes (the width bit is OR'd in at trigger time after the table read), so this lift applies to both. Verified acceptable in 15-bit on hardware.

## Multi-source Channel Sharing

### Cycle-start CH1 contention guard (V26 EUCLID KICK)
- DMGARP V26 added a Euclidean drum machine where the KICK lane writes a CH1 sweep (no CH4 involvement). On cycle-start steps where `wNoiseAccent == ACCENT_KIK` (= 1), both the V20 `PlayKickAccent` (called from `MaybeTriggerAccent`) and the new `PlayEuclidKickSweep` would write CH1 in sequence, with ACC writing last and silently winning while still consuming Euclid's `hKickStepActive` budget.
- **Fix shape: collision-detect at the early writer, not the late one.** `PlayEuclidKickSweep` runs *before* `MaybeTriggerAccent` in the step handler, but `hAccentPending` is already armed by `AdvanceArp` on the previous step. So the early writer can read `hAccentPending && wNoiseAccent == 1` and bail BEFORE writing CH1 — yielding cleanly to ACC. 5 lines of guard. ACC behavior remains byte-for-byte V25.
- Alternative considered & rejected: have the late writer (ACC) check whether Euclid already wrote and skip. Worse because ACC is the legacy path and changing it risks regressing all V25 ACC behavior; the new writer should bear the integration cost.
- Generalizes: when adding a new writer to a shared resource, prefer "new writer detects conflict and yields to legacy" over "legacy detects new writer and yields." Keeps regression surface on the new code.

### Same-step CH4 retrigger semantics — explicitly out of V26 scope
- The original V26 design had three Euclid lanes (KICK/SNARE/HAT) all writing CH4 alongside the existing Accent / Fill / Tonal CH4 writers. Five rounds of Codex adversarial review surfaced increasingly speculative concerns about same-step CH4 retrigger order: when two writers both want CH4 on the same step, does the second NR44=$80 retrigger cleanly cancel the first envelope, or layer-and-clip, or pop?
- These questions can only be answered on real DMG hardware. The cable was unavailable, so V26 cut the CH4 click from KICK entirely (CH1-only) and deferred SNARE/HAT to V27. K=0 cold boot keeps V25's CH4 sequencer behavior byte-for-byte regression-free.
- Lesson: when adversarial review turns speculative about hardware semantics you can't verify, narrow the feature scope rather than adding speculative arbitration code. V27 with hardware in hand is the right place to settle the multi-writer question.

### Bjorklund-Euclidean rotation convention
- The classic Bjorklund algorithm produces a pattern whose first 1-bit may not be at slot 0 (e.g., the recursive form for E(3,8) yields `01001001`, but the conventional notation is `10010010`). Different sources canonicalize differently.
- DMGARP V26 generates with `tools/gen-euclid-table.py`: recursive Bjorklund, swap-and-complement when k > n-k, then **rotate so pattern[0] == 1**. This puts the strongest beat at slot 0, matching user expectations from Steve Reich / Toussaint conventions and making the visualizer's "downbeat at the left" reading natural.
- Self-checks in the script (E(3,8) = `10010010`, E(5,8) = `10110110`, E(7,12) = `101011010110`) catch generator bugs before the `.inc` lands in ROM.

## Input Dispatch (HandleInput contract)

### Action callees must preserve b/c (V26.1 EUCLID regression)
- `HandleInput` (`arpeggio.asm:917`) documents `b = held buttons, c = newly pressed`, and the callees-only-touch-`a/d/e/h/l` rule lets the post-input auto-repeat block reuse `b`/`c` without re-reading the joypad. The original V26 EUCLID action routines (`EuclidKickHitsUp`, `EuclidKickClampAfterN`, `EuclidKickRotNext`) all wrote `b` as a scratch register — silently violating the contract.
- Symptom: ROT *appears* not to respond to B+UD. Actually fired correctly via `EuclidKickRotNext`, but the trashed `b` then poisoned the auto-repeat block's modifier-mask check, the B-release detection, and any chained `bit X, b` reads in the same dispatcher pass. The bug presented as "feature broken," not "register clobber."
- Fix shape: scratch in `d` instead. The contract reserves `a/d/e/h/l` for callees, so `d` is free; substitution is byte-for-byte equivalent and avoids a `push bc`/`pop bc` cost.
- Audit cue: `grep "ld b, a"` inside any HandleInput callee tree is suspicious. New action routines should default to `d` for stash-and-compare patterns.

### Plain-LR rotate UX with per-page LR auto-repeat
- DMGARP V26.1 binds plain ←/→ (no modifier) to ROT on page 8 because "rotate the visualizer pattern" reads naturally as a ←/→ shift gesture. The per-page LR auto-repeat lives parallel to the global UD-only repeat block at `:582-606` and shares `wRepeatCounter` (only one directional class is active per page-frame).
- Key invariant: the new LR-repeat path must gate on `wCurrentPage == 7` so page 1's plain-LR `PrevPattern`/`NextPattern` (one-shot, no repeat) is unaffected. Other pages' plain LR remains inert as before.
- When introducing per-page repeat hooks, run them *before* the global UD repeat block and `jp .udAutoRepeat` to fall through if the page-specific path doesn't claim the frame. Keeps the legacy block untouched and easy to audit.

### Page-aware col-0 modifier indicators
- DMGARP paints a `TILE_PLAY` (►) row marker at col 0 of each row whose modifier (A / B / AB / START) is currently held. The dispatch lives in the tail of `UpdateHUD` (`arpeggio.asm:4573-4753`) and is page-keyed via `cp wCurrentPage`.
- Failure mode is silent: a new page that uses B/AB/ST modifiers must add a `cp <page> / jp z, .<page>Ind` entry to the chain at `:4622-4633`. If you forget, the page falls through to `.doneIndicators` and the only modifier indicator that works is A (because the A-indicator path at `:4593-4619` has a generic "rows 6+7" fall-through that happens to match many pages). Symptom looks like "indicator works for A, not for B/AB" — bug shape from V26.2.
- The A-indicator dispatch has its own page-shape conventions (rows 6+7, row 6 only, rows 7+8) — when adding a page whose A binding doesn't fit any of those, add an A-side entry too, not just a B/AB/ST entry.

### Help-row tooltip ordering (HelpRowTick must run early in VBlank)
- DMGARP's `HelpRowTick` writes 20 tiles to row 17 (`$9A20`). On the DMG, VRAM writes during MODE 3 (DRAW) are silently dropped, so any tooltip code that runs after the per-frame VBlank window has expired loses cells.
- V26.3 symptom: on the EUCLID page, the per-frame work in `UpdateHUD` (visualizer's 16-iter Bjorklund pattern paint + 6 rows of value writes + modifier-indicator dispatch) had grown enough that the tail-position `jp HelpRowTick` was landing in MODE 3. Result: tooltip rendered with random partial cells (`BOOM KICK` showing only `KICK` because the prefix writes happened too late) and the timer-driven 20-cell clear didn't fully clear (single-tile artifacts persisted past the 1-second timeout).
- Fix: call `HelpRowTick` at the **start** of `UpdateHUD`, not the end. Row 17 writes then land while VBlank is freshest, with hundreds of T-cycles of headroom regardless of which page is active.
- Lesson: when adding heavy per-frame work (large render loops, multi-row value writes), audit what's *still* called at the tail. Anything with strict full-row-write semantics (tooltips, large badges) belongs at the start of the VBlank window, not the end. **Update from V27.1 below**: the "incremental writes tolerate occasional MODE 3 misses" half of this lesson was wrong — see next section.

### Tail-of-UpdateHUD MODE 3 overrun: stuck cells, not glitch (V27.1)
- Earlier (V26.3) reasoning was: tooltip / badge writes need full-row landing in VBlank, but per-cell value/indicator writes are self-healing because the next frame re-paints. **That's only true if the cycle pattern varies frame-to-frame.** When `UpdateHUD` traces the same control-flow every frame (no input event, no animation), the same write lands at the same scanline-relative position on every frame. If that position falls inside MODE 3 once, it falls inside MODE 3 forever — and the cell stays stuck at whatever value the LCD framebuffer happened to hold when the frame became deterministic.
- V27.1 symptoms (all on EUCLID page, all after V27 added a 30+-tile PITCH row plus other Page 8 polish):
  - Modifier `►` indicator at col 0 of a single row could remain visible for **seconds** after the button was released. Other pages' indicators were instant. The "stuck" tile was always the same one for a given setting.
  - PITCH values −30 and −31 rendered as **"−39"** even though static trace of the renderer was correct (sign='-', tens=3, ones=0/1). The ones-digit at `$9933` was the latest write inside the PITCH cell and was the one being dropped — leaving the previous frame's "9" visible (from PITCH=−29 mag 29).
  - SOUND / DECAY 3-letter labels (e.g. `PCH` / `BOM` / `SHR`) tore in a setting-dependent way: at PITCH +31 they switched cleanly, at PITCH +08 different letters changed on different frames. The user-visible "depends on settings" is the diagnostic giveaway — random tearing would not correlate with parameters.
- Root cause is identical to V26.3's tooltip case: by the time UpdateHUD reaches the trailing writes (last cells of `.page8Values`, then the col-0 `.euclidPageInd` block), the LCD has left VBlank and every dropped write silently disappears. The novel finding is that determinism turns "1-frame stale" into "stuck until something perturbs cycle count."
- Fix shape (V27.1): two caches that drop the late-frame VRAM-write count to zero in steady state.
  1. **Dirty-flag gate the heaviest paint.** `RenderEuclidVisualizer` (16-tile Bjorklund render, ~640 cycles) only runs when `wEuclidPatternDirty` is set. The flag is set at boot, on page enter, and at the entry of every handler that mutates the visualizer's inputs (`EuclidKickHitsUp/Down`, `EuclidKickLenNext/Prev`, `EuclidKickRotNext/Prev`). Cleared after each successful paint.
  2. **Shadow-cache the last writes in the frame.** `.euclidPageInd` collapses the 4-tile modifier indicator into a 3-state byte (none/B/AB) compared against `wHudP8Ind`. Unchanged → single CP+JP, zero VRAM writes. Initialized to `$FF` at boot and on page enter so the first frame always paints.
- Why it works without per-cell value caching: the ~250-cycle steady-state value writes (HITS/LEN/LEVEL/PITCH/SOUND/DECAY/ROT) fit inside VBlank once the ~640-cycle visualizer is gated. Cycle-math the budget *before* implementing per-cell shadow tables; only escalate if hardware testing still shows tearing.
- Diagnostic checklist when an HUD element acts up on a single page:
  - "Stuck for seconds, not flickering" → deterministic MODE 3, not stale-by-one-frame. Cache the heaviest preceding paint.
  - "Glitches depend on settings, not random" → cycle count varies with the setting (loop iterations, divide-by-10 length). Same fix.
  - "Other pages are fine, only page X" → page X's UpdateHUD path is the longest. Don't touch the indicator block / common code; trim *page X*'s `.pageNValues`.
- Pre-emptive guidance: when a new page introduces a render loop above ~200 cycles, add a dirty flag from the start. The V27.1 round-trip (ship → on-hardware bug report → diagnose → cache) cost more than the 5 lines of dirty-flag plumbing would have. Pages 1–7 work because they don't have a per-frame loop the size of the Euclidean visualizer; the moment you write one, gate it.
- **Hardware-verified 2026-05-17:** the dirty-flag + shadow-cache mitigation holds in sustained normal use on Page 8 (real DMG hardware). No stuck modifier markers or stale digits observed.

### Help-row entry size invariant
- Each `HelpStr_*` entry must be **exactly** `HELP_LEN` (= 20) bytes. `ShowHelpByIndex` computes `base + idx * 20` with no bounds check; off-by-one in the byte count of one entry shifts every later entry's content into the wrong cells.
- Pattern: `db <visible chars>` followed by `ds N, TILE_BLANK` to pad to 20. Count visible chars + N = 20.
- Single-entry tables: load `xor a` before `ShowHelpByIndex` (template at `HelpFor_TonalTransp`). Don't pass through whatever value happened to be in `a` — the multiply-by-20 will read garbage from the next data symbol if `a` isn't 0.

### BOOM ≠ ACCENT KIK (V26 deferral)
- ACCENT page's KIK preset is layered: `PlayKickAccent` writes both a CH1 sweep and a CH4 noise click via `NoisePresets_KickClick`. EUCLID page's BOOM SOUND only writes CH1.
- A V26.1 attempt to bolt a CH4 write onto `PlayEuclidKickSweep` was reviewed and rejected. The Euclid kick path runs *before* `MaybeTriggerTonal` and `MaybeTriggerAccent` in the step handler; an unarbitrated CH4 write can be silenced by the fill-cut path (NR42=0), overwritten by SNR/RIM accent on cycle-starts, or cancel a still-ringing tonal note — all behaviors the legacy CH4 paths protect against via tonal suppression and accent tail-frame countdowns.
- Lesson: parity between two superficially-similar features (BOOM kick body vs ACCENT kick body) is not a "just add the missing layer" job when the missing layer touches a shared resource with existing arbitration. Defer to the layer that owns arbitration — for DMGARP that's V27's CH4 multi-writer arbiter.

### CH1 sweep-overflow silences envelope decay (V27 DECAY fix)
- CH1's hardware sweep auto-silences the channel permanently when the computed period exceeds 2047. For punchy kick presets (TIGHT/BOOM/PUNCH) this happens within ~70–280 ms depending on NR10 period and shift. Until the channel is silenced, the frequency sweeps; after overflow, the channel is dead until the next trigger.
- Consequence: a DECAY knob that only writes the NR12 envelope step feels like a volume knob on aggressive-sweep presets. All three SHRT/MID/LONG settings get cut at the same instant by sweep overflow; the only audible difference is how much the envelope had decayed by that moment — coarser volume attenuation, not tail length.
- Fix: couple DECAY to the sweep period (NR10 bits 6-4). SHRT uses the preset's fast sweep period; MID and LONG add 1-2 period steps, extending the audible window to ~2–3× of SHRT. This gives the envelope decay enough room to be heard as a real tail.
- Implementation: `EuclidKickNR10ByDecay` — 12-byte table indexed by `wEuclidKickSound * 3 + wEuclidKickDecay`. `PlayEuclidKickSweep` reads NR10 from this table and skips the NR10 byte in `EuclidKickSoundPresets`. SUB's row is identical across all three DECAY values ($34/$34/$34) since its ~796 ms sweep window already gives the envelope room without any period extension.
- Rule of thumb: before adding a decay control to any CH1 sweep preset, compute the sweep-overflow time (see `docs/superpowers/specs/2026-05-06-euclidean-drum-machine-design.md` for the math). If it is shorter than the envelope range, the decay knob controls volume, not tail. Fix by co-varying NR10.

### MBC1 SRAM access gating
- MBC1+RAM+BATTERY SRAM at `$A000-$A7FF` is **off by default**. Reading from it returns open-bus garbage; writing to it is silently discarded. You must enable it first by writing `$0A` to any address in `$0000-$1FFF`, and disable it by writing `$00` to the same range afterward.
- On real hardware, forgetting to disable SRAM before returning to normal code is not immediately fatal, but leaving it enabled during the next VRAM write window is safe (SRAM and VRAM are on different buses). Still, always pair `EnableSRAM` / `DisableSRAM` around every access — unexpected SRAM-open windows are hard to debug.
- mGBA persists SRAM to a `.sav` file alongside the ROM (`roms/dmg-arp.sav`) and reloads it on every launch. `make clean` removes the ROM but not the `.sav`, so saves survive rebuilds. The `.sav` file is only stale-wiped if `EnsureSRAM` detects a magic or schema mismatch on boot.

### ROM0 size budget (DMGARP V30 baseline)
- DMGARP's entire codebase lives in `SECTION "Main", ROM0[$0150]` and `SECTION "Data", ROM0` — there are no ROMX sections. ROM0 is 16 KB (`$0000-$3FFF`). As of V30.0, 15,935 bytes are used with **449 bytes free**.
- If a future feature exhausts ROM0, the options are: (a) trim unused data (word tables, help strings, unused control rows), or (b) move large read-only tables to a `SECTION "X", ROMX[$4000]` bank and add MBC1 bank-switch calls around every access. Option (b) is a significant refactor — design new features with the budget in mind.
- The linker error when ROM0 overflows is `FATAL: Unable to place "Data" (ROM0 section) anywhere`. It does not tell you the overage; use a temporary `ROMX[$4000]` dummy for the Data section to get a map file, then subtract the section sizes.

### Transactional SRAM writes — commit occupied flag last
- When saving a slot record to battery-backed SRAM, write the `occupied=0` byte **first** (to invalidate any prior content), write the full payload, then write `occupied=1` **last** as the commit. A single-byte write is atomic on this hardware; the SRAM controller has no write buffer or cache. If power is lost mid-save, the slot reads as empty rather than corrupt-but-valid.
- The pre-existing danger: if `occupied=1` is written before params, a subsequent load of that slot restores a mix of new and stale bytes. A stale `wStride=0` byte causes `ComputeNoteCount` to hang in an infinite modulo loop (it divides by `wStride`).
- Register allocation gotcha (V30.0 bug): `ComputeNameDigits` leaves `b=100` on exit (the modulo divisor). Any subsequent `ld a, b` to recover a slot index reads 100, not the original slot argument. The fix is to stash the slot index in a WRAM scratch byte (`wSubDrawSlot`) before calling name-generation helpers, then reload it for each `GetSlotPtr` call.

### Post-load normalization checklist
- After bulk-restoring params via `SaveParamTable`, call these in order before returning from `LoadSlot`:
  1. `LoadWaveRAM` — pushes the restored `wCH3Wave` preset into `rWaveRAM` (CH3 requires an OFF→write→ON cycle before the new waveform takes effect).
  2. Zero `wCH3Running` — so the CH3 service retriggers the channel with the new mode/volume/wave on the next arp step. Without this, CH3 stays stuck in "already running" state from before the load.
  3. `EuclidKickClampAfterN` — clamps `wEuclidKickK` to [0,N], `wEuclidKickRot` to [0,N-1], and resets `wEuclidKickStep` to 0. The step counter is not saved (it is runtime state); if the pre-load value exceeds the loaded N, the step-advance check (`cp N / jr z, .wrap`) never fires because it tests for exact equality — the kick lane goes permanently silent.

### Per-field range validation on SRAM read (V30.2)
- `ValidateSlot` runs a read-only pass over all `SAVE_PARAM_COUNT` (61 as of V38) SRAM param bytes before any WRAM writes occur. It compares each byte against a parallel `SaveParamRangeTable` (61 × `db min, max`). The table order must exactly mirror `SaveParamTable`. the `SAVE_PARAM_COUNT` constant keeps them in sync — update this constant whenever a param is added.
- If any byte fails, `LoadSlot` clears the occupied flag in SRAM and returns `a=0` to its caller; WRAM is untouched. The caller shows "EMPTY SLOT" and redraws the slot list. This prevents corrupted SRAM from hanging the ROM (wStride=0 → infinite loop in ComputeNoteCount).
- Register trick: during the validation loop, `b` = iteration count, `c` = byte under test (loaded via `ld a, [hli] / ld c, a`), `de` = range table cursor, `hl` = SRAM byte cursor. No push/pop inside the loop. The `cp c` instruction checks `a - c` unsigned; for min check, `jr c` passes if min < byte, `jr nz` fails if min > byte; for max check, `jr c` fails if max < byte.
- `ClampArpPosition` must be called after `ComputeNoteCount` in `LoadSlot`. Every other path that can shrink the note count (bank change, octave-range decrease, stride increase) already does this; missing it leaves `wArpPosition >= wNoteCount`, and the ascending-mode wrap-on-exact-equality never fires until 8-bit overflow.

### MBC1 32 KB banked SRAM on EMS 64M carts — works, but probe every unit (V38)
- V38 moved DMGARP to `$0149=$03` (32 KB / four 8 KB banks). MBC1 RAM banking needs
  **mode 1** (`1→$6000`, set together with SRAM enable) and bank select via `$4000`.
  With a 2-bank ROM the mode-1/BANK2 bits have no ROM-side effect (masked away), so
  the switch is free.
- On-device result: a healthy EMS USB 64M unit passes fully — distinct data in all
  four banks, battery retention across power cycles. But **an individual unit was
  found whose SRAM goes completely dead under the $03 size code** (every bank reads
  open-bus, nothing retained) while the same cart works fine with `-r 2`. This is a
  per-unit defect, not a family property — never generalize one cart's failure.
- Probe before trusting battery saves: `make build-sramtest` builds
  `src/sramtest.asm`, which writes per-bank signatures and shows `KEPT` (retention
  from the previous run) and `LIVE` (this-session write/readback) as per-bank
  PASS/FAIL. `F F F P` = banking ignored (all writes alias one bank); all-`F` = SRAM
  dead under this header. mGBA passes regardless — the emulator proves the code
  path, never the cart.

### Slot-record growth must be guarded by a build-time assert (V37→V38 bug)
- V37 appended a 61st entry to `SaveParamTable` but left the 64-byte slot stride
  unchanged; the record (4 header + 61 params = 65 bytes) silently overlapped the
  next slot, so **every save overwrote the neighbour's occupied flag** — occupied
  slots appeared empty (data loss) or empty ones occupied (garbage).
- The stride comment ("4 header + 55 params + 5 pad") had been stale for two
  versions; nothing forced the arithmetic to be re-checked. V38 fixed the stride
  (72) and added `ASSERT 4 + SAVE_PARAM_COUNT <= SAVE_SLOT_SIZE`. Any constant that
  encodes "A must fit in B" belongs in a build-time ASSERT, not a comment.

### MBC1 RAM-size code — use $02 (8 KB) or $03 (32 KB), never $01
- Pan Docs lists `$0149=$01` as "unused/unofficial". The EMS USB 64M smart card treats it as "no SRAM": `EnableSRAM` is silently ignored and all reads from `$A000-$BFFF` return open-bus. The open-bus value on DMG is the opcode of the current read instruction; `LD A,[HLI]` = `$2A` = 42 decimal, which can produce visually plausible but entirely wrong data in any SRAM-backed table.
- The spec-compliant MBC1+RAM sizes are `$02` (8 KB / 1 bank) and `$03` (32 KB / 4 banks). All standard MBC1 carts handle `$02`; see the V38 note above for `$03` on flash carts. The actual SRAM usage need not fill the declared size; only the declared size matters for MBC1 enablement.
- Symptom on real hardware with wrong RAM size: every SRAM read returns the same opcode byte, producing identical junk values in every slot. In mGBA, save/load works fine because the emulator allocates SRAM regardless of the declared size code.
- **Verification pattern**: after writing to SRAM, immediately read back a sentinel byte (e.g. the `occupied=1` commit byte) and compare. On a disabled or failed SRAM, the read-back will differ. This costs ~12 bytes but catches the failure before the "SAVED" tooltip misleads the user.

### ROM section layout for 32 KB MBC1 ROMs
- RGBDS does not enforce a `ROM0` / `ROMX` split when only ROM0 sections exist; the linker places everything sequentially in the 32 KB address space. However, once any `ROMX` section is declared, ROM0 is restricted to `$0000-$3FFF` and ROMX to `$4000-$7FFF`.
- For a 32 KB MBC1 ROM (2 banks), bank 1 is **always mapped** at `$4000-$7FFF` — there is no bank switching. Code in bank 0 can freely read data or call subroutines at `$4000+` via normal 16-bit addresses. Moving large read-only data tables from `ROM0` to `ROMX, BANK[1]` is a safe way to free ROM0 space without adding bank-switch complexity.
- Data references (`ld hl, Label`) work correctly with ROMX labels because `hl` is a full 16-bit register and the CPU maps the entire `$0000-$7FFF` space unconditionally.

### Sub-page input intercept pattern
- DMGARP's save/load UI uses a `wSubPage` byte (0=none, 1=SAVE list, 2=LOAD list, 3=PRESET matrix) that intercepts all joypad input at the top of `HandleInput` before SELECT / page routing. This is cleaner than per-page branches inside the existing page dispatchers: the sub-page owns the full button surface and can ignore SELECT, START, and modifier combos without coupling to each page's input logic.
- Key invariant: `DoPageRedraw` for the host page (CONTROLS) clears `wSubPage = 0` and `wSubDirty = 0` on re-entry. This means pressing B (which sets `wPageRedraw = 1`) exits the sub-page via the normal redraw path rather than a special exit routine. No separate "exit sub-page" VRAM clear is needed.
- The main loop skips `UpdateHUD` while `wSubPage != 0` (only `HelpRowTick` still runs), preventing the normal HUD writer from overwriting sub-page content.
