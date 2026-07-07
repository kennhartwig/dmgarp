# DMGARP Architecture Reference

Starting map for the codebase, audio engine, and key symbols. Line numbers
drift as the code evolves — treat them as approximate pointers and verify with
`grep` before relying on a specific location.

**Current version:** V0.38.2  
**Target hardware:** Original DMG Game Boy (1989). No CGB-specific features.  
**Toolchain:** RGBDS v1.0.1

---

## File Structure

```
dmgarp/
├── src/
│   ├── arpeggio.asm          main source (~12 000 lines)
│   ├── euclid-table.inc      Euclidean pattern lookup (510 bytes, generated)
│   └── sramtest.asm          SRAM banking probe ROM (make build-sramtest)
├── tools/
│   └── gen-euclid-table.py   Euclidean table generator
├── scripts/
│   ├── bootstrap-tools.sh    downloads RGBDS + mGBA into tools/
│   ├── build-ems-flasher.sh  builds patched ems-flasher for EMS cart flashing
│   ├── gen-euclid-table.py   Euclidean table generator
│   ├── run-emulator.sh
│   ├── run-debugger.sh
│   └── smoke-test.sh
└── Makefile
```

---

## Build Pipeline

`rgbasm -o build/arpeggio.o src/arpeggio.asm`  
`rgblink -o roms/dmg-arp.gb build/arpeggio.o`  
`rgbfix -v -p 0xFF -m 0x03 -r 3 -t DMGARP roms/dmg-arp.gb`

Cart type: MBC1+RAM+BATTERY (`-m 0x03`), 32 KB banked SRAM (`-r 3`, four
8 KB banks via MBC1 mode-1 RAM banking). The ROM is 32 KB; SRAM bank 0
holds the 8 save-slot records, bank 1 the eight per-slot preset matrices.

---

## Core Architecture

### Tick source and main loop

The VBlank ISR (`~line 3053`) is the tick source only: it decrements
`hSpeedCounter` and sets `hStepReady` when it reaches zero. It does not touch
APU registers.

The main loop polls `hStepReady` and runs the step handler, which calls
`PlayCurrentNote`. **APU register writes happen from the main loop, not from
VBlank.** DMG hardware does not require VBlank alignment for APU writes.

**VRAM and OAM writes are gated to VBlank via `WaitVBlank`.** This invariant
is real and must be preserved.

### Gate timing

`hGateCounter` is owned by the main-loop step handler: initialized on reset,
reloaded when a new note plays, decremented on each main-loop pass. When it
reaches zero, the gate-expire branch mutes CH1/CH2/CH3 by writing
`DAC_ON_SILENT` to their envelope registers. Gate=SIL (silence) mutes CH2
only; CH1, CH3, and CH4 continue.

### No transport toggle

`wPlaying` is always 1. There is no pause/stop. The arpeggio runs continuously
from init. START is not bound to a transport on any page.

---

## WRAM Layout (key symbols, `~lines 185–430`)

```
wCurrentBank        0–27 (28 scale banks)
wPlayingBank        bank used for note lookup (may lag wCurrentBank by one step)
wRootNote           0–11 (semitone)
wRootOctave         0–4
wArpPosition        current arp step
wArpDirection       0=ascending, 1=descending (ping-pong flag)
wPatternType        0=ASC, 1=DESC, 2=PINGPONG, 3=RANDOM
wSpeed              0–31 (index into SpeedTable, 32 log presets)
wOctaveRange        1–3
wStride             1–4
wGateLength         0=OFF, 1=75%, 2=50%, 3=25%, 4=SIL (CH2 only)
wRngState           LFSR for random pattern + general RNG
wCurrentPage        0–9 (active UI page)
wSubPage            0=none, 1=SAVE list, 2=LOAD list, 3=PRESET matrix
wSubCursor          selected slot 0–7 (lists) / cell 0–15 (matrix)
wSubArmCounter      two-press-confirm countdown (0=unarmed)
wSubArmAction       which confirm is armed: 0=none, 1=overwrite, 2=delete
wPresetBuf          16 × 61-byte preset snapshots (working matrix)
wPresetOcc          16 occupied flags
wPresetActive       last loaded/saved cell 0–15 ($FF=none, the "playing" dot)
wMuteCH4            session mute flag for CH4 subsystems
wMuteEuc            session mute flag for Euclidean kick (CH1 sweep)
```

---

## Note Calculation

1. `position × stride / scale_size` → scale degree + octave offset
2. `ScaleTable[bank × 10 + degree]` → semitone offset
3. `(root_note + offset) mod 12` → note in octave, with octave wrapping
4. `FreqTable[final_octave × 12 + note]` → 2-byte NR13/NR23 period

---

## Channel Playback

### CH2 (main voice, `~lines 1788–1827`)
NR21 duty byte, NR22 envelope, NR23/NR24 frequency + trigger.

### CH3 (wavetable, `~lines 1836–1887`)
16-byte waveform loaded to `$FF30–$FF3F` on first trigger. Only retriggers
(NR34 bit 7) on initial note, after waveform change, or after a gap — avoids
the wave-trigger pop on subsequent notes.

### CH1 (companion voice, `~lines 1889–2044`)

6 modes dispatched from a table near the mode constants:

| Mode | Behavior |
|------|----------|
| OFF  | Silenced |
| OC+  | One octave above CH2 (freq index +12) |
| OC−  | One octave below CH2 (freq index −12) |
| DET  | Same freq index as CH2 + small low-byte offset from `DetuneOffsets` |
| INT  | CH2 freq index + (`wCH1Interval` + 1) semitones above the played note |
| SCL  | Scale-degree offset inside the active scale (diatonic follow) |

CH1 also has OFFSET: a deferred-fire delay (0=off, 1–14 = 6–87% of the step
interval). FireCH1Now retriggers from a timer interrupt-equivalent event.

### CH4 (noise/drum, `~line 3200+`)

Three subsystems share CH4 and operate in priority order:

1. **Accent** — fires at arp cycle start. KIK: CH1 pitch sweep + CH4 noise
   click (layered). SNR, RIM: CH4 only. `MaybeTriggerAccent` consumes
   `hAccentPending` set by `AdvanceArp`.
2. **Fill** — gate-noise burst on every step. Multi-hit (CH4 retriggered every
   gate-off). Volume curves (FLT/LR↑/LR↓/ER↑/ER↓) computed in software from
   a 16-byte LUT; hardware envelope is bypassed (step=0).
3. **Tonal** — 7-bit or 15-bit LFSR shadow melody. Priority setting
   (`wTonalPri`) controls when Tonal yields to Accent or Fill.

### Euclidean kick (`~lines 3350+`, V26+)

CH1-only (no CH4 writes). Bjorklund pattern from `EuclidPatternTable` (510
bytes, `INCLUDE "src/euclid-table.inc"`). Fires `PlayEuclidKickSweep` when
`hEuclidKickWants` is set and neither `wMuteEuc` nor an ACC=KIK collision
blocks it.

V35: per-hit LFO modulation of pitch and velocity. Two independent LFOs
(wEucPLfo* / wEucVLfo*), each with shape/rate/depth. Phase accumulator
updated each kick trigger.

V37: LOCK mode (`wEuclidKickLock`). When locked, `EuclidKickApplyLock` snaps
LEN to the current arp cycle length on every step. Plain ↑ on the EUCLID
page engages LOCK; plain ↓ releases it.

---

## Data Tables

| Table | Purpose |
|-------|---------|
| `FreqTable` | 60 × 2-byte periods, C2–B6 |
| `ScaleTable` | 28 × 10 semitone offsets, zero-padded |
| `ScaleSizeTable` | Notes per octave per bank |
| `SpeedTable` | 32 log speed presets (VBlank frame counts) |
| `WavePresets` | 4 duty/envelope byte pairs (STD/THN/LNG/NRW) |
| `AttackPresets` | 4 NR12/NR22 envelope bytes |
| `CH1VolTable` | 8 NR12 values for vol 0–7 |
| `DetuneOffsets` | 5 frequency offsets for DET sub-param |
| `CH1DutyTable` | 4 NR11 duty bytes |
| `WavetableData` | 5 × 16-byte waveforms (SIN/SAW/TRI/ORG/BAS) |
| `CH3ShapePointers` | 7 word pointers into CH3Shape_* |
| `EuclidPatternTable` | 510 bytes (15×17×2), Bjorklund lookup |
| `EuclidKickSoundPresets` | 4 × 4-byte CH1 sweep records (TIGHT/BOOM/SUB/PUNCH) |
| `EuclidKickNR10ByDecay` | 12 bytes (4 SOUNDs × 3 DECAYs) |
| `SaveWordTable` | 64 × 7-byte random word names for save slots |
| `SaveParamTable` | 61 WRAM addresses + terminator (`SAVE_PARAM_COUNT`) |
| `HelpStr_*` | Help-row tooltip strings (1280 B, 20-tile fields) |

---

## Scale Banks (28 total)

**Church modes (banks 0–6, 7 notes):**
Ionian, Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian

**Harmonic minor modes (banks 7–13, 7 notes):**
Harmonic Minor, Locrian ♮6, Ionian ♯5, Dorian ♯11, Phrygian Dominant,
Lydian ♯2, Super Locrian

**Messiaen modes (banks 14–20, variable 6–10 notes):**
Whole Tone (6), Octatonic (8), modes 3–7 (9, 8, 6, 8, 10)

**Ethiopian pentatonic (banks 21–27, 5 notes):**
Tizita Maj, Tizita Min, Bati Maj, Bati Min, Ambassel, Anchihoye, Yematibela

---

## UI — 10 Pages

`MAX_PAGE EQU 9` → pages 0..9 (ten total). Page index in `wCurrentPage`.
SELECT increments the page index, wrapping 9 → 0.

Pages 1–10 (displayed numbering) have inverted-color title bars in row 0 with
a `N/10` indicator at cols 16–19. Page 1 (MAIN) uses a live title area
(group name + scale name + note + octave). Row 17 on every page is the
help-row overlay (20 tiles, auto-clears after ~3 s).

| Index | Display | Title | Sub-title |
|-------|---------|-------|-----------|
| 0 | 1/10 | MAIN | (live group name) |
| 1 | 2/10 | CHANNEL 1 | |
| 2 | 3/10 | TIMING | |
| 3 | 4/10 | WAVE | CHANNEL 3 |
| 4 | 5/10 | ACCENT | CHANNEL 4 |
| 5 | 6/10 | FILL | CHANNEL 4 |
| 6 | 7/10 | TONAL | CHANNEL 4 |
| 7 | 8/10 | EUCLID KICK | |
| 8 | 9/10 | MIXER | |
| 9 | 10/10 | CONTROLS | |

### CONTROLS page sub-pages

`wSubPage = 1` (SAVE) or `2` (LOAD) → 8-slot list. UP/DOWN moves cursor;
A acts (save requires two-press confirm via `wSubArmCounter`); B exits.
Static button-hint rows sit on row 13 of each list.

### Preset matrix (V38)

`wSubPage = 3` → 4×4 grid of 16 full-parameter snapshots (entered with A+→
on CONTROLS). Snapshots reuse the save system's `CaptureCurrentState` /
`RestoreState` walk over `SaveParamTable` (61 bytes each) into `wPresetBuf`.
D-pad moves the cursor in 2D (cursor bits 3-2 = row, 1-0 = column); A saves
into the cell (two-press confirm on overwrite, `wSubArmAction=1`), B loads
with a single press (`ApplyParamReconciliation` runs, the CONTROLS repaint
is suppressed so the performer stays on the grid), START deletes
(two-press, `wSubArmAction=2`), SELECT exits. Occupied cells render as
inverted digits; `wPresetActive` draws a dot after the cell that is
currently playing. The working matrix lives in WRAM and reaches SRAM only
through a slot save — an unsaved matrix is lost at power-off by design.

---

## Battery SRAM Layout

Schema 8 (V38). 32 KB SRAM, four 8 KB banks; MBC1 mode 1 is set alongside
SRAM enable, bank select via `$4000`. Bank 0 is the resting state.

```
BANK 0                                   BANK 1
$A000  4 B   Magic 'D','A','R','P'      $A000  1024 B  Slot 0 preset matrix
$A004  1 B   Schema version ($08)       $A400  1024 B  Slot 1 preset matrix
$A005  3 B   Reserved                   ...            stride 1024 — eight
$A008  72 B  Slot 0                                    matrices fill the bank
...          stride 72, 8 slots         BANKS 2-3      unused
```

Slot record (72 B): occupied, word_idx, name fields ×2, params[61],
active-preset byte (offset 65, $FF=none — restores the "playing" dot on
load), pad. Preset record (64 B): occupied, params[61], pad[2]. Slot saves
are transactional (occupied=0 → params → matrix → occupied=1 commit) so a
power loss mid-save leaves the slot empty, never corrupt. Loads
range-validate every param byte (slots and each occupied preset) against
`SaveParamRangeTable` before touching WRAM.

`EnsureSRAM` validates magic + schema on boot; wipes occupied flags
(slot and preset, not param bytes) on mismatch. SRAM must be explicitly
enabled/disabled around every access via the MBC1 enable register.

**Schema version must be incremented whenever `SaveParamTable` changes** (any
address, range bound, or entry count change). Without the bump, old SRAM is
silently read into the new layout. A build-time
`ASSERT 4 + SAVE_PARAM_COUNT <= SAVE_SLOT_SIZE` guards the slot stride —
V37 shipped a 65-byte record in a 64-byte stride, and every save overwrote
the next slot's occupied flag.

---

## Key Architectural Principles

- VRAM/OAM writes only during VBlank.
- APU writes from the main loop (not VBlank) — no "VBlank-safe APU" invariant.
- No dynamic memory allocation — all data pre-baked in ROM.
- Single-file source (`arpeggio.asm`) plus one include (`euclid-table.inc`).
- No mid-frame timing tricks or undocumented hardware behavior.
