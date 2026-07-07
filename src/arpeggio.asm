; =============================================================================
; DMGARP — Game Boy DMG Modal Scale Arpeggiator
; =============================================================================
; 21 banks (7 church + 7 harmonic minor + 7 Messiaen modes)
; VBlank interrupt-driven timing, 4 arp patterns, real-time controls
; CH2 square wave with 3 waveform presets + variable attack envelope
; =============================================================================

; --- Hardware Registers ------------------------------------------------------

DEF rP1   EQU $FF00
DEF rNR10 EQU $FF10
DEF rNR11 EQU $FF11
DEF rNR12 EQU $FF12
DEF rNR13 EQU $FF13
DEF rNR14 EQU $FF14
DEF rNR21 EQU $FF16
DEF rNR22 EQU $FF17
DEF rNR23 EQU $FF18
DEF rNR24 EQU $FF19
DEF rNR30 EQU $FF1A
DEF rNR31 EQU $FF1B
DEF rNR32 EQU $FF1C
DEF rNR33 EQU $FF1D
DEF rNR34 EQU $FF1E
DEF rWaveRAM EQU $FF30
DEF rNR41 EQU $FF20
DEF rNR42 EQU $FF21
DEF rNR43 EQU $FF22
DEF rNR44 EQU $FF23
DEF rNR50 EQU $FF24
DEF rNR51 EQU $FF25
DEF rNR52 EQU $FF26
DEF rLCDC EQU $FF40
DEF rSCY  EQU $FF42
DEF rSCX  EQU $FF43
DEF rLY   EQU $FF44
DEF rBGP  EQU $FF47
DEF rIE   EQU $FFFF

DEF DAC_ON_SILENT EQU $08      ; vol 0, dir up, period 0 — keeps DAC alive

; --- Button Constants --------------------------------------------------------

DEF BTN_RIGHT  EQU %00000001
DEF BTN_LEFT   EQU %00000010
DEF BTN_UP     EQU %00000100
DEF BTN_DOWN   EQU %00001000
DEF BTN_A      EQU %00010000
DEF BTN_B      EQU %00100000
DEF BTN_SELECT EQU %01000000
DEF BTN_START  EQU %10000000

; --- Tile Constants ----------------------------------------------------------

DEF TILE_BLANK     EQU 0
DEF TILE_UP_ARROW  EQU 1
DEF TILE_DN_ARROW  EQU 2
DEF TILE_PINGPONG  EQU 3
DEF TILE_RANDOM    EQU 4
DEF TILE_PLAY      EQU 5
DEF TILE_PAUSE     EQU 6
DEF TILE_SHARP     EQU 7
DEF TILE_DIGIT0    EQU 8
DEF TILE_A         EQU 18
DEF TILE_B         EQU 19
DEF TILE_C         EQU 20
DEF TILE_D         EQU 21
DEF TILE_E         EQU 22
DEF TILE_F         EQU 23
DEF TILE_G         EQU 24
DEF TILE_H         EQU 25
DEF TILE_I         EQU 26
DEF TILE_L         EQU 27
DEF TILE_M         EQU 28
DEF TILE_N         EQU 29
DEF TILE_O         EQU 30
DEF TILE_P         EQU 31
DEF TILE_R         EQU 32
DEF TILE_S         EQU 33
DEF TILE_T         EQU 34
DEF TILE_V         EQU 35
DEF TILE_X         EQU 36
DEF TILE_Y         EQU 37
DEF TILE_K         EQU 38
DEF TILE_W         EQU 39
DEF TILE_U         EQU 40
DEF TILE_DOT       EQU 41
DEF TILE_SLASH     EQU 42
DEF TILE_PLUS      EQU 43
DEF TILE_DASH      EQU 44
DEF TILE_Z         EQU 45
DEF TILE_J         EQU 46
DEF TILE_m         EQU 47
DEF TILE_LF_ARROW  EQU 48
DEF TILE_RT_ARROW  EQU 49
DEF TILE_Q         EQU 50

; --- Inverted Tile Constants (generated at boot by InvertTiles, base = 64) ---
; Inverted copies of tiles 0..50 live at indices 64..114 in VRAM ($8400+).
; Only aliases for tiles actually used in title bars + page indicators are
; defined; new aliases are free to add (the tile data already exists).

DEF INV_TILE_BASE   EQU 64
DEF INV_TILE_BLANK  EQU INV_TILE_BASE + TILE_BLANK
DEF INV_TILE_DIGIT0 EQU INV_TILE_BASE + TILE_DIGIT0
DEF INV_TILE_SLASH  EQU INV_TILE_BASE + TILE_SLASH
DEF INV_TILE_A      EQU INV_TILE_BASE + TILE_A
DEF INV_TILE_C      EQU INV_TILE_BASE + TILE_C
DEF INV_TILE_E      EQU INV_TILE_BASE + TILE_E
DEF INV_TILE_G      EQU INV_TILE_BASE + TILE_G
DEF INV_TILE_H      EQU INV_TILE_BASE + TILE_H
DEF INV_TILE_I      EQU INV_TILE_BASE + TILE_I
DEF INV_TILE_L      EQU INV_TILE_BASE + TILE_L
DEF INV_TILE_M      EQU INV_TILE_BASE + TILE_M
DEF INV_TILE_N      EQU INV_TILE_BASE + TILE_N
DEF INV_TILE_O      EQU INV_TILE_BASE + TILE_O
DEF INV_TILE_T      EQU INV_TILE_BASE + TILE_T
DEF INV_TILE_F      EQU INV_TILE_BASE + TILE_F
DEF INV_TILE_V      EQU INV_TILE_BASE + TILE_V
DEF INV_TILE_W      EQU INV_TILE_BASE + TILE_W
DEF INV_TILE_D      EQU INV_TILE_BASE + TILE_D
DEF INV_TILE_K      EQU INV_TILE_BASE + TILE_K
DEF INV_TILE_U      EQU INV_TILE_BASE + TILE_U
DEF INV_TILE_R      EQU INV_TILE_BASE + TILE_R
DEF INV_TILE_UP_ARROW EQU INV_TILE_BASE + TILE_UP_ARROW
DEF INV_TILE_DN_ARROW EQU INV_TILE_BASE + TILE_DN_ARROW
DEF INV_TILE_S        EQU INV_TILE_BASE + TILE_S
DEF INV_TILE_B        EQU INV_TILE_BASE + TILE_B
DEF INV_TILE_P        EQU INV_TILE_BASE + TILE_P
DEF INV_TILE_X        EQU INV_TILE_BASE + TILE_X

; --- Game Constants ----------------------------------------------------------

DEF ARP_BANK_COUNT   EQU 28
DEF SCALE_ENTRY_SIZE EQU 10
DEF VERSION_RELEASE  EQU 0
DEF VERSION_FEATURE  EQU 38
DEF VERSION_FIX      EQU 2
DEF DEFAULT_SPEED    EQU 11
DEF MIN_SPEED        EQU 0
DEF MAX_SPEED        EQU 31
DEF MAX_GATE         EQU 4
DEF MAX_STRIDE       EQU 4
DEF MIN_OCTAVE_RANGE EQU 1
DEF MAX_OCTAVE_RANGE EQU 3
DEF PAT_ASCENDING    EQU 0
DEF PAT_DESCENDING   EQU 1
DEF PAT_PINGPONG     EQU 2
DEF PAT_RANDOM       EQU 3
DEF PAT_COUNT        EQU 4
DEF WAVE_COUNT       EQU 4
DEF MAX_ATTACK       EQU 3
DEF GROUP_SIZE       EQU 7
DEF REPEAT_DELAY     EQU 26
DEF REPEAT_RATE      EQU 5
DEF MAX_SWING        EQU 7
DEF MAX_CH1MODE      EQU 5
DEF MAX_CH1VOL       EQU 7
DEF MAX_CH1DET       EQU 4
DEF MAX_CH1INT       EQU 18
DEF MAX_CH1DEG       EQU 6
DEF MAX_CH3MODE      EQU 2
DEF CH3_WAVE_COUNT   EQU 5
DEF MAX_CH3VOL       EQU 3
DEF CH3_SHAPE_COUNT  EQU 8   ; wCH3Shape: 0=OFF, 1=PLK, 2=DCY, 3=ATK, 4=AD, 5=TRM, 6=GAT, 7=RND
DEF MAX_CH3SHAPE     EQU 7   ; wCH3Shape max value (0=OFF..7=RND)
DEF MAX_CH3RATE      EQU 8   ; wCH3Rate:  1..8 arp steps per envelope/cycle
DEF CH3_SHAPE_RND    EQU 7   ; shape index for random; special-cased in engine
DEF MAX_CH1ATK       EQU 2   ; wCH1Attack: 0=OFF, 1=SAM, 2=INDP
DEF MAX_CH1ATKTYPE   EQU 3   ; wCH1AtkType: 1-3 (index 0 not used)
DEF MAX_CH1WAVE      EQU 3   ; wCH1Wave: 0=12.5%, 1=25%, 2=50%, 3=75%
DEF MAX_CH1OFFSET    EQU 14  ; wCH1Offset: 0=OFF, 1..14 = 6..87 % step delay (V34.1: doubled)
DEF MAX_NOISE_ACCENT EQU 3   ; wNoiseAccent: 0=OFF, 1=KIK, 2=SNR, 3=RIM
DEF MAX_FILL_LEVEL   EQU 7   ; wFillLevel:   0..7 (volume seed, NR42 nibble = level<<1)
DEF MAX_FILL_COLOR   EQU 1   ; wFillColor:   0=HIS (15-bit LFSR), 1=MTL (7-bit LFSR)
DEF MAX_FILL_PITCH   EQU 7   ; wFillPitch:   0..7 (NR43 clock-shift bits 7..4)
DEF MAX_FILL_FREQ    EQU 7   ; wFillFreq:    0..7 (NR43 divider bits 2..0)
DEF MAX_FILL_SHAPE   EQU 4   ; wFillShape:   0=FLT, 1=ER↑, 2=ER↓, 3=LR↑, 4=LR↓
DEF MAX_TONAL_LEVEL  EQU 7   ; wTonalLevel:  0..7
DEF MAX_TONAL_MAP    EQU 2   ; wTonalMap:    0=TRK, 1=GML, 2=INV
DEF MAX_TONAL_WIDTH  EQU 1   ; wTonalWidth:  0=15-bit, 1=7-bit
DEF MAX_TONAL_DECAY  EQU 2   ; wTonalDecay:  0=PNG, 1=RNG, 2=CUT
DEF MAX_TONAL_TRANSP EQU 24  ; wTonalTransp: 0..24, displayed -12..+12 (offset 12)
DEF MAX_TONAL_TRIG   EQU 2   ; wTonalTrig:   0=EVR, 1=HLF, 2=Q4
DEF MAX_TONAL_PRI    EQU 3   ; wTonalPri:    0=ALL, 1=+ACC, 2=+FIL, 3=SOLO
; --- V26 Euclidean Drum Machine (KICK lane, CH1-only) ---
DEF MAX_EUCLID_KICK_N      EQU 16  ; wEuclidKickN:     pattern length 2..16
DEF MIN_EUCLID_KICK_N      EQU 2
DEF MAX_EUCLID_KICK_LEVEL  EQU 7   ; wEuclidKickLevel: 0..7 (NR12 high nibble)
DEF MAX_EUCLID_KICK_SOUND  EQU 3   ; wEuclidKickSound: 0=TIGHT, 1=BOOM, 2=SUB, 3=PUNCH
DEF MAX_EUCLID_KICK_DECAY  EQU 2   ; wEuclidKickDecay: 0=SHRT, 1=MID, 2=LONG
DEF MAX_EUCLID_KICK_PITCH  EQU 63  ; wEuclidKickPitch: 0..63 (offset binary, 32=zero, signed -32..+31; ×16 at apply)
DEF EUCLID_PITCH_NEUTRAL   EQU 32  ; signed-zero anchor for pitch offset math
; --- V35 Euclid MOD (per-hit LFO on pitch + velocity) ---
DEF MAX_EUCLID_PLFO_SHAPE  EQU 5   ; wEucPLfoShape: 0=OFF,1=UP,2=DN,3=TRI,4=SIN,5=RND
DEF MAX_EUCLID_PLFO_RATE   EQU 6   ; wEucPLfoRate:  0=2ST,1=4ST,2=8ST,3=1BR,4=2BR,5=4BR,6=8BR
DEF MAX_EUCLID_PLFO_DEPTH  EQU 15  ; wEucPLfoDepth: 0..15 (reg-unit amplitude)
DEF MAX_EUCLID_VLFO_SHAPE  EQU 5   ; wEucVLfoShape: same set
DEF MAX_EUCLID_VLFO_RATE   EQU 6   ; wEucVLfoRate:  same set
DEF MAX_EUCLID_VLFO_DEPTH  EQU 7   ; wEucVLfoDepth: 0..7 (±depth level swing, clamp 1..7)
DEF MAX_PAGE         EQU 9   ; pages 0..9 (MAIN, CH1, TIMING, WAVE, ACCENT, FILL, TONAL, EUCLID, MIXER, CONTROLS)

; --- V30 Save/Load constants ---
DEF SAVE_WORD_COUNT    EQU 64   ; entries in SaveWordTable
DEF SAVE_SLOT_COUNT    EQU 8    ; save slots
DEF SAVE_SLOT_SIZE     EQU 72   ; bytes per slot: 4 header + 61 params + 7 pad (V38: was 64 — see slot-overlap bug, GB-DEV-LESSONS)
DEF SRAM_MAGIC_0       EQU $44  ; 'D'
DEF SRAM_MAGIC_1       EQU $41  ; 'A'
DEF SRAM_MAGIC_2       EQU $52  ; 'R'
DEF SRAM_MAGIC_3       EQU $50  ; 'P'
DEF SAVE_SCHEMA_VERSION EQU 8   ; bumped V38: slot stride 72, per-slot preset matrix appended
DEF SAVE_PARAM_COUNT   EQU 61   ; entries in SaveParamTable (+1 lock param V37)
DEF SUB_ARM_FRAMES     EQU 120  ; 2 seconds at 60 Hz
; --- V38 preset matrix constants ---
; SRAM is 32 KB / 4 banks (header -r 3). Slot records live in bank 0, the eight
; per-slot preset matrices fill SRAM BANK 1 exactly (8 × 1024 = 8 KB). MBC1 RAM
; banking: mode 1 via $6000 (set in EnableSRAM), bank select via $4000-$5FFF.
; On-device verified 2026-07-07 (cart 4). Cart 3's SRAM only responds to an 8 KB
; header — cart-specific defect; cart 3 is retired from SRAM duty (see
; GB-DEV-LESSONS "EMS 64M: probe every cart").
DEF PRESET_COUNT       EQU 16   ; 4×4 matrix cells
DEF PRESET_SIZE        EQU 64   ; SRAM bytes per preset: 1 occupied + 61 params + 2 pad
DEF MATRIX_SIZE        EQU PRESET_COUNT * PRESET_SIZE ; 1024 bytes per slot matrix
DEF MATRIX_BASE        EQU $A000 ; in SRAM BANK 1: MATRIX_BASE + slot*1024
DEF MATRIX_SRAM_BANK   EQU 1    ; matrices' RAM bank; all other save data = bank 0
; A slot record must never bleed into its neighbour (V37 shipped exactly that bug:
; 4+61 = 65 > 64 — saving slot N clobbered slot N+1's occupied flag).
ASSERT 4 + SAVE_PARAM_COUNT <= SAVE_SLOT_SIZE
; Slot records fit bank 0; matrices fit bank 1.
ASSERT $A008 + SAVE_SLOT_COUNT * SAVE_SLOT_SIZE <= $C000
ASSERT MATRIX_BASE + SAVE_SLOT_COUNT * MATRIX_SIZE <= $C000

; =============================================================================
; Interrupt Vectors
; =============================================================================

SECTION "VBlank_ISR", ROM0[$0040]
    jp VBlankHandler

SECTION "STAT_ISR", ROM0[$0048]
    reti

SECTION "Timer_ISR", ROM0[$0050]
    reti

SECTION "Serial_ISR", ROM0[$0058]
    reti

SECTION "Joypad_ISR", ROM0[$0060]
    reti

; =============================================================================
; Header
; =============================================================================

SECTION "Header", ROM0[$0100]
    nop
    jp EntryPoint
    ds $150 - @, 0

; =============================================================================
; HRAM
; =============================================================================

SECTION "HRAM", HRAM

hSpeedCounter:
    ds 1
hStepReady:
    ds 1
hGateCounter:
    ds 1
hFreqIndex:
    ds 1
hArpDegree:
    ds 1
hArpOctave:
    ds 1
hAccentPending:
    ds 1        ; 1 = cycle-start event, consumed by MaybeTriggerAccent
hFillActive:
    ds 1        ; 1 = gate-noise fill is playing on CH4, cut at next note-on
hAccentTailFrames:
    ds 1        ; remaining VBlank frames the accent envelope is still ringing
                ; (ticked down by VBlankHandler; suppresses fill while > 0)
hCycleReset:
    ds 1        ; 1 = next step starts a new arpeggio cycle (set by AdvanceArp,
                ; consumed at step handler entry to reset wCyclePhase to 0)
hKickStepActive:
    ds 1        ; 1 = a KIK accent fired on the current step; cleared at the
                ; next step boundary. Used by the gate-expiry path to skip
                ; muting CH1 so the kick's pitch-sweep body keeps decaying.
                ; One-shot per step — distinct from hAccentTailFrames, which
                ; runs for ~30 frames and protects fill/tonal across steps.
                ; V26: also set by PlayEuclidKickSweep when Euclid writes CH1.
hEuclidKickWants:
    ds 1        ; V26: 1 = Euclid KICK fires this step (set by EuclidPreArbitrate,
                ; consumed by PlayEuclidKickSweep). Cleared each step before
                ; EuclidPreArbitrate writes to it.
hHelpFrames:
    ds 1        ; help-row countdown (180=3s); ticked by VBlankHandler.
                ; STRICTLY single-purpose: never read by audio/gate paths.
hHelpNameLo:
    ds 1        ; pointer to active 20-tile string
hHelpNameHi:
    ds 1
hHelpDirty:
    ds 1        ; bit0=needs redraw, bit1=needs clear
hHelpLastPage:
    ds 1        ; shadow of wCurrentPage for change detection
hCH3ShapeIdx:
    ds 1        ; current step index in shape sequence (0-based)
hCH3ShapeCnt:
    ds 1        ; countdown frames to next shape step
hCH3ShapeBase:
    ds 1        ; frames per step (computed at engine init)
hCH3ShapeRunning:
    ds 1        ; 0=idle/stopped, 1=shape engine active
hCH3ShapeMuted:
    ds 1        ; 1=NR32 forced to 0 by gate-off; engine still advances
hCH3ShapeLast:
    ds 1        ; last NR32 value the shape engine wrote (restored on note-on)
hCH1OffsetCounter:
    ds 1        ; VBlanks remaining until deferred CH1 fire (0=inactive)
hCH1FirePending:
    ds 1        ; 1 = deferred CH1 fire armed, not yet dispatched
hEucModLevel:
    ds 1        ; V35: modulated LEVEL value used by PlayEuclidKickSweep (1..7)
hEucModPitch:
    ds 1        ; V35: modulated PITCH value used by PlayEuclidKickSweep (0..63)

; =============================================================================
; WRAM
; =============================================================================

SECTION "WRAM", WRAM0

wPlaying:       ds 1
wCurrentBank:   ds 1
wPlayingBank:   ds 1
wRootNote:      ds 1
wRootOctave:    ds 1
wArpPosition:   ds 1
wArpDirection:  ds 1
wPatternType:   ds 1
wSpeed:         ds 1
wDutyCycle:     ds 1
wOctaveRange:   ds 1
wNoteCount:     ds 1
wGateLength:    ds 1
wStride:        ds 1
wAttackSpeed:   ds 1
wPrevButtons:   ds 1
wRepeatCounter: ds 1
wCurrentPage:   ds 1
wPageRedraw:    ds 1
wSwing:         ds 1
wSwingPhase:    ds 1
wCH1Mode:           ds 1
wCH1ModePending:    ds 1   ; visually previewed mode while A+LR navigates on page 2
wCH1ModeNav:        ds 1   ; 1 = A-held navigation in progress, 0 = idle
wCH1Volume:     ds 1
wCH1Detune:     ds 1
wCH1Interval:   ds 1
wCH1ScaleDeg:   ds 1
wCH1DetunePending:   ds 1    ; preview while A held; commit→wCH1Detune on A release
wCH1IntervalPending: ds 1
wCH1ScaleDegPending: ds 1
wCH1Attack:     ds 1
wCH1AtkType:    ds 1
wCH1Wave:       ds 1
wCH1Offset:     ds 1        ; 0=OFF, 1..7 = 12/25/33/50/67/75/87 % step delay
wRngState:      ds 1
wTapFrames:     ds 1
wTapFrac:       ds 1        ; 1/8-frame fractional tap interval (0..7)
wTapCounter:    ds 1
wTapSubdiv:     ds 1
wTapEffective:  ds 1
wTapBpmTiles:   ds 3        ; precomputed inverted BPM digit tiles (hund/tens/ones)
wTapCount:      ds 1
wInvertTimer:   ds 1
wCH3Mode:       ds 1
wCH3Wave:       ds 1
wCH3Volume:     ds 1
wCH3Running:    ds 1        ; 0 = needs trigger, 1 = already playing
wCH3Shape:      ds 1        ; 0=OFF, 1=PLK, 2=DCY, 3=ATK, 4=AD, 5=TRM, 6=GAT, 7=RND
wCH3Rate:       ds 1        ; 1..8 arp steps per envelope/cycle (saved; 0=compat default=1)
wNoiseAccent:   ds 1        ; 0=OFF, 1=KIK, 2=SNR, 3=RIM (CH4 accent preset)
wFillLevel:     ds 1        ; 0..7 (CH4 fill volume seed; NR42 nibble = level<<1)
wFillColor:     ds 1        ; 0=HIS (15-bit LFSR), 1=MTL (7-bit LFSR)
wFillPitch:     ds 1        ; 0..7 (NR43 clock-shift high nibble)
wFillFreq:      ds 1        ; 0..7 (NR43 divider, bits 2..0)
wFillShape:     ds 1        ; 0=FLT, 1=ER↑, 2=ER↓, 3=LR↑, 4=LR↓
wFillCycleStep: ds 1        ; cached: 16 / cycle_length (pattern-aware)
wCyclePhase:    ds 1        ; monotonic phase 0..cycle_length-1, reset at cycle starts
wTonalMode:     ds 1        ; 0=OFF, 1=ON
wTonalLevel:    ds 1        ; 0..7 (NR42 high nibble via LevelTable)
wTonalMap:      ds 1        ; 0=TRK, 1=GML, 2=INV (mapping table choice)
wTonalWidth:    ds 1        ; 0=15-bit (white), 1=7-bit (metallic) — NR43 bit 3
wTonalDecay:    ds 1        ; 0=PNG, 1=RNG, 2=CUT (envelope step + gate-off mute)
wTonalTransp:   ds 1        ; 0..24, displayed -12..+12 (offset binary, 12=zero)
wTonalTrig:     ds 1        ; 0=EVR, 1=HLF (every 2nd), 2=Q4 (every 4th)
wTonalPri:      ds 1        ; 0=ALL, 1=+ACC, 2=+FIL, 3=SOLO (CH4 priority)
wTonalTrigCount: ds 1       ; runtime step counter; reset at cycle starts
wTonalLock:     ds 1        ; 0=FRE (normal trigger), 1=LOK (freeze CH4, no retrigger)
; --- V26 Euclidean Drum Machine (KICK lane, CH1-only) ---
wEuclidKickK:     ds 1      ; 0..N (HITS). Cold boot 0 (silent).
wEuclidKickN:     ds 1      ; 2..16 (LEN). Cold boot 8.
wEuclidKickRot:   ds 1      ; 0..N-1 (ROT). Cold boot 0.
wEuclidKickLevel: ds 1      ; 0..7 (NR12 high nibble). Cold boot 5.
wEuclidKickSound: ds 1      ; 0..3 (SOUND timbre index). Cold boot 1 (BOOM).
wEuclidKickDecay: ds 1      ; 0..2 (DECAY envelope index). Cold boot 1 (MID).
wEuclidKickPitch: ds 1      ; 0..63 offset-binary, 32=zero (signed -32..+31 steps; ×16 at apply ≈ ±6 semitones).
wEuclidKickLock:  ds 1      ; 0=FRE (manual LEN), 1=LOK (LEN tracks arp cycle length). V37.
wEuclidKickStep:  ds 1      ; 0..N-1 (phase counter, +1 per step, mod N).
; --- V27.1 Page 8 HUD caching (MODE-3 dropped-write mitigation) ---
wEuclidPatternDirty: ds 1   ; nonzero → compute vis buf outside VBlank (V37: feeds blit path).
wHudP8Ind:           ds 1   ; last-painted Page 8 indicator state ($FF=unknown).
; --- V37 Euclid visualizer shadow buffer (unsaved scratch, no save-schema impact) ---
wEuclidVisBuf:       ds 18  ; shadow: 16 step tiles + 2 arrow tiles, computed outside VBlank.
wEuclidVisReady:     ds 1   ; 1 = buffer computed and awaiting blit into VRAM.
; --- V35 Euclid MOD LFO params (saved) ---
wEucPLfoShape:  ds 1    ; 0=OFF,1=UP,2=DN,3=TRI,4=SIN,5=RND
wEucPLfoRate:   ds 1    ; 0=2ST,1=4ST,2=8ST,3=1BR,4=2BR,5=4BR,6=8BR
wEucPLfoDepth:  ds 1    ; 0..15
wEucVLfoShape:  ds 1
wEucVLfoRate:   ds 1
wEucVLfoDepth:  ds 1    ; 0..7
; --- V35 Euclid MOD runtime state (not saved) ---
wEucModView:    ds 1    ; 0=KICK view, 1=MOD view (START toggles on page 8)
wEucLfoDirty:   ds 1    ; 1=recompute phase increments (set by param change or N change)
wEucPLfoPhLo:   ds 1    ; pitch LFO 16-bit phase accumulator low byte
wEucPLfoPhHi:   ds 1    ; pitch LFO 16-bit phase accumulator high byte
wEucPLfoIncLo:  ds 1    ; pitch LFO precomputed step increment low byte
wEucPLfoIncHi:  ds 1    ; pitch LFO precomputed step increment high byte
wEucVLfoPhLo:   ds 1    ; velocity LFO phase accumulator low byte
wEucVLfoPhHi:   ds 1    ; velocity LFO phase accumulator high byte
wEucVLfoIncLo:  ds 1    ; velocity LFO step increment low byte
wEucVLfoIncHi:  ds 1    ; velocity LFO step increment high byte
; --- V30 Save/Load sub-page state ---
wSubPage:            ds 1   ; 0=none, 1=SAVE list, 2=LOAD list
wSubCursor:          ds 1   ; 0..7 selected slot index
wSubArmCounter:      ds 1   ; frames remaining on two-press overwrite arm (0=not armed)
wSubDirty:           ds 1   ; 1=sub-page needs full redraw
wSubDrawSlot:        ds 1   ; scratch: slot index being drawn in DrawOneSlotRow
wSubSavedWord:       ds 1   ; scratch: word_idx written by SaveSlot, kept for read-back verify
wRndSkipBit:         ds 1   ; scratch: mode selector for RandomizeParams (0=WILD, 1=MILD)
; --- V32/V36 per-channel mute flags (all 5 saved to SRAM per slot) ---
wMuteCH4:            ds 1   ; 0=audible, 1=CH4 (accent/fill/tonal) muted
wMuteEuc:            ds 1   ; 0=audible, 1=Euclid kick (CH1 sweep) muted
wMuteCH1:            ds 1   ; 0=audible, 1=CH1 melodic companion muted (V36)
wMuteCH2:            ds 1   ; 0=audible, 1=CH2 arp note muted (V36)
wMuteCH3:            ds 1   ; 0=audible, 1=CH3 wave muted (V36)
; --- V38 preset matrix (16 presets, WRAM working copy; persisted per save slot) ---
; Each preset is a SAVE_PARAM_COUNT-byte copy of all SaveParamTable entries
; (same snapshot format the old undo/redo history used). The matrix lives in
; WRAM only while playing; it reaches SRAM exclusively through SaveSlot and is
; restored by LoadSlot — build a matrix, save the slot, or lose it at power-off.
; 4×4 UI on the CONTROLS sub-page (wSubPage=3): A=load, B=save, ST=del, SEL=back.
wPresetBuf:          ds PRESET_COUNT * SAVE_PARAM_COUNT ; 16 × 61 = 976 bytes
wPresetOcc:          ds PRESET_COUNT            ; per-preset occupied flag (0=empty)
wSubArmAction:       ds 1                       ; armed confirm: 0=none, 1=overwrite, 2=delete
wPresetActive:       ds 1                       ; V38.1: last loaded/saved cell 0..15 ($FF=none);
                                                ; session marker only (not saved); shown as a
                                                ; dot after the cell digits. Reset on LoadSlot.

; =============================================================================
; Main Code
; =============================================================================

SECTION "Main", ROM0[$0150]

EntryPoint:
    call WaitVBlank
    call DisableLCD
    call LoadTiles
    call InvertTiles            ; build inverted tiles at $8400 (LCD off)

    xor a
    call FillBGMap

    ; --- Draw and show start screen ---
    call DrawStartScreen

    ld a, $CC                   ; BGP: 0=white, 1=black, 2=white, 3=black
    ldh [rBGP], a               ; (color 2 only used by inverted tiles → white ink)
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ld a, $91
    ldh [rLCDC], a

    call WaitForStart

    ; --- Transition to arp mode ---
    call WaitVBlank
    call DisableLCD
    xor a
    call FillBGMap
    call DrawControls

    call InitSound

    ; --- Initialize WRAM ---
    ld a, 1
    ld [wPlaying], a
    ld [wCurrentBank], a
    ld [wPlayingBank], a
    ld [wPrevButtons], a
    ld [wAttackSpeed], a

    xor a
    ld [wDutyCycle], a

    ld a, 2
    ld [wRootNote], a

    xor a
    ld [wArpPosition], a
    ld [wArpDirection], a
    ld [wPatternType], a

    xor a
    ld [wRootOctave], a

    ld a, 2
    ld [wOctaveRange], a

    ld a, MAX_GATE
    ld [wGateLength], a

    ld a, 1
    ld [wStride], a

    ld a, DEFAULT_SPEED
    ld [wSpeed], a

    ld a, REPEAT_DELAY
    ld [wRepeatCounter], a

    xor a
    ld [wCurrentPage], a
    ld [wPageRedraw], a
    ld [wSwing], a
    ld [wSwingPhase], a
    ld [wCH1Mode], a
    ld [wCH1ModePending], a
    ld [wCH1ModeNav], a
    ld [wCH1Attack], a
    ld [wTapFrames], a
    ld [wTapFrac], a
    ld [wTapCounter], a
    ld [wTapEffective], a
    ld [wTapCount], a
    ld [wInvertTimer], a
    ld [wCH3Mode], a
    ld [wCH3Wave], a
    ld [wCH3Running], a
    ld [wCH3Shape], a           ; default: OFF (shape engine disabled)
    ld [wNoiseAccent], a
    ld [wFillLevel], a
    ld [wFillColor], a
    ld [wFillShape], a
    ld [wCyclePhase], a
    ld [wTonalMode], a          ; OFF
    ld [wTonalMap], a           ; TRK
    ld [wTonalDecay], a         ; PNG
    ld [wTonalTrig], a          ; EVR
    ld [wTonalTrigCount], a
    ld [wTonalLock], a          ; FRE

    ld a, 4
    ld [wTonalLevel], a

    ld a, 1
    ld [wTonalWidth], a         ; 7-bit metallic (the headline flavor)
    ld [wTonalPri], a           ; +ACC

    ld a, 12
    ld [wTonalTransp], a        ; offset-binary zero

    ; --- V26 Euclidean Drum Machine init ---
    xor a
    ld [wEuclidKickK], a        ; HITS=0 (cold boot silent — V25 byte-for-byte regression-free)
    ld [wEuclidKickRot], a
    ld [wEuclidKickStep], a
    ld a, 8
    ld [wEuclidKickN], a        ; LEN=8
    ld a, 5
    ld [wEuclidKickLevel], a    ; LEVEL=5
    ld a, 1
    ld [wEuclidKickSound], a    ; SOUND=BOOM
    ld [wEuclidKickDecay], a    ; DECAY=MID
    ld a, EUCLID_PITCH_NEUTRAL
    ld [wEuclidKickPitch], a    ; PITCH=0 (signed neutral, kick uses preset frequency unchanged)
    xor a
    ld [wEuclidKickLock], a     ; LOCK=FRE (manual LEN by default)

    ; Force first-frame paint of Page 8 cached HUD elements.
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld a, $FF
    ld [wHudP8Ind], a
    xor a
    ld [wEuclidVisReady], a    ; V37: no buffer computed yet

    ; --- V35 Euclid MOD LFO init ---
    xor a
    ld [wEucPLfoShape], a
    ld [wEucPLfoRate], a
    ld [wEucPLfoDepth], a
    ld [wEucVLfoShape], a
    ld [wEucVLfoRate], a
    ld [wEucVLfoDepth], a
    ld [wEucModView], a
    ld [wEucLfoDirty], a
    ld [wEucPLfoPhLo], a
    ld [wEucPLfoPhHi], a
    ld [wEucPLfoIncLo], a
    ld [wEucPLfoIncHi], a
    ld [wEucVLfoPhLo], a
    ld [wEucVLfoPhHi], a
    ld [wEucVLfoIncLo], a
    ld [wEucVLfoIncHi], a

    ; --- V30 sub-page state ---
    xor a
    ld [wSubPage], a
    ld [wSubCursor], a
    ld [wSubArmCounter], a
    ld [wSubDirty], a
    ld [wSubDrawSlot], a
    ld [wSubSavedWord], a
    ld [wSubArmAction], a

    ; --- V38 preset matrix: boot empty; LoadSlot brings in a slot's matrix ---
    ld hl, wPresetOcc
    ld b, PRESET_COUNT
.clearPresetOcc:
    ld [hl], 0
    inc hl
    dec b
    jr nz, .clearPresetOcc
    ld a, $FF
    ld [wPresetActive], a       ; no active preset yet
    ; --- V32/V36 mute flags ---
    xor a
    ld [wMuteCH4], a
    ld [wMuteEuc], a
    ld [wMuteCH1], a
    ld [wMuteCH2], a
    ld [wMuteCH3], a

    call EnsureSRAM             ; validate/initialise battery-backed SRAM

    xor a

    ld a, 4
    ld [wFillFreq], a           ; default divider 4 (mid range)

    ld a, 3
    ld [wFillPitch], a          ; default clock-shift 3 (moderate pitch)
    ld [wCH3Volume], a

    ld a, 2
    ld [wCH3Rate], a            ; default: 2 steps per envelope cycle

    ld a, 7
    ld [wCH1Volume], a
    ld a, 2
    ld [wCH1Detune], a
    ld [wCH1DetunePending], a
    ld a, 6
    ld [wCH1Interval], a
    ld [wCH1IntervalPending], a
    ld a, 1
    ld [wCH1ScaleDeg], a
    ld [wCH1ScaleDegPending], a
    ld [wCH1AtkType], a        ; default: preset 1 ($89, moderate attack)

    ld a, 2
    ld [wCH1Wave], a           ; default: 50% (classic square wave)
    xor a
    ld [wCH1Offset], a         ; default: OFF
    ld a, 2
    ld [wTapSubdiv], a         ; also 1

    ld a, $A7
    ld [wRngState], a

    call ComputeNoteCount

    ; Seed prev button state so held START from start screen isn't re-detected
    call ReadButtons
    ld [wPrevButtons], a

    ; --- Initialize HRAM ---
    ld a, DEFAULT_SPEED
    ldh [hSpeedCounter], a
    xor a
    ldh [hStepReady], a
    ldh [hGateCounter], a
    ldh [hAccentPending], a
    ldh [hFillActive], a
    ldh [hAccentTailFrames], a
    ldh [hKickStepActive], a
    ldh [hEuclidKickWants], a
    ldh [hCH1OffsetCounter], a
    ldh [hCH1FirePending], a
    ld a, 1
    ldh [hCycleReset], a    ; arm reset so first step sets wCyclePhase=0
    xor a
    ldh [hHelpFrames], a
    ldh [hHelpNameLo], a
    ldh [hHelpNameHi], a
    ldh [hHelpDirty], a
    ldh [hHelpLastPage], a  ; matches default wCurrentPage=0
    ldh [hCH3ShapeIdx], a
    ldh [hCH3ShapeCnt], a
    ldh [hCH3ShapeBase], a
    ldh [hCH3ShapeRunning], a
    ldh [hCH3ShapeMuted], a
    ldh [hCH3ShapeLast], a

    ; --- Enable VBlank interrupt ---
    ld a, 1
    ldh [rIE], a
    ei

    ; --- Set display ---
    ld a, $CC                   ; BGP: 0=white, 1=black, 2=white, 3=black
    ldh [rBGP], a
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ld a, $91
    ldh [rLCDC], a

; =============================================================================
; Main Loop
; =============================================================================

MainLoop:
    halt
    nop

    ; Increment tap counter if counting
    ld a, [wTapCounter]
    and a
    jr z, .noTapCount
    cp 255
    jr z, .tapOverflow
    inc a
    ld [wTapCounter], a
    jr .noTapCount
.tapOverflow:
    xor a
    ld [wTapCounter], a     ; abandon on overflow (>4.2 sec)
    ld [wTapCount], a       ; reset tap count
.noTapCount:

    ; Invert timer countdown
    ld a, [wInvertTimer]
    and a
    jr z, .noInvert
    dec a
    ld [wInvertTimer], a
    jr nz, .noInvert
    ld a, $CC                   ; restore normal palette (white-ink-on-black for inverted)
    ldh [rBGP], a
.noInvert:

    ; Read buttons FIRST so wPrevButtons reflects the current frame before
    ; UpdateHUD paints modifier indicators (V27: fixes 1-frame lag where
    ; ► markers appeared late and lingered after release).
    call ReadButtons
    ld b, a
    ld a, [wPrevButtons]
    cpl
    and b
    ld c, a
    ld a, b
    ld [wPrevButtons], a
    push bc                     ; preserve held + new-presses across HUD work

    ; Handle deferred page redraw (LCD off, skip HUD this frame)
    ld a, [wPageRedraw]
    and a
    jr z, .noRedraw
    call DoPageRedraw
    jr .afterHUD
.noRedraw:
    ; Handle sub-page dirty redraw (also disables/re-enables LCD)
    ld a, [wSubDirty]
    and a
    jr z, .noSubDirty
    call DrawSubPage
    jr .afterHUD
.noSubDirty:
    ; Skip full HUD updates while in sub-page (DrawSubPage owns the screen)
    ld a, [wSubPage]
    and a
    jr z, .doUpdateHUD
    call HelpRowTick            ; still tick help-row timer in sub-page
    call CH3ShapeTick           ; still advance shape engine in sub-page
    jr .afterHUD
.doUpdateHUD:
    call UpdateHUD
.afterHUD:

    pop bc                      ; restore current/new-presses for HandleInput

    ; c = new presses, b = held buttons
    ld a, c
    and a
    call nz, HandleInput

    ; --- CH1 VOICING + sub-param deferred commit (page 2, V33.2 / V36.3) ---
    ; Arm on first A-press on page 2; commit all pending→committed on A release.
    ld a, b
    and BTN_A
    jr nz, .ch1ModeAHeld
    ld a, [wCH1ModeNav]
    and a
    jr z, .ch1ModeDone
    xor a
    ld [wCH1ModeNav], a
    ld a, [wCH1ModePending]
    ld [wCH1Mode], a
    ld a, [wCH1DetunePending]
    ld [wCH1Detune], a
    ld a, [wCH1IntervalPending]
    ld [wCH1Interval], a
    ld a, [wCH1ScaleDegPending]
    ld [wCH1ScaleDeg], a
    jr .ch1ModeDone
.ch1ModeAHeld:
    ld a, [wCH1ModeNav]
    and a
    jr nz, .ch1ModeDone
    ld a, [wCurrentPage]
    cp 1
    jr nz, .ch1ModeDone
    ld a, 1
    ld [wCH1ModeNav], a
    ld a, [wCH1Mode]
    ld [wCH1ModePending], a
    ld a, [wCH1Detune]
    ld [wCH1DetunePending], a
    ld a, [wCH1Interval]
    ld [wCH1IntervalPending], a
    ld a, [wCH1ScaleDeg]
    ld [wCH1ScaleDegPending], a
.ch1ModeDone:

    ; --- Page-2 AB+↑↓ auto-repeat (CH1 OFFSET, V34.1) ---
    ; Held-state repeat (re-samples b each frame) — also covers the case where the
    ; single-frame AB+↑ press edge is missed (3-key combo edge is fragile).
    ld a, [wCurrentPage]
    cp 1                            ; page 2 (0-indexed = 1)?
    jr nz, .p4RateHead
    ld a, b
    and %00110000                   ; A+B both held?
    cp %00110000
    jr nz, .p4RateHead
    ld a, c
    and %00001100                   ; UD newly pressed?
    jr z, .p2ABUDNoNew
    ld a, REPEAT_DELAY
    ld [wRepeatCounter], a
    jp .noRepeat
.p2ABUDNoNew:
    ld a, b
    and %00001100                   ; UD held?
    jp z, .noRepeat
    ld a, [wRepeatCounter]
    dec a
    ld [wRepeatCounter], a
    jp nz, .noRepeat
    ld a, REPEAT_RATE
    ld [wRepeatCounter], a
    bit 2, b                        ; UP held?
    jr z, .p2ABOffDown
    call CH1OffsetNext
    jp .noRepeat
.p2ABOffDown:
    call CH1OffsetPrev
    jp .noRepeat

.p4RateHead:
    ; --- Page-4 AB+↑↓ auto-repeat (RATE) ---
    ld a, [wCurrentPage]
    cp 3                            ; page 4 (0-indexed = 3)?
    jr nz, .p4ABUDHead
    ld a, b
    and %00110000                   ; A+B both held?
    cp %00110000
    jr nz, .p4ABUDHead
    ; AB on page 4 → RATE
    ld a, c
    and %00001100                   ; UD newly pressed?
    jr z, .p4ABUDNoNew
    ld a, REPEAT_DELAY
    ld [wRepeatCounter], a
    jp .noRepeat
.p4ABUDNoNew:
    ld a, b
    and %00001100                   ; UD held?
    jp z, .noRepeat
    ld a, [wRepeatCounter]
    dec a
    ld [wRepeatCounter], a
    jp nz, .noRepeat
    ld a, REPEAT_RATE
    ld [wRepeatCounter], a
    bit 2, b                        ; UP held?
    jr z, .p4ABRateDown
    call CH3RateUp
    jp .noRepeat
.p4ABRateDown:
    call CH3RateDown
    jp .noRepeat

.p4ABUDHead:
    ; --- V31.1: Page-8 B+↑↓ auto-repeat (PITCH) ---
    ; Lone B + UD on page 8 steps wEuclidKickPitch. Reuses wRepeatCounter —
    ; only one directional class is active per page-frame (same invariant as LR block).
    ; Must come before the LR block: LR's modifier gate jumps to .udAutoRepeat on any
    ; modifier hit (including lone B), so the B+UD block must be checked first.
    ld a, [wCurrentPage]
    cp 7
    jr nz, .p8LRCheck           ; not page 8 → try LR block
    ld a, b
    and %10110000               ; mask A(4) + B(5) + ST(7)
    cp %00100000                ; lone B?
    jr nz, .p8LRCheck           ; not lone B → try LR block
    ; UD newly pressed → load delay, skip firing this frame
    ld a, c
    and %00001100
    jr z, .p8BUDNoNew
    ld a, REPEAT_DELAY
    ld [wRepeatCounter], a
    jp .noRepeat
.p8BUDNoNew:
    ld a, b
    and %00001100               ; UD held?
    jp z, .noRepeat             ; lone B but nothing pressed/held in UD → nothing to do
    ld a, [wRepeatCounter]
    dec a
    ld [wRepeatCounter], a
    jp nz, .noRepeat
    ld a, REPEAT_RATE
    ld [wRepeatCounter], a
    bit 2, b                    ; UP held?
    jr z, .p8BUDDown
    call EuclidKickPitchUp
    jp .noRepeat
.p8BUDDown:
    call EuclidKickPitchDown
    jp .noRepeat

    ; --- V26.1: Page-8 plain-LR auto-repeat (ROT) ---
    ; Plain ←/→ on page 8 rotates the pattern. To support hold-to-rotate,
    ; gate the existing UD-only repeat block by page and run a parallel LR
    ; repeat path here. wRepeatCounter is reused — only one directional class
    ; is active per page-frame, so they don't collide.
.p8LRCheck:
    ld a, [wCurrentPage]
    cp 7
    jr nz, .udAutoRepeat
    ld a, b
    and %10110000               ; A/B/START held → not a plain-LR scenario
    jr nz, .udAutoRepeat
    ; LR newly pressed → reset counter and skip firing this frame
    ld a, c
    and %00000011
    jr z, .p8LRNoNew
    ld a, REPEAT_DELAY
    ld [wRepeatCounter], a
    jp .noRepeat
.p8LRNoNew:
    ld a, b
    and %00000011               ; LR held?
    jp z, .udAutoRepeat
    ld a, [wRepeatCounter]
    dec a
    ld [wRepeatCounter], a
    jp nz, .noRepeat
    ld a, REPEAT_RATE
    ld [wRepeatCounter], a
    bit 0, b                    ; right held → next; else left → prev
    jr z, .p8LRLeft
    call EuclidKickRotNext
    jp .noRepeat
.p8LRLeft:
    call EuclidKickRotPrev
    jp .noRepeat

.udAutoRepeat:
    ; --- Auto-repeat for speed (A+↑↓) and note (plain ↑↓) ---
    ld a, c
    and %00001100           ; up or down newly pressed?
    jr z, .noRepeatReset
    ld a, REPEAT_DELAY
    ld [wRepeatCounter], a
    jp .noRepeat
.noRepeatReset:
    ; Check if repeatable combo is held
    ; Case 1: A held (not B, not START), up or down held
    ld a, b
    and %10110000           ; mask START+B+A
    cp %00010000            ; only A held?
    jr z, .checkRepeatDir
    ; Case 2: No modifier, up or down held
    ld a, b
    and %10110000
    jp nz, .noRepeat        ; some modifier other than lone A → skip
    ; Allow plain UD repeat on page 0 (MAIN) and page 2 (TIMING) only
    ld a, [wCurrentPage]
    and a
    jr z, .checkRepeatDir
    cp 2
    jp nz, .noRepeat
.checkRepeatDir:
    ld a, b
    and %00001100           ; up or down held?
    jp z, .noRepeat
    ; Decrement counter
    ld a, [wRepeatCounter]
    dec a
    ld [wRepeatCounter], a
    jp nz, .noRepeat
    ; Counter expired — fire repeat
    ld a, REPEAT_RATE
    ld [wRepeatCounter], a
    bit 4, b                ; A held?
    jr z, .repeatPlain
    ; A + direction — check page
    ld a, [wCurrentPage]
    and a
    jr z, .repeatAPage1
    cp 1
    jr z, .repeatAPage2
    cp 2
    jr z, .repeatAPage3
    ; Page 4: no auto-repeat (wave changes need discrete presses)
    jr .noRepeat
.repeatAPage3:
    ; Page 3: A+dir = subdivision
    bit 2, b
    jr z, .repeatADownP3
    call SubdivUp
    jr .noRepeat
.repeatADownP3:
    call SubdivDown
    jr .noRepeat
.repeatAPage1:
    bit 2, b
    jr z, .repeatADown
    call SpeedUp
    jr .noRepeat
.repeatADown:
    call SpeedDown
    jr .noRepeat
.repeatAPage2:
    ; Page 2: A+UD = mode-dependent sub-param (use pending so repeat targets previewed mode)
    ld a, [wCH1ModePending]
    cp 3
    jr z, .repP2Det
    cp 4
    jr z, .repP2Int
    cp 5
    jr z, .repP2Deg
    jr .noRepeat            ; OFF/OC+/OC-: no repeat
.repP2Det:
    bit 2, b
    jr z, .repP2DetDn
    call CH1DetUp
    jr .noRepeat
.repP2DetDn:
    call CH1DetDown
    jr .noRepeat
.repP2Int:
    bit 2, b
    jr z, .repP2IntDn
    call CH1IntUp
    jr .noRepeat
.repP2IntDn:
    call CH1IntDown
    jr .noRepeat
.repP2Deg:
    bit 2, b
    jr z, .repP2DegDn
    call CH1DegUp
    jr .noRepeat
.repP2DegDn:
    call CH1DegDown
    jr .noRepeat
.repeatPlain:
    ld a, [wCurrentPage]
    cp 2
    jr z, .repeatPlainP3
    bit 2, b
    jr z, .repeatPlainDown
    call RootNoteUp
    jr .noRepeat
.repeatPlainDown:
    call RootNoteDown
    jr .noRepeat
.repeatPlainP3:
    bit 2, b
    jr z, .repeatPlainP3Down
    call TapNudgeUp
    jr .noRepeat
.repeatPlainP3Down:
    call TapNudgeDown
.noRepeat:

    ; --- Check B release: apply pending bank change ---
    bit 5, b
    jr nz, .bStillHeld
    ld a, [wCurrentBank]
    ld d, a
    ld a, [wPlayingBank]
    cp d
    jr z, .bStillHeld
    ld a, d
    ld [wPlayingBank], a
    call ComputeNoteCount
    call ClampArpPosition
.bStillHeld:

    ; --- Gate check (silence note when gate expires) ---
    ldh a, [hGateCounter]
    and a
    jr z, .noGate
    dec a
    ldh [hGateCounter], a
    jr nz, .noGate
    ld a, DAC_ON_SILENT
    ldh [rNR22], a          ; CH2: DAC alive, vol 0
    ld a, $80
    ldh [rNR24], a          ; retrigger CH2 at vol 0
    ; CH1 mute guard: if a KIK accent fired on THIS step, skip muting CH1 so
    ; the kick's pitch-sweep body keeps decaying through the gate-off window.
    ; PlayCurrentNote on the next step rewrites NR10-NR14 cleanly. Other accent
    ; types (SNR/RIM) don't use CH1, so their tails are unaffected by this mute.
    ; Uses a one-shot per-step latch (hKickStepActive), not hAccentTailFrames —
    ; the latter is a 30-frame decay timer that would erroneously skip mutes on
    ; the 3-4 subsequent steps after a kick at fast tempos, breaking gate %.
    ldh a, [hKickStepActive]
    and a
    jr nz, .skipCh1Mute
    ld a, DAC_ON_SILENT
    ldh [rNR12], a          ; CH1: DAC alive, vol 0
    ld a, $80
    ldh [rNR14], a          ; retrigger CH1 at vol 0
.skipCh1Mute:
    xor a
    ldh [rNR32], a              ; CH3 mute via volume
    ld a, 1
    ldh [hCH3ShapeMuted], a     ; shape engine survives — gate only mutes output
    ; Gate-noise fill dispatch:
    ;   1. If an accent's envelope is still ringing (hAccentTailFrames > 0),
    ;      skip the fill so its CH4 retrigger doesn't clip the decay tail.
    ;      The countdown covers same-step (just-fired) and next-step carry-over
    ;      cases at fast tempos, where the per-step latch alone was insufficient.
    ;   2. If SHAPE=FLT and LEVEL=0, skip — that's the explicit "off" combo.
    ;   3. Otherwise compose NR41/43/42 + retrigger via ComposeAndPlayFill, and
    ;      arm hFillActive so the next note-on mutes CH4 before accent re-arm.
    ldh a, [hAccentTailFrames]
    and a
    jr nz, .noGate
    ; Tonal-mode PRI dispatch:
    ;   wTonalPri bit 0 = 0 (ALL/+FIL) → fill replaces tonal (existing behavior)
    ;   wTonalPri bit 0 = 1 (+ACC/SOLO) → fill suppressed; if DECAY=CUT, software
    ;     mute via NR42=$08 (V16 anti-pop pattern) so the sustained tonal cuts
    ;     cleanly; otherwise leave CH4 alone so the natural envelope decay rings.
    ld a, [wTonalMode]
    and a
    jr z, .checkFill
    ld a, [wTonalLock]
    and a
    jr nz, .noGate              ; LOCK engaged: frozen sound rides through gate-offs
    ld a, [wTonalPri]
    bit 0, a
    jr z, .checkFill
    ; Fill suppressed — only act for CUT decay (software mute).
    ld a, [wTonalDecay]
    cp 2
    jr nz, .noGate
    call SilenceTonalCH4
    jr .noGate
.checkFill:
    ld a, [wMuteCH4]
    and a
    jr nz, .noGate              ; CH4 muted: skip fill entirely
    ld a, [wFillShape]
    and a
    jr nz, .fireFill
    ld a, [wFillLevel]
    and a
    jr z, .noGate
.fireFill:
    call ComposeAndPlayFill
    ld a, 1
    ldh [hFillActive], a
.noGate:

    ; Deferred CH1 fire: fires when counter reaches 0 after offset arm (V34.0)
    ldh a, [hCH1FirePending]
    and a
    jr z, .ch1NoPending
    ldh a, [hCH1OffsetCounter]
    and a
    jr nz, .ch1NoPending
    xor a
    ldh [hCH1FirePending], a
    call FireCH1Now
.ch1NoPending:

    ; V37: compute euclid vis buffer outside VBlank whenever the pattern is dirty.
    ; Runs every frame (step and non-step) so the visualizer updates promptly on edits.
    ld a, [wEuclidPatternDirty]
    and a
    jr z, .skipVisCmp
    call ComputeEuclidVisBuf
    ld a, 1
    ld [wEuclidVisReady], a
    xor a
    ld [wEuclidPatternDirty], a
.skipVisCmp:

    ; Check step ready
    ldh a, [hStepReady]
    and a
    jp z, MainLoop

    xor a
    ldh [hStepReady], a
    ldh [hKickStepActive], a    ; clear before MaybeTriggerAccent may set it;
                                ; ensures the kick's "skip CH1 mute" guard
                                ; fires only on the kick's own step.

    ; Update wCyclePhase for this step.  hCycleReset is set by AdvanceArp on
    ; cycle-start events (ASC wrap, DESC wrap, PINGPONG reversals); else we
    ; just increment.  Done unconditionally so wCyclePhase advances even on
    ; gate=silence steps, keeping LR↑/LR↓ fills phase-aligned across mode flips.
    ldh a, [hCycleReset]
    and a
    jr z, .phaseInc
    xor a
    ldh [hCycleReset], a
    ld [wCyclePhase], a
    ld [wTonalTrigCount], a    ; reset tonal pattern counter so the cycle-start
                               ; (downbeat) note always fires regardless of TRIG
    jr .phaseDone
.phaseInc:
    ld a, [wCyclePhase]
    inc a
    ld [wCyclePhase], a
.phaseDone:
    call EuclidPreArbitrate         ; V26: compute hEuclidKickWants for this step
                                    ; (also phase-ticks wEuclidKickStep mod N)

    ld a, [wPlaying]
    and a
    jp z, MainLoop

    call PlayCurrentNote
    call PlayEuclidKickSweep        ; V26: overwrite CH1 with kick sweep on KICK-pattern
                                    ; steps unless ACC=KIK is firing this step.
    ; Cut gate-noise fill (if any) before accent so an accent preset's NR42
    ; write overrules the mute and plays unclipped. If no accent fires, the
    ; mute stands and CH4 is silent until the next gate-off.
    ldh a, [hFillActive]
    and a
    jr z, .noFillCut
    xor a
    ldh [hFillActive], a
    ldh [rNR42], a
.noFillCut:
    call MaybeTriggerTonal
    call MaybeTriggerAccent

    ; Set gate counter — proportional to speed
    ld a, [wGateLength]
    and a
    jr z, .noGateSet       ; gate=OFF → no counter
    cp MAX_GATE
    jr z, .noGateSet       ; gate=SIL → CH2 silent inline; no gate-off counter
    ; a = gate level (1, 2, or 3)
    ld b, a              ; b = gate level
    call LoadSpeedFrames ; a = speed (VBlanks per step)
    cp 2
    jr c, .noGateSet     ; speed 1: no room for gate, skip
    ; Compute fraction: 1=75%, 2=50%, 3=25%
    dec b
    jr z, .gate75
    dec b
    jr z, .gate50
    ; Gate 3 = 25% = speed >> 2
    srl a
    srl a                ; a = speed/4
    and a
    jr z, .noGateSet     ; if result is 0, skip (speed too low)
    jr .gateStore
.gate75:
    ; Gate 1 = 75% = speed - (speed >> 2)
    ld b, a
    srl a                ; a = speed/2
    srl a                ; a = speed/4
    ld c, a
    ld a, b
    sub c                ; a = speed - speed/4
    jr .gateStore
.gate50:
    ; Gate 2 = 50% = speed >> 1
    srl a                ; a = speed/2
    jr .gateStore
.gateStore:
    ldh [hGateCounter], a
.noGateSet:
    call AdvanceArp
.afterAdvance:

    ; --- Reload speed counter with swing ---
    ld a, [wSwing]
    and a
    jr z, .noSwingAdj
    ld d, a                 ; d = swing offset
    ld a, [wSwingPhase]
    xor 1
    ld [wSwingPhase], a     ; toggle phase
    and a
    jr z, .swingLong
    ; Short step: speed - offset (min 1)
    call LoadSpeedFrames
    sub d
    jr c, .swingMin
    jr nz, .swingStore
.swingMin:
    ld a, 1
    jr .swingStore
.swingLong:
    ; Long step: speed + offset
    call LoadSpeedFrames
    add d
    jr .swingStore
.noSwingAdj:
    call LoadSpeedFrames
.swingStore:
    ldh [hSpeedCounter], a

    jp MainLoop

; =============================================================================
; Input Handling
; =============================================================================

HandleInput:
    ; c = new presses, wPrevButtons = currently held (just stored)
    ; All called routines must preserve b and c (only use a/d/e/h/l)

    ; Sub-page intercepts all input while active
    ld a, [wSubPage]
    and a
    jp nz, HandleSubPageInput

    bit 6, c                ; SELECT newly pressed?
    jr z, .noSelect
    bit 7, b                ; ST held? → reverse cycle
    jr nz, .selectPrev
    call TogglePage
    jr .noSelect
.selectPrev:
    call TogglePagePrev
.noSelect:

    ; Page routing
    ld a, [wCurrentPage]
    and a
    jp z, .page1Input
    cp 2
    jr z, .page3Input
    cp 3
    jp z, .page4Input
    cp 4
    jp z, .page5Input
    cp 5
    jp z, .page6Input
    cp 6
    jp z, .page7Input
    cp 7
    jp z, .page8Input
    cp 8
    jp z, .pageMixerInput
    cp 9
    jp z, .page9Input
    ; Page 2: START first (avoids dead-code after A/AB/B early returns)
    bit 7, b                ; START held?
    jr z, .p2NoStart
    bit 0, c                ; Right → CH1WaveUp
    call nz, CH1WaveUp
    bit 1, c                ; Left → CH1WaveDown
    call nz, CH1WaveDown
    ret
.p2NoStart:
    ; Page 2: A-held, AB-held, or B-held
    bit 4, b                ; A held?
    jr z, .p2NoA
    bit 5, b                ; AB held?
    jr nz, .abHeldPage2
    jp .aHeld               ; A alone → mode + sub-param
.abHeldPage2:
    ; AB+↑↓ on page 2: CH1 OFFSET (always active)
    bit 2, c                ; Up?
    call nz, CH1OffsetNext
    bit 3, c                ; Down?
    call nz, CH1OffsetPrev
    ; AB+LR on page 2: INDP attack type (only active when INDP)
    ld a, [wCH1Attack]
    cp 2
    ret nz
    bit 0, c                ; Right?
    call nz, CH1IAtkUp
    bit 1, c                ; Left?
    call nz, CH1IAtkDown
    ret
.p2NoA:
    bit 5, b                ; B held?
    jp z, .pageDone
    ; B held on Page 2: volume + attack cycle
    bit 2, c                ; Up?
    call nz, CH1VolUp
    bit 3, c                ; Down?
    call nz, CH1VolDown
    bit 0, c                ; Right?
    call nz, CH1AtkNext
    bit 1, c                ; Left?
    call nz, CH1AtkPrev
    ret
.page3Input:
    ; Page 3: B = tap, A+UD = subdivision, A+LR = swing,
    ; plain UD = ±1-frame tap nudge (no-op when tap inactive)
    bit 5, c
    call nz, TapTempo
    bit 4, b                ; A held?
    jr nz, .p3AHeld
    ; A not held — plain UD nudge (skip if START/SELECT/B held)
    ld a, b
    and %11100000
    ret nz
    bit 2, c
    call nz, TapNudgeUp
    bit 3, c
    call nz, TapNudgeDown
    ret
.p3AHeld:
    bit 2, c                ; Up?
    call nz, SubdivUp
    bit 3, c                ; Down?
    call nz, SubdivDown
    bit 0, c                ; Right?
    call nz, SwingUp
    bit 1, c                ; Left?
    call nz, SwingDown
    ret
.page4Input:
    ; Page 4: A+LR=mode, A+UD=wave, B+UD=volume, B+LR=shape, AB+UD=rate
    bit 4, b                ; A held?
    jr z, .p4NoA
    bit 5, b                ; B also held (AB)?
    jr nz, .p4AB
    ; A alone: MODE (LR), WAVE (UD)
    bit 0, c                ; Right?
    call nz, CH3ModeNext
    bit 1, c                ; Left?
    call nz, CH3ModePrev
    bit 2, c                ; Up?
    call nz, CH3WaveNext
    bit 3, c                ; Down?
    call nz, CH3WavePrev
    ret
.p4AB:
    ; AB: RATE (UD) — no auto-repeat here; handled in repeat block
    bit 2, c                ; Up?
    call nz, CH3RateUp
    bit 3, c                ; Down?
    call nz, CH3RateDown
    ret
.p4NoA:
    bit 5, b                ; B held?
    jp z, .pageDone
    ; B alone: VOLUME (UD), SHAPE (LR)
    bit 2, c                ; Up?
    call nz, CH3VolUp
    bit 3, c                ; Down?
    call nz, CH3VolDown
    bit 0, c                ; Right?
    call nz, CH3ShapeNext
    bit 1, c                ; Left?
    call nz, CH3ShapePrev
    ret
.page5Input:
    ; Page 5 (ACCENT): A+LR cycles ACCENT preset (OFF/KIK/SNR/RIM)
    bit 4, b                ; A held?
    ret z
    bit 5, b                ; AB? — reserved for future Euclidean params
    ret nz
    bit 0, c
    call nz, NoiseAccentNext
    bit 1, c
    call nz, NoiseAccentPrev
    ret
.page6Input:
    ; Page 6 (FILL):
    ;   A alone:  A+UD = LEVEL
    ;   B alone:  B+LR = COLOR, B+UD = PITCH
    ;   AB both:  AB+LR = SHAPE, AB+UD = FREQ
    bit 4, b                ; A held?
    jr z, .p6NoA
    bit 5, b                ; B also held?
    jr nz, .p6AB
    ; A alone: LEVEL via UD
    bit 2, c
    call nz, FillLevelNext
    bit 3, c
    call nz, FillLevelPrev
    ret
.p6AB:
    ; AB both held: SHAPE (LR) + FREQ (UD)
    bit 0, c
    call nz, FillShapeNext
    bit 1, c
    call nz, FillShapePrev
    bit 2, c
    call nz, FillFreqNext
    bit 3, c
    call nz, FillFreqPrev
    ret
.p6NoA:
    bit 5, b                ; B held?
    ret z
    ; B alone: COLOR (LR) + PITCH (UD)
    bit 0, c
    call nz, FillColorNext
    bit 1, c
    call nz, FillColorPrev
    bit 2, c
    call nz, FillPitchNext
    bit 3, c
    call nz, FillPitchPrev
    ret
.page7Input:
    ; Page 7 (TONAL):
    ;   A alone: A+LR = MODE,  A+UD = LEVEL
    ;   B alone: B+LR = MAP,   B+UD = WIDTH
    ;   AB:      AB+LR = DECAY, AB+UD = TRANSP
    ;   ST:      ST+LR = TRIG,  ST+UD = PRI
    bit 7, b                    ; START held? (priority over A/B/AB)
    jr z, .p7NoStart
    bit 0, c
    call nz, TonalTrigNext
    bit 1, c
    call nz, TonalTrigPrev
    bit 2, c
    call nz, TonalPriNext
    bit 3, c
    call nz, TonalPriPrev
    ret
.p7NoStart:
    bit 4, b                    ; A held?
    jr z, .p7NoA
    bit 5, b                    ; AB?
    jr nz, .p7AB
    ; A alone: MODE (LR) + LEVEL (UD)
    bit 0, c
    call nz, TonalModeNext
    bit 1, c
    call nz, TonalModePrev
    bit 2, c
    call nz, TonalLevelUp
    bit 3, c
    call nz, TonalLevelDown
    ret
.p7AB:
    ; AB: DECAY (LR) + TRANSP (UD)
    bit 0, c
    call nz, TonalDecayNext
    bit 1, c
    call nz, TonalDecayPrev
    bit 2, c
    call nz, TonalTranspUp
    bit 3, c
    call nz, TonalTranspDown
    ret
.p7NoA:
    bit 5, b                    ; B held?
    jr z, .p7NoMod
    ; B alone: MAP (LR) + WIDTH (UD)
    bit 0, c
    call nz, TonalMapNext
    bit 1, c
    call nz, TonalMapPrev
    bit 2, c
    call nz, TonalWidthNext
    bit 3, c
    call nz, TonalWidthPrev
    ret
.p7NoMod:
    ; No modifier — bare UD toggles LOCK; LR unbound
    bit 2, c
    call nz, TonalLockToggle
    bit 3, c
    call nz, TonalLockToggle
    ret
.page8Input:
    ; Page 8 (EUCLID KICK / EUCLID MOD sub-view):
    ;   ST press:  toggle KICK ↔ MOD sub-view  (V35)
    ;   KICK view: plain LR=ROT; A+UD=HITS, A+LR=LEN; B+LR=LEVEL, B+UD=PITCH; AB=SOUND/DECAY
    ;   MOD view:  A+LR=P.SHAPE, A+UD=P.RATE; B+LR=V.SHAPE, B+UD=V.RATE; AB+LR=P.DEPTH, AB+UD=V.DEPTH
    ; START press toggles view and triggers redraw.
    bit 7, b                    ; START held?
    jr z, .p8NoStart
    bit 7, c                    ; newly pressed?
    jr z, .p8NoStart
    ld a, [wEucModView]
    xor 1
    ld [wEucModView], a
    ld a, 1
    ld [wPageRedraw], a
    ld [wEuclidPatternDirty], a
    ld a, $FF
    ld [wHudP8Ind], a
    ret
.p8NoStart:
    ld a, [wEucModView]
    and a
    jp nz, .p8ModInput
    ; --- KICK view ---
    ld a, b
    and %10110000               ; mask A/B/START
    jr nz, .p8WithMod
    bit 0, c
    call nz, EuclidKickRotNext
    bit 1, c
    call nz, EuclidKickRotPrev
    bit 2, c                    ; plain ↑ = LOCK ON
    call nz, EuclidKickLockOn
    bit 3, c                    ; plain ↓ = LOCK OFF
    call nz, EuclidKickLockOff
    ret
.p8WithMod:
    bit 4, b                    ; A held?
    jr z, .p8NoA
    bit 5, b                    ; AB?
    jr nz, .p8AB
    ; A alone: HITS (UD) + LEN (LR, disabled when LOCK on)
    ld a, [wEuclidKickLock]
    and a
    jr nz, .p8ALockedLen
    bit 0, c
    call nz, EuclidKickLenNext
    bit 1, c
    call nz, EuclidKickLenPrev
.p8ALockedLen:
    bit 2, c
    call nz, EuclidKickHitsUp
    bit 3, c
    call nz, EuclidKickHitsDown
    ret
.p8AB:
    ; AB: SOUND (UD) + DECAY (LR)
    bit 0, c
    call nz, EuclidKickDecayNext
    bit 1, c
    call nz, EuclidKickDecayPrev
    bit 2, c
    call nz, EuclidKickSoundNext
    bit 3, c
    call nz, EuclidKickSoundPrev
    ret
.p8NoA:
    bit 5, b                    ; B held?
    ret z
    ; B alone: LEVEL (LR) + PITCH (UD).
    bit 0, c
    call nz, EuclidKickLevelUp
    bit 1, c
    call nz, EuclidKickLevelDown
    bit 2, c
    call nz, EuclidKickPitchUp
    bit 3, c
    call nz, EuclidKickPitchDown
    ret

.p8ModInput:
    ; --- MOD view input: A=pitch LFO, B=vel LFO, AB=depths ---
    ld a, b
    and %10110000               ; any modifier?
    jr z, .p8ModPlain
    bit 4, b                    ; A held?
    jr z, .p8ModNoA
    bit 5, b                    ; AB?
    jr nz, .p8ModAB
    ; A alone: P.SHAPE (LR) + P.RATE (UD)
    bit 0, c
    call nz, EucPLfoShapeNext
    bit 1, c
    call nz, EucPLfoShapePrev
    bit 2, c
    call nz, EucPLfoRateNext
    bit 3, c
    call nz, EucPLfoRatePrev
    ret
.p8ModAB:
    ; AB: P.DEPTH (LR) + V.DEPTH (UD)
    bit 0, c
    call nz, EucPLfoDepthUp
    bit 1, c
    call nz, EucPLfoDepthDown
    bit 2, c
    call nz, EucVLfoDepthUp
    bit 3, c
    call nz, EucVLfoDepthDown
    ret
.p8ModNoA:
    bit 5, b                    ; B held?
    ret z
    ; B alone: V.SHAPE (LR) + V.RATE (UD)
    bit 0, c
    call nz, EucVLfoShapeNext
    bit 1, c
    call nz, EucVLfoShapePrev
    bit 2, c
    call nz, EucVLfoRateNext
    bit 3, c
    call nz, EucVLfoRatePrev
    ret
.p8ModPlain:
    ret                         ; plain LR/UD reserved in MOD view

.pageMixerInput:
    ; Page 8 (MIXER): plain ↑↓←→ = toggle CH1/CH2/CH3/CH4; plain A = toggle EUC.
    ; No modifiers — bail if any of A/B/START are held.
    ld a, b
    and %10100000               ; B(5) + ST(7) only — A allowed (toggles EUC)
    ret nz
    bit 2, c                    ; UP → toggle CH1 companion mute
    call nz, ToggleMuteCH1
    bit 3, c                    ; DOWN → toggle CH2 arp-note mute
    call nz, ToggleMuteCH2
    bit 1, c                    ; LEFT → toggle CH3 wave mute
    call nz, ToggleMuteCH3
    bit 0, c                    ; RIGHT → toggle CH4 mute
    call nz, ToggleMuteCH4
    bit 4, c                    ; A button → toggle Euclid kick mute
    call nz, ToggleMuteEuc
    ret

.page9Input:
    ; Page 9 (CONTROLS): A+UP → SAVE sub-page; A+RIGHT → PRESET matrix;
    ; B+DOWN → LOAD sub-page
    bit 4, b                    ; A held?
    jr z, .p9NoA
    bit 5, b                    ; AB held? → no-op
    jr nz, .p9NoA
    bit 2, c                    ; UP newly pressed?
    jr z, .p9NoAUp
    ld a, 1
    ld [wSubPage], a            ; enter SAVE list
    xor a
    ld [wSubCursor], a
    ld [wSubArmCounter], a
    ld a, 1
    ld [wSubDirty], a
    ret
.p9NoAUp:
    bit 0, c                    ; RIGHT newly pressed? (V38)
    jr z, .p9NoA
    ld a, 3
    ld [wSubPage], a            ; enter PRESET matrix
    xor a
    ld [wSubCursor], a
    ld [wSubArmCounter], a
    ld [wSubArmAction], a
    ld a, 1
    ld [wSubDirty], a
    ret
.p9NoA:
    bit 5, b                    ; B held?
    jr z, .p9NoB
    bit 4, b                    ; AB held? → no-op
    jr nz, .p9NoB
    bit 3, c                    ; DOWN newly pressed?
    jr z, .p9NoB
    ld a, 2
    ld [wSubPage], a            ; enter LOAD list
    xor a
    ld [wSubCursor], a
    ld [wSubArmCounter], a
    ld a, 1
    ld [wSubDirty], a
    ret
.p9NoB:
.p9NoAB:
    bit 7, b                    ; START held?
    ret z
    bit 4, b                    ; A also held? → no-op
    ret nz
    bit 5, b                    ; B also held? → no-op
    ret nz
    bit 2, c                    ; UP newly pressed? → WILD randomize
    jr z, .p9NoStUp
    jp RandomizeWild
.p9NoStUp:
    bit 3, c                    ; DOWN newly pressed? → MILD randomize
    ret z
    jp RandomizeMild

.pageDone:
    ret
.page1Input:

    ; START held modifier (octave range + waveform)
    bit 7, b
    jr z, .noStartHeld
    bit 2, c
    jr z, .noSTUp
    call OctaveRangeUp
.noSTUp:
    bit 3, c
    jr z, .noSTDown
    call OctaveRangeDown
.noSTDown:
    bit 1, c
    jr z, .noSTLeft
    call WaveformPrev
.noSTLeft:
    bit 0, c
    jr z, .noSTRight
    call WaveformNext
.noSTRight:
    ret
.noStartHeld:

    ; Check A+B modifier (held in b = current buttons)
    bit 4, b
    jr z, .noAHeld
    bit 5, b
    jr nz, .abHeld
    jr .aHeld
.noAHeld:
    bit 5, b
    jp nz, .bHeld

    ; --- Plain D-pad ---
    bit 2, c
    jr z, .noUp
    call RootNoteUp
.noUp:
    bit 3, c
    jr z, .noDown
    call RootNoteDown
.noDown:
    bit 1, c
    jr z, .noLeft
    call PrevPattern
.noLeft:
    bit 0, c
    jr z, .noRight
    call NextPattern
.noRight:
    ret

.abHeld:
    bit 2, c
    jr z, .noABUp
    call StrideUp
.noABUp:
    bit 3, c
    jr z, .noABDown
    call StrideDown
.noABDown:
    bit 1, c
    jr z, .noABLeft
    call AttackDown
.noABLeft:
    bit 0, c
    jr z, .noABRight
    call AttackUp
.noABRight:
    ret

.aHeld:
    ld a, [wCurrentPage]
    and a
    jr nz, .aHeldPage2
    ; Page 1: Speed + Gate
    bit 2, c
    jr z, .noAUp
    call SpeedUp
.noAUp:
    bit 3, c
    jr z, .noADown
    call SpeedDown
.noADown:
    bit 1, c
    jr z, .noALeft
    call GateLengthDown
.noALeft:
    bit 0, c
    jr z, .noARight
    call GateLengthUp
.noARight:
    ret
.aHeldPage2:
    ; Page 2: A+LR = CH1 mode, A+UD = sub-param
    bit 1, c
    jr z, .noP2ALeft
    call CH1ModePendingPrev
.noP2ALeft:
    bit 0, c
    jr z, .noP2ARight
    call CH1ModePendingNext
.noP2ARight:
    ; A+UD: dispatch based on previewed mode (pending) so sub-param edits track the preview
    ld a, [wCH1ModePending]
    cp 3
    jr z, .p2SubDet
    cp 4
    jr z, .p2SubInt
    cp 5
    jr z, .p2SubDeg
    ret                     ; OFF/OC+/OC-: no sub-param
.p2SubDet:
    bit 2, c
    call nz, CH1DetUp
    bit 3, c
    call nz, CH1DetDown
    ret
.p2SubInt:
    bit 2, c
    call nz, CH1IntUp
    bit 3, c
    call nz, CH1IntDown
    ret
.p2SubDeg:
    bit 2, c
    call nz, CH1DegUp
    bit 3, c
    call nz, CH1DegDown
    ret

.bHeld:
    bit 2, c
    jr z, .noBUp
    call OctaveUp
.noBUp:
    bit 3, c
    jr z, .noBDown
    call OctaveDown
.noBDown:
    bit 1, c
    jr z, .noBLeft
    call PrevBank
.noBLeft:
    bit 0, c
    jr z, .noBRight
    call NextBank
.noBRight:
    ret

; =============================================================================
; Action Routines (only modify a/d/e/h/l, preserve b/c)
; =============================================================================

; Note: TogglePlay was removed when the gate feature landed — START is unused,
; and wPlaying stays 1 throughout the session (arpeggio auto-starts at init).
; If a transport-reset path is ever reintroduced: DESC mode needs pattern-aware
; initialization (set wArpPosition = wNoteCount-1, or suppress the first
; .descWrap accent), otherwise the first wrap double-hits hAccentPending.

NextBank:
    ld a, [wCurrentBank]
    inc a
    cp ARP_BANK_COUNT
    jr c, .ok
    xor a
.ok:
    ld [wCurrentBank], a
    ret

PrevBank:
    ld a, [wCurrentBank]
    and a
    jr z, .wrap
    dec a
    jr .ok
.wrap:
    ld a, ARP_BANK_COUNT - 1
.ok:
    ld [wCurrentBank], a
    ret

NextGroup:
    ld a, [wCurrentBank]
    ld d, 0
.div:
    cp GROUP_SIZE
    jr c, .divDone
    sub GROUP_SIZE
    inc d
    jr .div
.divDone:
    inc d
    ld a, d
    cp 4
    jr c, .noWrap
    xor a
    ld d, a
.noWrap:
    ld a, d
    add a
    add d
    add a
    add d
    ld [wCurrentBank], a
    ld [wPlayingBank], a
    call ComputeNoteCount
    jp ClampArpPosition

RootNoteUp:
    ld a, [wRootNote]
    inc a
    cp 12
    jr c, .noWrap
    ld a, [wRootOctave]
    cp 3
    jr z, .clamp
    inc a
    ld [wRootOctave], a
    xor a
.noWrap:
    ld [wRootNote], a
    ret
.clamp:
    ret

RootNoteDown:
    ld a, [wRootNote]
    and a
    jr z, .wrapDown
    dec a
    ld [wRootNote], a
    ret
.wrapDown:
    ld a, [wRootOctave]
    and a
    ret z
    dec a
    ld [wRootOctave], a
    ld a, 11
    ld [wRootNote], a
    ret

NextPattern:
    ld a, [wPatternType]
    inc a
    cp PAT_COUNT
    jr c, .ok
    xor a
.ok:
    ld [wPatternType], a
    xor a
    ld [wArpDirection], a
    call ComputeNoteCount       ; refresh wFillCycleStep cache for new pattern
    jp HelpFor_Pattern

PrevPattern:
    ld a, [wPatternType]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, PAT_COUNT - 1
.store:
    ld [wPatternType], a
    xor a
    ld [wArpDirection], a
    call ComputeNoteCount       ; refresh wFillCycleStep cache for new pattern
    jp HelpFor_Pattern

TapTempo:
    ; Visual feedback: brief screen invert
    ld a, 3                     ; 3 frames (~50ms)
    ld [wInvertTimer], a
    ld a, $1B                   ; inverted palette
    ldh [rBGP], a

    ld a, [wTapCounter]
    and a
    jr z, .firstTap
    ; Second+ tap: interval measured
    ld [wTapFrames], a
    xor a
    ld [wTapFrac], a
    call ComputeTapEffective
    ; Increment tap count
    ld a, [wTapCount]
    inc a
    ld [wTapCount], a
    ; Phase sync only after 5th tap (count >= 4, first tap doesn't increment)
    cp 4
    jr c, .noSync
    ld a, 1
    ldh [hStepReady], a
    xor a
    ld [wSwingPhase], a
.noSync:
    ld a, 1
    ld [wTapCounter], a     ; restart counting
    ret
.firstTap:
    ld a, 1
    ld [wTapCounter], a     ; start counting
    ret

ComputeTapEffective:
    ld a, [wTapFrames]
    and a
    jp z, .clearEff
    ld b, a
    ld a, [wTapSubdiv]
    dec a
    jr z, .noDiv
    dec a
    jr z, .div2
    dec a
    jr z, .div3
    ; subdiv 4
    ld a, b
    srl a
    srl a
    jr .ensureMin
.div3:
    ld a, b
    ld d, 0
.d3loop:
    sub 3
    jr c, .d3done
    inc d
    jr .d3loop
.d3done:
    ld a, d
    jr .ensureMin
.div2:
    ld a, b
    srl a
    jr .ensureMin
.noDiv:
    ld a, b
.ensureMin:
    and a
    jr nz, .storeEff
    ld a, 1
.storeEff:
    ld [wTapEffective], a
    ; Precompute BPM display tiles — avoids 16-bit divide inside VBlank every frame
    ld a, [wTapFrames]
    ld d, 0
    add a                       ; ×2
    rl d
    add a                       ; ×4
    rl d
    add a                       ; ×8
    rl d
    ld e, a
    ld a, [wTapFrac]
    add e
    ld e, a
    ld a, d
    adc 0
    ld d, a                     ; de = 8·wTapFrames + wTapFrac
    ld hl, 28800
    ld bc, 0
    ld a, 16
    push af
.bpmDivLoop:
    add hl, hl
    rl c
    rl b
    ld a, b
    cp d
    jr c, .bpmNoSub
    jr nz, .bpmDoSub
    ld a, c
    cp e
    jr c, .bpmNoSub
.bpmDoSub:
    ld a, c
    sub e
    ld c, a
    ld a, b
    sbc d
    ld b, a
    inc l
.bpmNoSub:
    pop af
    dec a
    push af
    jr nz, .bpmDivLoop
    pop af
    ld a, h
    cp 4
    jr nc, .bpmCap
    cp 3
    jr c, .bpmOk
    jr nz, .bpmCap
    ld a, l
    cp 232
    jr c, .bpmOk
.bpmCap:
    ld hl, 999
.bpmOk:
    ld d, 0
.bpmHLoop:
    ld a, l
    sub 100
    ld l, a
    ld a, h
    sbc 0
    ld h, a
    jr c, .bpmHDone
    inc d
    jr .bpmHLoop
.bpmHDone:
    ld a, l
    add 100
    ld e, 0
.bpmTLoop:
    cp 10
    jr c, .bpmTDone
    sub 10
    inc e
    jr .bpmTLoop
.bpmTDone:
    push af
    ld a, d
    add INV_TILE_DIGIT0
    ld [wTapBpmTiles], a
    ld a, e
    add INV_TILE_DIGIT0
    ld [wTapBpmTiles+1], a
    pop af
    add INV_TILE_DIGIT0
    ld [wTapBpmTiles+2], a
    ret
.clearEff:
    ld [wTapEffective], a
    ret

; Nudge the active tapped tempo by 1/8 frame (UP=faster, DOWN=slower).
; wTapFrac (0..7) is the sub-frame fractional part; carries/borrows propagate
; to wTapFrames. No-op when tap tempo is inactive.
TapNudgeUp:
    ld a, [wTapEffective]
    and a
    ret z
    ld a, [wTapFrames]
    cp 32
    jr nc, .nudgeUpSlow         ; slow region: full-frame step
    ld a, [wTapFrac]
    and a
    jr z, .nudgeUpBorrow
    dec a
    ld [wTapFrac], a
    jp ComputeTapEffective
.nudgeUpBorrow:
    ld a, [wTapFrames]
    cp 2
    ret c                       ; at 1 frame, can't go faster
    dec a
    ld [wTapFrames], a
    ld a, 7
    ld [wTapFrac], a
    jp ComputeTapEffective
.nudgeUpSlow:
    dec a                       ; a still holds wTapFrames (≥ 32)
    ld [wTapFrames], a
    xor a
    ld [wTapFrac], a
    jp ComputeTapEffective

TapNudgeDown:
    ld a, [wTapEffective]
    and a
    ret z
    ld a, [wTapFrames]
    cp 32
    jr nc, .nudgeDownSlow       ; slow region: full-frame step
    ld a, [wTapFrac]
    cp 7
    jr z, .nudgeDownCarry
    inc a
    ld [wTapFrac], a
    jp ComputeTapEffective
.nudgeDownCarry:
    ld a, [wTapFrames]
    cp 255
    ret z
    inc a
    ld [wTapFrames], a
    xor a
    ld [wTapFrac], a
    jp ComputeTapEffective
.nudgeDownSlow:
    cp 255
    ret z                       ; at max, can't go slower
    inc a
    ld [wTapFrames], a
    xor a
    ld [wTapFrac], a            ; pin frac=0 in slow region
    jp ComputeTapEffective

LoadSpeedFrames:
    ld a, [wTapEffective]
    and a
    ret nz                  ; if tap active, return effective interval
    ld a, [wSpeed]
    ld hl, SpeedTable
    add l
    ld l, a
    jr nc, .ncST
    inc h
.ncST:
    ld a, [hl]
    ret

; CH1OffsetMul — multiplier table in 1/32 units (offset index 0..14)
; mult = 2*index → evenly spaced ~6.25% per step (V34.1: doubled granularity)
CH1OffsetMul:
    db 0    ; 0  OFF (immediate)
    db 2    ; 1  06%
    db 4    ; 2  12%
    db 6    ; 3  19%
    db 8    ; 4  25%
    db 10   ; 5  31%
    db 12   ; 6  37%
    db 14   ; 7  44%
    db 16   ; 8  50%
    db 18   ; 9  56%
    db 20   ; 10 62%
    db 22   ; 11 69%
    db 24   ; 12 75%
    db 26   ; 13 81%
    db 28   ; 14 87%

; ComputeCH1OffsetFrames — convert step length to deferred-CH1 frame count
; Input:  a = speed_frames (from LoadSpeedFrames)
; Output: a = frames to delay CH1 (0 → fire immediately)
; Clobbers: b, c, d, e, h, l
ComputeCH1OffsetFrames:
    ld c, a                    ; c = speed_frames
    ld a, [wCH1Offset]
    and a
    ret z                      ; OFF → return 0 immediately
    ld hl, CH1OffsetMul
    add l
    ld l, a
    jr nc, .ncMul
    inc h
.ncMul:
    ld a, [hl]                 ; a = multiplier (0..28)
    ld b, a
    ld hl, 0
    ld d, 0
    ld e, c
.mulLoop:
    srl b
    jr nc, .mulSkip
    add hl, de
.mulSkip:
    sla e
    rl d
    ld a, b
    and a
    jr nz, .mulLoop
    ; hl = speed * mult; shift right 5 (divide by 32)
    ld a, l
    ld b, 5
.shrLoop:
    srl h
    rr a
    dec b
    jr nz, .shrLoop
    ret                        ; a = offset_frames (0 → treat as immediate)

SpeedUp:
    xor a
    ld [wTapFrames], a      ; deactivate tap tempo
    ld [wTapFrac], a
    ld [wTapCounter], a
    ld [wTapEffective], a
    ld [wTapCount], a
    ld a, 1
    ld [wTapSubdiv], a
    ld a, [wSpeed]
    cp MIN_SPEED
    ret z
    dec a
    ld [wSpeed], a
    ret

SpeedDown:
    xor a
    ld [wTapFrames], a      ; deactivate tap tempo
    ld [wTapFrac], a
    ld [wTapCounter], a
    ld [wTapEffective], a
    ld [wTapCount], a
    ld a, 1
    ld [wTapSubdiv], a
    ld a, [wSpeed]
    cp MAX_SPEED
    ret z
    inc a
    ld [wSpeed], a
    ret

SubdivUp:
    ld a, [wTapSubdiv]
    cp 4
    ret z
    inc a
    ld [wTapSubdiv], a
    jp ComputeTapEffective

SubdivDown:
    ld a, [wTapSubdiv]
    cp 1
    ret z
    dec a
    ld [wTapSubdiv], a
    jp ComputeTapEffective

OctaveRangeUp:
    ld a, [wOctaveRange]
    cp MAX_OCTAVE_RANGE
    ret z
    inc a
    ld [wOctaveRange], a
    jp ComputeNoteCount

OctaveRangeDown:
    ld a, [wOctaveRange]
    cp MIN_OCTAVE_RANGE
    ret z
    dec a
    ld [wOctaveRange], a
    call ComputeNoteCount
    jp ClampArpPosition

GateLengthUp:
    ld a, [wGateLength]
    cp MAX_GATE
    ret z
    inc a
    ld [wGateLength], a
    jp HelpFor_Gate

GateLengthDown:
    ld a, [wGateLength]
    and a
    ret z
    dec a
    ld [wGateLength], a
    jp HelpFor_Gate

StrideUp:
    ld a, [wStride]
    cp MAX_STRIDE
    ret z
    inc a
    ld [wStride], a
    call ComputeNoteCount
    jp ClampArpPosition

StrideDown:
    ld a, [wStride]
    cp 1
    ret z
    dec a
    ld [wStride], a
    jp ComputeNoteCount

OctaveUp:
    ld a, [wRootOctave]
    cp 4
    ret z
    inc a
    ld [wRootOctave], a
    ret

OctaveDown:
    ld a, [wRootOctave]
    and a
    ret z
    dec a
    ld [wRootOctave], a
    ret

WaveformNext:
    ld a, [wDutyCycle]
    cp WAVE_COUNT - 1
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wDutyCycle], a
    jp HelpFor_CH2Wave

WaveformPrev:
    ld a, [wDutyCycle]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, WAVE_COUNT - 1
.store:
    ld [wDutyCycle], a
    jp HelpFor_CH2Wave

AttackUp:
    ld a, [wAttackSpeed]
    cp MAX_ATTACK
    ret z
    inc a
    ld [wAttackSpeed], a
    ret

AttackDown:
    ld a, [wAttackSpeed]
    and a
    ret z
    dec a
    ld [wAttackSpeed], a
    ret

TogglePage:
    ld a, [wCurrentPage]
    cp MAX_PAGE
    jr c, .incPage
    xor a                   ; wrap 5→0
    jr .storePage
.incPage:
    inc a
.storePage:
    ld [wCurrentPage], a
    xor a
    ld [wEucModView], a     ; reset MOD sub-view on any page change
    ld a, 1
    ld [wPageRedraw], a     ; defer redraw to VBlank
    ; Invalidate Page 8 caches so the first frame on Page 8 paints fresh.
    ld [wEuclidPatternDirty], a
    ld a, $FF
    ld [wHudP8Ind], a
    ret

TogglePagePrev:
    ld a, [wCurrentPage]
    and a
    jr nz, .decPage
    ld a, MAX_PAGE          ; wrap 0 → MAX_PAGE
    jr .storePage
.decPage:
    dec a
.storePage:
    ld [wCurrentPage], a
    xor a
    ld [wEucModView], a     ; reset MOD sub-view on any page change
    ld a, 1
    ld [wPageRedraw], a
    ld [wEuclidPatternDirty], a
    ld a, $FF
    ld [wHudP8Ind], a
    ret

DoPageRedraw:
    xor a
    ld [wPageRedraw], a     ; clear flag
    call DisableLCD         ; safe: called right after halt (in VBlank)
    ld a, [wCurrentPage]
    and a
    jr nz, .notPage1
    ; Page 1: restore all controls
    call BlankPageRows
    ld hl, ControlsData
    call DrawData
    jp .reenable
.notPage1:
    cp 2
    jr z, .redrawPage3
    cp 3
    jr z, .redrawPage4
    cp 4
    jr z, .redrawPage5
    cp 5
    jr z, .redrawPage6
    cp 6
    jp z, .redrawPage7
    cp 7
    jp z, .redrawPage8
    cp 8
    jp z, .redrawMixer
    cp 9
    jp z, .redrawPage9
    ; Page 2
    call BlankPageRows
    ld hl, ControlsPage2
    call DrawData
    ; Blank row 7 ($98E0-$98F3, 20 tiles) to prevent stale sub-param labels
    ld hl, $98E0
    ld a, TILE_BLANK
    ld c, 20
.blankRow7:
    ld [hli], a
    dec c
    jr nz, .blankRow7
    ; Blank row 6 value area ($98D1-$98D3) to prevent stale mode name
    ld [$98D1], a
    ld [$98D2], a
    ld [$98D3], a
    jp .reenable
.redrawPage3:
    call BlankPageRows
    ld hl, ControlsPage3
    call DrawData
    jp .reenable
.redrawPage4:
    call BlankPageRows
    ld hl, ControlsPage4
    call DrawData
    jp .reenable
.redrawPage5:
    call BlankPageRows
    ; ACCENT page: only row 6 has content. BlankPageRows clears rows 8-10;
    ; we add row 7 (20 tiles) and row 6 cols 17-19 ($98D1-$98D3) so stale
    ; labels from FILL/CH1/etc. don't leak. The previous 80-byte linear walk
    ; from $98E0 crossed BG-map row boundaries (32-tile-wide map, 20 visible)
    ; and missed row 9 cols 16-19; the row-6 patch was also written to the
    ; wrong addresses ($98F1-F3, which is row 7 cols 17-19).
    ld hl, $98E0
    ld a, TILE_BLANK
    ld c, 20
.blankP5Row7:
    ld [hli], a
    dec c
    jr nz, .blankP5Row7
    ld [$98D1], a
    ld [$98D2], a
    ld [$98D3], a
    ld hl, ControlsAccentPage
    call DrawData
    jp .reenable
.redrawPage6:
    call BlankPageRows
    ; FILL page: paints labels across rows 6-10. BlankPageRows clears rows
    ; 8-10; add row 7 (20 tiles) so stale ACCENT/CH1 labels there don't leak.
    ld hl, $98E0
    ld a, TILE_BLANK
    ld c, 20
.blankP6Row7:
    ld [hli], a
    dec c
    jr nz, .blankP6Row7
    ld hl, ControlsFillPage
    call DrawData
    jp .reenable
.redrawPage7:
    call BlankPageRows
    ; TONAL page: 8 controls span rows 6-13. BlankPageRows clears rows 8-13;
    ; we add row 7 (20 tiles) and row 6 value column ($98D1-$98D3) so stale
    ; labels from prior pages don't leak.
    ld hl, $98E0
    ld a, TILE_BLANK
    ld c, 20
.blankP7Row7:
    ld [hli], a
    dec c
    jr nz, .blankP7Row7
    ld [$98D1], a
    ld [$98D2], a
    ld [$98D3], a
    ld hl, ControlsTonalPage
    call DrawData
    jp .reenable
.redrawPage8:
    call BlankPageRows
    ; EUCLID page: visualizer at row 5 (BlankPageRows already cleared this).
    ; Labels on rows 6-11 with values at cols 17-19. BlankPageRows skips rows
    ; 6 and 7, so blank them explicitly to clear stale labels from prior pages.
    ld hl, $98C0                ; row 6
    call BlankRow
    ld hl, $98E0                ; row 7
    call BlankRow
    ld a, [wEucModView]
    and a
    jr z, .redrawPage8Kick
    ld hl, ControlsEuclidModPage
    call DrawData
    jp .reenable
.redrawPage8Kick:
    ld hl, ControlsEuclidPage
    call DrawData
    jp .reenable
.redrawMixer:
    call BlankPageRows
    ld hl, $98C0                ; row 6 — blank explicitly (BlankPageRows skips it)
    call BlankRow
    ld hl, $98E0                ; row 7 — blank explicitly
    call BlankRow
    ld hl, ControlsMixerPage
    call DrawData
    jp .reenable
.redrawPage9:
    call BlankPageRows          ; clears rows 0-5 and 8-14 (rows 6/7 skipped)
    ld hl, $98C0                ; row 6 — blank explicitly
    call BlankRow
    ld hl, $98E0                ; row 7 — blank explicitly (PRESET row drawn below)
    call BlankRow
    ; Reset sub-page state on CONTROLS page entry
    xor a
    ld [wSubPage], a
    ld [wSubDirty], a
    ld hl, ControlsPage9_Base
    call DrawData
.reenable:
    ; Help row: clear row 17 explicitly here so the user never sees a stale
    ; long-name overlay on the new page, even for the one frame between this
    ; redraw and the next UpdateHUD. HelpRowTick's page-change branch syncs
    ; hHelpLastPage so the next UpdateHUD doesn't redo the clear.
    call HelpRowTick
    ld a, $91
    ldh [rLCDC], a
    ret

SwingUp:
    ld a, [wSwing]
    cp MAX_SWING
    ret z
    inc a
    ld [wSwing], a
    ret

SwingDown:
    ld a, [wSwing]
    and a
    ret z
    dec a
    ld [wSwing], a
    ret

CH1ModeNext:
    ld a, [wCH1Mode]
    cp MAX_CH1MODE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wCH1Mode], a
    jp HelpFor_CH1Mode

CH1ModePrev:
    ld a, [wCH1Mode]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_CH1MODE
.store:
    ld [wCH1Mode], a
    jp HelpFor_CH1Mode

; V33.2: Pending variants — update preview only; commit fires on A-release.
CH1ModePendingNext:
    ld a, [wCH1ModePending]
    cp MAX_CH1MODE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wCH1ModePending], a
    jp HelpFor_CH1Mode

CH1ModePendingPrev:
    ld a, [wCH1ModePending]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_CH1MODE
.store:
    ld [wCH1ModePending], a
    jp HelpFor_CH1Mode

; --- Noise Accent (Page 4) ---
NoiseAccentNext:
    ld a, [wNoiseAccent]
    cp MAX_NOISE_ACCENT
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wNoiseAccent], a
    jp HelpFor_Accent

NoiseAccentPrev:
    ld a, [wNoiseAccent]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_NOISE_ACCENT
.store:
    ld [wNoiseAccent], a
    jp HelpFor_Accent

; --- Gate-Noise Fill Parameters (Page 4 DRUMS) ---
FillLevelNext:
    ld a, [wFillLevel]
    cp MAX_FILL_LEVEL
    ret z
    inc a
    ld [wFillLevel], a
    ret

FillLevelPrev:
    ld a, [wFillLevel]
    and a
    ret z
    dec a
    ld [wFillLevel], a
    ret

FillColorNext:
    ld a, [wFillColor]
    cp MAX_FILL_COLOR
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wFillColor], a
    jp HelpFor_FillColor

FillColorPrev:
    ld a, [wFillColor]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_FILL_COLOR
.store:
    ld [wFillColor], a
    jp HelpFor_FillColor

FillPitchNext:
    ld a, [wFillPitch]
    cp MAX_FILL_PITCH
    ret z
    inc a
    ld [wFillPitch], a
    ret

FillPitchPrev:
    ld a, [wFillPitch]
    and a
    ret z
    dec a
    ld [wFillPitch], a
    ret

FillShapeNext:
    ld a, [wFillShape]
    cp MAX_FILL_SHAPE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wFillShape], a
    jp HelpFor_FillShape

FillShapePrev:
    ld a, [wFillShape]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_FILL_SHAPE
.store:
    ld [wFillShape], a
    jp HelpFor_FillShape

FillFreqNext:
    ld a, [wFillFreq]
    cp MAX_FILL_FREQ
    ret z
    inc a
    ld [wFillFreq], a
    ret

; --- Tonal Noise Parameters (Page 7) ---
TonalModeNext:
    ld a, [wTonalMode]
    xor 1                       ; OFF↔ON toggle
    ld [wTonalMode], a
    jr nz, .modeOn              ; new value 1 (ON)? skip silence
    ld a, [wTonalLock]
    and a
    jr nz, .modeOn              ; LOCK engaged? keep CH4 ringing
    call SilenceTonalCH4
.modeOn:
    jp HelpFor_TonalMode
TonalModePrev:
    jr TonalModeNext            ; 2-state cycle is symmetric

TonalLevelUp:
    ld a, [wTonalLevel]
    cp MAX_TONAL_LEVEL
    ret z
    inc a
    ld [wTonalLevel], a
    jp HelpFor_TonalLevel
TonalLevelDown:
    ld a, [wTonalLevel]
    and a
    ret z
    dec a
    ld [wTonalLevel], a
    jp HelpFor_TonalLevel

TonalMapNext:
    ld a, [wTonalMap]
    cp MAX_TONAL_MAP
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wTonalMap], a
    jp HelpFor_TonalMap
TonalMapPrev:
    ld a, [wTonalMap]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_TONAL_MAP
.store:
    ld [wTonalMap], a
    jp HelpFor_TonalMap

TonalWidthNext:
    ld a, [wTonalWidth]
    xor 1
    ld [wTonalWidth], a
    jp HelpFor_TonalWidth
TonalWidthPrev:
    jr TonalWidthNext

TonalDecayNext:
    ld a, [wTonalDecay]
    cp MAX_TONAL_DECAY
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wTonalDecay], a
    jp HelpFor_TonalDecay
TonalDecayPrev:
    ld a, [wTonalDecay]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_TONAL_DECAY
.store:
    ld [wTonalDecay], a
    jp HelpFor_TonalDecay

TonalTranspUp:
    ld a, [wTonalTransp]
    cp MAX_TONAL_TRANSP
    ret z
    inc a
    ld [wTonalTransp], a
    jp HelpFor_TonalTransp
TonalTranspDown:
    ld a, [wTonalTransp]
    and a
    ret z
    dec a
    ld [wTonalTransp], a
    jp HelpFor_TonalTransp

TonalTrigNext:
    ld a, [wTonalTrig]
    cp MAX_TONAL_TRIG
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wTonalTrig], a
    jp HelpFor_TonalTrig
TonalTrigPrev:
    ld a, [wTonalTrig]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_TONAL_TRIG
.store:
    ld [wTonalTrig], a
    jp HelpFor_TonalTrig

TonalPriNext:
    ld a, [wTonalPri]
    cp MAX_TONAL_PRI
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wTonalPri], a
    jp HelpFor_TonalPri
TonalPriPrev:
    ld a, [wTonalPri]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_TONAL_PRI
.store:
    ld [wTonalPri], a
    jp HelpFor_TonalPri

TonalLockToggle:
    ld a, [wTonalLock]
    xor 1
    ld [wTonalLock], a
    jr nz, .locked              ; new value 1 (LOCK engaged): no silence
    ; Released lock (FRE). If MODE is also OFF, silence CH4 now.
    ld a, [wTonalMode]
    and a
    jr nz, .locked              ; MODE=ON: silence handled by next trigger / gate logic
    call SilenceTonalCH4
.locked:
    jp HelpFor_TonalLock

; Anti-pop CH4 silence: NR42=$08 (DAC on, vol 0) then retrigger NR44=$80.
; Called when tonal MODE transitions OFF (with LOCK=FRE) and when LOCK is
; released while MODE=OFF.
SilenceTonalCH4:
    ld a, $08
    ldh [rNR42], a
    ld a, $80
    ldh [rNR44], a
    ret

; MuteCH4 / UnmuteCH4 — V32.2: explicit set/clear for wMuteCH4. Each is
; idempotent: toast and redraw fire only on actual state change; idempotent
; presses are fully silent. MuteCH4 calls SilenceTonalCH4 anti-pop on change.
; Three audio guards read wMuteCH4 each step: MaybeTriggerAccent (accent),
; .checkFill (gate-noise fill), and MaybeTriggerTonal (tonal). See those sites.
; Clobbers: a, hl
MuteCH4:
    ld a, [wMuteCH4]
    and a
    ret nz                      ; already muted — no-op, no toast
    ld a, 1
    ld [wMuteCH4], a
    call SilenceTonalCH4        ; silence any ringing CH4 tail immediately
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteOn
    jp ShowHelpByIndex

UnmuteCH4:
    ld a, [wMuteCH4]
    and a
    ret z                       ; already audible — no-op, no toast
    xor a
    ld [wMuteCH4], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteOff
    jp ShowHelpByIndex

; MuteEuc / UnmuteEuc — V32.2: explicit set/clear for wMuteEuc. Idempotent:
; toast and redraw fire only on actual state change. No CH1 silence needed —
; PlayCurrentNote overwrites CH1 on the next step before any kick would fire.
; Single audio guard in PlayEuclidKickSweep. Called from page-9 AB+← / AB+→.
; Clobbers: a, hl
MuteEuc:
    ld a, [wMuteEuc]
    and a
    ret nz                      ; already muted — no-op, no toast
    ld a, 1
    ld [wMuteEuc], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteEucOn
    jp ShowHelpByIndex

UnmuteEuc:
    ld a, [wMuteEuc]
    and a
    ret z                       ; already audible — no-op, no toast
    xor a
    ld [wMuteEuc], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteEucOff
    jp ShowHelpByIndex

; --- V36 MIXER page: toggle wrappers for all 5 mute voices ---
; ToggleMuteCHx: called from page-8 (MIXER) input handler on a plain-press.
; Each checks current state and dispatches to its Mute/Unmute counterpart.
; CH4 and EUC reuse existing separate Mute/Unmute routines.
; CH1/CH2/CH3 have new dedicated Mute/Unmute pairs below.

ToggleMuteCH4:
    ld a, [wMuteCH4]
    and a
    jp nz, UnmuteCH4
    jp MuteCH4

ToggleMuteEuc:
    ld a, [wMuteEuc]
    and a
    jp nz, UnmuteEuc
    jp MuteEuc

; MuteCH1/UnmuteCH1: companion melody voice on CH1 (NOT the Euclid kick).
; Anti-pop on mute: SilenceCH1. No CH3 interaction needed.
MuteCH1:
    ld a, [wMuteCH1]
    and a
    ret nz
    ld a, 1
    ld [wMuteCH1], a
    call SilenceCH1
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteCH1On
    jp ShowHelpByIndex

UnmuteCH1:
    ld a, [wMuteCH1]
    and a
    ret z
    xor a
    ld [wMuteCH1], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteCH1Off
    jp ShowHelpByIndex

ToggleMuteCH1:
    ld a, [wMuteCH1]
    and a
    jp nz, UnmuteCH1
    jp MuteCH1

; MuteCH2/UnmuteCH2: main arp note on CH2.
; Anti-pop: DAC_ON_SILENT + retrigger at vol 0 (same as .skipCH2 path).
MuteCH2:
    ld a, [wMuteCH2]
    and a
    ret nz
    ld a, 1
    ld [wMuteCH2], a
    ld a, DAC_ON_SILENT
    ldh [rNR22], a
    ld a, $80
    ldh [rNR24], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteCH2On
    jp ShowHelpByIndex

UnmuteCH2:
    ld a, [wMuteCH2]
    and a
    ret z
    xor a
    ld [wMuteCH2], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteCH2Off
    jp ShowHelpByIndex

ToggleMuteCH2:
    ld a, [wMuteCH2]
    and a
    jp nz, UnmuteCH2
    jp MuteCH2

; MuteCH3/UnmuteCH3: wave channel CH3.
; Anti-pop on mute: rNR32=0 + hCH3ShapeMuted=1 (shape engine survives).
MuteCH3:
    ld a, [wMuteCH3]
    and a
    ret nz
    ld a, 1
    ld [wMuteCH3], a
    xor a
    ldh [rNR32], a
    ld a, 1
    ldh [hCH3ShapeMuted], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteCH3On
    jp ShowHelpByIndex

UnmuteCH3:
    ld a, [wMuteCH3]
    and a
    ret z
    xor a
    ld [wMuteCH3], a
    ld a, 1
    ld [wPageRedraw], a
    xor a
    ld hl, HelpStr_MuteCH3Off
    jp ShowHelpByIndex

ToggleMuteCH3:
    ld a, [wMuteCH3]
    and a
    jp nz, UnmuteCH3
    jp MuteCH3

; --- V26 Euclidean Drum Machine action routines (Page 8) ---
; All wrap on edit. K-edit wraps [0, N]. N-edit wraps [2, 16] with side-effect
; clamps on K and Rot, plus a phase reset on wEuclidKickStep. Rot wraps [0, N-1].

EuclidKickHitsUp:
    ; K → K+1, wrap to 0 when K == N (so K range is [0, N] inclusive).
    ; Scratch in d (HandleInput contract requires preserving b/c).
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld a, [wEuclidKickK]
    ld d, a
    ld a, [wEuclidKickN]
    cp d
    jr z, .wrap0
    ld a, d
    inc a
    ld [wEuclidKickK], a
    ret
.wrap0:
    xor a
    ld [wEuclidKickK], a
    ret
EuclidKickHitsDown:
    ; K → K-1, wrap K=0 to K=N.
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld a, [wEuclidKickK]
    and a
    jr z, .wrapN
    dec a
    ld [wEuclidKickK], a
    ret
.wrapN:
    ld a, [wEuclidKickN]
    ld [wEuclidKickK], a
    ret

EuclidKickLenNext:
    ; N → N+1, wrap [2..16]. After change, clamp K to [0, N_new] and Rot to
    ; [0, N_new - 1], reset wEuclidKickStep.
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld [wEucLfoDirty], a          ; bar rates depend on N
    ld a, [wEuclidKickN]
    cp MAX_EUCLID_KICK_N
    jr c, .incN
    ld a, MIN_EUCLID_KICK_N
    jr .storeN
.incN:
    inc a
.storeN:
    ld [wEuclidKickN], a
    jr EuclidKickClampAfterN
EuclidKickLenPrev:
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld [wEucLfoDirty], a          ; bar rates depend on N
    ld a, [wEuclidKickN]
    cp MIN_EUCLID_KICK_N + 1
    jr nc, .decN
    ld a, MAX_EUCLID_KICK_N
    jr .storeN
.decN:
    dec a
.storeN:
    ld [wEuclidKickN], a
    ; fall through into clamp helper

EuclidKickClampAfterN:
    ; Clamp wEuclidKickK to [0, N], wEuclidKickRot to [0, N-1], reset Step.
    ; Reached via EuclidKickLenNext/Prev and EuclidKickApplyLock.
    ; Scratch in d (HandleInput contract requires preserving b/c).
    ld a, [wEuclidKickN]
    ld d, a                 ; d = N
    ld a, [wEuclidKickK]
    cp d
    jr c, .kOk
    jr z, .kOk              ; K == N is valid (all-hits)
    ld a, d
    ld [wEuclidKickK], a
.kOk:
    ld a, [wEuclidKickRot]
    cp d
    jr c, .rOk              ; Rot < N is valid (Rot < N, since N >= 2 and Rot >= 0)
    ld a, d
    dec a
    ld [wEuclidKickRot], a
.rOk:
    xor a
    ld [wEuclidKickStep], a
    ret

; --- V37: LOCK — LEN tracks arp cycle length ---

EuclidKickApplyLock:
    ; If LOCK off, return immediately.
    ld a, [wEuclidKickLock]
    and a
    ret z
    push bc
    ; target = wNoteCount, halved until it fits [2..16].
    ld a, [wNoteCount]
.halveLp:
    cp MAX_EUCLID_KICK_N + 1
    jr c, .halveDone
    srl a
    jr .halveLp
.halveDone:
    ; Clamp to minimum LEN.
    cp MIN_EUCLID_KICK_N
    jr nc, .lockClamped
    ld a, MIN_EUCLID_KICK_N
.lockClamped:
    ld c, a                      ; c = new_N
    ld a, [wEuclidKickN]         ; a = old_N
    cp c
    jr z, .lockNoChange          ; LEN unchanged → skip everything
    ld b, a                      ; b = old_N
    ; --- Scale HITS: new_K = round(old_K × new_N ÷ old_N) ---
    ; Preserves inter-hit spacing when the cycle length changes.
    ld a, [wEuclidKickK]         ; a = old_K
    and a
    jr z, .lockKZero             ; old_K == 0 → new_K stays 0 (silent stays silent)
    ; Multiply old_K × new_N → hl (16-bit; max 16×16=256, +8 rounding → 264, safe).
    ld e, a                      ; e = loop count = old_K
    ld h, 0
    ld l, 0
.lockMulLp:
    ld a, l
    add a, c                     ; l += new_N
    ld l, a
    jr nc, .lockMulNoC
    inc h
.lockMulNoC:
    dec e
    jr nz, .lockMulLp
    ; Rounding: hl += old_N/2 (half-up).
    ld a, b
    srl a                        ; a = old_N / 2
    add a, l
    ld l, a
    jr nc, .lockDiv
    inc h
.lockDiv:
    ; Divide hl by old_N (b) → d (quotient = new_K).
    ld d, 0
.lockDivLp:
    ld a, l
    sub b
    ld e, a                      ; tentative l
    ld a, h
    sbc a, 0                     ; tentative h
    jr c, .lockDivDone           ; underflow → done
    ld l, e
    ld h, a
    inc d
    jr .lockDivLp
.lockDivDone:
    ; d = new_K; clamp to [0, new_N] then floor at 1 if old_K was ≥1.
    ld a, d
    cp c                         ; compare new_K with new_N
    jr c, .lockKClampOk
    ld a, c                      ; clamp to new_N (all-hits)
.lockKClampOk:
    and a                        ; new_K == 0?
    jr nz, .lockKStore
    ld a, 1                      ; floor at 1 — never silence if pattern had hits
    jr .lockKStore
.lockKZero:
    xor a                        ; old_K was 0 → new_K = 0
.lockKStore:
    ld [wEuclidKickK], a
    ; --- Store new LEN, set dirty flags, finalize ---
    ld a, c
    ld [wEuclidKickN], a
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld [wEucLfoDirty], a
    pop bc
    jp EuclidKickClampAfterN     ; clamps K/Rot (safety), resets Step; ret → caller
.lockNoChange:
    pop bc
    ret

EuclidKickLockOn:
    ; Plain ↑ on page 8 KICK view — engage LOCK and snap LEN to arp cycle.
    ld a, 1
    ld [wEuclidKickLock], a
    ld [wEuclidPatternDirty], a  ; repaint visualizer even if N doesn't change
    call EuclidKickApplyLock
    ld a, $FF
    ld [wHudP8Ind], a            ; force HUD modifier indicator repaint
    jp HelpFor_EuclidKickLock

EuclidKickLockOff:
    ; Plain ↓ on page 8 KICK view — release LOCK, LEN stays put.
    xor a
    ld [wEuclidKickLock], a
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld a, $FF
    ld [wHudP8Ind], a
    jp HelpFor_EuclidKickLock

EuclidKickRotNext:
    ; Rot → Rot+1, wrap to 0 when Rot == N-1.
    ; Scratch in d (HandleInput contract requires preserving b/c).
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld a, [wEuclidKickN]
    dec a
    ld d, a                 ; d = N - 1
    ld a, [wEuclidKickRot]
    cp d
    jr z, .wrap0
    inc a
    ld [wEuclidKickRot], a
    ret
.wrap0:
    xor a
    ld [wEuclidKickRot], a
    ret
EuclidKickRotPrev:
    ld a, 1
    ld [wEuclidPatternDirty], a
    ld a, [wEuclidKickRot]
    and a
    jr z, .wrapMax
    dec a
    ld [wEuclidKickRot], a
    ret
.wrapMax:
    ld a, [wEuclidKickN]
    dec a
    ld [wEuclidKickRot], a
    ret

EuclidKickLevelUp:
    ld a, [wEuclidKickLevel]
    cp MAX_EUCLID_KICK_LEVEL
    ret z
    inc a
    ld [wEuclidKickLevel], a
    ret
EuclidKickLevelDown:
    ld a, [wEuclidKickLevel]
    and a
    ret z
    dec a
    ld [wEuclidKickLevel], a
    ret

EuclidKickSoundNext:
    ld a, [wEuclidKickSound]
    cp MAX_EUCLID_KICK_SOUND
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wEuclidKickSound], a
    jp HelpFor_EuclidKickSound
EuclidKickSoundPrev:
    ld a, [wEuclidKickSound]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_EUCLID_KICK_SOUND
.store:
    ld [wEuclidKickSound], a
    jp HelpFor_EuclidKickSound

EuclidKickDecayNext:
    ld a, [wEuclidKickDecay]
    cp MAX_EUCLID_KICK_DECAY
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wEuclidKickDecay], a
    jp HelpFor_EuclidKickDecay
EuclidKickDecayPrev:
    ld a, [wEuclidKickDecay]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_EUCLID_KICK_DECAY
.store:
    ld [wEuclidKickDecay], a
    jp HelpFor_EuclidKickDecay

EuclidKickPitchUp:
    ld a, [wEuclidKickPitch]
    cp MAX_EUCLID_KICK_PITCH
    ret z
    inc a
    ld [wEuclidKickPitch], a
    ret
EuclidKickPitchDown:
    ld a, [wEuclidKickPitch]
    and a
    ret z
    dec a
    ld [wEuclidKickPitch], a
    ret

; --- Euclid MOD LFO param routines (V35) --- ----------------------------------------

EucPLfoShapeNext:
    ld a, [wEucPLfoShape]
    cp MAX_EUCLID_PLFO_SHAPE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wEucPLfoShape], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucPLfoShape

EucPLfoShapePrev:
    ld a, [wEucPLfoShape]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_EUCLID_PLFO_SHAPE
.store:
    ld [wEucPLfoShape], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucPLfoShape

EucPLfoRateNext:
    ld a, [wEucPLfoRate]
    cp MAX_EUCLID_PLFO_RATE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wEucPLfoRate], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucPLfoRate

EucPLfoRatePrev:
    ld a, [wEucPLfoRate]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_EUCLID_PLFO_RATE
.store:
    ld [wEucPLfoRate], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucPLfoRate

EucPLfoDepthUp:
    ld a, [wEucPLfoDepth]
    cp MAX_EUCLID_PLFO_DEPTH
    ret z
    inc a
    ld [wEucPLfoDepth], a
    jp HelpFor_EucPLfoDepth

EucPLfoDepthDown:
    ld a, [wEucPLfoDepth]
    and a
    ret z
    dec a
    ld [wEucPLfoDepth], a
    jp HelpFor_EucPLfoDepth

EucVLfoShapeNext:
    ld a, [wEucVLfoShape]
    cp MAX_EUCLID_VLFO_SHAPE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wEucVLfoShape], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucVLfoShape

EucVLfoShapePrev:
    ld a, [wEucVLfoShape]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_EUCLID_VLFO_SHAPE
.store:
    ld [wEucVLfoShape], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucVLfoShape

EucVLfoRateNext:
    ld a, [wEucVLfoRate]
    cp MAX_EUCLID_VLFO_RATE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wEucVLfoRate], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucVLfoRate

EucVLfoRatePrev:
    ld a, [wEucVLfoRate]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_EUCLID_VLFO_RATE
.store:
    ld [wEucVLfoRate], a
    ld a, 1
    ld [wEucLfoDirty], a
    jp HelpFor_EucVLfoRate

EucVLfoDepthUp:
    ld a, [wEucVLfoDepth]
    cp MAX_EUCLID_VLFO_DEPTH
    ret z
    inc a
    ld [wEucVLfoDepth], a
    jp HelpFor_EucVLfoDepth

EucVLfoDepthDown:
    ld a, [wEucVLfoDepth]
    and a
    ret z
    dec a
    ld [wEucVLfoDepth], a
    jp HelpFor_EucVLfoDepth

; EucLfoPreamble — compute LFO-modulated level and pitch, store in HRAM scratch.
; Called once per kick hit from PlayEuclidKickSweep before audio register writes.
; Clobbers: a, b, c, d, e, h, l.
EucLfoPreamble:
    ; --- VLFO: modulate LEVEL ---
    ld a, [wEucVLfoShape]
    and a
    jr z, .noVMod
    ld a, [wEucVLfoDepth]
    and a
    jr z, .noVMod
    ld a, [wEucVLfoPhHi]
    ld c, a                         ; c = phaseHi
    ld a, [wEucVLfoShape]
    call SampleLfoShape             ; a = signed sample (-128..+127)
    ld d, a                         ; d = sample
    ld a, [wEucVLfoDepth]
    ld b, a                         ; b = depth
    ld a, d
    call SignedMulShift7            ; a = (sample × depth) >> 7 → ±7
    ld b, a                         ; b = level offset
    ld a, [wEuclidKickLevel]
    add b                           ; a = base + offset
    ; Clamp 1..7 (never silence a firing kick via LFO)
    bit 7, a                        ; negative underflow?
    jr nz, .vClampMin               ; → floor at 1
    cp 8
    jr c, .vCheckZero               ; < 8: check for exact 0
    ld a, 7                         ; >= 8: ceil at 7
    jr .vDone
.vCheckZero:
    and a
    jr nz, .vDone                   ; 1..7: leave as-is
.vClampMin:
    ld a, 1                         ; 0 or negative: floor at 1
.vDone:
    ldh [hEucModLevel], a
    jr .doPitch
.noVMod:
    ld a, [wEuclidKickLevel]
    ldh [hEucModLevel], a
.doPitch:
    ; --- PLFO: modulate PITCH ---
    ld a, [wEucPLfoShape]
    and a
    jr z, .noPMod
    ld a, [wEucPLfoDepth]
    and a
    jr z, .noPMod
    ld a, [wEucPLfoPhHi]
    ld c, a                         ; c = phaseHi
    ld a, [wEucPLfoShape]
    call SampleLfoShape             ; a = signed sample
    ld d, a
    ld a, [wEucPLfoDepth]
    ld b, a
    ld a, d
    call SignedMulShift6            ; a = (sample × depth) >> 6 → ±30 reg-units
    ld b, a
    ld a, [wEuclidKickPitch]
    add b                           ; a = base + offset
    ; Clamp 0..63
    bit 7, a
    jr z, .pClampMax
    xor a
    jr .pDone
.pClampMax:
    cp 64
    jr c, .pDone
    ld a, 63
.pDone:
    ldh [hEucModPitch], a
    ret
.noPMod:
    ld a, [wEuclidKickPitch]
    ldh [hEucModPitch], a
    ret

; SampleLfoShape — compute signed LFO output from phase and shape.
; Input: c = phaseHi (0..255), a = shape (1=UP,2=DN,3=TRI,4=SIN,5=RND; 0 not called)
; Output: a = signed sample (-128..+127)
; Clobbers: b, h, l
SampleLfoShape:
    cp 1
    jr nz, .notUp
    ld a, c
    sub 128                         ; RAMP↑: -128..+127
    ret
.notUp:
    cp 2
    jr nz, .notDn
    ld a, 127
    sub c                           ; RAMP↓: +127..-128 (127-phaseHi)
    ret
.notDn:
    cp 3
    jr nz, .notTri
    ld a, c
    bit 7, a
    jr nz, .triFall
    sub 64                          ; TRI rising: phi 0..127 → -64..+63
    ret
.triFall:
    cpl
    sub 64                          ; TRI falling: phi 128..255 → +63..-64
    ret
.notTri:
    cp 4
    jr nz, .notSin
    ld b, c                         ; b = phaseHi (preserved)
    ld a, c
    and $3F                         ; a = phi & 63 (quarter index)
    bit 6, b                        ; Q1 or Q3? → use reversed index
    jr z, .sinQ02
    cpl
    and $3F                         ; a = 63 - (phi & 63)
.sinQ02:
    ld hl, SineQtable
    add l
    ld l, a
    jr nc, .sinNC
    inc h
.sinNC:
    ld a, [hl]                      ; 0..127 unsigned
    bit 7, b                        ; negative half (phi 128..255)?
    ret z
    cpl
    inc a                           ; negate → -127..0
    ret
.notSin:
    ; RAND (shape=5)
    call NextRandomByte             ; a = pseudorandom 0..255
    sub 128                         ; center: -128..+127
    ret

; SignedMul8x8 — signed 8-bit × unsigned n-bit multiply → hl (signed 16-bit)
; Input: a = signed multiplicand (-128..+127), b = multiplier (0..15)
; Output: hl = product
; Clobbers: a, c, d, e
SignedMul8x8:
    ld e, a
    ld d, 0
    bit 7, a
    jr z, .smPos
    dec d                           ; d = $FF (sign-extend negative)
.smPos:
    ld hl, 0
    ld a, b
    and a
    ret z
    ld c, a
.smLoop:
    add hl, de
    dec c
    jr nz, .smLoop
    ret

; SignedMulShift7 — (a × b) >> 7, signed 8-bit result
SignedMulShift7:
    call SignedMul8x8
    ld b, 7
.s7Loop:
    sra h
    rr l
    dec b
    jr nz, .s7Loop
    ld a, l
    ret

; SignedMulShift6 — (a × b) >> 6, signed 8-bit result
SignedMulShift6:
    call SignedMul8x8
    ld b, 6
.s6Loop:
    sra h
    rr l
    dec b
    jr nz, .s6Loop
    ld a, l
    ret

; RecomputeLfoIncrements — recompute both LFO phase increments.
; Called lazily when wEucLfoDirty is set.
; Clobbers: a, b, c, d, e, h, l.
RecomputeLfoIncrements:
    xor a
    ld [wEucLfoDirty], a
    ld a, [wEucPLfoShape]
    and a
    jr z, .rcSkipP
    ld a, [wEucPLfoRate]
    ld b, a
    call LfoRateToPeriod
    call LfoDivide65536
    ld a, l
    ld [wEucPLfoIncLo], a
    ld a, h
    ld [wEucPLfoIncHi], a
    jr .rcDoV
.rcSkipP:
    xor a
    ld [wEucPLfoIncLo], a
    ld [wEucPLfoIncHi], a
.rcDoV:
    ld a, [wEucVLfoShape]
    and a
    jr z, .rcSkipV
    ld a, [wEucVLfoRate]
    ld b, a
    call LfoRateToPeriod
    call LfoDivide65536
    ld a, l
    ld [wEucVLfoIncLo], a
    ld a, h
    ld [wEucVLfoIncHi], a
    ret
.rcSkipV:
    xor a
    ld [wEucVLfoIncLo], a
    ld [wEucVLfoIncHi], a
    ret

; LfoRateToPeriod — rate index → period in steps.
; Input: b = rate (0=2ST,1=4ST,2=8ST,3=1BR,4=2BR,5=4BR,6=8BR)
; Output: hl = period length (steps)
; Clobbers: a, c
LfoRateToPeriod:
    ld a, b
    cp 3
    jr nc, .barRate
    ld hl, 2                        ; step rates: 2 << b
    and a
    jr z, .rateRet
    ld c, a
.stShift:
    add hl, hl
    dec c
    jr nz, .stShift
    jr .rateRet
.barRate:
    sub 3                           ; a = bar multiplier shift (0..3)
    ld c, a
    ld a, [wEuclidKickN]
    ld l, a
    ld h, 0
    ld a, c
    and a
    jr z, .rateRet
.barShift:
    add hl, hl
    dec a
    jr nz, .barShift
.rateRet:
    ld a, h
    or l
    jr nz, .periodOK
    ld hl, 2
.periodOK:
    ret

; LfoDivide65536 — floor(65536 / hl) using 16-step restoring division.
; Computes floor(32768/de) then doubles.
; Input: hl = divisor (1..128)
; Output: hl = floor(65536 / divisor)
; Clobbers: a, b, c, d, e
LfoDivide65536:
    ld d, h
    ld e, l
    ld hl, $8000                    ; dividend = 32768
    ld bc, 0
    ld a, 16
    push af
.lfdLoop:
    add hl, hl
    rl c
    rl b
    ld a, b
    cp d
    jr c, .lfdNoSub
    jr nz, .lfdDoSub
    ld a, c
    cp e
    jr c, .lfdNoSub
.lfdDoSub:
    ld a, c
    sub e
    ld c, a
    ld a, b
    sbc d
    ld b, a
    inc l
.lfdNoSub:
    pop af
    dec a
    push af
    jr nz, .lfdLoop
    pop af
    add hl, hl                      ; floor(32768/de) × 2 ≈ floor(65536/de)
    ret

; HelpFor_ stubs for all six MOD params
HelpFor_EucPLfoShape:
    ld a, [wEucPLfoShape]
    ld hl, HelpStr_EucPLfoShape
    jp ShowHelpByIndex
HelpFor_EucPLfoRate:
    ld a, [wEucPLfoRate]
    ld hl, HelpStr_EucPLfoRate
    jp ShowHelpByIndex
HelpFor_EucPLfoDepth:
    ld a, [wEucPLfoDepth]
    ld hl, HelpStr_EucPLfoDepth
    jp ShowHelpByIndex
HelpFor_EucVLfoShape:
    ld a, [wEucVLfoShape]
    ld hl, HelpStr_EucVLfoShape
    jp ShowHelpByIndex
HelpFor_EucVLfoRate:
    ld a, [wEucVLfoRate]
    ld hl, HelpStr_EucVLfoRate
    jp ShowHelpByIndex
HelpFor_EucVLfoDepth:
    ld a, [wEucVLfoDepth]
    ld hl, HelpStr_EucVLfoDepth
    jp ShowHelpByIndex

; ComputeEuclidVisBuf — writes 18 bytes to wEuclidVisBuf (16 step tiles + 2 arrow tiles).
; Safe to call any time (no VRAM access). BlitEuclidVis copies the result to VRAM in
; .page8Values. Display position i shows raw slot (i+Rot) mod N for i<N, else BLANK.
; Hit = TILE_X, miss = TILE_DOT. Out-of-range = TILE_BLANK at i == N.
; Clobbers a, b, c, d, e, h, l.
ComputeEuclidVisBuf:
    ; Pattern address: hl = base + ((N-2)*17 + K) * 2
    ld a, [wEuclidKickN]
    sub 2
    ld b, a
    add a
    add a
    add a
    add a
    add b                           ; (N-2)*17
    ld b, a
    ld a, [wEuclidKickK]
    add b                           ; (N-2)*17 + K
    ld l, a
    ld h, 0
    add hl, hl                      ; * 2 (byte offset)
    ld bc, EuclidPatternTable
    add hl, bc

    ld a, [hli]
    ld d, a                         ; d = pattern high byte
    ld a, [hl]
    ld e, a                         ; e = pattern low byte

    ld hl, wEuclidVisBuf            ; V37: write to shadow buffer, not VRAM
    ld b, 0                         ; b = display index 0..15
.vLoop:
    ld a, [wEuclidKickN]
    cp b
    jr c, .vOut                     ; b > N
    jr z, .vOut                     ; b == N (display 0..N-1 only)

    ; raw_slot = (b + Rot) mod N. Save d/e, use d as scratch for N.
    push de
    ld a, [wEuclidKickRot]
    add b
    ld c, a                         ; c = b + Rot (< 2N)
    ld a, [wEuclidKickN]
    ld d, a
    ld a, c
    cp d
    jr c, .vModOk                   ; c < N already
    sub d                           ; c -= N
.vModOk:
    ld c, a                         ; c = raw_slot 0..15
    pop de

    ; Pick byte (d=high if slot<8 else e=low), set up shift count = (slot mod 8) + 1
    ld a, c
    cp 8
    jr c, .vUseHi
    sub 8
    ld c, a
    ld a, e
    jr .vHaveByte
.vUseHi:
    ld c, a
    ld a, d
.vHaveByte:
    inc c
.vShift:
    rlca
    dec c
    jr nz, .vShift
    jr nc, .vMiss
    ld a, TILE_X
    jr .vWrite
.vMiss:
    ld a, TILE_DOT
    jr .vWrite
.vOut:
    ld a, TILE_BLANK
.vWrite:
    ld [hli], a
    inc b
    ld a, b
    cp 16
    jr nz, .vLoop
    ; V26.1: hint that plain ←/→ rotates the pattern. After the 16-tile loop,
    ; hl == $98B0 (row 5, col 16). Hide arrows on MOD sub-view (plain LR is
    ; not wired to rotation there).
    ld a, [wEucModView]
    and a
    jr nz, .visNoArrows
    ld a, TILE_LF_ARROW
    ld [hli], a
    ld a, TILE_RT_ARROW
    ld [hl], a
    ret
.visNoArrows:
    ld a, TILE_BLANK
    ld [hli], a
    ld [hl], a
    ret

; BlitEuclidVis — copies wEuclidVisBuf (18 bytes) → $98A0 (row 5 cols 0..17).
; ~180 cycles; fits comfortably in VBlank after HelpRowTick. Clobbers a, c, d, e, h, l.
BlitEuclidVis:
    ld hl, wEuclidVisBuf
    ld de, $98A0
    ld c, 18
.lp:
    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, .lp
    ret

; EuclidPreArbitrate: looks up the KICK pattern bit at (Step+Rot) mod N and
; stores 0/1 in hEuclidKickWants, then advances wEuclidKickStep mod N.
; K=0 short-circuits to wants=0 but still advances Step so phase stays locked.
; Called from the step handler after .phaseDone, before gate/play branching.
EuclidPreArbitrate:
    xor a
    ldh [hEuclidKickWants], a
    ld a, [wEuclidKickK]
    and a
    jr z, .advanceStep              ; lane muted; just phase-tick

    ; slot_idx = (Step + Rot) mod N → d
    ld a, [wEuclidKickRot]
    ld b, a
    ld a, [wEuclidKickStep]
    add b                           ; a = Step + Rot, max 15+15 = 30
    ld b, a
    ld a, [wEuclidKickN]
    ld c, a
    ld a, b
.modN:
    cp c
    jr c, .modNDone
    sub c
    jr .modN
.modNDone:
    ld d, a                         ; d = slot_idx 0..15

    ; Pattern address: hl = EuclidPatternTable + ((N-2)*17 + K) * 2
    ld a, [wEuclidKickN]
    sub 2
    ld b, a
    add a
    add a
    add a
    add a
    add b                           ; a = (N-2)*17, max 14*17 = 238
    ld b, a
    ld a, [wEuclidKickK]
    add b                           ; a = (N-2)*17 + K, max 254
    ld l, a
    ld h, 0
    add hl, hl                      ; hl = byte offset (max 508)
    ld bc, EuclidPatternTable
    add hl, bc

    ; b = high byte, c = low byte
    ld a, [hli]
    ld b, a
    ld c, [hl]

    ; Pick byte and intra-byte bit position; rotate (pos+1) times to drop bit into CY.
    ld a, d
    cp 8
    jr c, .useHigh
    sub 8                           ; a = slot_idx - 8 (0..7)
    ld e, a
    ld a, c                         ; low byte
    jr .haveByte
.useHigh:
    ld e, a                         ; e = slot_idx (0..7)
    ld a, b                         ; high byte
.haveByte:
    inc e                           ; e in [1..8]
.shiftLoop:
    rlca
    dec e
    jr nz, .shiftLoop
    jr nc, .advanceStep             ; pattern bit was 0
    ld a, 1
    ldh [hEuclidKickWants], a

.advanceStep:
    ; wEuclidKickStep = (Step + 1) mod N
    ld a, [wEuclidKickStep]
    inc a
    ld b, a
    ld a, [wEuclidKickN]
    cp b
    jr nz, .stepKeep
    xor a                           ; wrap to 0
    ld [wEuclidKickStep], a
    jr .lfoTick
.stepKeep:
    ld a, b
    ld [wEuclidKickStep], a

.lfoTick:
    ; V35: recompute phase increments if dirty, then tick both LFO accumulators.
    ld a, [wEucLfoDirty]
    and a
    call nz, RecomputeLfoIncrements
    ; Tick PLFO (only if shape ≠ OFF)
    ld a, [wEucPLfoShape]
    and a
    jr z, .lfoTickV
    ld a, [wEucPLfoIncLo]
    ld b, a
    ld a, [wEucPLfoPhLo]
    add b
    ld [wEucPLfoPhLo], a
    ld a, [wEucPLfoIncHi]
    ld b, a
    ld a, [wEucPLfoPhHi]
    adc b
    ld [wEucPLfoPhHi], a
.lfoTickV:
    ; Tick VLFO (only if shape ≠ OFF)
    ld a, [wEucVLfoShape]
    and a
    ret z
    ld a, [wEucVLfoIncLo]
    ld b, a
    ld a, [wEucVLfoPhLo]
    add b
    ld [wEucVLfoPhLo], a
    ld a, [wEucVLfoIncHi]
    ld b, a
    ld a, [wEucVLfoPhHi]
    adc b
    ld [wEucVLfoPhHi], a
    ret

; PlayEuclidKickSweep — overwrite CH1 with KICK sweep when this step's pattern
; bit fired AND there's no Accent=KIK collision. Called from the step handler
; right after PlayCurrentNote, so the melody's CH1 register state is replaced
; for one step. The next step's PlayCurrentNote clears NR10 and re-writes CH1
; back to the arp melody. Sets hKickStepActive so the gate-expiry path skips
; muting CH1 — the kick body's envelope decay continues into gate-off.
;
; Accent=KIK collision: ACC=KIK fires LATER in MaybeTriggerAccent and writes
; CH1 via PlayKickAccent. On a cycle-start step that is also a KICK-pattern
; step, ACC's write would clobber Euclid's. Better: detect and bail here so
; ACC owns CH1 cleanly. User who wants Euclid to drive cycle-starts must set
; ACCENT = OFF.
;
; Clobbers: a, b, c, d, e, hl
PlayEuclidKickSweep:
    ldh a, [hEuclidKickWants]
    and a
    ret z
    ld a, [wMuteEuc]
    and a
    ret nz

    ldh a, [hAccentPending]
    and a
    jr z, .doFire
    ld a, [wNoiseAccent]
    cp 1                            ; ACCENT = KIK
    ret z

.doFire:
    ld a, [wEuclidKickLevel]
    and a
    ret z                            ; LEVEL=0 → silent

    ; Cancel any pending deferred CH1 fire so the kick's decay isn't stomped.
    xor a
    ldh [hCH1FirePending], a
    ldh [hCH1OffsetCounter], a

    ; V35: compute LFO-modulated level and pitch into HRAM scratch.
    call EucLfoPreamble

    ; Compose NR12 = (TonalLevelTable[level] << 4) | KickDecayEnvelope[decay].
    ; TonalLevelTable values fit in low nibble (0..$F), so swap+mask is safe.
    ldh a, [hEucModLevel]
    ld hl, TonalLevelTable
    add l
    ld l, a
    jr nc, .ncEuLvl
    inc h
.ncEuLvl:
    ld a, [hl]
    swap a
    and $F0
    ld c, a                         ; c = level high nibble
    ld a, [wEuclidKickDecay]
    ld hl, KickDecayEnvelope
    add l
    ld l, a
    jr nc, .ncEuDec
    inc h
.ncEuDec:
    ld a, [hl]
    or c
    ld d, a                         ; d = NR12 byte (level + decay)

    ; NR10: source from per-(SOUND, DECAY) table so DECAY controls sweep window.
    ; On punchy presets SHRT/MID/LONG keep the preset's base sweep/add 1-2 extra
    ; period steps, extending the audible window to match the envelope tail.
    ; SUB row is $34/$34/$34 — byte-identical to today across all DECAY settings.
    ld a, [wEuclidKickSound]
    ld c, a
    add a
    add c                           ; a = sound * 3
    ld c, a
    ld a, [wEuclidKickDecay]
    add c                           ; a = sound * 3 + decay
    ld c, a
    ld b, 0
    ld hl, EuclidKickNR10ByDecay
    add hl, bc
    ld a, [hl]
    ldh [rNR10], a

    ; Look up SOUND preset record (4 bytes: NR10, NR11, NR13, NR14_lo).
    ; Preset NR10 byte is skipped — it now only documents the SHRT baseline.
    ld a, [wEuclidKickSound]
    add a
    add a                           ; a = sound * 4
    ld c, a
    ld b, 0
    ld hl, EuclidKickSoundPresets
    add hl, bc
    inc hl                          ; skip preset NR10 (overridden above)

    ld a, [hli]
    ldh [rNR11], a
    ld a, d
    ldh [rNR12], a

    ; PITCH offset: combine preset 11-bit X with signed (pitch - 32) × 16.
    ; ×16 gives ~±6 semitones for TIGHT/BOOM/PUNCH (X_base=$2C7 ± 496 → 215..1207).
    ; SUB (X_base=$100): positive travel safe (+496 → 752); negative travel clamped
    ; at register floor 0 since $100 - 512 < 0.
    ld a, [hli]                     ; preset NR13 (low 8 bits of X)
    ld c, a
    ld a, [hl]                      ; preset NR14_lo (3 LSBs = X high, rest = flags)
    ld b, a                         ; b = full NR14_lo for flag preservation below
    and $07
    ld h, a                         ; h = X high (3 bits)
    ld l, c                         ; hl = X_base (0..2047); c is free from here

    ldh a, [hEucModPitch]
    sub EUCLID_PITCH_NEUTRAL        ; signed offset -32..+31 in a
    ; multiply by 16: sign-extend to de, then shift de left 4
    ld c, a                         ; c = signed offset (c free: ld l,c already consumed it)
    add a                           ; CY = sign bit
    sbc a                           ; a = $00 (pos) or $FF (neg) — sign extension
    ld d, a
    ld e, c
    sla e
    rl d
    sla e
    rl d
    sla e
    rl d
    sla e
    rl d
    add hl, de                      ; hl = X_new
    ; Clamp floor: SUB + large negative offset can wrap hl negative
    bit 7, h
    jr z, .kickPitchOK
    ld hl, 0
.kickPitchOK:

    ld a, l
    ldh [rNR13], a
    ld a, b
    and $F8                         ; preserve non-freq flag bits from preset
    or h                            ; merge new freq high (3 bits)
    or $80                          ; trigger
    ldh [rNR14], a

    ld a, 1
    ldh [hKickStepActive], a        ; gate-expiry skip-mute (also set by PlayKickAccent)
    ret

FillFreqPrev:
    ld a, [wFillFreq]
    and a
    ret z
    dec a
    ld [wFillFreq], a
    ret

; --- CH1 Volume ---
CH1VolUp:
    ld a, [wCH1Volume]
    cp MAX_CH1VOL
    ret z
    inc a
    ld [wCH1Volume], a
    ret

CH1VolDown:
    ld a, [wCH1Volume]
    and a
    ret z
    dec a
    ld [wCH1Volume], a
    ret

; --- CH1 Detune Amount ---
CH1DetUp:
    ld a, [wCH1DetunePending]
    cp MAX_CH1DET
    ret z
    inc a
    ld [wCH1DetunePending], a
    ret

CH1DetDown:
    ld a, [wCH1DetunePending]
    and a
    ret z
    dec a
    ld [wCH1DetunePending], a
    ret

; --- CH1 Interval ---
CH1IntUp:
    ld a, [wCH1IntervalPending]
    cp MAX_CH1INT
    ret z
    inc a
    ld [wCH1IntervalPending], a
    jp HelpFor_CH1Int

CH1IntDown:
    ld a, [wCH1IntervalPending]
    and a
    ret z
    dec a
    ld [wCH1IntervalPending], a
    jp HelpFor_CH1Int

; --- CH1 Scale Degree ---
CH1DegUp:
    ld a, [wCH1ScaleDegPending]
    cp MAX_CH1DEG
    ret z
    inc a
    ld [wCH1ScaleDegPending], a
    ret

CH1DegDown:
    ld a, [wCH1ScaleDegPending]
    and a
    ret z
    dec a
    ld [wCH1ScaleDegPending], a
    ret

; --- CH1 Attack 3-way (OFF/SAM/INDP) ---
CH1AtkNext:
    ld a, [wCH1Attack]
    inc a
    cp MAX_CH1ATK + 1
    jr c, .store
    xor a
.store:
    ld [wCH1Attack], a
    jp HelpFor_CH1Atk

CH1AtkPrev:
    ld a, [wCH1Attack]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_CH1ATK
.store:
    ld [wCH1Attack], a
    jp HelpFor_CH1Atk

; --- CH1 INDP Attack Type (1-3) ---
CH1IAtkUp:
    ld a, [wCH1AtkType]
    cp MAX_CH1ATKTYPE
    ret z
    inc a
    ld [wCH1AtkType], a
    ret

CH1IAtkDown:
    ld a, [wCH1AtkType]
    cp 1                    ; floor at 1 (index 0 not used)
    ret z
    dec a
    ld [wCH1AtkType], a
    ret

; --- CH1 Waveform (Duty Cycle) ---
CH1WaveUp:
    ld a, [wCH1Wave]
    cp MAX_CH1WAVE
    jr c, .inc
    xor a                  ; wrap WDE → NRW
    jr .store
.inc:
    inc a
.store:
    ld [wCH1Wave], a
    jp HelpFor_CH1Wave

CH1WaveDown:
    ld a, [wCH1Wave]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_CH1WAVE      ; wrap NRW → WDE
.store:
    ld [wCH1Wave], a
    jp HelpFor_CH1Wave

; --- CH1 Offset ---
CH1OffsetNext:
    ld a, [wCH1Offset]
    cp MAX_CH1OFFSET
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wCH1Offset], a
    jp HelpFor_CH1Offset

CH1OffsetPrev:
    ld a, [wCH1Offset]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_CH1OFFSET
.store:
    ld [wCH1Offset], a
    jp HelpFor_CH1Offset

; --- CH3 Mode ---
CH3ModeNext:
    ld a, [wCH3Mode]
    cp MAX_CH3MODE
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wCH3Mode], a
    xor a
    ld [wCH3Running], a     ; reset — need fresh trigger
    ld a, [wCH3Mode]
    and a
    call nz, LoadWaveRAM
    ld a, [wCH3Mode]
    and a
    jr nz, .help
    xor a
    ldh [rNR30], a          ; CH3 off
.help:
    jp HelpFor_CH3Mode

CH3ModePrev:
    ld a, [wCH3Mode]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, MAX_CH3MODE
.store:
    ld [wCH3Mode], a
    xor a
    ld [wCH3Running], a     ; reset — need fresh trigger
    ld a, [wCH3Mode]
    and a
    call nz, LoadWaveRAM
    ld a, [wCH3Mode]
    and a
    jr nz, .help
    xor a
    ldh [rNR30], a
.help:
    jp HelpFor_CH3Mode

; --- CH3 Wave Preset ---
CH3WaveNext:
    ld a, [wCH3Wave]
    cp CH3_WAVE_COUNT - 1
    jr c, .inc
    xor a
    jr .store
.inc:
    inc a
.store:
    ld [wCH3Wave], a
    xor a
    ld [wCH3Running], a     ; reset — new waveform needs trigger
    ld a, [wCH3Mode]
    and a
    call nz, LoadWaveRAM
    jp HelpFor_CH3Wave

CH3WavePrev:
    ld a, [wCH3Wave]
    and a
    jr z, .wrap
    dec a
    jr .store
.wrap:
    ld a, CH3_WAVE_COUNT - 1
.store:
    ld [wCH3Wave], a
    xor a
    ld [wCH3Running], a     ; reset — new waveform needs trigger
    ld a, [wCH3Mode]
    and a
    call nz, LoadWaveRAM
    jp HelpFor_CH3Wave

; --- CH3 Volume ---
CH3VolUp:
    ld a, [wCH3Volume]
    cp MAX_CH3VOL
    ret z
    inc a
    ld [wCH3Volume], a
    ret

CH3VolDown:
    ld a, [wCH3Volume]
    and a
    ret z
    dec a
    ld [wCH3Volume], a
    ret

; --- CH3 Shape ---
CH3ShapeNext:
    ld a, [wCH3Shape]
    cp MAX_CH3SHAPE
    jr z, .wrap
    inc a
    jr .store
.wrap:
    xor a
.store:
    ld [wCH3Shape], a
    ; Reset engine so next note-on initializes from new shape
    xor a
    ldh [hCH3ShapeRunning], a
    ldh [hCH3ShapeMuted], a
    jp HelpFor_CH3Shape

CH3ShapePrev:
    ld a, [wCH3Shape]
    and a
    jr z, .wrapPrev
    dec a
    jr .storePrev
.wrapPrev:
    ld a, MAX_CH3SHAPE
.storePrev:
    ld [wCH3Shape], a
    xor a
    ldh [hCH3ShapeRunning], a
    ldh [hCH3ShapeMuted], a
    jp HelpFor_CH3Shape

; --- CH3 Rate ---
CH3RateUp:
    ld a, [wCH3Rate]
    cp MAX_CH3RATE
    ret z
    inc a
    ld [wCH3Rate], a
    xor a
    ldh [hCH3ShapeRunning], a   ; next note-on re-inits with new rate
    ret

CH3RateDown:
    ld a, [wCH3Rate]
    cp 1
    ret z
    dec a
    ld [wCH3Rate], a
    xor a
    ldh [hCH3ShapeRunning], a   ; next note-on re-inits with new rate
    ret

ComputeNoteCount:
    ; Pattern shape changed — invalidate any queued accent. Without this, a
    ; wrap/reversal latched just before the user releases B (or changes stride/
    ; range/group) would fire on the first note of the new pattern, which may
    ; not be a real cycle boundary under the new wNoteCount.
    xor a
    ldh [hAccentPending], a
    ; noteCount = scaleSize[bank] * octaveRange + 1
    ld a, [wPlayingBank]
    ld hl, ScaleSizeTable
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc:
    ld a, [hl]
    ; a = notes per octave for this bank; multiply by octaveRange
    ld d, a
    ld a, [wOctaveRange]
    ld e, a
    xor a
.mul:
    add d
    dec e
    jr nz, .mul
    ; a = scaleSize * octaveRange — divide by stride
    ld d, a
    ld a, [wStride]
    cp 1
    jr z, .noDiv
    ld e, a               ; e = stride
    ld a, d               ; a = total notes
    ld d, 0
.divStride:
    cp e
    jr c, .divDone
    sub e
    inc d
    jr .divStride
.divDone:
    ld a, d               ; a = total / stride
    jr .storeCount
.noDiv:
    ld a, d
.storeCount:
    inc a
    ld [wNoteCount], a
    ; Cache wFillCycleStep = 16 / cycle_length (clamped >= 1) for LR↑/LR↓.
    ; cycle_length depends on pattern. AdvanceArp fires hCycleReset at every
    ; cycle-start event (ASC wrap, DESC wrap, PINGPONG top + bottom reversals).
    ;   ASC, DESC: wNoteCount notes per ramp.
    ;   PINGPONG:  steady-state segments are wNoteCount-1 notes long (the
    ;              boundary note's phase is consumed before the reversal arms
    ;              hCycleReset). The very first cold-start segment is
    ;              wNoteCount notes — accept slight oversampling on cycle 1
    ;              rather than undershooting all subsequent segments.
    ;   RANDOM:    wFillCycleStep = 0 sentinel — phase undefined;
    ;              LR↑/LR↓ fall back to FLT in ComposeAndPlayFill.
    ; HandleInput contract: callers preserve b (held) and c (newly pressed),
    ; so push/pop bc around this loop which uses both as scratch.
    push bc
    ld b, a                ; b = wNoteCount (divisor for ASC/DESC)
    ld a, [wPatternType]
    cp PAT_RANDOM
    jr z, .fillStepRandom
    cp PAT_PINGPONG
    jr nz, .fillStepHaveDivisor
    ld a, b
    dec a
    jr nz, .fillStepPingpongOk
    inc a                  ; degenerate N=1: clamp divisor to 1
.fillStepPingpongOk:
    ld b, a                ; b = wNoteCount - 1 for PINGPONG
.fillStepHaveDivisor:
    ld a, 16
    ld c, 0                ; c = quotient
.fillStepDiv:
    cp b
    jr c, .fillStepDone
    sub b
    inc c
    jr .fillStepDiv
.fillStepDone:
    ld a, c
    and a
    jr nz, .fillStepStore
    inc a                  ; clamp to 1 when noteCount > 16
    jr .fillStepStore
.fillStepRandom:
    xor a                  ; sentinel: 0 → LR↑/LR↓ fall back to FLT
.fillStepStore:
    ld [wFillCycleStep], a
    pop bc
    call EuclidKickApplyLock    ; V37: snap LEN to arp cycle if LOCK is on
    ret

ClampArpPosition:
    ld a, [wNoteCount]
    ld d, a
    ld a, [wArpPosition]
    cp d
    ret c
    ld a, d
    dec a
    ld [wArpPosition], a
    ret

; =============================================================================
; Play Current Note
; =============================================================================

PlayCurrentNote:
    ; Get scale size for playing bank
    ld a, [wPlayingBank]
    ld hl, ScaleSizeTable
    add l
    ld l, a
    jr nc, .ncSS
    inc h
.ncSS:
    ld a, [hl]
    ld e, a                 ; e = scale size (notes per octave)

    ; Multiply position by stride, then divide by scaleSize
    ld a, [wStride]
    ld d, a              ; d = stride
    ld a, [wArpPosition]
    ld h, a              ; h = position
    xor a
.mulStride:
    add h
    dec d
    jr nz, .mulStride
    ; a = position * stride
    ld d, 0
.divN:
    cp e
    jr c, .divNdone
    sub e
    inc d
    jr .divN
.divNdone:
    ; a = degree, d = arp_octave
    ldh [hArpDegree], a
    push af
    ld a, d
    ldh [hArpOctave], a
    pop af

    ; ScaleTable index = bank * 10 + degree (16-bit to avoid overflow)
    push af              ; save degree
    push de              ; save d=arp_octave

    ld a, [wPlayingBank]
    ld l, a
    ld h, 0              ; hl = bank
    add hl, hl           ; hl = bank*2
    ld d, h
    ld e, l              ; de = bank*2
    add hl, hl           ; hl = bank*4
    add hl, hl           ; hl = bank*8
    add hl, de           ; hl = bank*10
    ld de, ScaleTable
    add hl, de           ; hl = &ScaleTable[bank*10]

    pop de               ; restore d=arp_octave
    pop af               ; restore degree
    add l                ; hl += degree
    ld l, a
    jr nc, .nc1
    inc h
.nc1:
    ld a, [hl]

    ; absolute_note = rootNote + semitone_offset
    ld e, a
    ld a, [wRootNote]
    add e

    ; note_in_octave = absolute_note % 12, extra_octaves = absolute_note / 12
    ld e, 0
.div12:
    cp 12
    jr c, .div12done
    sub 12
    inc e
    jr .div12
.div12done:
    ; a = note_in_octave, e = extra_octaves, d = arp_octave

    push af

    ; final_octave = rootOctave + extra_octaves + arp_octave
    ld a, [wRootOctave]
    add e
    add d
    cp 5
    jr c, .octOk
    ld a, 4
.octOk:
    ; freq_index = final_octave * 12 + note_in_octave
    ld d, a
    add a
    add d
    add a
    add a

    pop de
    ; d = note_in_octave (from pushed a)
    add d

    ldh [hFreqIndex], a     ; save for CH1

    ; Byte offset = index * 2
    add a
    ld hl, FreqTable
    add l
    ld l, a
    jr nc, .nc2
    inc h
.nc2:
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld e, a

    ; Mute guard: wMuteCH2 or GATE=SIL → skip CH2 (SIL: CH2 register only)
    ld a, [wMuteCH2]
    and a
    jr nz, .skipCH2
    ld a, [wGateLength]
    cp MAX_GATE
    jr z, .skipCH2

    ; --- Check CH3 REPLACE mode: skip CH2 if replacing ---
    ld a, [wCH3Mode]
    cp 1                    ; RPL?
    jr z, .skipCH2

    ; Write CH2 (waveform from WavePresets)
    push de
    ld a, [wDutyCycle]
    add a
    ld hl, WavePresets
    add l
    ld l, a
    jr nc, .ncWave
    inc h
.ncWave:
    ld a, [hli]
    ldh [rNR21], a
    ld a, [hl]

    ; Override envelope if attack is active
    push af
    ld a, [wAttackSpeed]
    and a
    jr z, .noAtk
    ld hl, AttackPresets
    add l
    ld l, a
    jr nc, .ncAtk
    inc h
.ncAtk:
    pop af
    ld a, [hl]
    ldh [rNR22], a
    jr .atkDone
.noAtk:
    pop af
    ldh [rNR22], a
.atkDone:
    pop de
    ld a, d
    ldh [rNR23], a
    ld a, e
    or $80
    ldh [rNR24], a
    jr .ch2Done

.skipCH2:
    ld a, DAC_ON_SILENT
    ldh [rNR22], a          ; CH2: DAC alive, vol 0
    ld a, $80
    ldh [rNR24], a          ; retrigger CH2 at vol 0

.ch2Done:
    ; --- Write CH3 if active ---
    ld a, [wCH3Mode]
    and a
    jr z, .noCH3

    ; wMuteCH3: mute output, keep shape engine alive
    ld a, [wMuteCH3]
    and a
    jr z, .ch3Audible
    xor a
    ldh [rNR32], a             ; CH3 output silent
    ld a, 1
    ldh [hCH3ShapeMuted], a    ; suppress shape writes (mirrors gate-off pattern)
    jr .noCH3
.ch3Audible:

    push de

    ; Ensure CH3 DAC is on
    ld a, $80
    ldh [rNR30], a

    ; No length timer
    xor a
    ldh [rNR31], a

    ; Write frequency low byte
    pop de
    ld a, d
    ldh [rNR33], a

    ; Check if CH3 is already running
    ld a, [wCH3Running]
    and a
    jr nz, .ch3Running

    ; --- First trigger: mute → trigger → unmute ---
    xor a
    ldh [rNR32], a          ; mute for clean trigger
    ld a, e
    or $80
    ldh [rNR34], a          ; trigger at vol 0 (click inaudible)
    ld a, 1
    ld [wCH3Running], a
    jr .ch3Vol

.ch3Running:
    ; --- Already running: update freq only, no trigger ---
    ld a, e
    ldh [rNR34], a          ; freq high, NO trigger bit

.ch3Vol:
    ; Shape engine or static volume
    ld a, [wCH3Shape]
    and a
    jr z, .ch3StaticVol     ; SHAPE=OFF → use static volume

    ; Shape engine active — clear gate mute, init if not already running
    xor a
    ldh [hCH3ShapeMuted], a  ; un-mute: shape drives NR32 again

    ldh a, [hCH3ShapeRunning]
    and a
    jr z, .ch3ShapeInit      ; not running → init (first note or post-envelope)

    ; Already running — restore last step value so channel isn't silent
    ; until the next step transition completes
    ldh a, [hCH3ShapeLast]
    ldh [rNR32], a
    jr .noCH3

.ch3ShapeInit:
    call CH3ShapeInit        ; init engine, writes NR32 value[0] + hCH3ShapeLast
    jr .noCH3

.ch3StaticVol:
    ld a, [wCH3Volume]
    ld hl, CH3VolNR32
    add l
    ld l, a
    jr nc, .ncV3
    inc h
.ncV3:
    ld a, [hl]
    ldh [rNR32], a

.noCH3:
    ; --- CH1 Dual ---
    ; wMuteCH1 mute guard — companion only; kick (wMuteEuc) guarded separately
    ld a, [wMuteCH1]
    and a
    jp nz, SilenceCH1

    ld a, [wCH1Mode]
    and a
    jr nz, .ch1MaybeDelay
    jp SilenceCH1
.ch1MaybeDelay:
    ld a, [wCH1Offset]
    and a
    jr z, .ch1Immediate
    call LoadSpeedFrames
    call ComputeCH1OffsetFrames
    and a
    jr z, .ch1Immediate         ; rounds to 0 → immediate
    ldh [hCH1OffsetCounter], a
    ld a, 1
    ldh [hCH1FirePending], a
    ret
.ch1Immediate:
    jp FireCH1Now

FireCH1Now:
    ; No sweep on CH1
    xor a
    ldh [rNR10], a

    ; CH1 independent duty cycle
    ld a, [wCH1Wave]
    ld hl, CH1DutyTable
    add l
    ld l, a
    jr nc, .ncW1
    inc h
.ncW1:
    ld a, [hl]
    ldh [rNR11], a          ; duty cycle

    ; --- CH1 Envelope: volume table + 3-way attack (OFF/SAM/INDP) ---
    ld a, [wCH1Volume]
    and a
    jr z, .ch1Mute          ; vol 0 → always mute
    ld a, [wCH1Attack]
    and a
    jr z, .ch1SustVol       ; OFF → sustained volume
    cp 2
    jr z, .ch1Indp          ; INDP → own preset
    ; SAME: mirror CH2 attack (wAttackSpeed)
    ld a, [wAttackSpeed]
    and a
    jr z, .ch1SustVol       ; CH2 has no attack → sustained
    ld hl, AttackPresets
    add l
    ld l, a
    jr nc, .ncAtk1
    inc h
.ncAtk1:
    ld a, [hl]
    ldh [rNR12], a
    jr .ch1EnvDone
.ch1Indp:
    ld a, [wCH1AtkType]
    ld hl, AttackPresets
    add l
    ld l, a
    jr nc, .ncIAtk
    inc h
.ncIAtk:
    ld a, [hl]
    ldh [rNR12], a
    jr .ch1EnvDone
.ch1Mute:
    ld a, DAC_ON_SILENT
    ldh [rNR12], a
    jr .ch1EnvDone
.ch1SustVol:
    ; Sustained volume from table
    ld a, [wCH1Volume]
    ld hl, CH1VolTable
    add l
    ld l, a
    jr nc, .ncVol1
    inc h
.ncVol1:
    ld a, [hl]
    ldh [rNR12], a
.ch1EnvDone:

    ; --- CH1 Frequency: 6-mode dispatch ---
    ldh a, [hFreqIndex]
    ld d, a                 ; d = base freq index
    ld a, [wCH1Mode]

    cp 1
    jr z, .ch1OctUp
    cp 2
    jr z, .ch1OctDown
    cp 3
    jr z, .ch1Detune
    cp 4
    jr z, .ch1Interval
    cp 5
    jp z, CH1ScaleLookup
    ; Should not reach here (mode 0 handled above)
    ret

.ch1OctUp:
    ld a, d
    add 12
    cp 60
    jr c, .ch1FreqLookup
    jp SilenceCH1

.ch1OctDown:
    ld a, d
    sub 12
    jr nc, .ch1FreqLookup
    jp SilenceCH1

.ch1Interval:
    ; INT mode: add wCH1Interval + 1 semitones
    ld a, [wCH1Interval]
    inc a                   ; +1 because internal 0 = +1 semitone
    add d
    cp 60
    jr c, .ch1FreqLookup
    jp SilenceCH1

.ch1FreqLookup:
    ; a = freq index, look up FreqTable → d/e
    add a                   ; byte offset = index * 2
    ld hl, FreqTable
    add l
    ld l, a
    jr nc, .ncF1
    inc h
.ncF1:
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld e, a
    jp WriteCH1Freq

.ch1Detune:
    ; DET mode: same freq index + detune offset
    ld a, d
    add a                   ; byte offset = index * 2
    ld hl, FreqTable
    add l
    ld l, a
    jr nc, .ncF1d
    inc h
.ncF1d:
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld e, a
    ; Add detune offset to freq low byte
    ld a, [wCH1Detune]
    ld hl, DetuneOffsets
    add l
    ld l, a
    jr nc, .ncDT
    inc h
.ncDT:
    ld a, [hl]
    add d
    ld d, a
    jr nc, .noDetCarry
    inc e
.noDetCarry:
    jp WriteCH1Freq

; --- CH1 Global Helpers ---

WriteCH1Freq:
    ; Input: d = freq low byte, e = freq high byte
    ld a, d
    ldh [rNR13], a
    ld a, e
    or $80                  ; trigger
    ldh [rNR14], a
    ret

SilenceCH1:
    ld a, DAC_ON_SILENT
    ldh [rNR12], a
    ld a, $80
    ldh [rNR14], a
    ret

; --- CH1 Scale Lookup ---
; Computes CH1 frequency from current arp degree + wCH1ScaleDeg offset
; Uses hArpDegree, hArpOctave, wPlayingBank, wRootNote, wRootOctave

CH1ScaleLookup:
    ; new_degree = hArpDegree + wCH1ScaleDeg + 1
    ldh a, [hArpDegree]
    ld d, a
    ld a, [wCH1ScaleDeg]
    inc a                   ; internal 0 = +1 degree
    add d                   ; a = degree + offset

    ; Get scale size
    push af
    ld a, [wPlayingBank]
    ld hl, ScaleSizeTable
    add l
    ld l, a
    jr nc, .ncSS1
    inc h
.ncSS1:
    ld a, [hl]
    ld e, a                 ; e = scale size
    pop af

    ; Division loop: while a >= e → a -= e, extra_oct++
    ld d, 0                 ; d = extra_oct from wrapping
.sclDiv:
    cp e
    jr c, .sclDivDone
    sub e
    inc d
    jr .sclDiv
.sclDivDone:
    ; a = new_degree, d = extra_oct from wrapping

    ; ScaleTable lookup: bank * 10 + new_degree
    push af
    push de
    ld a, [wPlayingBank]
    ld l, a
    ld h, 0
    add hl, hl              ; bank*2
    ld d, h
    ld e, l                 ; de = bank*2
    add hl, hl              ; bank*4
    add hl, hl              ; bank*8
    add hl, de              ; bank*10
    ld de, ScaleTable
    add hl, de
    pop de
    pop af
    add l
    ld l, a
    jr nc, .ncST1
    inc h
.ncST1:
    ld a, [hl]              ; semitone offset from scale

    ; absolute_note = rootNote + semitone_offset
    ld e, a
    ld a, [wRootNote]
    add e

    ; note_in_octave = absolute_note % 12, extra_octaves = absolute_note / 12
    ld e, 0
.sclDiv12:
    cp 12
    jr c, .sclDiv12Done
    sub 12
    inc e
    jr .sclDiv12
.sclDiv12Done:
    ; a = note_in_octave, e = extra_octaves, d = extra_oct from wrapping
    push af

    ; final_octave = rootOctave + extra_octaves + hArpOctave + extra_oct
    ld a, [wRootOctave]
    add e
    add d
    push af
    ldh a, [hArpOctave]
    ld e, a
    pop af
    add e

    ; Check bounds
    cp 5
    jr c, .sclOctOk
    ; Out of range — silence
    pop af
    jp SilenceCH1
.sclOctOk:
    ; freq_index = final_octave * 12 + note_in_octave
    ld d, a
    add a
    add d                   ; a = octave * 3
    add a
    add a                   ; a = octave * 12
    pop de                  ; d = note_in_octave
    add d

    ; Bounds check
    cp 60
    jr c, .sclInRange
    jp SilenceCH1
.sclInRange:
    ; FreqTable lookup
    add a                   ; byte offset = index * 2
    ld hl, FreqTable
    add l
    ld l, a
    jr nc, .ncSF
    inc h
.ncSF:
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld e, a
    jp WriteCH1Freq

; =============================================================================
; Advance Arp Position
; =============================================================================

AdvanceArp:
    ld a, [wPatternType]
    and a
    jr z, .ascending
    cp PAT_DESCENDING
    jr z, .descending
    cp PAT_PINGPONG
    jr z, .pingpong
    jr .random

.ascending:
    ld a, [wArpPosition]
    inc a
    ld d, a
    ld a, [wNoteCount]
    cp d
    jr nz, .ascOk
    ld d, 0
    ld a, 1                 ; ASC wrap → cycle start
    ldh [hAccentPending], a
    ldh [hCycleReset], a
.ascOk:
    ld a, d
    ld [wArpPosition], a
    ret

.descending:
    ld a, [wArpPosition]
    and a
    jr z, .descWrap
    dec a
    ld [wArpPosition], a
    ret
.descWrap:
    ld a, [wNoteCount]
    dec a
    ld [wArpPosition], a
    ld a, 1                 ; DESC wrap → cycle start
    ldh [hAccentPending], a
    ldh [hCycleReset], a
    ret

.pingpong:
    ld a, [wArpDirection]
    and a
    jr nz, .ppDown

    ; Going up
    ld a, [wArpPosition]
    inc a
    ld d, a
    ld a, [wNoteCount]
    dec a
    cp d
    jr nc, .ppUpOk
    ; Hit top — reverse
    ld a, 1
    ld [wArpDirection], a
    ld a, [wArpPosition]
    dec a
    ld [wArpPosition], a
    ld a, 1                 ; PINGPONG top reversal → cycle start
    ldh [hAccentPending], a
    ldh [hCycleReset], a
    ret
.ppUpOk:
    ld a, d
    ld [wArpPosition], a
    ret

.ppDown:
    ld a, [wArpPosition]
    and a
    jr z, .ppHitBottom
    dec a
    ld [wArpPosition], a
    ret
.ppHitBottom:
    xor a
    ld [wArpDirection], a
    ld a, 1
    ld [wArpPosition], a
    ldh [hAccentPending], a ; PINGPONG bottom reversal → cycle start
    ldh [hCycleReset], a
    ret

.random:
    ; Note: no accent — random pattern has no natural cycle boundary.
    ; Probabilistic / periodic drum hits are the job of #6 (Euclidean).
    ld a, [wRngState]
    srl a
    jr nc, .noTap
    xor $B4
.noTap:
    ld [wRngState], a

    ; a mod noteCount
    ld d, a
    ld a, [wNoteCount]
    ld e, a
    ld a, d
.modLoop:
    cp e
    jr c, .modDone
    sub e
    jr .modLoop
.modDone:
    ld [wArpPosition], a
    ret

; =============================================================================
; Update HUD (called during VBlank)
; =============================================================================

UpdateHUD:
    ; --- Help row first ---
    ; V26.3: paint row 17 at the very start of UpdateHUD, while the VBlank
    ; window is freshest. The EUCLID page's per-frame work (visualizer,
    ; modifier indicators, value writes) was eating enough VBlank time that
    ; HelpRowTick — previously called as a tail-jp at the end — could land
    ; in MODE 3 and lose VRAM writes, causing tooltip rendering to look
    ; partial / stale. Calling it first guarantees row 17 lands in VBlank.
    call HelpRowTick
    call CH3ShapeTick           ; advance NR32 volume shape engine each frame

    ; --- Rows 0/1 (group/mode/note/octave) only on page 0 ---
    ; On pages 1..5 these rows hold a static title bar painted by DoPageRedraw,
    ; so don't overwrite them every VBlank.
    ld a, [wCurrentPage]
    and a
    jp nz, .afterMainHud

    ; --- Group-Index division ---
    ld a, [wCurrentBank]
    ld d, 0
.grpDiv:
    cp GROUP_SIZE
    jr c, .grpDone
    sub GROUP_SIZE
    inc d
    jr .grpDiv
.grpDone:
    ; d = group (0-2), a = index within group (0-6)
    inc a
    ld e, a             ; e = index+1 (1-7)

    ; --- Group name (row 0, 20 tiles) ---
    push de
    ld a, d
    ld hl, GroupNames
    ; d × 20: d×16 + d×4
    swap a              ; a = d × 16
    ld b, a
    ld a, d
    add a
    add a               ; a = d × 4
    add b               ; a = d × 20
    add l
    ld l, a
    jr nc, .ncGN
    inc h
.ncGN:
    ld de, $9800
    ld b, 20
.groupName:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .groupName
    pop de

    ; --- Group-Index display (row 1, cols 0-2: "G-N") ---
    ld a, d
    inc a
    add TILE_DIGIT0
    ld [$9820], a
    ld a, TILE_DASH
    ld [$9821], a
    ld a, e
    add TILE_DIGIT0
    ld [$9822], a

    ; --- Mode name (row 1, cols 3-12, 10 tiles) ---
    ld a, [wCurrentBank]
    ld l, a
    ld h, 0              ; hl = bank
    add hl, hl           ; hl = bank*2
    ld d, h
    ld e, l              ; de = bank*2
    add hl, hl           ; hl = bank*4
    add hl, hl           ; hl = bank*8
    add hl, de           ; hl = bank*10
    ld de, ModeNames
    add hl, de           ; hl = &ModeNames[bank*10]
    ld de, $9823
    ld b, 10
.modeName:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .modeName

    ; --- Note name (row 1, cols 14-15) ---
    ld a, [wRootNote]
    add a
    ld hl, NoteNames
    add l
    ld l, a
    jr nc, .nc4
    inc h
.nc4:
    ld a, [hli]
    ld [$982E], a
    ld a, [hl]
    ld [$982F], a

    ; --- Octave digit (row 1, col 16) ---
    ld a, [wRootOctave]
    add 2
    add TILE_DIGIT0
    ld [$9830], a

    ; --- Page indicator on row 0 cols 16-19 ("1/10", inverted tiles) ---
    ; Four inverted tiles render as white-on-black pill in the top-right,
    ; matching the title-bar styling of pages 2-10. Overwrites GroupNames
    ; right padding (cols 16-19 are blank in every group entry; group 1
    ; "HARMONIC MINOR" was shifted left one col to free col 16).
    ld a, INV_TILE_DIGIT0 + 1
    ld [$9810], a
    ld a, INV_TILE_SLASH
    ld [$9811], a
    ld a, INV_TILE_DIGIT0 + 1
    ld [$9812], a
    ld a, INV_TILE_DIGIT0
    ld [$9813], a

.afterMainHud:
    ; --- Pattern indicator (row 4, cols 17-19) — skip on page 2 ---
    ld a, [wCurrentPage]
    and a
    jr nz, .patDone
    ld a, [wPatternType]
    cp PAT_RANDOM
    jr z, .patRandom
    ld d, a
    ld a, TILE_BLANK
    ld [$9891], a
    ld [$9892], a
    ld a, d
    add TILE_UP_ARROW
    ld [$9893], a
    jr .patDone
.patRandom:
    ld a, TILE_R
    ld [$9891], a
    ld a, TILE_A
    ld [$9892], a
    ld a, TILE_N
    ld [$9893], a
.patDone:

    ; --- Row 6-7 values (page-dependent) ---
    ld a, [wCurrentPage]
    and a
    jr nz, .notPage1Values
    jp .page1Values
.notPage1Values:
    cp 1
    jr z, .page2Values
    cp 2
    jp z, .page3Values
    cp 3
    jp z, .page4Values
    cp 4
    jp z, .page5Values
    cp 5
    jp z, .page6Values
    cp 6
    jp z, .page7Values
    cp 7
    jp z, .page8Values
    cp 8
    jp z, .mixerPageValues
    jp .page9Values             ; page 9 (CONTROLS): no dynamic values

.page2Values:
    ; Page 2: CH1 Mode (row 6), sub-param (row 7), volume (row 8), attack (row 9)

    ; Row 6, cols 17-19: mode name (read pending for preview while A held)
    ld a, [wCH1ModePending]
    ld d, a
    add a
    add d                   ; a = mode * 3
    ld hl, CH1Names
    add l
    ld l, a
    jr nc, .ncCH
    inc h
.ncCH:
    ld a, [hli]
    ld [$98D1], a
    ld a, [hli]
    ld [$98D2], a
    ld a, [hl]
    ld [$98D3], a

    ; Row 7: dynamic sub-param label + value (read pending so row tracks preview while A held)
    ld a, [wCH1ModePending]
    cp 3
    jr z, .p2SubDET
    cp 4
    jr z, .p2SubINT
    cp 5
    jr z, .p2SubSCL
    ; OFF/OC+/OC-: blank row 7 (label + value area)
    ld hl, $98E1
    ld b, 13
.p2BlankLabel:
    ld [hl], TILE_BLANK
    inc hl
    dec b
    jr nz, .p2BlankLabel
    ld a, TILE_BLANK
    ld [$98F1], a
    ld [$98F2], a
    ld [$98F3], a
    jr .p2Row8

.p2SubDET:
    ld hl, SubLabel_DET
    call .p2WriteLabel
    ld a, TILE_BLANK
    ld [$98F1], a
    ld [$98F2], a
    ld a, [wCH1DetunePending]
    inc a                   ; display as 1-5
    add TILE_DIGIT0
    ld [$98F3], a
    jr .p2Row8

.p2SubINT:
    ld hl, SubLabel_INT
    call .p2WriteLabel
    ; Table lookup: wCH1IntervalPending (0-18) → 3 tile interval name
    ld a, [wCH1IntervalPending]
    ld d, a
    add a           ; ×2
    add d           ; ×3 (3 tiles per entry)
    ld hl, CH1IntNames
    add l
    ld l, a
    jr nc, .ncIntN
    inc h
.ncIntN:
    ld a, [hli]
    ld [$98F1], a
    ld a, [hli]
    ld [$98F2], a
    ld a, [hl]
    ld [$98F3], a
    jr .p2Row8

.p2SubSCL:
    ld hl, SubLabel_SCL
    call .p2WriteLabel
    ld a, TILE_BLANK
    ld [$98F1], a
    ld [$98F2], a
    ld a, [wCH1ScaleDegPending]
    inc a                   ; display as 1-7
    add TILE_DIGIT0
    ld [$98F3], a
    jr .p2Row8

.p2WriteLabel:
    ; Copy 13 tiles from HL to row 7 ($98E1)
    ld de, $98E1
    ld b, 13
.p2WL:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .p2WL
    ret

.p2Row8:
    ; Row 8, cols 17-19: volume digit
    ld a, TILE_BLANK
    ld [$9911], a
    ld [$9912], a
    ld a, [wCH1Volume]
    add TILE_DIGIT0
    ld [$9913], a

    ; Row 9, cols 17-19: attack OFF/SAM/IND
    ld a, [wCH1Attack]
    ld d, a
    add a
    add d                   ; a = atk * 3
    ld hl, CH1AtkNames
    add l
    ld l, a
    jr nc, .ncAtk
    inc h
.ncAtk:
    ld a, [hli]
    ld [$9931], a
    ld a, [hli]
    ld [$9932], a
    ld a, [hl]
    ld [$9933], a

    ; Row 10: IATK sub-param (only shown when INDP)
    ld a, [wCH1Attack]
    cp 2
    jr nz, .blankRow10
    ; Write SubLabel_IATK (13 tiles) to $9941
    ld hl, SubLabel_IATK
    ld de, $9941
    ld b, 13
.copyIATK:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .copyIATK
    ; Write value at $9951-$9953
    ld a, TILE_BLANK
    ld [$9951], a
    ld [$9952], a
    ld a, [wCH1AtkType]
    add TILE_DIGIT0         ; wCH1AtkType is 1-3, no +1 needed
    ld [$9953], a
    ; Row 11: CH1 wave name (3 tiles)
    ld a, [wCH1Wave]
    ld d, a
    add a           ; ×2
    add d           ; ×3 (3 tiles per entry)
    ld hl, CH1WaveNames
    add l
    ld l, a
    jr nc, .ncCH1WN
    inc h
.ncCH1WN:
    ld a, [hli]
    ld [$9971], a
    ld a, [hli]
    ld [$9972], a
    ld a, [hl]
    ld [$9973], a
    ; Row 12, cols 17-19: offset name
    ld a, [wCH1Offset]
    ld d, a
    add a
    add d                   ; a = offset * 3
    ld hl, CH1OffsetNames
    add l
    ld l, a
    jr nc, .ncOffA
    inc h
.ncOffA:
    ld a, [hli]
    ld [$9991], a
    ld a, [hli]
    ld [$9992], a
    ld a, [hl]
    ld [$9993], a
    jp .valueDone
.blankRow10:
    ; Blank row 10 label ($9941-$994D) and value ($9951-$9953)
    ld hl, $9941
    ld a, TILE_BLANK
    ld b, 13
.blankIATK:
    ld [hli], a
    dec b
    jr nz, .blankIATK
    ld [$9951], a
    ld [$9952], a
    ld [$9953], a
    ; Row 11: CH1 wave name
    ld a, [wCH1Wave]
    ld d, a
    add a           ; ×2
    add d           ; ×3 (3 tiles per entry)
    ld hl, CH1WaveNames
    add l
    ld l, a
    jr nc, .ncWNb
    inc h
.ncWNb:
    ld a, [hli]
    ld [$9971], a
    ld a, [hli]
    ld [$9972], a
    ld a, [hl]
    ld [$9973], a
    ; Row 12, cols 17-19: offset name
    ld a, [wCH1Offset]
    ld d, a
    add a
    add d                   ; a = offset * 3
    ld hl, CH1OffsetNames
    add l
    ld l, a
    jr nc, .ncOffB
    inc h
.ncOffB:
    ld a, [hli]
    ld [$9991], a
    ld a, [hli]
    ld [$9992], a
    ld a, [hl]
    ld [$9993], a
    jp .valueDone

.page3Values:
    ; Page 3: BPM (row 6, cols 17-19) or dashes
    ld a, [wTapFrames]
    and a
    jr z, .noTapDisplay
    call .displayBPM
    jr .showSubdiv
.noTapDisplay:
    ld a, TILE_DASH
    ld [$98D1], a
    ld [$98D2], a
    ld [$98D3], a
.showSubdiv:
    ; Row 7: subdivision digit at col 19
    ld a, TILE_BLANK
    ld [$98F1], a
    ld [$98F2], a
    ld a, [wTapSubdiv]
    add TILE_DIGIT0
    ld [$98F3], a
    ; Row 8: swing digit at cols 17-19
    ld a, TILE_BLANK
    ld [$9911], a
    ld [$9912], a
    ld a, [wSwing]
    add TILE_DIGIT0
    ld [$9913], a
    jp .valueDone

.page4Values:
    ; Page 4: CH3 Mode (row 6), Wave (row 7), Volume (row 8), Shape (row 9), Rate (row 10)
    ; Row 6, cols 17-19: mode name
    ld a, [wCH3Mode]
    ld d, a
    add a
    add d                   ; a = mode * 3
    ld hl, CH3ModeNames
    add l
    ld l, a
    jr nc, .ncCH3M
    inc h
.ncCH3M:
    ld a, [hli]
    ld [$98D1], a
    ld a, [hli]
    ld [$98D2], a
    ld a, [hl]
    ld [$98D3], a

    ; Row 7, cols 17-19: wave name
    ld a, [wCH3Wave]
    ld d, a
    add a
    add d                   ; a = wave * 3
    ld hl, CH3WaveNames
    add l
    ld l, a
    jr nc, .ncCH3W
    inc h
.ncCH3W:
    ld a, [hli]
    ld [$98F1], a
    ld a, [hli]
    ld [$98F2], a
    ld a, [hl]
    ld [$98F3], a

    ; Row 8, cols 17-19: volume (blank when SHAPE != OFF)
    ld a, [wCH3Shape]
    and a
    jr nz, .p4BlankVol
    ld a, [wCH3Volume]
    ld d, a
    add a
    add d                   ; a = vol * 3
    ld hl, CH3VolNames
    add l
    ld l, a
    jr nc, .ncCH3V
    inc h
.ncCH3V:
    ld a, [hli]
    ld [$9911], a
    ld a, [hli]
    ld [$9912], a
    ld a, [hl]
    ld [$9913], a
    jr .p4Shape
.p4BlankVol:
    ld a, TILE_BLANK
    ld [$9911], a
    ld [$9912], a
    ld [$9913], a

.p4Shape:
    ; Row 9, cols 17-19: shape name
    ld a, [wCH3Shape]
    ld d, a
    add a
    add d                   ; a = shape * 3
    ld hl, CH3ShapeNames
    add l
    ld l, a
    jr nc, .ncCH3S
    inc h
.ncCH3S:
    ld a, [hli]
    ld [$9931], a
    ld a, [hli]
    ld [$9932], a
    ld a, [hl]
    ld [$9933], a

    ; Row 10, cols 17-19: rate digit (blank blank digit)
    ld a, TILE_BLANK
    ld [$9951], a
    ld [$9952], a
    ld a, [wCH3Rate]
    and a
    jr nz, .p4RateNonZero
    ld a, 1                 ; clamp 0 → 1 for display
.p4RateNonZero:
    add TILE_DIGIT0
    ld [$9953], a
    jp .valueDone

.page5Values:
    ; Page 5 (ACCENT) value column: row 6 ACCENT name (cols 17-19)
    ld a, [wNoiseAccent]
    ld d, a
    add a
    add d                   ; a = accent * 3
    ld hl, NoiseAccentNames
    add l
    ld l, a
    jr nc, .ncACC
    inc h
.ncACC:
    ld a, [hli]
    ld [$98D1], a
    ld a, [hli]
    ld [$98D2], a
    ld a, [hl]
    ld [$98D3], a
    jp .valueDone

.page6Values:
    ; Page 6 (FILL) value column across rows 6-10:
    ;   row 6: LEVEL digit
    ;   row 7: COLOR name (HIS/MTL)
    ;   row 8: PITCH digit
    ;   row 9: FREQ digit
    ;   row 10: SHAPE name (FLT/ER↑/ER↓/LR↑/LR↓)

    ; Row 6: LEVEL digit
    ld a, TILE_BLANK
    ld [$98D1], a
    ld [$98D2], a
    ld a, [wFillLevel]
    add TILE_DIGIT0
    ld [$98D3], a

    ; Row 7: COLOR name
    ld a, [wFillColor]
    ld d, a
    add a
    add d                   ; a = color * 3
    ld hl, FillColorNames
    add l
    ld l, a
    jr nc, .ncCOL6
    inc h
.ncCOL6:
    ld a, [hli]
    ld [$98F1], a
    ld a, [hli]
    ld [$98F2], a
    ld a, [hl]
    ld [$98F3], a

    ; Row 8: PITCH digit
    ld a, TILE_BLANK
    ld [$9911], a
    ld [$9912], a
    ld a, [wFillPitch]
    add TILE_DIGIT0
    ld [$9913], a

    ; Row 9: FREQ digit
    ld a, TILE_BLANK
    ld [$9931], a
    ld [$9932], a
    ld a, [wFillFreq]
    add TILE_DIGIT0
    ld [$9933], a

    ; Row 10: SHAPE name
    ld a, [wFillShape]
    ld d, a
    add a
    add d                   ; a = shape * 3
    ld hl, FillShapeNames
    add l
    ld l, a
    jr nc, .ncSHP6
    inc h
.ncSHP6:
    ld a, [hli]
    ld [$9951], a
    ld a, [hli]
    ld [$9952], a
    ld a, [hl]
    ld [$9953], a
    jp .valueDone

.page7Values:
    ; Page 7 (TONAL) value column across rows 6-13:
    ;   row 6: MODE name (OFF/ ON)
    ;   row 7: LEVEL digit
    ;   row 8: MAP name (TRK/GML/INV)
    ;   row 9: WIDTH name (15/ 7B)
    ;   row 10: DECAY name (PNG/RNG/CUT)
    ;   row 11: TRANSP signed (-12..+12, 3 chars)
    ;   row 12: TRIG name (EVR/HLF/ Q4)
    ;   row 13: PRI name (ALL/+AC/+FI/SOL)

    ; Row 6: MODE name
    ld a, [wTonalMode]
    ld d, a
    add a
    add d                       ; a = mode * 3
    ld hl, TonalModeNames
    add l
    ld l, a
    jr nc, .ncTM
    inc h
.ncTM:
    ld a, [hli]
    ld [$98D1], a
    ld a, [hli]
    ld [$98D2], a
    ld a, [hl]
    ld [$98D3], a

    ; Row 7: LEVEL digit (cols 17-19, blanks then digit)
    ld a, TILE_BLANK
    ld [$98F1], a
    ld [$98F2], a
    ld a, [wTonalLevel]
    add TILE_DIGIT0
    ld [$98F3], a

    ; Row 8: MAP name
    ld a, [wTonalMap]
    ld d, a
    add a
    add d
    ld hl, TonalMapNames
    add l
    ld l, a
    jr nc, .ncTMap
    inc h
.ncTMap:
    ld a, [hli]
    ld [$9911], a
    ld a, [hli]
    ld [$9912], a
    ld a, [hl]
    ld [$9913], a

    ; Row 9: WIDTH name
    ld a, [wTonalWidth]
    ld d, a
    add a
    add d
    ld hl, TonalWidthNames
    add l
    ld l, a
    jr nc, .ncTW
    inc h
.ncTW:
    ld a, [hli]
    ld [$9931], a
    ld a, [hli]
    ld [$9932], a
    ld a, [hl]
    ld [$9933], a

    ; Row 10: DECAY name
    ld a, [wTonalDecay]
    ld d, a
    add a
    add d
    ld hl, TonalDecayNames
    add l
    ld l, a
    jr nc, .ncTD
    inc h
.ncTD:
    ld a, [hli]
    ld [$9951], a
    ld a, [hli]
    ld [$9952], a
    ld a, [hl]
    ld [$9953], a

    ; Row 11: TRANSP signed display (-12..+12 from 0..24)
    ; cols 17-19: [sign or blank][tens][ones], with TILE_DASH/TILE_PLUS/TILE_BLANK as sign
    ld a, [wTonalTransp]
    sub 12                      ; signed semitone offset; carry set if negative
    jr c, .negTransp
    jr z, .zeroTransp
    ; positive: +N
    ld d, a                     ; d = magnitude (1..12)
    ld a, TILE_PLUS
    ld [$9971], a
    jr .splitTransp
.zeroTransp:
    ld d, 0
    ld a, TILE_BLANK
    ld [$9971], a
    jr .splitTransp
.negTransp:
    ; a is two's-complement negative; negate to get magnitude
    cpl
    inc a
    ld d, a
    ld a, TILE_DASH
    ld [$9971], a
.splitTransp:
    ; d holds magnitude 0..12; split into tens/ones
    ld a, d
    ld e, 0
.transpTens:
    cp 10
    jr c, .transpDone
    sub 10
    inc e
    jr .transpTens
.transpDone:
    push af
    ld a, e
    add TILE_DIGIT0
    ld [$9972], a
    pop af
    add TILE_DIGIT0
    ld [$9973], a

    ; Row 12: TRIG name
    ld a, [wTonalTrig]
    ld d, a
    add a
    add d
    ld hl, TonalTrigNames
    add l
    ld l, a
    jr nc, .ncTT
    inc h
.ncTT:
    ld a, [hli]
    ld [$9991], a
    ld a, [hli]
    ld [$9992], a
    ld a, [hl]
    ld [$9993], a

    ; Row 13: PRI name
    ld a, [wTonalPri]
    ld d, a
    add a
    add d
    ld hl, TonalPriNames
    add l
    ld l, a
    jr nc, .ncTP
    inc h
.ncTP:
    ld a, [hli]
    ld [$99B1], a
    ld a, [hli]
    ld [$99B2], a
    ld a, [hl]
    ld [$99B3], a

    ; Row 14: full-row paint — inverted when LOK on, normal when FRE.
    ; Writes all 20 cols every frame so LOK toggle takes effect immediately
    ; without requiring a page-reload (ControlsTonalPage entry is one-shot).
    ld a, [wTonalLock]
    and a
    jr nz, .lockRowInv

    ; --- Normal (FRE) ---
    ld hl, $99C0
    ld a, TILE_BLANK
    ld [hli], a                ; col 0
    ld a, TILE_L
    ld [hli], a                ; col 1
    ld a, TILE_O
    ld [hli], a
    ld a, TILE_C
    ld [hli], a
    ld a, TILE_K
    ld [hli], a                ; col 4
    ld a, TILE_BLANK
    REPT 6
    ld [hli], a                ; cols 5-10
    ENDR
    ld a, TILE_UP_ARROW
    ld [hli], a                ; col 11
    ld a, TILE_DN_ARROW
    ld [hli], a                ; col 12
    ld a, TILE_BLANK
    REPT 4
    ld [hli], a                ; cols 13-16
    ENDR
    ld de, TonalLockNames      ; idx 0 → FRE
    jr .lockRowValue

.lockRowInv:
    ; --- Inverted (LOK) ---
    ld hl, $99C0
    ld a, INV_TILE_BLANK
    ld [hli], a                ; col 0
    ld a, INV_TILE_L
    ld [hli], a
    ld a, INV_TILE_O
    ld [hli], a
    ld a, INV_TILE_C
    ld [hli], a
    ld a, INV_TILE_K
    ld [hli], a                ; col 4
    ld a, INV_TILE_BLANK
    REPT 6
    ld [hli], a                ; cols 5-10
    ENDR
    ld a, INV_TILE_UP_ARROW
    ld [hli], a                ; col 11
    ld a, INV_TILE_DN_ARROW
    ld [hli], a                ; col 12
    ld a, INV_TILE_BLANK
    REPT 4
    ld [hli], a                ; cols 13-16
    ENDR
    ld de, TonalLockNamesInv + 3  ; idx 1 → LOK inverted
.lockRowValue:
    ld a, [de]
    ld [hli], a                ; col 17
    inc de
    ld a, [de]
    ld [hli], a                ; col 18
    inc de
    ld a, [de]
    ld [hli], a                ; col 19
    jp .valueDone

.page8Values:
    ; Page 8 (EUCLID KICK) values column at cols 17-19, one parameter per row.
    ; Layout (V27): rows grouped by modifier — A, A, B, B, AB, AB, plain.
    ;   row 5:  pattern visualizer (16 tiles, blitted from wEuclidVisBuf by BlitEuclidVis)
    ;   row 6:  HITS   (2 digits at cols 18-19, blank at 17)         A+UD
    ;   row 7:  LEN    (2 digits)                                    A+LR
    ;   row 8:  LEVEL  (1 digit at col 19, blanks at 17-18)          B+LR
    ;   row 9:  PITCH  (sign + 2 digits at cols 17-19)               B+UD
    ;   row 10: SOUND  name (3 tiles at cols 17-19)                  AB+UD
    ;   row 11: DECAY  name (3 tiles)                                AB+LR
    ;   row 12: ROT    (2 digits at cols 18-19, blank at 17)         plain LR
    ; V37: blit the pre-computed shadow buffer into VRAM. ~180 cycles — fits VBlank
    ; with margin now that the 16-iteration compute is gone from the hot path.
    ld a, [wEuclidVisReady]
    and a
    jr z, .skipVis
    call BlitEuclidVis
    xor a
    ld [wEuclidVisReady], a
.skipVis:
    ; Branch to MOD view if active
    ld a, [wEucModView]
    and a
    jp nz, .page8ModValues

    ; Row 6 cols 17-19: HITS value
    ld a, [wEuclidKickK]
    call .euclTwoDigits
    ld a, TILE_BLANK
    ld [$98D1], a
    ld a, b
    ld [$98D2], a
    ld a, c
    ld [$98D3], a

    ; Row 7 cols 17-19: LEN value
    ld a, [wEuclidKickN]
    call .euclTwoDigits
    ld a, TILE_BLANK
    ld [$98F1], a
    ld a, b
    ld [$98F2], a
    ld a, c
    ld [$98F3], a

    ; Row 8 col 19: LEVEL digit (1 digit, blanks at 17-18)
    ld a, TILE_BLANK
    ld [$9911], a
    ld [$9912], a
    ld a, [wEuclidKickLevel]
    add TILE_DIGIT0
    ld [$9913], a

    ; Row 9 cols 17-19: PITCH signed display (-32..+31 from 0..63, neutral=32)
    ; Format: [sign][tens][ones], always shows literal '+' or '-' (zero is "+00").
    ld a, [wEuclidKickPitch]
    sub EUCLID_PITCH_NEUTRAL    ; signed offset; carry set if negative
    jr nc, .pitchNonNeg
    ; negative: sign='-', magnitude = -a
    cpl
    inc a
    ld d, a
    ld a, TILE_DASH
    ld [$9931], a
    jr .pitchSplit
.pitchNonNeg:
    ; zero or positive: sign='+', magnitude = a
    ld d, a
    ld a, TILE_PLUS
    ld [$9931], a
.pitchSplit:
    ; d = magnitude 0..32; render as two digits with leading zero kept.
    ld a, d
    ld e, 0
.pitchTens:
    cp 10
    jr c, .pitchTensDone
    sub 10
    inc e
    jr .pitchTens
.pitchTensDone:
    push af
    ld a, e
    add TILE_DIGIT0
    ld [$9932], a
    pop af
    add TILE_DIGIT0
    ld [$9933], a

    ; Row 10 cols 17-19: SOUND name (3 tiles)
    ld a, [wEuclidKickSound]
    ld d, a
    add a
    add d                       ; a = sound * 3
    ld hl, EuclidKickSoundNames
    add l
    ld l, a
    jr nc, .ncES
    inc h
.ncES:
    ld a, [hli]
    ld [$9951], a
    ld a, [hli]
    ld [$9952], a
    ld a, [hl]
    ld [$9953], a

    ; Row 11 cols 17-19: DECAY name (3 tiles)
    ld a, [wEuclidKickDecay]
    ld d, a
    add a
    add d
    ld hl, EuclidKickDecayNames
    add l
    ld l, a
    jr nc, .ncED
    inc h
.ncED:
    ld a, [hli]
    ld [$9971], a
    ld a, [hli]
    ld [$9972], a
    ld a, [hl]
    ld [$9973], a

    ; Row 12 cols 17-19: ROT value
    ld a, [wEuclidKickRot]
    call .euclTwoDigits
    ld a, TILE_BLANK
    ld [$9991], a
    ld a, b
    ld [$9992], a
    ld a, c
    ld [$9993], a

    ; Row 13 cols 17-19: LOCK value (FRE/LOK via TonalLockNames)
    ld a, [wEuclidKickLock]
    ld d, a
    add a
    add d                        ; a = lock * 3
    ld hl, TonalLockNames
    add l
    ld l, a
    jr nc, .ncEKL
    inc h
.ncEKL:
    ld a, [hli]
    ld [$99B1], a
    ld a, [hli]
    ld [$99B2], a
    ld a, [hl]
    ld [$99B3], a
    jp .valueDone

.page8ModValues:
    ; MOD view: render LFO param values (rows 6-11, cols 17-19).
    ; Row 6: P.SHAPE name
    ld a, [wEucPLfoShape]
    ld d, a
    add a
    add d
    ld hl, EucLfoShapeNames
    add l
    ld l, a
    jr nc, .ncMPS
    inc h
.ncMPS:
    ld a, [hli]
    ld [$98D1], a
    ld a, [hli]
    ld [$98D2], a
    ld a, [hl]
    ld [$98D3], a

    ; Row 7: P.RATE name
    ld a, [wEucPLfoRate]
    ld d, a
    add a
    add d
    ld hl, EucLfoRateNames
    add l
    ld l, a
    jr nc, .ncMPR
    inc h
.ncMPR:
    ld a, [hli]
    ld [$98F1], a
    ld a, [hli]
    ld [$98F2], a
    ld a, [hl]
    ld [$98F3], a

    ; Row 8: V.SHAPE name
    ld a, [wEucVLfoShape]
    ld d, a
    add a
    add d
    ld hl, EucLfoShapeNames
    add l
    ld l, a
    jr nc, .ncMVS
    inc h
.ncMVS:
    ld a, [hli]
    ld [$9911], a
    ld a, [hli]
    ld [$9912], a
    ld a, [hl]
    ld [$9913], a

    ; Row 9: V.RATE name
    ld a, [wEucVLfoRate]
    ld d, a
    add a
    add d
    ld hl, EucLfoRateNames
    add l
    ld l, a
    jr nc, .ncMVR
    inc h
.ncMVR:
    ld a, [hli]
    ld [$9931], a
    ld a, [hli]
    ld [$9932], a
    ld a, [hl]
    ld [$9933], a

    ; Row 10: P.DEPTH (0..15, two digits)
    ld a, [wEucPLfoDepth]
    call .euclTwoDigits
    ld a, TILE_BLANK
    ld [$9951], a
    ld a, b
    ld [$9952], a
    ld a, c
    ld [$9953], a

    ; Row 11: V.DEPTH (0..7, single digit)
    ld a, TILE_BLANK
    ld [$9971], a
    ld [$9972], a
    ld a, [wEucVLfoDepth]
    add TILE_DIGIT0
    ld [$9973], a

    jp .valueDone

.euclTwoDigits:
    ; Input: a = 0..16. Output: b = tens tile (or BLANK), c = ones tile.
    ld d, 0
.euclTensLoop:
    cp 10
    jr c, .euclTensDone
    sub 10
    inc d
    jr .euclTensLoop
.euclTensDone:
    add TILE_DIGIT0
    ld c, a                     ; c = ones tile
    ld a, d
    and a
    jr nz, .euclTensSet
    ld b, TILE_BLANK
    ret
.euclTensSet:
    add TILE_DIGIT0
    ld b, a
    ret

.mixerPageValues:
    ; Page 8 (MIXER): ON/MUT at cols 17-19 for each voice row (rows 6-10).
    ; Row 6 col 17 = $98D1 (CH1), Row 7 = $98F1 (CH2), Row 8 = $9911 (CH3),
    ; Row 9 = $9931 (CH4), Row 10 = $9951 (EUC).
    ; Writes 3 tiles per row: "ON " or "MUT" depending on mute state.

    ; CH1 (row 6)
    ld a, [wMuteCH1]
    and a
    jr z, .mixCH1On
    ld a, TILE_M
    ld [$98D1], a
    ld a, TILE_U
    ld [$98D2], a
    ld a, TILE_T
    ld [$98D3], a
    jr .mixCH1Done
.mixCH1On:
    ld a, TILE_O
    ld [$98D1], a
    ld a, TILE_N
    ld [$98D2], a
    ld a, TILE_BLANK
    ld [$98D3], a
.mixCH1Done:

    ; CH2 (row 7)
    ld a, [wMuteCH2]
    and a
    jr z, .mixCH2On
    ld a, TILE_M
    ld [$98F1], a
    ld a, TILE_U
    ld [$98F2], a
    ld a, TILE_T
    ld [$98F3], a
    jr .mixCH2Done
.mixCH2On:
    ld a, TILE_O
    ld [$98F1], a
    ld a, TILE_N
    ld [$98F2], a
    ld a, TILE_BLANK
    ld [$98F3], a
.mixCH2Done:

    ; CH3 (row 8)
    ld a, [wMuteCH3]
    and a
    jr z, .mixCH3On
    ld a, TILE_M
    ld [$9911], a
    ld a, TILE_U
    ld [$9912], a
    ld a, TILE_T
    ld [$9913], a
    jr .mixCH3Done
.mixCH3On:
    ld a, TILE_O
    ld [$9911], a
    ld a, TILE_N
    ld [$9912], a
    ld a, TILE_BLANK
    ld [$9913], a
.mixCH3Done:

    ; CH4 (row 9)
    ld a, [wMuteCH4]
    and a
    jr z, .mixCH4On
    ld a, TILE_M
    ld [$9931], a
    ld a, TILE_U
    ld [$9932], a
    ld a, TILE_T
    ld [$9933], a
    jr .mixCH4Done
.mixCH4On:
    ld a, TILE_O
    ld [$9931], a
    ld a, TILE_N
    ld [$9932], a
    ld a, TILE_BLANK
    ld [$9933], a
.mixCH4Done:

    ; EUC (row 10)
    ld a, [wMuteEuc]
    and a
    jr z, .mixEucOn
    ld a, TILE_M
    ld [$9951], a
    ld a, TILE_U
    ld [$9952], a
    ld a, TILE_T
    ld [$9953], a
    jp .valueDone
.mixEucOn:
    ld a, TILE_O
    ld [$9951], a
    ld a, TILE_N
    ld [$9952], a
    ld a, TILE_BLANK
    ld [$9953], a
    jp .valueDone

.page9Values:
    ; Page 9 (CONTROLS): no dynamic values, fall through to valueDone
    jp .valueDone

.page1Values:
    ; Page 1: Speed (row 6, cols 17-19) + Gate (row 7, cols 17-19)
    ld a, [wTapFrames]
    and a
    jr nz, .tapSpeedP1
    ; Normal: blank col 17, 2-digit display at cols 18-19
    ld a, TILE_BLANK
    ld [$98D1], a
    ld a, [wSpeed]
    ld b, a
    ld a, 32
    sub b
    ld d, 0
.tens:
    cp 10
    jr c, .tensDone
    sub 10
    inc d
    jr .tens
.tensDone:
    ld e, a
    ld a, d
    add TILE_DIGIT0
    ld [$98D2], a
    ld a, e
    add TILE_DIGIT0
    ld [$98D3], a
    jr .speedDone
.tapSpeedP1:
    ; BPM at cols 17-19
    call .displayBPM
.speedDone:

    ; Gate name (3 tiles at row 7, cols 17-19)
    ld a, [wGateLength]
    ld d, a
    add a
    add d                   ; a = gate * 3
    ld hl, GateNames
    add l
    ld l, a
    jr nc, .ncGT
    inc h
.ncGT:
    ld a, [hli]
    ld [$98F1], a
    ld a, [hli]
    ld [$98F2], a
    ld a, [hl]
    ld [$98F3], a
    jp .valueDone

; Subroutine: paint cached BPM tiles at $98D1-$98D3.
; Digits are precomputed by ComputeTapEffective into wTapBpmTiles.
.displayBPM:
    ld a, [wTapFrames]
    or a
    ret z
    ld a, [wTapBpmTiles]
    ld [$98D1], a
    ld a, [wTapBpmTiles+1]
    ld [$98D2], a
    ld a, [wTapBpmTiles+2]
    ld [$98D3], a
    ret

.valueDone:

    ; --- Rows 8-13 values — skip on page 2 ---
    ld a, [wCurrentPage]
    and a
    jr nz, .skipPage1Values

    ; --- Octave value (row 8, cols 17-19) ---
    ld a, TILE_BLANK
    ld [$9911], a
    ld [$9912], a
    ld a, [wRootOctave]
    add 2
    add TILE_DIGIT0
    ld [$9913], a

    ; --- Attack digit (row 10, col 19) ---
    ld a, [wAttackSpeed]
    add TILE_DIGIT0
    ld [$9953], a

    ; --- Stride digit (row 11, col 19) ---
    ld a, [wStride]
    add TILE_DIGIT0
    ld [$9973], a

    ; --- Range digit (row 12, col 19) ---
    ld a, [wOctaveRange]
    add TILE_DIGIT0
    ld [$9993], a

    ; --- Waveform name (row 13, cols 17-19) ---
    ld a, [wDutyCycle]
    ld d, a
    add a
    add d
    ld hl, WaveNames
    add l
    ld l, a
    jr nc, .ncWN
    inc h
.ncWN:
    ld a, [hli]
    ld [$99B1], a
    ld a, [hli]
    ld [$99B2], a
    ld a, [hl]
    ld [$99B3], a

.skipPage1Values:

    ; --- Modifier indicators (col 0, rows 6-13) ---
    ld a, [wPrevButtons]
    ld b, a

    ; A held (not AB)? → indicator tile in c
    bit 4, b
    jr z, .noAInd
    bit 5, b
    jr nz, .noAInd
    ld a, TILE_PLAY
    jr .haveAInd
.noAInd:
    ld a, TILE_BLANK
.haveAInd:
    ld c, a                 ; save indicator tile
    ; Page-aware A row writes:
    ;   page 2 (TIMING): rows 7 + 8
    ;   page 4 (ACCENT): row 6 only
    ;   page 5 (FILL):   row 6 only
    ;   else (0,1,3):    rows 6 + 7
    ld a, [wCurrentPage]
    cp 2
    jr z, .aPage2Rows
    cp 4
    jr z, .aRow6Only
    cp 5
    jr z, .aRow6Only
    cp 8
    jr z, .aIndDone             ; MIXER: single-tap toggles, no A-modifier
    cp 9
    jr z, .aIndDone             ; CONTROLS: A indicator handled in controlsPageInd
    ; Pages 0, 1, 3, 6, 7: A on rows 6 and 7
    ld a, c
    ld [$98C0], a
    ld [$98E0], a
    jr .aIndDone
.aPage2Rows:
    ; Page 2: A on rows 7 and 8 (SWING is A+LR on row 8)
    ld a, TILE_BLANK
    ld [$98C0], a
    ld a, c
    ld [$98E0], a
    ld [$9900], a
    jr .aIndDone
.aRow6Only:
    ; Pages 4, 5: A on row 6, blank row 7 (so B/AB on FILL can claim it)
    ld a, c
    ld [$98C0], a
    ld a, TILE_BLANK
    ld [$98E0], a
.aIndDone:

    ; B/AB/START indicators — page-dependent
    ld a, [wCurrentPage]
    and a
    jp z, .showAllIndicators
    cp 1
    jr z, .page2BInd        ; Page 2: B at rows 8-9
    cp 3
    jr z, .page4BInd        ; Page 4 (1-indexed) = WAVE
    cp 5
    jp z, .fillPageInd      ; Page 6 (1-indexed) = FILL
    cp 6
    jp z, .showAllIndicators ; Page 7 (TONAL): A/B/AB/ST all in use, two rows each
    cp 7
    jp z, .euclidPageInd     ; Page 8 (EUCLID): B → row 9, AB → rows 10+11
    cp 8
    jp z, .doneIndicators    ; Page 9 (MIXER): single-tap, no B/AB indicators
    cp 9
    jp z, .controlsPageInd   ; Page 10 (CONTROLS): A → SAVE row, B → LOAD row
    jp .doneIndicators       ; Page 3 (TIMING) and Page 5 (ACCENT): A only

.page2BInd:
    ; Page 2: B held (not AB)? → rows 8-9
    ld a, b
    and %00110000
    cp %00100000
    jr nz, .noBIndP2
    ld a, TILE_PLAY
    jr .writeBP2
.noBIndP2:
    ld a, TILE_BLANK
.writeBP2:
    ld [$9900], a
    ld [$9920], a
    ; AB held AND wCH1Attack == 2 (INDP)? → row 10
    ld a, b
    and %00110000
    cp %00110000
    jr nz, .p2NoAB
    ld a, [wCH1Attack]
    cp 2
    jr nz, .p2NoAB
    ld a, TILE_PLAY
    jr .p2WriteAB
.p2NoAB:
    ld a, TILE_BLANK
.p2WriteAB:
    ld [$9940], a
    ; START held? → row 11 col 0 ($9960)
    bit 7, b
    jr z, .p2NoStartInd
    ld a, TILE_PLAY
    jr .p2WriteStartInd
.p2NoStartInd:
    ld a, TILE_BLANK
.p2WriteStartInd:
    ld [$9960], a
    ; AB held? → row 12 col 0 ($9980) for OFFSET (V34.0, always active)
    ld a, b
    and %00110000
    cp %00110000
    jr nz, .p2NoAbOff
    ld a, TILE_PLAY
    jr .p2WriteAbOff
.p2NoAbOff:
    ld a, TILE_BLANK
.p2WriteAbOff:
    ld [$9980], a
    jp .doneIndicators

.page4BInd:
    ; Page 4: B alone → rows 8+9; AB → row 10; neither → all blank
    ld a, b
    and %00110000           ; A(4) + B(5)
    cp %00100000            ; B alone?
    jr z, .p4BAlone
    cp %00110000            ; AB?
    jr z, .p4ABInd
    ; Neither modifier: blank all three rows
    ld a, TILE_BLANK
    ld [$9900], a           ; row 8 (VOLUME)
    ld [$9920], a           ; row 9 (SHAPE)
    ld [$9940], a           ; row 10 (RATE)
    jp .doneIndicators
.p4BAlone:
    ld a, TILE_PLAY
    ld [$9900], a           ; row 8 (VOLUME)
    ld [$9920], a           ; row 9 (SHAPE)
    ld a, TILE_BLANK
    ld [$9940], a           ; row 10 (RATE) blank
    jp .doneIndicators
.p4ABInd:
    ld a, TILE_BLANK
    ld [$9900], a           ; row 8 blank
    ld [$9920], a           ; row 9 blank
    ld a, TILE_PLAY
    ld [$9940], a           ; row 10 (RATE)
    jp .doneIndicators

.euclidPageInd:
    ; Page 8 (EUCLID): B alone → rows 8+9 (LEVEL/PITCH); AB → rows 10+11 (SOUND/DECAY).
    ; Plain LR (ROTATE on row 12) and ST (reserved) get no col-0 marker.
    ; Cached: paint only when modifier state changes, so the steady-state
    ; frame skips four VRAM writes that were dropping in MODE 3 on hardware.
    ; State: 0 = no modifier, 1 = B alone, 2 = AB held.
    ld a, b
    and %00110000
    cp %00100000                ; B alone?
    jr nz, .euCheckAB
    ld a, 1
    jr .euHaveState
.euCheckAB:
    cp %00110000                ; AB held?
    jr nz, .euNoMod
    ld a, 2
    jr .euHaveState
.euNoMod:
    xor a                       ; state = 0
.euHaveState:
    ld d, a                     ; d = desired state
    ld a, [wHudP8Ind]
    cp d
    jp z, .doneIndicators       ; unchanged → skip all four writes
    ld a, d
    ld [wHudP8Ind], a
    ; Paint per state. Dispatch instead of two independent compares so the
    ; whole indicator block stays small even when state actually changes.
    and a
    jr z, .euPaintNone
    cp 1
    jr z, .euPaintB
    ; state == 2 → AB
    ld a, TILE_BLANK
    ld [$9900], a
    ld [$9920], a
    ld a, TILE_PLAY
    ld [$9940], a
    ld [$9960], a
    jp .doneIndicators
.euPaintB:
    ld a, TILE_PLAY
    ld [$9900], a
    ld [$9920], a
    ld a, TILE_BLANK
    ld [$9940], a
    ld [$9960], a
    jp .doneIndicators
.euPaintNone:
    ld a, TILE_BLANK
    ld [$9900], a
    ld [$9920], a
    ld [$9940], a
    ld [$9960], a
    jp .doneIndicators

.controlsPageInd:
    ; Page 9 (CONTROLS): A alone → ▶ on SAVE row (row 3) + PRESET row (row 7);
    ; B alone → ▶ on LOAD row (row 4)
    ld a, b
    and %00110000
    cp %00010000            ; A alone (bit4 set, bit5 clear)
    jr nz, .ctrlNoA
    ld a, TILE_PLAY
    jr .ctrlWriteA
.ctrlNoA:
    ld a, TILE_BLANK
.ctrlWriteA:
    ld [$9860], a           ; row 3 col 0 (SAVE row)
    ld [$98E0], a           ; row 7 col 0 (PRESET row)
    ld a, b
    and %00110000
    cp %00100000            ; B alone (bit5 set, bit4 clear)
    jr nz, .ctrlNoB
    ld a, TILE_PLAY
    jr .ctrlWriteB
.ctrlNoB:
    ld a, TILE_BLANK
.ctrlWriteB:
    ld [$9880], a           ; row 4 col 0 (LOAD row)
    ; ST alone → ▶ on RND ALL (row 5), RND FX (row 6)
    ld a, b
    and %10110000           ; mask A(4) + B(5) + ST(7)
    cp %10000000            ; ST alone?
    jr nz, .ctrlNoST
    ld a, TILE_PLAY
    jr .ctrlWriteST
.ctrlNoST:
    ld a, TILE_BLANK
.ctrlWriteST:
    ld [$98A0], a           ; row 5 col 0 (RND ALL row)
    ld [$98C0], a           ; row 6 col 0 (RND FX row)
    jp .doneIndicators

.fillPageInd:
    ; Page 6 (FILL): B (not AB) → rows 7+8 (COLOR/PITCH); AB → rows 9+10 (FREQ/SHAPE)
    ld a, b
    and %00110000
    cp %00100000            ; B alone?
    jr nz, .fillNoB
    ld a, TILE_PLAY
    jr .fillWriteB
.fillNoB:
    ld a, TILE_BLANK
.fillWriteB:
    ld [$98E0], a           ; row 7
    ld [$9900], a           ; row 8

    ld a, b
    and %00110000
    cp %00110000            ; AB held?
    jr z, .fillABOn
    ld a, TILE_BLANK
    jr .fillWriteAB
.fillABOn:
    ld a, TILE_PLAY
.fillWriteAB:
    ld [$9920], a           ; row 9
    ld [$9940], a           ; row 10
    jp .doneIndicators

.showAllIndicators:
    ; B held (not AB)? → rows 8-9
    bit 5, b
    jr z, .noBInd
    bit 4, b
    jr nz, .noBInd
    ld a, TILE_PLAY
    jr .writeB
.noBInd:
    ld a, TILE_BLANK
.writeB:
    ld [$9900], a
    ld [$9920], a

    ; AB held? → rows 10-11
    ld a, b
    and %00110000
    cp  %00110000
    jr z, .abIndOn
    ld a, TILE_BLANK
    jr .writeAB
.abIndOn:
    ld a, TILE_PLAY
.writeAB:
    ld [$9940], a
    ld [$9960], a

    ; START held? → rows 12-13
    bit 7, b
    jr z, .noSTInd
    ld a, TILE_PLAY
    jr .writeST
.noSTInd:
    ld a, TILE_BLANK
.writeST:
    ld [$9980], a
    ld [$99A0], a

.doneIndicators:
    ; V26.3: HelpRowTick is now called at the start of UpdateHUD instead of
    ; here, so row 17 writes land while VBlank is fresh. Just return.
    ret

; =============================================================================
; Start Screen
; =============================================================================

DrawStartScreen:
    ld hl, StartScreenData
    jr DrawData

DrawControls:
    ld hl, ControlsData

DrawData:
.drawLoop:
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    and a
    ret z
    ld b, a
.drawString:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .drawString
    jr .drawLoop

WaitForStart:
    ; Wait for any held START to be released first
.waitRelease:
    call WaitVBlank
    call ReadButtons
    bit 7, a
    jr nz, .waitRelease
    ; Now wait for fresh START press
.waitPress:
    call WaitVBlank
    call ReadButtons
    bit 7, a
    jr z, .waitPress
    ret

; =============================================================================
; VBlank Handler
; =============================================================================

VBlankHandler:
    push af
    ; Decrement accent tail-frame countdown (saturate at 0). Frame-accurate
    ; even when the main loop is busy. Used by the gate-off fill suppression.
    ldh a, [hAccentTailFrames]
    and a
    jr z, .tailDone
    dec a
    ldh [hAccentTailFrames], a
.tailDone:
    ; CH1 offset countdown — tick toward 0; main loop fires CH1 when it hits.
    ldh a, [hCH1OffsetCounter]
    and a
    jr z, .ch1OffDone
    dec a
    ldh [hCH1OffsetCounter], a
.ch1OffDone:
    ; Help-row countdown — strictly single-purpose timer (do not read from
    ; audio/gate paths; that's the trap that broke V22 KIK gating).
    ldh a, [hHelpFrames]
    and a
    jr z, .helpTickDone
    dec a
    ldh [hHelpFrames], a
    jr nz, .helpTickDone
    ; Reached zero this frame — arm clear bit
    ldh a, [hHelpDirty]
    or %00000010
    ldh [hHelpDirty], a
.helpTickDone:
    ; Sub-page arm counter (save overwrite two-press confirm timeout)
    ld a, [wSubArmCounter]
    and a
    jr z, .armTickDone
    dec a
    ld [wSubArmCounter], a
    jr nz, .armTickDone
    ; Arm expired: set dirty flag so indicator repaints to ▶
    ld a, 1
    ld [wSubDirty], a
.armTickDone:
    ldh a, [hSpeedCounter]
    dec a
    ldh [hSpeedCounter], a
    jr nz, .done
    ld a, 1
    ldh [hStepReady], a
    push hl
    ld a, [wTapEffective]
    and a
    jr nz, .tapReload
    ld a, [wSpeed]
    ld hl, SpeedTable
    add l
    ld l, a
    jr nc, .ncVB
    inc h
.ncVB:
    ld a, [hl]
    jr .reloadDone
.tapReload:
    ; a already = wTapEffective
.reloadDone:
    ldh [hSpeedCounter], a
    pop hl
.done:
    pop af
    reti

; =============================================================================
; Utility Routines
; =============================================================================

ReadButtons:
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0F
    ld b, a

    ld a, $10
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0F
    swap a
    or b
    ld b, a

    ld a, $30
    ldh [rP1], a
    ld a, b
    ret

WaitVBlank:
.loop:
    ldh a, [rLY]
    cp 144
    jr c, .loop
    ret

DisableLCD:
    ldh a, [rLCDC]
    res 7, a
    ldh [rLCDC], a
    ret

; =============================================================================
; Help Row — long-name display on row 17 ($9A20), 20 tiles wide
; =============================================================================
;
; Width invariant: every write to row 17 is exactly 20 bytes. The BG map row is
; 32 tiles but only the first 20 are visible. Do NOT extend these copies past
; 20 — the bug shape Codex flagged in V22 ACCENT/FILL was a longer linear loop
; bleeding into adjacent rows.
;
; Single-purpose timer: hHelpFrames is decremented in VBlank and never read by
; audio/gate paths. (The V22 KIK regression stemmed from reusing a similar
; multi-frame countdown as a same-step gate flag — don't repeat that.)

DEF HELP_LEN          EQU 20
DEF HELP_ROW_VRAM     EQU $9A20
DEF HELP_TIMER_FRAMES EQU 60      ; ~1 second at 60 Hz

; ShowHelpByIndex(hl = base of 20-byte string array, a = value index)
; Computes hl = base + a*20, latches it into hHelpName*, arms timer + redraw.
; Preserves b, c. Clobbers a, d, e, h, l.
ShowHelpByIndex:
    push hl
    ld h, 0
    ld l, a
    add hl, hl              ; hl = idx * 2
    add hl, hl              ; hl = idx * 4
    ld d, h
    ld e, l                 ; de = idx * 4
    add hl, hl              ; hl = idx * 8
    add hl, hl              ; hl = idx * 16
    add hl, de              ; hl = idx * 20
    pop de                  ; de = original base pointer
    add hl, de              ; hl = base + idx*20
    ld a, l
    ldh [hHelpNameLo], a
    ld a, h
    ldh [hHelpNameHi], a
    ld a, HELP_TIMER_FRAMES
    ldh [hHelpFrames], a
    ldh a, [hHelpDirty]
    or %00000001            ; arm redraw
    and %11111101           ; cancel pending stale-clear (a fresh trigger
                            ; supersedes any timer-armed clear from a prior msg)
    ldh [hHelpDirty], a
    ret

; --- Per-control help wrappers ------------------------------------------------
; Each loads the appropriate base table and current value, then tail-calls
; ShowHelpByIndex. Cycle routines call these in place of their final `ret`,
; so both manual presses and auto-repeat paths share one trigger.

HelpFor_Pattern:
    ld a, [wPatternType]
    ld hl, HelpStr_Pattern
    jp ShowHelpByIndex

HelpFor_Gate:
    ld a, [wGateLength]
    ld hl, HelpStr_Gate
    jp ShowHelpByIndex

HelpFor_CH2Wave:
    ld a, [wDutyCycle]
    ld hl, HelpStr_CH2Wave
    jp ShowHelpByIndex

HelpFor_CH1Mode:
    ld a, [wCH1ModePending]
    ld hl, HelpStr_CH1Mode
    jp ShowHelpByIndex

HelpFor_CH1Int:
    ld a, [wCH1IntervalPending]
    ld hl, HelpStr_CH1Int
    jp ShowHelpByIndex

HelpFor_CH1Atk:
    ld a, [wCH1Attack]
    ld hl, HelpStr_CH1Atk
    jp ShowHelpByIndex

HelpFor_CH1Wave:
    ld a, [wCH1Wave]
    ld hl, HelpStr_CH1Wave
    jp ShowHelpByIndex

HelpFor_CH1Offset:
    ld a, [wCH1Offset]
    ld hl, HelpStr_CH1Offset
    jp ShowHelpByIndex

HelpFor_CH3Mode:
    ld a, [wCH3Mode]
    ld hl, HelpStr_CH3Mode
    jp ShowHelpByIndex

HelpFor_CH3Wave:
    ld a, [wCH3Wave]
    ld hl, HelpStr_CH3Wave
    jp ShowHelpByIndex

HelpFor_CH3Shape:
    ld a, [wCH3Shape]
    ld hl, HelpStr_CH3Shape
    jp ShowHelpByIndex

HelpFor_CH3Rate:
    ; Rate is numeric; no per-value string — show a fixed "RATE" label.
    xor a
    ld hl, HelpStr_CH3Rate
    jp ShowHelpByIndex

HelpFor_Accent:
    ld a, [wNoiseAccent]
    ld hl, HelpStr_Accent
    jp ShowHelpByIndex

HelpFor_FillColor:
    ld a, [wFillColor]
    ld hl, HelpStr_FillColor
    jp ShowHelpByIndex

HelpFor_FillShape:
    ld a, [wFillShape]
    ld hl, HelpStr_FillShape
    jp ShowHelpByIndex

HelpFor_TonalMode:
    ld a, [wTonalMode]
    ld hl, HelpStr_TonalMode
    jp ShowHelpByIndex

HelpFor_TonalLock:
    ld a, [wTonalLock]
    ld hl, HelpStr_TonalLock
    jp ShowHelpByIndex

HelpFor_TonalLevel:
    ld a, [wTonalLevel]
    ld hl, HelpStr_TonalLevel
    jp ShowHelpByIndex

HelpFor_TonalMap:
    ld a, [wTonalMap]
    ld hl, HelpStr_TonalMap
    jp ShowHelpByIndex

HelpFor_TonalWidth:
    ld a, [wTonalWidth]
    ld hl, HelpStr_TonalWidth
    jp ShowHelpByIndex

HelpFor_TonalDecay:
    ld a, [wTonalDecay]
    ld hl, HelpStr_TonalDecay
    jp ShowHelpByIndex

; Special-case: TRANSP shows a single static label regardless of value, because
; the numeric value is already on-screen in the row. We must zero `a` before
; calling ShowHelpByIndex — the shared helper computes base + a*20 with no
; bounds check, so a non-zero index against a 1-entry table would read garbage.
HelpFor_TonalTransp:
    xor a
    ld hl, HelpStr_TonalTransp
    jp ShowHelpByIndex

HelpFor_TonalTrig:
    ld a, [wTonalTrig]
    ld hl, HelpStr_TonalTrig
    jp ShowHelpByIndex

HelpFor_TonalPri:
    ld a, [wTonalPri]
    ld hl, HelpStr_TonalPri
    jp ShowHelpByIndex

; --- V26.1/V26.2: Euclidean Drum Machine help wrappers (Page 8) -------------
; Only SOUND and DECAY get tooltips (their 3-letter names — TGT/BOM/SUB/PCH and
; SHT/MID/LNG — are not self-explanatory). HITS/LENGTH/ROTATE/LEVEL labels
; speak for themselves and were intentionally dropped in V26.2.
HelpFor_EuclidKickSound:
    ld a, [wEuclidKickSound]
    ld hl, HelpStr_EuclidKickSound
    jp ShowHelpByIndex

HelpFor_EuclidKickDecay:
    ld a, [wEuclidKickDecay]
    ld hl, HelpStr_EuclidKickDecay
    jp ShowHelpByIndex

HelpFor_EuclidKickLock:
    ld a, [wEuclidKickLock]
    ld hl, HelpStr_TonalLock    ; reuse FRE→FREE / LOK→LOCKED strings
    jp ShowHelpByIndex

; V31: Randomize action flashes — single static string, so a=0 before ShowHelpByIndex.
HelpFor_RndWild:
    xor a
    ld hl, HelpStr_RndWild
    jp ShowHelpByIndex

HelpFor_RndMild:
    xor a
    ld hl, HelpStr_RndMild
    jp ShowHelpByIndex

; HelpRowTick — called from end of UpdateHUD (already inside the VBlank window
; opened by the MainLoop halt/nop). Handles three concerns:
;   1. Page-switch detection: if wCurrentPage != hHelpLastPage, force-clear
;      and zero the timer so a stale message doesn't bleed across screens.
;   2. Dirty-clear (bit 1): blank row 17.
;   3. Dirty-redraw (bit 0): copy 20 bytes from hHelpName* to row 17.
; Redraw runs after clear so a fresh trigger on a page-switch frame still wins.
HelpRowTick:
    ; --- Page-change detection ---
    ld a, [wCurrentPage]
    ld b, a
    ldh a, [hHelpLastPage]
    cp b
    jr z, .noPageChange
    ld a, b
    ldh [hHelpLastPage], a
    xor a
    ldh [hHelpFrames], a    ; cancel any running timer
    ldh [hHelpNameLo], a
    ldh [hHelpNameHi], a
    ldh a, [hHelpDirty]
    or %00000010            ; arm clear
    and %11111110           ; drop any pending redraw
    ldh [hHelpDirty], a
.noPageChange:
    ; --- Sticky LOCKED re-arm (page 7 + LOK only) ---
    ; When the help-row timer expires while on page 7 with LOK engaged,
    ; re-stamp the LOCKED tooltip. This lets transient tooltips from other
    ; controls (MODE, LEVEL, …) still flash for ~1 s, then LOCKED returns
    ; without a blank-row gap: ShowHelpByIndex cancels the pending clear bit.
    ld a, [wCurrentPage]
    cp 6
    jr nz, .noStickyArm
    ld a, [wTonalLock]
    and a
    jr z, .noStickyArm
    ldh a, [hHelpFrames]
    and a
    jr nz, .noStickyArm
    call HelpFor_TonalLock
.noStickyArm:

    ; --- Clear (bit 1) ---
    ldh a, [hHelpDirty]
    bit 1, a
    jr z, .noClear
    res 1, a
    ldh [hHelpDirty], a
    ld hl, HELP_ROW_VRAM
    ld b, HELP_LEN
    ld a, TILE_BLANK
.clearLoop:
    ld [hli], a
    dec b
    jr nz, .clearLoop
.noClear:

    ; --- Redraw (bit 0) ---
    ldh a, [hHelpDirty]
    bit 0, a
    ret z
    res 0, a
    ldh [hHelpDirty], a
    ldh a, [hHelpNameLo]
    ld e, a
    ldh a, [hHelpNameHi]
    ld d, a
    or e
    ret z                   ; defensive: null pointer → nothing to draw
    ld hl, HELP_ROW_VRAM
    ld b, HELP_LEN
.redrawLoop:
    ld a, [de]
    ld [hli], a
    inc de
    dec b
    jr nz, .redrawLoop
    ret

LoadTiles:
    ld hl, TileData
    ld de, $8000
    ld bc, TileDataEnd - TileData
.copy:
    ld a, [hli]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copy
    ret

FillBGMap:
    ld hl, $9800
    ld bc, 32 * 32
    ld d, a
.fill:
    ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .fill
    ret

; Generate inverted-color copies of tiles 0..50 at indices 64..114.
; LCD must be off (VRAM source read).
InvertTiles:
    ld hl, $8000                ; src: original tiles
    ld de, $8400                ; dst: inverted tiles (base index 64)
    ld bc, 51 * 16              ; 51 tiles × 16 bytes
.loop:
    ld a, [hli]
    cpl
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .loop
    ret

InitSound:
    ld a, $80
    ldh [rNR52], a
    ld a, $77
    ldh [rNR50], a
    ld a, $FF
    ldh [rNR51], a
    call SilenceSound
    ret

SilenceSound:
    ld a, DAC_ON_SILENT
    ldh [rNR12], a          ; CH1: DAC alive, vol 0
    ldh [rNR22], a          ; CH2: DAC alive, vol 0
    ld a, $80
    ldh [rNR14], a          ; retrigger CH1 at vol 0
    ldh [rNR24], a          ; retrigger CH2 at vol 0
    xor a
    ldh [rNR42], a          ; CH4 DAC off (muted; re-armed by PlayNoisePreset)
    ldh [rNR32], a          ; CH3 volume mute
    ld [wCH3Running], a     ; reset CH3 running flag
    ldh [hFillActive], a    ; fill is gone — don't let main loop mute CH4 again
    ret

; -----------------------------------------------------------------------------
; Noise helpers (CH4)
; -----------------------------------------------------------------------------
; PlayNoisePreset — Write a 3-byte (NR41, NR42, NR43) preset and trigger CH4.
; NR44 is always written with $80 (plain retrigger, no length enable) so the
; envelope in NR42 alone shapes the perceived decay.
; Input:  hl = pointer to 3-byte preset
; Clobbers: a
PlayNoisePreset:
    ld a, [hli]
    ldh [rNR41], a
    ld a, [hli]
    ldh [rNR42], a
    ld a, [hl]
    ldh [rNR43], a
    ld a, $80
    ldh [rNR44], a
    ret

; MaybeTriggerAccent — Consume hAccentPending; if set and wNoiseAccent != 0,
; trigger the matching preset from NoisePresets. Clears the flag either way.
; Clobbers: a, b, hl
MaybeTriggerAccent:
    ldh a, [hAccentPending]
    and a
    ret z
    xor a
    ldh [hAccentPending], a     ; always clear flag
    ; V32: global CH4 mute — consume the flag but suppress all accent audio
    ld a, [wMuteCH4]
    and a
    ret nz
    ld a, [wNoiseAccent]
    and a
    ret z                        ; ACCENT = OFF (no fire, fill stays allowed)
    ld b, a                      ; b = accent idx (preserved across flag write)
    ; Tonal-mode accent suppression: PRI bit 1 set ⇔ +FIL (2) or SOLO (3).
    ; Skip the entire accent path so its NR42/NR43/NR12-14 writes don't clobber
    ; a sustained tonal note ringing into the cycle-start step.
    ld a, [wTonalMode]
    and a
    jr z, .accentNoTonalSup
    ld a, [wTonalPri]
    bit 1, a
    ret nz
.accentNoTonalSup:
    ; Arm the tail-frame countdown so the next step's gate-off fill won't clip
    ; the accent envelope's decay. Decremented per VBlank by VBlankHandler.
    ld a, b                      ; restore accent idx as offset into AccentTailFrames
    ld hl, AccentTailFrames
    add l
    ld l, a
    jr nc, .tailNc
    inc h
.tailNc:
    ld a, [hl]
    ldh [hAccentTailFrames], a
    ld a, b
    cp 1
    jr z, PlayKickAccent         ; KIK: CH1 pitch-sweep + CH4 click
    ; SNR/RIM: CH4-only preset lookup
    ld b, a
    add a                        ; a = idx * 2
    add b                        ; a = idx * 3
    ld hl, NoisePresets
    add l
    ld l, a
    jr nc, .ok
    inc h
.ok:
    jp PlayNoisePreset

; PlayKickAccent — Layered kick drum: CH1 pitch-sweep body + CH4 transient click.
; CH4 noise alone cannot produce a pitched "thud", so the accent steals CH1 for
; one step and drives NR10 sweep from a low frequency downward. The next arp
; step's PlayCurrentNote re-writes NR10-NR14 (the .ch1Active path clears NR10
; first), so the sweep does not leak into subsequent arp notes.
; On this accent step, the arp's CH1 layer is replaced by the kick — musically
; idiomatic for a downbeat (drummer hits kick instead of the chord on beat 1).
; Clobbers: a, b, hl  (b/hl via PlayNoisePreset)
PlayKickAccent:
    ld a, 1
    ldh [hKickStepActive], a     ; one-shot latch consumed by gate-expiry to
                                 ; skip CH1 mute on this step only; cleared at
                                 ; the next step boundary.
    ld a, $23                    ; NR10: sweep time 2, decrease, shift 3
    ldh [rNR10], a
    ld a, $80                    ; NR11: duty 50%, length 0
    ldh [rNR11], a
    ld a, $F2                    ; NR12: vol 15, decay, step 2 (~260 ms)
    ldh [rNR12], a
    ld a, $C7                    ; NR13: freq low byte (~G2, ~98 Hz)
    ldh [rNR13], a
    ld a, $82                    ; NR14: trigger + freq high 3 bits
    ldh [rNR14], a
    ld hl, NoisePresets_KickClick
    jp PlayNoisePreset

; MaybeTriggerTonal — Fire a CH4 tonal-noise hit on note-on if all gates pass.
; Reads hFreqIndex (set by PlayCurrentNote) for the note value and looks up
; NR43 from the active mapping table; composes NR42 from level/decay; triggers
; via NR44=$80. Increments wTonalTrigCount once per call (after MODE/LEVEL
; gates, before exit), so HLF/Q4 cadence stays locked through accent-tail
; suppression and pattern misses. Pattern gate reads the pre-increment value,
; so downbeat fires on counter==0. Gate=4 silent steps do not call this
; function at all and therefore do not advance the counter — by design
; (HLF/Q4 count audible notes, not grid steps; if grid-step semantics ever
; needed, move the tick into the shared step handler instead).
; Mapping index: GML wraps modulo 12 so transposition stays musical at the
; melody-range edges; TRK/INV clamp to [0,59] (deliberate floor/ceiling).
; Skip conditions: MODE=OFF / LEVEL=0 (feature off, counter not advanced),
; hAccentTailFrames>0 (counter advances, trigger suppressed),
; or trigger pattern blocks this step (counter advances, trigger suppressed).
; Clobbers: a, b, c, d, hl
MaybeTriggerTonal:
    ld a, [wTonalMode]
    and a
    ret z
    ld a, [wTonalLock]
    and a
    ret nz                      ; LOCK engaged: CH4 frozen, no retrigger
    ld a, [wTonalLevel]
    and a
    ret z
    ldh a, [hAccentTailFrames]
    and a
    jp nz, .advance              ; counter advances on the way out

    ; Pattern gating (reads pre-increment counter)
    ld a, [wTonalTrig]
    and a
    jr z, .pattOK                ; EVR
    cp 1
    jr z, .checkHLF
    ; Q4: count & 3 == 0
    ld a, [wTonalTrigCount]
    and %11
    jp nz, .advance
    jr .pattOK
.checkHLF:
    ld a, [wTonalTrigCount]
    bit 0, a
    jp nz, .advance

.pattOK:
    ; V32: global CH4 mute — counter still advances via .advance, trigger suppressed
    ld a, [wMuteCH4]
    and a
    jp nz, .advance
    ; Compute mapping index. GML wraps mod 12 (no clamp); TRK/INV clamp [0,59].
    ldh a, [hFreqIndex]
    ld b, a
    ld a, [wTonalTransp]
    add b                        ; a = note + transp (range [0,83])
    ld d, a                      ; stash raw sum for both branches

    ld a, [wTonalMap]
    cp 1
    jr z, .mapGML

    ; TRK / INV: subtract 12, then clamp to [0,59]
    ld a, d
    sub 12
    jr nc, .nonNeg
    xor a                        ; clamp negative → 0
    jr .haveIdx
.nonNeg:
    cp 60
    jr c, .haveIdx
    ld a, 59                     ; clamp ≥60 → 59
.haveIdx:
    ld c, a
    ld a, [wTonalMap]
    cp 2
    jr z, .mapINV
    ld hl, TonalMap_TRK
    jr .lookup
.mapINV:
    ld hl, TonalMap_INV
    jr .lookup

.mapGML:
    ; (raw + 48) mod 12. raw ∈ [0,83] so raw+48 ∈ [48,131] — always
    ; non-negative, so the unsigned mod loop works without sign branching.
    ; Equivalent to (note + transp - 12 + 60) mod 12 since 60 mod 12 = 0.
    ld a, d
    add 48
.gmlMod:
    cp 12
    jr c, .gmlModDone
    sub 12
    jr .gmlMod
.gmlModDone:
    ld c, a
    ld hl, TonalMap_GML

.lookup:
    ld a, c
    add l
    ld l, a
    jr nc, .ncMap
    inc h
.ncMap:
    ld a, [hl]
    and $77                      ; mask away bit 3 (width OR'd in below) and bit 7
    ld b, a

    ; OR width into bit 3
    ld a, [wTonalWidth]
    add a
    add a
    add a                        ; width << 3
    or b
    ld b, a                      ; b = NR43

    ; NR42 = (LevelTable[level] << 4) | DecayEnvelope[decay]
    ld a, [wTonalLevel]
    ld hl, TonalLevelTable
    add l
    ld l, a
    jr nc, .ncLvl
    inc h
.ncLvl:
    ld a, [hl]
    swap a
    and $F0
    ld c, a
    ld a, [wTonalDecay]
    ld hl, TonalDecayEnvelope
    add l
    ld l, a
    jr nc, .ncDec
    inc h
.ncDec:
    ld a, [hl]
    or c
    ld c, a                      ; c = NR42

    ; Write CH4 registers
    xor a
    ldh [rNR41], a               ; length disabled
    ld a, c
    ldh [rNR42], a
    ld a, b
    ldh [rNR43], a
    ld a, $80
    ldh [rNR44], a               ; trigger (no length enable)
    ; fall through to .advance

.advance:
    ld a, [wTonalTrigCount]
    inc a
    ld [wTonalTrigCount], a
    ret

; ComposeAndPlayFill — Build NR41/43/42 from wFill{Level,Color,Pitch,Shape} at
; runtime and retrigger CH4 with NR44=$80. Called by the gate-off silencer
; when a fill should fire (accent not active, and not in the FLT+LEVEL=0 off
; combo). The 5 SHAPE modes map as (HUD → internal label):
;   0 FLT  / .shapeFlt  — flat sustain at LEVEL (vol=level<<1, dir down, step 0)
;   1 ER↑  / .shapeUpw  — exponential ramp up across cycle (concave swell)
;   2 ER↓  / .shapeDnw  — exponential ramp down across cycle
;   3 LR↑  / .shapeUpc  — linear ramp up: level = min(pos*fillCycleStep, 15)
;   4 LR↓  / .shapeDnc  — linear ramp down: level = 15 - LR↑ level
; LR↑/LR↓ ignore wFillLevel and compute their volume nibble from wCyclePhase.
; Internal labels keep the legacy UPW/DNW/UPC/DNC mnemonics (W=wave/exp,
; C=cycle/linear) since they're code-only — only HUD value tiles changed.
; Clobbers: a, b, c, hl
ComposeAndPlayFill:
    xor a
    ldh [rNR41], a              ; length = 0 (no length enable — NR44 omits bit 6)

    ; NR43 = (pitch << 4) | (color << 3) | (freq & 7)
    ld a, [wFillPitch]
    swap a
    and $F0
    ld b, a
    ld a, [wFillColor]
    add a                        ; color << 1
    add a                        ; color << 2
    add a                        ; color << 3 (bit 3 of NR43)
    or b
    ld b, a
    ld a, [wFillFreq]
    and %00000111                ; divider bits 2..0
    or b
    ldh [rNR43], a

    ; NR42 composition per SHAPE.
    ld a, [wFillShape]
    and a
    jr z, .shapeFlt
    cp 1
    jr z, .shapeUpw
    cp 2
    jr z, .shapeDnw
    cp 3
    jr z, .shapeUpc
    ; fall through: SHAPE 4 = LR↓
.shapeDnc:
    ld a, [wFillCycleStep]
    and a
    jr z, .shapeFlt              ; RANDOM (no cycle): behave like FLT
    call .computeCycleLevel
    ld a, 15
    sub b                        ; a = 15 - cycleLevel (saturated via computeCycleLevel)
    swap a                       ; vol nibble in high nibble
    and $F0                      ; step=0, dir=0 (down)
    jr .writeNR42
.shapeUpc:
    ld a, [wFillCycleStep]
    and a
    jr z, .shapeFlt              ; RANDOM (no cycle): behave like FLT
    call .computeCycleLevel
    ld a, b
    swap a
    and $F0                      ; step=0, dir=0 (down); sustain at computed level
    jr .writeNR42
.shapeFlt:
    ld a, [wFillLevel]
    add a                        ; level * 2 (maps 0..7 → 0..14)
    swap a
    and $F0                      ; vol nibble, step=0, dir=0
    jr .writeNR42
.shapeUpw:
    ; Multi-hit exponential ramp UP across cycle: same per-burst trigger as LR↑,
    ; but volume curve is concave (slow start, fast end) instead of linear.
    ; UpwExpTable maps the linear LR↑ level (0..15) → exponential level (0..15).
    ld a, [wFillCycleStep]
    and a
    jr z, .shapeFlt              ; RANDOM: no cycle, behave like FLT
    call .computeCycleLevel      ; b = linear level 0..15
    ld hl, UpwExpTable
    ld a, l
    add b
    ld l, a
    jr nc, .upwNoCarry
    inc h
.upwNoCarry:
    ld a, [hl]
    swap a
    and $F0                      ; vol nibble, step=0, dir=0
    jr .writeNR42
.shapeDnw:
    ; Multi-hit exponential ramp DOWN across cycle: fast drop with long tail.
    ; DnwExpTable is UpwExpTable reversed — produces the inverse curve.
    ld a, [wFillCycleStep]
    and a
    jr z, .shapeFlt
    call .computeCycleLevel
    ld hl, DnwExpTable
    ld a, l
    add b
    ld l, a
    jr nc, .dnwNoCarry
    inc h
.dnwNoCarry:
    ld a, [hl]
    swap a
    and $F0
.writeNR42:
    ldh [rNR42], a

    ld a, $80
    ldh [rNR44], a               ; retrigger (no length enable)
    ret

; Compute LR↑-direction cycle level → b, given wCyclePhase and wFillCycleStep.
; b = min(phase * fillCycleStep, 15).  Clobbers: a, c.
; Phase counts monotonically up across one cycle (set in step handler from
; hCycleReset), so the same code path works for ASC, DESC, and PINGPONG.
.computeCycleLevel:
    ld a, [wCyclePhase]
    ld c, a                      ; c = remaining iterations
    ld a, [wFillCycleStep]
    ld b, a                      ; b = step size
    xor a                        ; a = accumulator (level)
    ; Edge case: if position is 0, level = 0 (loop skipped by dec jump below).
    inc c                        ; pre-increment so dec-jr-z handles pos=0 cleanly
    jr .cycLoopTest
.cycLoopBody:
    add b
    cp 16
    jr c, .cycLoopTest
    ld a, 15                     ; saturate
    jr .cycLoopEnd
.cycLoopTest:
    dec c
    jr nz, .cycLoopBody
.cycLoopEnd:
    ld b, a                      ; return in b
    ret

; LoadWaveRAM — Load wavetable preset [wCH3Wave] into Wave RAM
; Must turn off NR30 before writing, turn back on after
LoadWaveRAM:
    push bc
    xor a
    ldh [rNR30], a          ; CH3 OFF (required before Wave RAM write)
    ld a, [wCH3Wave]
    swap a                   ; a * 16 (swap nibbles)
    ld e, a
    ld d, 0
    ld hl, WavetableData
    add hl, de               ; hl = &WavetableData[preset * 16]
    ld c, LOW(rWaveRAM)      ; c = $30
    ld b, 16
.copyWave:
    ld a, [hli]
    ldh [c], a
    inc c
    dec b
    jr nz, .copyWave
    ld a, $80
    ldh [rNR30], a           ; CH3 ON
    pop bc
    ret

BlankRow:
    ; hl = row start address. Blanks 20 tiles.
    xor a
    ld b, 20
.loop:
    ld [hli], a
    dec b
    jr nz, .loop
    ret

BlankPageRows:
    push bc
    ld hl, $9800    ; row 0 (title bar / page-0 group name)
    call BlankRow
    ld hl, $9820    ; row 1 (subtitle / page-0 mode+note+octave)
    call BlankRow
    ld hl, $9840    ; row 2 (V30.4: cleared so page-6 FILL tagline doesn't bleed)
    call BlankRow
    ld hl, $9860    ; row 3
    call BlankRow
    ld hl, $9880    ; row 4
    call BlankRow
    ld hl, $98A0    ; row 5 (legacy V18 title row, now unused but kept blanked)
    call BlankRow
    ld hl, $9900    ; row 8
    call BlankRow
    ld hl, $9920    ; row 9
    call BlankRow
    ld hl, $9940    ; row 10
    call BlankRow
    ld hl, $9960    ; row 11
    call BlankRow
    ld hl, $9980    ; row 12
    call BlankRow
    ld hl, $99A0    ; row 13
    call BlankRow
    ld hl, $99C0    ; row 14 (TONAL LOCK row)
    call BlankRow
    ld hl, $99E0    ; row 15 (V38.1: matrix/list hint rows must not bleed into pages)
    call BlankRow
    pop bc
    ret

; =============================================================================
; V30 Save/Load System
; =============================================================================

EnableSRAM:
    ld a, $0A
    ld [$0000], a
    ld a, 1
    ld [$6000], a               ; MBC1 mode 1 — enables RAM banking (V38 32 KB SRAM).
                                ; Harmless on the EMS mapper (probe-verified on-device);
                                ; no ROM-side effect for a 2-bank ROM (BANK2 bits masked).
    ret

DisableSRAM:
    xor a
    ld [$0000], a
    ret

; EnsureSRAM — validate magic+version at $A000; wipe and re-init if wrong.
EnsureSRAM:
    call EnableSRAM
    xor a
    ld [$4000], a               ; defensive: header/slot data lives in RAM bank 0
    ld hl, $A000
    ld a, [hli]
    cp SRAM_MAGIC_0
    jr nz, .doInit
    ld a, [hli]
    cp SRAM_MAGIC_1
    jr nz, .doInit
    ld a, [hli]
    cp SRAM_MAGIC_2
    jr nz, .doInit
    ld a, [hli]
    cp SRAM_MAGIC_3
    jr nz, .doInit
    ld a, [hl]
    cp SAVE_SCHEMA_VERSION
    jr z, .sramOk
.doInit:
    ld hl, $A000
    ld a, SRAM_MAGIC_0
    ld [hli], a
    ld a, SRAM_MAGIC_1
    ld [hli], a
    ld a, SRAM_MAGIC_2
    ld [hli], a
    ld a, SRAM_MAGIC_3
    ld [hli], a
    ld a, SAVE_SCHEMA_VERSION
    ld [hli], a
    xor a
    ld [hli], a
    ld [hli], a
    ld [hli], a         ; reserved $A005-$A007
    ; Zero all occupied flags (one per slot)
    ld hl, $A008
    ld de, SAVE_SLOT_SIZE
    ld c, SAVE_SLOT_COUNT
.clearSlot:
    ld [hl], 0
    add hl, de
    dec c
    jr nz, .clearSlot
    ; V38: zero every preset occupied flag in every slot's matrix (SRAM bank 1)
    ld a, MATRIX_SRAM_BANK
    ld [$4000], a
    ld c, 0
.clearMatrix:
    ld a, c
    call GetMatrixBase          ; hl = matrix base for slot c
    ld de, PRESET_SIZE
    ld b, PRESET_COUNT
.clearPreset:
    ld [hl], 0
    add hl, de
    dec b
    jr nz, .clearPreset
    inc c
    ld a, c
    cp SAVE_SLOT_COUNT
    jr nz, .clearMatrix
    xor a
    ld [$4000], a               ; back to bank 0
.sramOk:
    call DisableSRAM
    ret

; GetSlotPtr(a = slot 0..7) → hl = SRAM address of slot's occupied flag
; SRAM must be enabled by caller. Clobbers a, b, de, hl.
GetSlotPtr:
    ld b, a
    ld hl, $A008
    and a
    ret z
    ld de, SAVE_SLOT_SIZE
.gsp:
    add hl, de
    dec b
    jr nz, .gsp
    ret

; GetSlotOccupied(a = slot 0..7) → a = occupied byte (0=empty)
GetSlotOccupied:
    push bc
    push de
    push hl
    ld b, a
    call EnableSRAM
    ld a, b
    call GetSlotPtr
    ld a, [hl]
    push af
    call DisableSRAM
    pop af
    pop hl
    pop de
    pop bc
    ret

; --- V38 per-slot preset-matrix SRAM helpers ---------------------------------
; The matrices live in SRAM BANK 1 ($4000-select). Both copy routines switch to
; bank 1 on entry and back to bank 0 before returning, so all other SRAM code
; can keep assuming bank 0.

; GetMatrixBase(a = slot) → hl = MATRIX_BASE + slot*MATRIX_SIZE. Clobbers a.
; Relies on MATRIX_SIZE being a whole number of 256-byte pages.
ASSERT MATRIX_SIZE == 1024
GetMatrixBase:
    add a
    add a                       ; a = slot*4 (pages of 256)
    add HIGH(MATRIX_BASE)
    ld h, a
    ld l, LOW(MATRIX_BASE)
    ret

; WriteMatrixToSRAM(a = slot) — copy the WRAM preset matrix into the slot's
; SRAM matrix area (16 records: occupied + 61 params + 2 pad).
; SRAM must be enabled by the caller. Clobbers a, b, c, d, e, hl.
WriteMatrixToSRAM:
    call GetMatrixBase          ; hl = SRAM dest
    ld a, MATRIX_SRAM_BANK
    ld [$4000], a               ; matrices live in SRAM bank 1
    ld de, wPresetBuf           ; de = WRAM param source (packed, 61-byte stride)
    ld c, 0                     ; c = preset index
.wmPreset:
    push hl
    ld b, 0
    ld hl, wPresetOcc
    add hl, bc                  ; bc = index (b=0)
    ld a, [hl]
    pop hl
    ld [hli], a                 ; record byte 0: occupied
    ld b, SAVE_PARAM_COUNT
.wmParams:
    ld a, [de]
    inc de
    ld [hli], a
    dec b
    jr nz, .wmParams
    inc hl                      ; skip 2 pad bytes → next 64-byte record
    inc hl
    inc c
    ld a, c
    cp PRESET_COUNT
    jr nz, .wmPreset
    xor a
    ld [$4000], a               ; back to bank 0
    ret

; ReadMatrixFromSRAM(a = slot) — copy the slot's SRAM matrix into WRAM.
; Every occupied record is range-validated first (same walk as ValidateSlot);
; empty or out-of-range records leave wPresetOcc[i]=0 and the WRAM params alone.
; SRAM must be enabled by the caller. Clobbers a, b, c, d, e, hl.
ReadMatrixFromSRAM:
    call GetMatrixBase          ; hl = SRAM record base
    ld a, MATRIX_SRAM_BANK
    ld [$4000], a               ; matrices live in SRAM bank 1
    ld c, 0                     ; c = preset index
.rmPreset:
    ld a, [hl]                  ; occupied byte
    and a
    jr z, .rmEmpty
    push hl
    push bc
    inc hl                      ; first param byte
    call ValidateParamsAt       ; a=1 if all 61 bytes in range
    pop bc
    pop hl
    and a
    jr z, .rmEmpty
    ; copy 61 params into wPresetBuf + index*61
    push hl                     ; record base
    ld a, c
    push bc
    call GetPresetPtr           ; hl = WRAM dest
    pop bc
    pop de                      ; de = SRAM record base
    push de                     ; keep for the stride advance below
    inc de                      ; params start at record byte 1
    ld b, SAVE_PARAM_COUNT
.rmCopy:
    ld a, [de]
    inc de
    ld [hli], a
    dec b
    jr nz, .rmCopy
    pop hl                      ; hl = record base
    ld a, 1
    jr .rmSetOcc
.rmEmpty:
    xor a
.rmSetOcc:
    push hl
    ld b, 0
    ld hl, wPresetOcc
    add hl, bc
    ld [hl], a
    pop hl
    ld de, PRESET_SIZE
    add hl, de                  ; next record
    inc c
    ld a, c
    cp PRESET_COUNT
    jr nz, .rmPreset
    xor a
    ld [$4000], a               ; back to bank 0
    ret

; PickRandomWord — returns a = word index 0..SAVE_WORD_COUNT-1
; Advances wRngState LFSR, mixes with hSpeedCounter for entropy.
PickRandomWord:
    ld a, [wRngState]
    rra
    jr nc, .prwNoXor
    xor $B4
.prwNoXor:
    ld [wRngState], a
    ld b, a
    ldh a, [hSpeedCounter]
    xor b
.prwMod:
    cp SAVE_WORD_COUNT
    jr c, .prwDone
    sub SAVE_WORD_COUNT
    jr .prwMod
.prwDone:
    ret

; NextRandomByte — one LFSR step of wRngState, XOR-mixed with hSpeedCounter.
; Returns a = pseudo-random byte. Clobbers a, b. Mirrors PickRandomWord step.
NextRandomByte:
    ld a, [wRngState]
    rra
    jr nc, .nrbNoXor
    xor $B4
.nrbNoXor:
    ld [wRngState], a
    ld b, a
    ldh a, [hSpeedCounter]
    xor b
    ret

; RandomizeWild — randomize all saved params except wTapEffective (tap cache).
; V38: no pre-mutation snapshot — undo/redo removed; save a preset first if the
; current state is worth keeping.
RandomizeWild:
    xor a
    call RandomizeParams
    jp HelpFor_RndWild

; RandomizeMild — randomize all saved params except wTapEffective and key/tempo
; anchors (wCurrentBank, wRootNote, wRootOctave, wSpeed). Musical context stays.
RandomizeMild:
    ld a, 1
    call RandomizeParams
    jp HelpFor_RndMild

; RandomizeParams(a = mode: 0=WILD skips only wTapEffective;
;                           1=MILD also skips key/tempo anchors).
; Iterates SaveParamTable + SaveParamRangeTable in lockstep.
; For each non-skipped entry: generates a uniform random byte in [min..max]
; and writes it to the corresponding WRAM variable.
; Special-case: wGateLength is rolled in 0..MAX_GATE-1 (excludes SIL) to
; keep randomized presets audible.
; Runs the same LoadSlot reconciliation tail so runtime caches stay consistent.
; Preserves bc, de, hl. Clobbers a, f.
RandomizeParams:
    push bc
    push de
    push hl
    ld [wRndSkipBit], a
    ld de, SaveParamTable
    ld hl, SaveParamRangeTable
.rpLoop:
    ; Read WRAM address from SaveParamTable[de] → bc
    ld a, [de]
    inc de
    ld c, a
    ld a, [de]
    inc de
    ld b, a
    ; Terminator check (bc == 0)
    ld a, b
    or c
    jr z, .rpDone
    ; wTapEffective: skip in both modes (c = LOW byte of all $C0xx WRAM addrs)
    ld a, c
    cp LOW(wTapEffective)
    jr z, .rpSkip
    ; Mute matrix: never randomize (randomize must not silence channels)
    cp LOW(wMuteCH4)
    jr z, .rpSkip
    cp LOW(wMuteEuc)
    jr z, .rpSkip
    cp LOW(wMuteCH1)
    jr z, .rpSkip
    cp LOW(wMuteCH2)
    jr z, .rpSkip
    cp LOW(wMuteCH3)
    jr z, .rpSkip
    ; MILD mode: also skip key + tempo anchors
    ld a, [wRndSkipBit]
    and a
    jr z, .rpDoRand
    ld a, c
    cp LOW(wCurrentBank)
    jr z, .rpSkip
    cp LOW(wRootNote)
    jr z, .rpSkip
    cp LOW(wRootOctave)
    jr z, .rpSkip
    cp LOW(wSpeed)
    jr z, .rpSkip
.rpDoRand:
    ; Read range: min=[hl], max=[hl+1], advance hl by 2
    ld a, c                 ; preserve WRAM low byte before bc is clobbered
    push bc                 ; save WRAM address
    push de                 ; save SaveParamTable cursor
    ld b, [hl]              ; b = min
    inc hl
    ld c, [hl]              ; c = max
    inc hl
    ; wGateLength must never roll to SIL (MAX_GATE=4 → silence); clamp max to 3.
    cp LOW(wGateLength)
    jr nz, .rpRangeOk
    ld a, c
    cp MAX_GATE
    jr nz, .rpRangeOk
    dec c                   ; exclude SIL from random range
.rpRangeOk:
    push hl                 ; save RangeTable cursor
    ld a, c
    sub b
    inc a                   ; a = span (max - min + 1)
    ld e, a                 ; e = span
    ld d, b                 ; d = min
    call NextRandomByte     ; a = random byte; clobbers b only
.rpMod:
    cp e
    jr c, .rpModDone
    sub e
    jr .rpMod
.rpModDone:
    add a, d                ; a += min → value in [min..max]
    pop hl                  ; restore RangeTable cursor
    pop de                  ; restore SaveParamTable cursor
    pop bc                  ; restore WRAM address
    ld [bc], a
    jr .rpLoop
.rpSkip:
    ; Skip: advance RangeTable past this entry's min/max without using them
    inc hl
    inc hl
    jr .rpLoop
.rpDone:
    call ApplyParamReconciliation
    pop hl
    pop de
    pop bc
    ret

; ApplyParamReconciliation — shared post-mutation tail: push CH3 wave to Wave RAM,
; clamp Euclid K/Rot, refresh note-count/arp-position caches, set all repaint flags.
; Called after: RandomizeParams, LoadSlot, MatrixLoadPreset.
; Clobbers a. Other registers depend on callees.
ApplyParamReconciliation:
    call LoadWaveRAM
    xor a
    ld [wCH3Running], a
    call EuclidKickClampAfterN
    call ComputeNoteCount
    call ClampArpPosition
    ld a, $FF
    ld [wEuclidPatternDirty], a
    ld [wHudP8Ind], a
    ld a, 1
    ld [wPageRedraw], a
    ; wTapEffective is restored from snapshot, but the runtime accumulator fields are
    ; not part of SaveParamTable. Clear them so any subsequent tap starts a fresh
    ; running average rather than inheriting stale state from a different session.
    xor a
    ld [wTapFrames], a
    ld [wTapFrac], a
    ld [wTapCounter], a
    ld [wTapCount], a
    ; Sync pending CH1 mode + sub-params to committed values (load/randomize/preset).
    ld a, [wCH1Mode]
    ld [wCH1ModePending], a
    ld a, [wCH1Detune]
    ld [wCH1DetunePending], a
    ld a, [wCH1Interval]
    ld [wCH1IntervalPending], a
    ld a, [wCH1ScaleDeg]
    ld [wCH1ScaleDegPending], a
    xor a
    ld [wCH1ModeNav], a
    ret

; =============================================================================
; V38 Preset Matrix snapshots (replaces the V31.3 undo/redo history)
; =============================================================================

; PresetSlotOffsets — word table: preset * SAVE_PARAM_COUNT for presets 0..15.
; Avoids an awkward 61-multiply in asm.
PresetSlotOffsets:
DEF PS_IDX = 0
REPT PRESET_COUNT
    dw SAVE_PARAM_COUNT * PS_IDX
DEF PS_IDX = PS_IDX + 1
ENDR

; GetPresetPtr(a = preset 0..15) → hl = wPresetBuf + preset*SAVE_PARAM_COUNT
; Clobbers a, d, e.
GetPresetPtr:
    add a               ; a = preset * 2 (word index)
    ld e, a
    ld d, 0
    ld hl, PresetSlotOffsets
    add hl, de          ; hl = table + preset*2
    ld a, [hli]
    ld e, a
    ld a, [hl]
    ld d, a             ; de = preset * SAVE_PARAM_COUNT
    ld hl, wPresetBuf
    add hl, de
    ret

; CaptureCurrentState — copy all SaveParamTable WRAM values to [hl..hl+SAVE_PARAM_COUNT-1].
; In: hl = destination. Clobbers a, b, c, d, e, hl.
CaptureCurrentState:
    ld de, SaveParamTable
.ccsLoop:
    ld a, [de]
    inc de
    ld c, a
    ld a, [de]
    inc de
    ld b, a
    or c
    ret z               ; bc == 0 → terminator
    ld a, [bc]          ; read WRAM param
    ld [hli], a         ; write to snapshot buffer
    jr .ccsLoop

; RestoreState — copy [hl..hl+SAVE_PARAM_COUNT-1] into WRAM via SaveParamTable.
; In: hl = source. Clobbers a, b, c, d, e, hl.
RestoreState:
    ld de, SaveParamTable
.rsLoop:
    ld a, [de]
    inc de
    ld c, a
    ld a, [de]
    inc de
    ld b, a
    or c
    ret z               ; bc == 0 → terminator
    ld a, [hli]         ; read from snapshot buffer
    ld [bc], a          ; write WRAM param
    jr .rsLoop

; ComputeNameDigits — returns d=field1(0..99), e=field2(0..99)
; field1 = (wRootNote*5 + wSpeed) mod 100
; field2 = (wCurrentBank*3 + wPatternType*17 + wOctaveRange*7) mod 100
ComputeNameDigits:
    ; field1
    ld a, [wRootNote]
    ld c, a
    add a               ; *2
    add a               ; *4
    add c               ; *5
    ld c, a
    ld a, [wSpeed]
    add c
    ld b, 100
.cnd_f1:
    cp b
    jr c, .cnd_f1done
    sub b
    jr .cnd_f1
.cnd_f1done:
    ld d, a             ; d = field1
    ; field2: bank*3
    ld a, [wCurrentBank]
    ld c, a
    add a               ; *2
    add c               ; *3
    ld c, a
    ; + patternType*17
    ld a, [wPatternType]
    ld e, a
    add a               ; *2
    add a               ; *4
    add a               ; *8
    add a               ; *16
    add e               ; *17
    add c               ; + bank*3
    ld c, a
    ; + octaveRange*7
    ld a, [wOctaveRange]
    ld e, a
    add a               ; *2
    add a               ; *4
    add a               ; *8
    sub e               ; *7
    add c               ; + (bank*3 + pattern*17)
    ld b, 100
.cnd_f2:
    cp b
    jr c, .cnd_f2done
    sub b
    jr .cnd_f2
.cnd_f2done:
    ld e, a             ; e = field2
    ret

; SaveSlot(a = slot index 0..7) — write current params to SRAM slot
; Transactional: writes occupied=0 first, payload second, occupied=1 last.
; Power loss mid-save leaves the slot empty rather than corrupt-but-valid.
; SaveSlot(a = slot index 0..7) → a = 1 if SRAM verified OK, 0 on write failure.
; Transactional: writes occupied=0 first, payload second, occupied=1 last.
; After commit, reads back occupied + word_idx to detect silent SRAM failures.
SaveSlot:
    push bc
    push de
    push hl
    ld [wSubDrawSlot], a     ; stash slot index (b clobbered by PickRandomWord/ComputeNameDigits)
    call PickRandomWord      ; a = word index
    ld [wSubSavedWord], a    ; keep word_idx for post-write verification
    push af                  ; save word index before ComputeNameDigits clobbers a/b/c
    call ComputeNameDigits   ; d=field1, e=field2
    push de                  ; save field1+field2

    call EnableSRAM
    ld a, [wSubDrawSlot]
    call GetSlotPtr          ; hl = slot SRAM addr
    ld [hl], 0               ; invalidate occupied (power-loss safety)
    inc hl
    pop de                   ; d=field1, e=field2 (top of stack first)
    pop af                   ; a=word_idx
    ld [hl], a               ; word_idx at offset 1
    inc hl
    ld [hl], d               ; field1 at offset 2
    inc hl
    ld [hl], e               ; field2 at offset 3
    inc hl
    ; Write params via SaveParamTable
    ld de, SaveParamTable
.saveLoop:
    ld a, [de]
    inc de
    ld c, a
    ld a, [de]
    inc de
    ld b, a
    or c
    jr z, .saveDone
    ; Read WRAM[bc] → write to SRAM[hl]
    ld a, [bc]
    ld [hli], a
    jr .saveLoop
.saveDone:
    ; V38.2: slot offset 65 (first pad byte, hl points there after the params)
    ; remembers which preset was playing when the slot was saved, so the dot
    ; reappears right after a slot load. $FF = none.
    ld a, [wPresetActive]
    ld [hl], a
    ; V38: persist the working preset matrix alongside the params. Runs before
    ; the occupied=1 commit so a power loss mid-matrix leaves the slot empty.
    ld a, [wSubDrawSlot]
    call WriteMatrixToSRAM
    ; Commit: write occupied=1 only after full payload is written
    ld a, [wSubDrawSlot]
    call GetSlotPtr          ; hl = slot SRAM base
    ld [hl], 1
    ; Verify round-trip: read back occupied byte
    ld a, [hl]
    cp 1
    jr nz, .saveVerifyFail
    ; Verify word_idx round-trip (catches open-bus / dead-SRAM scenarios)
    inc hl
    ld a, [hl]               ; a = stored word_idx
    ld b, a
    ld a, [wSubSavedWord]
    cp b
    jr nz, .saveVerifyFail
    call DisableSRAM
    ld a, 1                  ; verified OK
    pop hl
    pop de
    pop bc
    ret
.saveVerifyFail:
    call DisableSRAM
    xor a                    ; write failure detected
    pop hl
    pop de
    pop bc
    ret

; ValidateSlot(a = slot index) → a = 1 if all params in range, 0 if any out of range.
; Caller must EnableSRAM first. Read-only: no WRAM or SRAM writes.
ValidateSlot:
    push bc
    push de
    push hl
    call GetSlotPtr          ; hl = slot base (a preserved, b/d/e clobbered)
    inc hl                   ; skip occupied
    inc hl                   ; skip word_idx
    inc hl                   ; skip field1
    inc hl                   ; skip field2 → now at param byte 0
    call ValidateParamsAt
    pop hl
    pop de
    pop bc
    ret

; ValidateParamsAt — hl = first of SAVE_PARAM_COUNT stored param bytes.
; Returns a = 1 if every byte is within its SaveParamRangeTable bounds, else 0.
; Shared by ValidateSlot (slot records) and ReadMatrixFromSRAM (preset records).
; Clobbers a, b, c, d, e, hl.
ValidateParamsAt:
    ld de, SaveParamRangeTable
    ld b, SAVE_PARAM_COUNT
.vpLoop:
    ld a, [hli]              ; a = stored byte, advance hl
    ld c, a                  ; c = byte under test
    ld a, [de]               ; a = min
    inc de
    cp c
    jr c, .vpMaxCheck        ; min < byte: OK, check max
    jr nz, .vpFail           ; min > byte: FAIL
.vpMaxCheck:
    ld a, [de]               ; a = max
    inc de
    cp c
    jr c, .vpFail            ; max < byte: FAIL
    dec b
    jr nz, .vpLoop
    ld a, 1                  ; all params in range
    ret
.vpFail:
    xor a
    ret

; LoadSlot(a = slot index 0..7) → a = 1 on success, 0 if slot fails validation.
; On failure: occupied flag cleared in SRAM, WRAM unchanged.
LoadSlot:
    push bc
    push de
    push hl
    ld b, a
    ld [wSubDrawSlot], a ; V38: stash slot for the matrix copy (b dies in the loop)
    call EnableSRAM
    ld a, b
    call ValidateSlot    ; a=1 if all params in range, 0 if any out of range
    and a
    jr z, .loadFail      ; invalid: bail without touching WRAM
    ld a, b
    call GetSlotPtr     ; hl = slot SRAM addr
    ; Skip 4-byte header (occupied, word_idx, field1, field2)
    inc hl
    inc hl
    inc hl
    inc hl
    ; Load params via SaveParamTable
    ld de, SaveParamTable
.loadLoop:
    ld a, [de]
    inc de
    ld c, a
    ld a, [de]
    inc de
    ld b, a
    or c
    jr z, .loadDone
    ld a, [hli]         ; read SRAM
    ld [bc], a          ; write WRAM
    jr .loadLoop
.loadDone:
    ; V38.2: hl sits at slot offset 65 — the stored active-preset byte. Read it
    ; before ReadMatrixFromSRAM clobbers hl/banks; sanitized below.
    ld a, [hl]
    ld [wPresetActive], a
    ; V38: restore the slot's preset matrix into WRAM (validated per preset)
    ld a, [wSubDrawSlot]
    call ReadMatrixFromSRAM
    ; Sanitize the restored marker: pre-V38.2 slots carry garbage in that pad
    ; byte, and a valid index must point at an occupied cell of the matrix we
    ; just loaded. Anything else → $FF (no dot).
    ld a, [wPresetActive]
    cp PRESET_COUNT
    jr nc, .loadNoActive
    call GetPresetOccPtr        ; hl = wPresetOcc + index (clobbers d, e)
    ld a, [hl]
    and a
    jr nz, .loadActiveOk
.loadNoActive:
    ld a, $FF
    ld [wPresetActive], a
.loadActiveOk:
    call DisableSRAM
    call ApplyParamReconciliation
    pop hl
    pop de
    pop bc
    ld a, 1
    ret
.loadFail:
    ld a, b
    call GetSlotPtr           ; hl = slot base
    ld [hl], 0                ; clear occupied — slot shows as empty from now on
    call DisableSRAM
    pop hl
    pop de
    pop bc
    xor a
    ret

; WriteTwoDigits: b = value (0..99), hl = VRAM dest.
; Writes tens then units tile; advances hl by 2.
; Clobbers a, d, e.
WriteTwoDigits:
    ld e, b
    ld d, 0
.wtd:
    ld a, e
    cp 10
    jr c, .wtdDone
    sub 10
    ld e, a
    inc d
    jr .wtd
.wtdDone:
    ld a, d
    add TILE_DIGIT0
    ld [hli], a
    ld a, e
    add TILE_DIGIT0
    ld [hli], a
    ret

; DrawOneSlotRow: a = slot (0..7), de = VRAM row address.
; SRAM must be enabled. LCD must be off.
; Reads slot header and draws 20 tiles.
DrawOneSlotRow:
    ld [wSubDrawSlot], a
    ; Compute SRAM address
    ld b, a
    ld hl, $A008
    and a
    jr z, .dorSramAt
.dorSramOff:
    ld a, l
    add SAVE_SLOT_SIZE
    ld l, a
    jr nc, .dorNC
    inc h
.dorNC:
    dec b
    jr nz, .dorSramOff
.dorSramAt:
    ; Read header
    ld a, [hli]         ; occupied → b
    ld b, a
    ld a, [hli]         ; word_idx → c
    ld c, a
    ld a, [hli]         ; field1 → push
    push af
    ld a, [hli]         ; field2 → push (top of stack)
    push af
    ; b=occupied, c=word_idx; stack=[field2(top),field1]
    ; Set up VRAM pointer in hl
    ld h, d
    ld l, e
    ; Col 0: cursor indicator
    ld a, [wSubCursor]
    ld d, a
    ld a, [wSubDrawSlot]
    cp d
    jr nz, .dorNoInd
    ld a, [wSubArmCounter]
    and a
    ld a, TILE_PAUSE
    jr nz, .dorWriteInd
    ld a, TILE_PLAY
    jr .dorWriteInd
.dorNoInd:
    ld a, TILE_BLANK
.dorWriteInd:
    ld [hli], a
    ; Col 1: blank
    ld a, TILE_BLANK
    ld [hli], a
    ; Col 2: slot number 1-indexed
    ld a, [wSubDrawSlot]
    add TILE_DIGIT0 + 1
    ld [hli], a
    ; Col 3: blank
    ld a, TILE_BLANK
    ld [hli], a
    ; Check occupied
    ld a, b
    and a
    jr nz, .dorFilled
    ; Empty slot: "SLOT N" at cols 4-9, blanks 10-19
    ld a, TILE_S
    ld [hli], a
    ld a, TILE_L
    ld [hli], a
    ld a, TILE_O
    ld [hli], a
    ld a, TILE_T
    ld [hli], a
    ld a, TILE_BLANK
    ld [hli], a
    ld a, [wSubDrawSlot]
    add TILE_DIGIT0 + 1
    ld [hli], a
    ld b, 14
    ld a, TILE_BLANK
.dorEmptyPad:
    ld [hli], a
    dec b
    jr nz, .dorEmptyPad
    pop af              ; discard field2
    pop af              ; discard field1
    ret
.dorFilled:
    ; hl = VRAM col 4 (occupied case, skip cols 0-3 already written)
    ; Write 7-tile word at cols 4-10
    ; c = word_idx; save VRAM col-4 as de
    ld d, h
    ld e, l
    ; Compute word_idx * 7 in hl
    ld a, c
    ld l, a
    ld h, 0
    ld b, h
    ld c, l             ; bc = word_idx
    add hl, hl          ; *2
    add hl, hl          ; *4
    add hl, hl          ; *8
    ; hl = idx*8; subtract bc once to get idx*7
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc b
    ld h, a
    ; hl = word_idx * 7; add table base
    push de             ; save VRAM col 4
    ld de, SaveWordTable
    add hl, de
    pop de              ; de = VRAM col 4
    ; Copy 7 tiles: ROM hl → VRAM de
    ld b, 7
.dorWordCopy:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .dorWordCopy
    ; de = VRAM col 11; transfer to hl for further writes
    ld h, d
    ld l, e
    ; Pop field data: field2 on top, field1 below
    pop bc              ; b = field2 value, c = garbage (flags)
    pop de              ; d = field1 value, e = garbage
    ; Save field2 in c (WriteTwoDigits preserves c)
    ld c, b             ; c = field2
    ld b, d             ; b = field1 for WriteTwoDigits
    ; Col 11: blank
    ld a, TILE_BLANK
    ld [hli], a
    ; Cols 12-13: field1
    call WriteTwoDigits
    ; Col 14: blank
    ld a, TILE_BLANK
    ld [hli], a
    ; Cols 15-16: field2
    ld b, c
    call WriteTwoDigits
    ; Cols 17-19: blanks
    ld a, TILE_BLANK
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ret

; DrawSubPage — clear screen and render sub-page (SAVE/LOAD slot list, or the
; V38 preset matrix). Called from main loop when wSubDirty != 0. LCD re-enabled
; on exit.
DrawSubPage:
    xor a
    ld [wSubDirty], a
    call DisableLCD
    ld a, [wSubPage]
    cp 3
    jp z, DrawMatrixPage        ; V38 matrix owns the whole screen
    ; Clear rows 0-15 (V38.1: includes the hint rows so nothing bleeds between
    ; sub-pages; rows 16-17 belong to the help system)
    ld hl, $9800
    ld c, 16
.dspClear:
    push hl
    call BlankRow               ; clobbers a, b
    pop hl
    ld de, $20
    add hl, de
    dec c
    jr nz, .dspClear
    ; Draw title bar row 0 (20 inverted tiles)
    ld a, [wSubPage]
    cp 1
    ld hl, SubPageSaveTitleBar
    jr z, .dspTitle
    ld hl, SubPageLoadTitleBar
.dspTitle:
    ld de, $9800
    ld b, 20
.dspTitleCopy:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .dspTitleCopy
    ; Inverted blank row 1 (subtitle separator)
    ld hl, $9820
    ld a, INV_TILE_BLANK
    ld b, 20
.dspSubtitle:
    ld [hli], a
    dec b
    jr nz, .dspSubtitle
    ; Draw 8 slot rows (rows 3-10, VRAM $9860-$9940)
    call EnableSRAM
    ld b, 0
    ld de, $9860
.dspSlotLoop:
    ld a, b
    push bc
    push de
    call DrawOneSlotRow
    pop de
    pop bc
    ; Advance VRAM by $20 (32 bytes per row)
    ld a, e
    add $20
    ld e, a
    jr nc, .dspSlotNC
    inc d
.dspSlotNC:
    inc b
    ld a, b
    cp SAVE_SLOT_COUNT
    jr nz, .dspSlotLoop
    call DisableSRAM
    ; V38.1: static button-hint row 13 (per list type)
    ld a, [wSubPage]
    cp 1
    ld hl, SubPageSaveHintRow
    jr z, .dspHint
    ld hl, SubPageLoadHintRow
.dspHint:
    ld de, $99A0
    ld b, 20
.dspHintCopy:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .dspHintCopy
    call HelpRowTick
    ld a, $91
    ldh [rLCDC], a
    ret

; DrawMatrixPage — render the V38 4×4 preset matrix. Entered from DrawSubPage
; with the LCD already off; re-enables it on exit.
; Cells: [marker][2 digits] at cols 2/7/12/17, screen rows 3/5/7/9.
; Occupied = inverted digits, empty = plain digits. Cursor marker = ►, or ⏸
; while an overwrite/delete confirm is armed (same idiom as the slot lists).
DrawMatrixPage:
    ; Clear rows 0-15 (rows 16-17 belong to the help system)
    ld hl, $9800
    ld c, 16
.dmpClear:
    push hl
    call BlankRow               ; clobbers a, b; hl += 20
    pop hl
    ld de, $20
    add hl, de
    dec c
    jr nz, .dmpClear
    ; Title bar (20 inverted tiles) + inverted separator row 1
    ld hl, SubPageMatrixTitleBar
    ld de, $9800
    ld b, 20
.dmpTitle:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .dmpTitle
    ld hl, $9820
    ld a, INV_TILE_BLANK
    ld b, 20
.dmpSep:
    ld [hli], a
    dec b
    jr nz, .dmpSep
    ; 16 cells
    ld c, 0                     ; c = preset index
.dmpCell:
    call MatrixCellAddr         ; hl = marker address (preserves c)
    ; marker column: ►/⏸ on the cursor cell, blank elsewhere
    ld a, [wSubCursor]
    cp c
    jr nz, .dmpNoCursor
    ld a, [wSubArmCounter]
    and a
    ld a, TILE_PAUSE
    jr nz, .dmpMarker
    ld a, TILE_PLAY
    jr .dmpMarker
.dmpNoCursor:
    ld a, TILE_BLANK
.dmpMarker:
    ld [hli], a
    ; digit base: inverted when occupied
    push hl
    ld b, 0
    ld hl, wPresetOcc
    add hl, bc
    ld a, [hl]
    pop hl
    and a
    ld b, TILE_DIGIT0
    jr z, .dmpDigits
    ld b, INV_TILE_DIGIT0
.dmpDigits:
    ; cell number c+1 as two digits (01..16)
    ld a, c
    inc a
    ld d, 0
    cp 10
    jr c, .dmpTens
    sub 10
    inc d
.dmpTens:
    ld e, a                     ; e = units, d = tens
    ld a, d
    add b
    ld [hli], a
    ld a, e
    add b
    ld [hli], a
    ; V38.1: dot after the digits marks the currently playing preset
    ld a, [wPresetActive]
    cp c
    ld a, TILE_DOT
    jr z, .dmpActive
    ld a, TILE_BLANK
.dmpActive:
    ld [hl], a
    inc c
    ld a, c
    cp PRESET_COUNT
    jr nz, .dmpCell
    ; Button hint rows (static): row 13 + row 15
    ld hl, MatrixHintRow1
    ld de, $99A0
    ld b, 20
.dmpHint1:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .dmpHint1
    ld hl, MatrixHintRow2
    ld de, $99E0
    ld b, 20
.dmpHint2:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .dmpHint2
    call HelpRowTick
    ld a, $91
    ldh [rLCDC], a
    ret

; MatrixCellAddr — c = preset index → hl = VRAM address of the cell's marker.
; Grid rows 3/5/7/9 = $9860 + row*$40; marker cols 1/6/11/16 = 1 + col*5.
; Cell = [marker][digit][digit][active-dot] → last dot lands on col 19 (V38.1:
; col-2 base put the last column's dot on invisible col 20).
; Preserves c. Clobbers a, d, e.
MatrixCellAddr:
    ld a, c
    and %00001100               ; row*4
    swap a                      ; ×16 → row*$40
    ld e, a
    ld d, 0
    ld hl, $9860 + 1
    add hl, de
    ld a, c
    and %00000011               ; col
    ld e, a
    add a
    add a                       ; col*4
    add e                       ; col*5
    ld e, a
    add hl, de                  ; d still 0
    ret

; HandleSubPageInput — process joypad in save/load slot list or preset matrix.
; b = held buttons, c = new presses (same convention as HandleInput).
HandleSubPageInput:
    ld a, [wSubPage]
    cp 3
    jp z, HandleMatrixInput     ; V38 preset matrix owns its own input
    ; UP: move cursor up with wrap
    bit 2, c
    jr z, .hsiNoUp
    ld a, [wSubCursor]
    and a
    jr z, .hsiWrapTop
    dec a
    jr .hsiStoreCursor
.hsiWrapTop:
    ld a, SAVE_SLOT_COUNT - 1
.hsiStoreCursor:
    ld [wSubCursor], a
    xor a
    ld [wSubArmCounter], a  ; cancel any armed state on cursor move
    ld a, 1
    ld [wSubDirty], a
    ret
.hsiNoUp:
    ; DOWN: move cursor down with wrap
    bit 3, c
    jr z, .hsiNoDown
    ld a, [wSubCursor]
    cp SAVE_SLOT_COUNT - 1
    jr z, .hsiWrapBot
    inc a
    jr .hsiStoreCursor2
.hsiWrapBot:
    xor a
.hsiStoreCursor2:
    ld [wSubCursor], a
    xor a
    ld [wSubArmCounter], a
    ld a, 1
    ld [wSubDirty], a
    ret
.hsiNoDown:
    ; B alone newly pressed: exit sub-page
    bit 5, c
    jr z, .hsiNoB
    bit 4, b
    jr nz, .hsiNoB          ; AB → ignore
    xor a
    ld [wSubPage], a
    ld [wSubArmCounter], a
    ld a, 1
    ld [wPageRedraw], a     ; redraw CONTROLS page
    ret
.hsiNoB:
    ; A newly pressed: save or load action
    bit 4, c
    ret z
    ld a, [wSubPage]
    cp 1
    jp z, SubPageSaveAction
    jp SubPageLoadAction

SubPageSaveAction:
    ld a, [wSubArmCounter]
    and a
    jr z, .armSave
    ; Already armed: commit save
    xor a
    ld [wSubArmCounter], a
    ld a, [wSubCursor]
    call SaveSlot            ; a=1 verified, a=0 write failure
    and a
    jr z, .saveFailed
    xor a
    ld hl, HelpStr_Saved
    call ShowHelpByIndex
    ld a, 1
    ld [wSubDirty], a
    ret
.saveFailed:
    xor a
    ld hl, HelpStr_SaveFail
    call ShowHelpByIndex
    ld a, 1
    ld [wSubDirty], a
    ret
.armSave:
    ; Arm two-press confirm
    ld a, SUB_ARM_FRAMES
    ld [wSubArmCounter], a
    ld a, 1
    ld [wSubDirty], a
    ; Show appropriate prompt
    ld a, [wSubCursor]
    call GetSlotOccupied
    and a
    jr nz, .armOccupied
    xor a
    ld hl, HelpStr_PressAgainSave
    jp ShowHelpByIndex
.armOccupied:
    xor a
    ld hl, HelpStr_PressAgainOverwr
    jp ShowHelpByIndex

SubPageLoadAction:
    ld a, [wSubCursor]
    call GetSlotOccupied
    and a
    jr nz, .doLoad
    ; Empty slot: flash EMPTY SLOT
    xor a
    ld hl, HelpStr_EmptySlot
    jp ShowHelpByIndex
.doLoad:
    ld a, [wSubCursor]
    call LoadSlot            ; a=1 on success, 0 if slot was invalid (cleared)
    and a
    jr z, .loadInvalid
    xor a
    ld hl, HelpStr_Loaded
    call ShowHelpByIndex
    ld a, 1
    ld [wSubDirty], a
    ret
.loadInvalid:
    ld a, 1
    ld [wSubDirty], a        ; force slot list repaint — slot now shows SLOT N
    xor a
    ld hl, HelpStr_EmptySlot
    jp ShowHelpByIndex

; =============================================================================
; V38 Preset Matrix sub-page (wSubPage = 3)
; =============================================================================

; GetPresetOccPtr(a = preset 0..15) → hl = wPresetOcc + preset. Clobbers d, e.
GetPresetOccPtr:
    ld d, 0
    ld e, a
    ld hl, wPresetOcc
    add hl, de
    ret

; HandleMatrixInput — joypad while the 4×4 preset matrix is on screen.
; b = held buttons, c = new presses. Cursor: bits 3-2 = row, bits 1-0 = column.
; A = save (2-press confirm on overwrite), B = load (1 press),
; START = delete (2-press confirm), SELECT = back to CONTROLS.  (V38.1: A/B
; swapped on user request — A saves, B loads.)
; Any cursor move cancels an armed confirm (same idiom as the slot lists).
HandleMatrixInput:
    bit 2, c                    ; UP → row-1 (wraps)
    jr z, .hmNoUp
    ld a, [wSubCursor]
    sub 4
    and 15
    jr .hmStoreCursor
.hmNoUp:
    bit 3, c                    ; DOWN → row+1 (wraps)
    jr z, .hmNoDown
    ld a, [wSubCursor]
    add 4
    and 15
    jr .hmStoreCursor
.hmNoDown:
    bit 1, c                    ; LEFT → column-1 within the row (wraps)
    jr z, .hmNoLeft
    ld a, [wSubCursor]
    ld d, a
    and %00001100               ; keep row bits
    ld e, a
    ld a, d
    dec a
    and %00000011
    or e
    jr .hmStoreCursor
.hmNoLeft:
    bit 0, c                    ; RIGHT → column+1 within the row (wraps)
    jr z, .hmButtons
    ld a, [wSubCursor]
    ld d, a
    and %00001100
    ld e, a
    ld a, d
    inc a
    and %00000011
    or e
.hmStoreCursor:
    ld [wSubCursor], a
    xor a
    ld [wSubArmCounter], a      ; cursor move cancels any armed confirm
    ld [wSubArmAction], a
    ld a, 1
    ld [wSubDirty], a
    ret
.hmButtons:
    bit 6, c                    ; SELECT → exit to CONTROLS
    jr z, .hmNoSel
    xor a
    ld [wSubPage], a
    ld [wSubArmCounter], a
    ld [wSubArmAction], a
    ld a, 1
    ld [wPageRedraw], a
    ret
.hmNoSel:
    bit 4, c                    ; A → save
    jr z, .hmNoA
    jp MatrixSavePreset
.hmNoA:
    bit 5, c                    ; B → load
    jr z, .hmNoB
    jp MatrixLoadPreset
.hmNoB:
    bit 7, c                    ; START → delete
    ret z
    jp MatrixDeletePreset

; MatrixLoadPreset — B press: restore the selected preset into the live params.
; One press by design (fast live switching); empty cells just flash EMPTY SLOT.
MatrixLoadPreset:
    xor a
    ld [wSubArmCounter], a      ; a load always cancels a pending confirm
    ld [wSubArmAction], a
    ld a, [wSubCursor]
    call GetPresetOccPtr
    ld a, [hl]
    and a
    jr z, .mlEmpty
    ld a, [wSubCursor]
    ld [wPresetActive], a       ; V38.1: this cell is now the playing preset
    ld a, [wSubCursor]
    call GetPresetPtr
    call RestoreState
    call ApplyParamReconciliation
    ; ApplyParamReconciliation set wPageRedraw — clear it, or the main loop
    ; redraws the CONTROLS page and kicks us out of the matrix (.redrawPage9
    ; resets wSubPage). Live use loads presets in quick succession; we stay on
    ; the matrix until SELECT. The page repaint happens on exit anyway.
    xor a
    ld [wPageRedraw], a
    ld hl, HelpStr_Loaded
    call ShowHelpByIndex
    ld a, 1
    ld [wSubDirty], a           ; repaint (arm marker may need clearing)
    ret
.mlEmpty:
    ld a, 1
    ld [wSubDirty], a
    xor a
    ld hl, HelpStr_EmptySlot
    jp ShowHelpByIndex

; MatrixSavePreset — A press: snapshot live params into the selected cell.
; Empty cell: immediate. Occupied cell: two-press confirm via wSubArmCounter
; (armed action 1); the second A within SUB_ARM_FRAMES commits the overwrite.
MatrixSavePreset:
    ld a, [wSubArmAction]
    cp 1
    jr nz, .msFresh
    ld a, [wSubArmCounter]
    and a
    jr z, .msFresh              ; arm expired → treat as a fresh press
    xor a                       ; armed overwrite confirmed
    ld [wSubArmCounter], a
    ld [wSubArmAction], a
    jr .msWrite
.msFresh:
    xor a
    ld [wSubArmCounter], a      ; cancel any foreign arm (e.g. pending delete)
    ld [wSubArmAction], a
    ld a, [wSubCursor]
    call GetPresetOccPtr
    ld a, [hl]
    and a
    jr z, .msWrite              ; empty cell → save immediately
    ld a, 1                     ; occupied → arm overwrite confirm
    ld [wSubArmAction], a
    ld a, SUB_ARM_FRAMES
    ld [wSubArmCounter], a
    ld a, 1
    ld [wSubDirty], a
    xor a
    ld hl, HelpStr_PressAgainOverwr
    jp ShowHelpByIndex
.msWrite:
    ld a, [wSubCursor]
    call GetPresetPtr           ; hl = wPresetBuf slot
    call CaptureCurrentState
    ld a, [wSubCursor]
    call GetPresetOccPtr
    ld [hl], 1
    ld a, [wSubCursor]
    ld [wPresetActive], a       ; V38.1: cell now equals the live params
    xor a
    ld hl, HelpStr_Saved
    call ShowHelpByIndex
    ld a, 1
    ld [wSubDirty], a
    ret

; MatrixDeletePreset — START press: clear the selected cell's occupied flag.
; Two-press confirm (armed action 2); empty cells just flash EMPTY SLOT.
MatrixDeletePreset:
    ld a, [wSubArmAction]
    cp 2
    jr nz, .mdFresh
    ld a, [wSubArmCounter]
    and a
    jr z, .mdFresh
    xor a                       ; armed delete confirmed
    ld [wSubArmCounter], a
    ld [wSubArmAction], a
    ld a, [wSubCursor]
    call GetPresetOccPtr
    ld [hl], 0
    ; V38.1: deleting the active cell clears the playing marker
    ld a, [wPresetActive]
    ld d, a
    ld a, [wSubCursor]
    cp d
    jr nz, .mdKeepActive
    ld a, $FF
    ld [wPresetActive], a
.mdKeepActive:
    xor a
    ld hl, HelpStr_Deleted
    call ShowHelpByIndex
    ld a, 1
    ld [wSubDirty], a
    ret
.mdFresh:
    xor a
    ld [wSubArmCounter], a
    ld [wSubArmAction], a
    ld a, [wSubCursor]
    call GetPresetOccPtr
    ld a, [hl]
    and a
    jr z, .mdEmpty
    ld a, 2                     ; occupied → arm delete confirm
    ld [wSubArmAction], a
    ld a, SUB_ARM_FRAMES
    ld [wSubArmCounter], a
    ld a, 1
    ld [wSubDirty], a
    xor a
    ld hl, HelpStr_PressAgainDelete
    jp ShowHelpByIndex
.mdEmpty:
    ld a, 1
    ld [wSubDirty], a
    xor a
    ld hl, HelpStr_EmptySlot
    jp ShowHelpByIndex

; =============================================================================
; Data Section
; =============================================================================

SECTION "Data", ROMX, BANK[1]

; --- Euclidean Drum Machine pattern table (510 bytes) -----------------------
; Generated by tools/gen-euclid-table.py. Layout: 15 rows (N=2..16) x 17 cols
; (K=0..16) x 2 bytes. Pattern is 16-bit big-endian, MSB = slot 0; low (16-N)
; bits = 0. Byte offset = (N - 2) * 34 + K * 2.
EuclidPatternTable:
INCLUDE "src/euclid-table.inc"

; --- Frequency Table (60 entries, C2-B6, 2 bytes each little-endian) ---------

FreqTable:
    ; Octave 2
    dw $002C    ; C2
    dw $009D    ; C#2
    dw $0107    ; D2
    dw $016B    ; D#2
    dw $01C9    ; E2
    dw $0223    ; F2
    dw $0277    ; F#2
    dw $02C7    ; G2
    dw $0312    ; G#2
    dw $0358    ; A2
    dw $039B    ; A#2
    dw $03DA    ; B2
    ; Octave 3
    dw $0416    ; C3
    dw $044E    ; C#3
    dw $0483    ; D3
    dw $04B5    ; D#3
    dw $04E5    ; E3
    dw $0511    ; F3
    dw $053B    ; F#3
    dw $0563    ; G3
    dw $0589    ; G#3
    dw $05AC    ; A3
    dw $05CE    ; A#3
    dw $05ED    ; B3
    ; Octave 4
    dw $060B    ; C4
    dw $0627    ; C#4
    dw $0642    ; D4
    dw $065B    ; D#4
    dw $0672    ; E4
    dw $0689    ; F4
    dw $069E    ; F#4
    dw $06B2    ; G4
    dw $06C4    ; G#4
    dw $06D6    ; A4
    dw $06E7    ; A#4
    dw $06F7    ; B4
    ; Octave 5
    dw $0706    ; C5
    dw $0714    ; C#5
    dw $0721    ; D5
    dw $072D    ; D#5
    dw $0739    ; E5
    dw $0744    ; F5
    dw $074F    ; F#5
    dw $0759    ; G5
    dw $0762    ; G#5
    dw $076B    ; A5
    dw $0773    ; A#5
    dw $077B    ; B5
    ; Octave 6
    dw $0783    ; C6
    dw $078A    ; C#6
    dw $0790    ; D6
    dw $0797    ; D#6
    dw $079D    ; E6
    dw $07A2    ; F6
    dw $07A7    ; F#6
    dw $07AC    ; G6
    dw $07B1    ; G#6
    dw $07B6    ; A6
    dw $07BA    ; A#6
    dw $07BE    ; B6

; --- Scale Size Table (21 banks, notes per octave) --------------------------

ScaleSizeTable:
    db 7, 7, 7, 7, 7, 7, 7     ; Church modes
    db 7, 7, 7, 7, 7, 7, 7     ; Harmonic minor modes
    db 6, 8, 9, 8, 6, 8, 10    ; Messiaen modes
    db 5, 5, 5, 5, 5, 5, 5     ; Ethiopian pentatonic

; --- Scale Table (21 banks x 10 semitone offsets, zero-padded) ---------------

ScaleTable:
    db 0, 2, 4, 5, 7, 9, 11, 0, 0, 0    ; 0  Ionian
    db 0, 2, 3, 5, 7, 9, 10, 0, 0, 0    ; 1  Dorian
    db 0, 1, 3, 5, 7, 8, 10, 0, 0, 0    ; 2  Phrygian
    db 0, 2, 4, 6, 7, 9, 11, 0, 0, 0    ; 3  Lydian
    db 0, 2, 4, 5, 7, 9, 10, 0, 0, 0    ; 4  Mixolydian
    db 0, 2, 3, 5, 7, 8, 10, 0, 0, 0    ; 5  Aeolian
    db 0, 1, 3, 5, 6, 8, 10, 0, 0, 0    ; 6  Locrian
    db 0, 2, 3, 5, 7, 8, 11, 0, 0, 0    ; 7  Harmonic Minor
    db 0, 1, 3, 5, 6, 9, 10, 0, 0, 0    ; 8  Locrian N6
    db 0, 2, 4, 5, 8, 9, 11, 0, 0, 0    ; 9  Ionian #5
    db 0, 2, 3, 6, 7, 9, 10, 0, 0, 0    ; 10 Dorian #11
    db 0, 1, 4, 5, 7, 8, 10, 0, 0, 0    ; 11 Phrygian Dominant
    db 0, 3, 4, 6, 7, 9, 11, 0, 0, 0    ; 12 Lydian #2
    db 0, 1, 3, 4, 6, 8, 9,  0, 0, 0    ; 13 Super Locrian
    db 0, 2, 4, 6, 8, 10, 0, 0, 0, 0    ; 14 Messiaen 1 (Whole Tone)
    db 0, 1, 3, 4, 6, 7, 9, 10, 0, 0    ; 15 Messiaen 2 (Octatonic)
    db 0, 2, 3, 4, 6, 7, 8, 10, 11, 0   ; 16 Messiaen 3
    db 0, 1, 2, 5, 6, 7, 8, 11, 0, 0    ; 17 Messiaen 4
    db 0, 1, 5, 6, 7, 11, 0, 0, 0, 0    ; 18 Messiaen 5
    db 0, 2, 4, 5, 6, 8, 10, 11, 0, 0   ; 19 Messiaen 6
    db 0, 1, 2, 3, 5, 6, 7, 8, 9, 11    ; 20 Messiaen 7
    db 0, 2, 4, 7, 9, 0, 0, 0, 0, 0    ; 21 Tizita Maj
    db 0, 2, 3, 7, 8, 0, 0, 0, 0, 0    ; 22 Tizita Min
    db 0, 4, 5, 7, 11, 0, 0, 0, 0, 0   ; 23 Bati Maj
    db 0, 3, 5, 7, 10, 0, 0, 0, 0, 0   ; 24 Bati Min
    db 0, 1, 5, 7, 8, 0, 0, 0, 0, 0    ; 25 Ambassel
    db 0, 1, 5, 6, 9, 0, 0, 0, 0, 0    ; 26 Anchihoye
    db 0, 2, 5, 7, 10, 0, 0, 0, 0, 0   ; 27 Yematibela

; --- Mode Names (21 x 10 tile indices) ---------------------------------------

ModeNames:
    db TILE_I, TILE_O, TILE_N, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK                   ; 0  Ionian
    db TILE_D, TILE_O, TILE_R, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK                   ; 1  Dorian
    db TILE_P, TILE_H, TILE_R, TILE_Y, TILE_G, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK                           ; 2  Phrygian
    db TILE_L, TILE_Y, TILE_D, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK                   ; 3  Lydian
    db TILE_M, TILE_I, TILE_X, TILE_O, TILE_L, TILE_Y, TILE_D, TILE_I, TILE_A, TILE_N                                   ; 4  Mixolydian
    db TILE_A, TILE_E, TILE_O, TILE_L, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK, TILE_BLANK                       ; 5  Aeolian
    db TILE_L, TILE_O, TILE_C, TILE_R, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK, TILE_BLANK                       ; 6  Locrian
    db TILE_H, TILE_A, TILE_R, TILE_M, TILE_BLANK, TILE_M, TILE_I, TILE_N, TILE_BLANK, TILE_BLANK                       ; 7  Harm Min
    db TILE_L, TILE_O, TILE_C, TILE_R, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_N, TILE_DIGIT0 + 6                      ; 8  Locrian N6
    db TILE_I, TILE_O, TILE_N, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK, TILE_SHARP, TILE_DIGIT0 + 5              ; 9  Ionian #5
    db TILE_D, TILE_O, TILE_R, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_SHARP, TILE_DIGIT0 + 1, TILE_DIGIT0 + 1         ; 10 Dorian #11
    db TILE_P, TILE_H, TILE_R, TILE_Y, TILE_G, TILE_BLANK, TILE_D, TILE_O, TILE_M, TILE_BLANK                           ; 11 Phryg Dom
    db TILE_L, TILE_Y, TILE_D, TILE_I, TILE_A, TILE_N, TILE_BLANK, TILE_BLANK, TILE_SHARP, TILE_DIGIT0 + 2              ; 12 Lydian #2
    db TILE_S, TILE_U, TILE_P, TILE_E, TILE_R, TILE_BLANK, TILE_L, TILE_O, TILE_C, TILE_BLANK                           ; 13 Super Loc
    db TILE_W, TILE_H, TILE_O, TILE_L, TILE_E, TILE_T, TILE_O, TILE_N, TILE_E, TILE_BLANK                               ; 14 Whole Tone
    db TILE_O, TILE_C, TILE_T, TILE_A, TILE_T, TILE_O, TILE_N, TILE_I, TILE_C, TILE_BLANK                               ; 15 Octatonic
    db TILE_M, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_DIGIT0 + 3, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK      ; 16 Messiaen 3
    db TILE_M, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_DIGIT0 + 4, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK      ; 17 Messiaen 4
    db TILE_M, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_DIGIT0 + 5, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK      ; 18 Messiaen 5
    db TILE_M, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_DIGIT0 + 6, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK      ; 19 Messiaen 6
    db TILE_M, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_DIGIT0 + 7, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK      ; 20 Messiaen 7
    db TILE_T, TILE_I, TILE_Z, TILE_I, TILE_T, TILE_A, TILE_BLANK, TILE_M, TILE_A, TILE_J                             ; 21 Tizita Maj
    db TILE_T, TILE_I, TILE_Z, TILE_I, TILE_T, TILE_A, TILE_BLANK, TILE_M, TILE_I, TILE_N                             ; 22 Tizita Min
    db TILE_B, TILE_A, TILE_T, TILE_I, TILE_BLANK, TILE_BLANK, TILE_M, TILE_A, TILE_J, TILE_BLANK                     ; 23 Bati Maj
    db TILE_B, TILE_A, TILE_T, TILE_I, TILE_BLANK, TILE_BLANK, TILE_M, TILE_I, TILE_N, TILE_BLANK                     ; 24 Bati Min
    db TILE_A, TILE_M, TILE_B, TILE_A, TILE_S, TILE_S, TILE_E, TILE_L, TILE_BLANK, TILE_BLANK                         ; 25 Ambassel
    db TILE_A, TILE_N, TILE_C, TILE_H, TILE_I, TILE_H, TILE_O, TILE_Y, TILE_E, TILE_BLANK                             ; 26 Anchihoye
    db TILE_Y, TILE_E, TILE_M, TILE_A, TILE_T, TILE_I, TILE_B, TILE_E, TILE_L, TILE_A                                 ; 27 Yematibela

; --- Note Names (12 x 2 tile indices: letter, accidental) -------------------

NoteNames:
    db TILE_C, TILE_BLANK       ; 0  C
    db TILE_C, TILE_SHARP       ; 1  C#
    db TILE_D, TILE_BLANK       ; 2  D
    db TILE_D, TILE_SHARP       ; 3  D#
    db TILE_E, TILE_BLANK       ; 4  E
    db TILE_F, TILE_BLANK       ; 5  F
    db TILE_F, TILE_SHARP       ; 6  F#
    db TILE_G, TILE_BLANK       ; 7  G
    db TILE_G, TILE_SHARP       ; 8  G#
    db TILE_A, TILE_BLANK       ; 9  A
    db TILE_A, TILE_SHARP       ; 10 A#
    db TILE_B, TILE_BLANK       ; 11 B

; --- Wave Presets (3 x 2 bytes: duty, envelope) -----------------------------

WavePresets:
    db $80, $F0    ; 0 STD: 50% duty, vol 15 sustained
    db $40, $F0    ; 1 THN: 25% duty, vol 15 sustained
    db $80, $F0    ; 2 LNG: 50% duty, vol 15 sustained
    db $00, $F0    ; 3 NRW: 12.5% duty, vol 15 sustained

; --- Noise Presets (4 x 3 bytes: NR41, NR42, NR43) --------------------------
; NR44 is always $80 at trigger (no length enable) — envelope shapes decay.
; Row 1 (KIK) is kept for table alignment but dispatched via PlayKickAccent,
; which uses NoisePresets_KickClick for the CH4 layer instead of this row.
NoisePresets:
    db $00, $00, $00   ; 0 OFF (placeholder; never dispatched)
    db $00, $00, $00   ; 1 KIK (unused; PlayKickAccent handles this slot)
    db $00, $F2, $20   ; 2 SNR: vol 15 + decay 2, mid pitch (shift 2, div 0, 15-bit)
    db $00, $F1, $18   ; 3 RIM: vol 15 + decay 1, 7-bit LFSR sharp click

; CH4 transient layer for PlayKickAccent — short bright click on top of CH1
; sweep. Higher frequency (shift 2) than a deep-thump noise so the attack
; reads as a pick/beater hit, not as the kick body itself.
NoisePresets_KickClick:
    db $00, $A2, $20   ; vol 10 + decay 2, shift 2 div 0 15-bit — short sizzle

; --- Accent Tail Frames (4 entries, indexed by wNoiseAccent) ----------------
; VBlank frames the accent envelope is still ringing after trigger. Used to
; suppress gate-noise fill on the next step so its CH4 retrigger doesn't clip
; the accent's decay tail. Tuned to the longest envelope of each preset:
;   KIK: CH1 sweep + CH4 click both decay ~26-30 frames
;   SNR: NR42=$F2 → step 2, decay ~16 frames
;   RIM: NR42=$F1 → step 1, decay ~10 frames
AccentTailFrames:
    db 0       ; 0 OFF
    db 30      ; 1 KIK
    db 16      ; 2 SNR
    db 10      ; 3 RIM

; --- Noise Accent Names (4 x 3 tile indices) --------------------------------
NoiseAccentNames:
    db TILE_O, TILE_F, TILE_F       ; 0 OFF
    db TILE_K, TILE_I, TILE_K       ; 1 KIK
    db TILE_S, TILE_N, TILE_R       ; 2 SNR
    db TILE_R, TILE_I, TILE_M       ; 3 RIM

; --- Fill Color Names (2 x 3 tile indices) ----------------------------------
FillColorNames:
    db TILE_H, TILE_I, TILE_S       ; 0 HIS (15-bit LFSR, smooth hiss)
    db TILE_M, TILE_T, TILE_L       ; 1 MTL (7-bit LFSR, metallic)

; --- Fill Shape Names (5 x 3 tile indices) ----------------------------------
; V24: rename UPW/DNW/UPC/DNC → ER↑/ER↓/LR↑/LR↓ so each tile maps tile-for-tile
; to a word in the tooltip expansion (E=EXP, L=LIN, R=RAMP, ↑/↓=UP/DOWN).
FillShapeNames:
    db TILE_F, TILE_L, TILE_T              ; 0 FLT  (flat sustain)
    db TILE_E, TILE_R, TILE_UP_ARROW       ; 1 ER↑  (exponential ramp up)
    db TILE_E, TILE_R, TILE_DN_ARROW       ; 2 ER↓  (exponential ramp down)
    db TILE_L, TILE_R, TILE_UP_ARROW       ; 3 LR↑  (linear ramp up)
    db TILE_L, TILE_R, TILE_DN_ARROW       ; 4 LR↓  (linear ramp down)

; --- Tonal Noise Tables ------------------------------------------------------
; LevelTable: NR42 high-nibble values for wTonalLevel 0..7 (perceptual scale).
TonalLevelTable:
    db $00, $02, $04, $06, $09, $0B, $0D, $0F

; DecayEnvelope: NR42 low nibble (envelope dir=0/decrease + step). CUT=$00 is
; sustained; gate-off path writes NR42=$08 (DAC alive, vol 0) for click-free mute.
TonalDecayEnvelope:
    db $02      ; 0 PNG: ~0.5s natural decay
    db $07      ; 1 RNG: ~1.6s ringing tail (lower if too long on hardware)
    db $00      ; 2 CUT: sustained until software mute on gate-off

; Mapping tables (60+12+60 = 132 bytes). All seed values to be tuned on real GB.
; NR43 7-bit field: clock-shift (high nibble) + divider ratio (bits 2..0).
; Bit 3 (LFSR width) is OR'd in at trigger time from wTonalWidth.
TonalMap_TRK:
    ; 60 entries, roughly linear high→low NR43 (low pitch index → high NR43 = low Hz).
    ; Seed: descending from $77 to $00 across 60 notes (high note → high pitch = low NR43).
    db $77, $76, $75, $74, $73, $72, $71, $70, $66, $65, $64, $63
    db $62, $61, $60, $57, $56, $55, $54, $53, $52, $51, $50, $47
    db $46, $45, $44, $43, $42, $41, $40, $37, $36, $35, $34, $33
    db $32, $31, $30, $27, $26, $25, $24, $23, $22, $21, $20, $17
    db $16, $15, $14, $13, $12, $11, $10, $07, $06, $05, $04, $00

TonalMap_GML:
    ; 12 hand-picked NR43 values across the chromatic — "the gamelan voicing".
    ; Seed: clusters of similar pitches, picking a coherent metallic palette.
    ; Entry 0 lifted from $44 → $36 after on-device tuning: $44 (clock-shift 4)
    ; produced sub-tonal rumble in 7B mode instead of a pitched ping. $36 sits
    ; between the next block ($35) and clear of any other entry — applies to
    ; both 7B and 15-bit since the table is shared (width OR'd in at trigger).
    db $36, $42, $40, $35, $33, $31, $25, $23, $21, $15, $13, $11

TonalMap_INV:
    ; Inverted: high note = low pitch (NR43 ascending). Hand-tuned, not auto-mirrored.
    db $00, $04, $05, $06, $07, $10, $11, $12, $13, $14, $15, $16
    db $17, $20, $21, $22, $23, $24, $25, $26, $27, $30, $31, $32
    db $33, $34, $35, $36, $37, $40, $41, $42, $43, $44, $45, $46
    db $47, $50, $51, $52, $53, $54, $55, $56, $57, $60, $61, $62
    db $63, $64, $65, $66, $70, $71, $72, $73, $74, $75, $76, $77

; --- Tonal Noise Names (3 tiles each) ---------------------------------------
TonalModeNames:
    db TILE_O, TILE_F, TILE_F                       ; 0 OFF
    db TILE_BLANK, TILE_O, TILE_N                   ; 1 ON

TonalMapNames:
    db TILE_T, TILE_R, TILE_K                       ; 0 TRK
    db TILE_G, TILE_M, TILE_L                       ; 1 GML
    db TILE_I, TILE_N, TILE_V                       ; 2 INV

TonalWidthNames:
    db TILE_DIGIT0+1, TILE_DIGIT0+5, TILE_BLANK     ; 0 15  (wTonalWidth=0 = 15-bit white)
    db TILE_BLANK, TILE_DIGIT0+7, TILE_B            ; 1  7B (wTonalWidth=1 = 7-bit metallic)

TonalDecayNames:
    db TILE_P, TILE_N, TILE_G                       ; 0 PNG
    db TILE_R, TILE_N, TILE_G                       ; 1 RNG
    db TILE_C, TILE_U, TILE_T                       ; 2 CUT

TonalTrigNames:
    db TILE_E, TILE_V, TILE_R                       ; 0 EVR (every step)
    db TILE_H, TILE_L, TILE_F                       ; 1 HLF (every 2nd)
    db TILE_BLANK, TILE_Q, TILE_DIGIT0+4            ; 2 Q4 (every 4th)

TonalPriNames:
    db TILE_A, TILE_L, TILE_L                       ; 0 ALL
    db TILE_PLUS, TILE_A, TILE_C                    ; 1 +AC (+ACC, 3 tiles)
    db TILE_PLUS, TILE_F, TILE_I                    ; 2 +FI (+FIL, 3 tiles)
    db TILE_S, TILE_O, TILE_L                       ; 3 SOL (SOLO, 3 tiles)

TonalLockNames:
    db TILE_F, TILE_R, TILE_E                       ; 0 FRE (free, normal trigger)
    db TILE_L, TILE_O, TILE_K                       ; 1 LOK (locked, CH4 frozen)

TonalLockNamesInv:
    db INV_TILE_F, INV_TILE_R, INV_TILE_E           ; 0 FRE inverted
    db INV_TILE_L, INV_TILE_O, INV_TILE_K           ; 1 LOK inverted

; --- Euclidean Drum Machine Names (3 tiles each) ----------------------------
EuclidKickSoundNames:
    db TILE_T, TILE_G, TILE_T                       ; 0 TGT (TIGHT)
    db TILE_B, TILE_O, TILE_M                       ; 1 BOM (BOOM)
    db TILE_S, TILE_U, TILE_B                       ; 2 SUB
    db TILE_P, TILE_C, TILE_H                       ; 3 PCH (PUNCH)

EuclidKickDecayNames:
    db TILE_S, TILE_H, TILE_T                       ; 0 SHT (SHRT)
    db TILE_M, TILE_I, TILE_D                       ; 1 MID
    db TILE_L, TILE_N, TILE_G                       ; 2 LNG (LONG)

; --- Euclid MOD LFO name tables (V35) -----------------------------------------
EucLfoShapeNames:
    db TILE_O, TILE_F, TILE_F                       ; 0 OFF
    db TILE_U, TILE_P, TILE_BLANK                   ; 1 UP  (ramp up)
    db TILE_D, TILE_N, TILE_BLANK                   ; 2 DN  (ramp down)
    db TILE_T, TILE_R, TILE_I                       ; 3 TRI (triangle)
    db TILE_S, TILE_I, TILE_N                       ; 4 SIN (sine)
    db TILE_R, TILE_N, TILE_D                       ; 5 RND (random)

EucLfoRateNames:
    db TILE_DIGIT0+2, TILE_S, TILE_T               ; 0 2ST (2 steps)
    db TILE_DIGIT0+4, TILE_S, TILE_T               ; 1 4ST (4 steps)
    db TILE_DIGIT0+8, TILE_S, TILE_T               ; 2 8ST (8 steps)
    db TILE_DIGIT0+1, TILE_B, TILE_R               ; 3 1BR (1 bar)
    db TILE_DIGIT0+2, TILE_B, TILE_R               ; 4 2BR (2 bars)
    db TILE_DIGIT0+4, TILE_B, TILE_R               ; 5 4BR (4 bars)
    db TILE_DIGIT0+8, TILE_B, TILE_R               ; 6 8BR (8 bars)

; 64-byte quarter-wave sine: SineQtable[i] = round(127 * sin(i * pi/128)), i=0..63
SineQtable:
    db   0,  3,  6,  9, 12, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 46
    db  49, 51, 54, 57, 60, 63, 65, 68, 71, 73, 76, 78, 81, 83, 85, 88
    db  90, 92, 94, 96, 98,100,102,104,106,107,109,111,112,113,115,116
    db 117,118,120,121,122,122,123,124,125,125,126,126,126,127,127,127

; --- Euclid KICK SOUND presets (4 entries × 4 bytes each: NR10, NR11, NR13, NR14_lo)
; NR10 is NOT read at runtime — PlayEuclidKickSweep sources NR10 from
; EuclidKickNR10ByDecay so DECAY controls sweep window as well as envelope step.
; The NR10 byte here documents the SHRT (fastest) baseline for each SOUND.
; NR11/NR13/NR14_lo are still read. All sweeps direction=decrease; duty per timbre.
EuclidKickSoundPresets:
    ; 0 TIGHT — fast sweep, 50% duty, mid-low start (~G2)
    db $13, $80, $C7, $02
    ; 1 BOOM  — matches existing PlayKickAccent body (period 2, shift 3)
    db $23, $80, $C7, $02
    ; 2 SUB   — slower sweep + larger shift, lower start (period $100, ~73 Hz)
    db $34, $80, $00, $01
    ; 3 PUNCH — fast sweep, 75% duty, mid-low start.
    ; NOTE (V27): NR10 shift=4 + period=1 quantizes PITCH response into
    ; ~$10-wide zones (X>>4 changes only every 16 register units). User
    ; will hear stepwise pitch changes on PCH at $C0/$D0/$E0/... boundaries
    ; — inherent CH1-sweep behavior, not a bug. BOOM/TIGHT (shift 3) and
    ; SUB (period 3) are smoother because their sweeps dominate less.
    db $14, $C0, $C7, $02

; --- Euclid KICK DECAY envelope steps (NR12 low nibble values) --------------
;   0 SHRT — env step 1 (~234 ms)
;   1 MID  — env step 3 (~750 ms)
;   2 LONG — env step 7 (~1.6 s, sustained until next CH1 write overwrites)
; Pairs with EuclidKickNR10ByDecay: NR10 extends the sweep window so these
; envelope steps are perceptible on punchy presets, not just on SUB.
KickDecayEnvelope:
    db $1, $3, $7

; --- Euclid KICK NR10 by (SOUND, DECAY) (4 × 3 = 12 bytes) ------------------
; Index = wEuclidKickSound * 3 + wEuclidKickDecay.
; SHRT row = preset NR10 (current punchy character preserved).
; MID/LONG add 1-2 sweep-period steps to extend the audible window, letting
; KickDecayEnvelope's $1/$3/$7 steps be heard as tail length, not just volume.
; SUB stays $34 across all three: its sweep window (~796 ms) already outlasts
; every envelope setting, so no NR10 modulation needed.
; Starter seeds — tune per SOUND on-device (mGBA then real DMG).
EuclidKickNR10ByDecay:
    db $13, $23, $33               ; TIGHT: period 1→2→3 (sweep win ~70/141/211 ms)
    db $23, $33, $43               ; BOOM:  period 2→3→4 (~141/211/282 ms)
    db $34, $34, $34               ; SUB:   unchanged (byte-identical to pre-fix)
    db $14, $24, $34               ; PUNCH: period 1→2→3, shift 4 (~133/265/398 ms)

; --- ER↑ / ER↓ exponential level curves (16 entries each) -------------------
; ER↑: linear^2 / 15 (concave up). ER↓ = ER↑ reversed (concave down decay).
; Indexed by the linear LR↑ level (0..15) returned from .computeCycleLevel.
UpwExpTable:
    db  0,  0,  0,  1,  1,  2,  2,  3,  4,  5,  7,  8, 10, 12, 13, 15
DnwExpTable:
    db 15, 13, 12, 10,  8,  7,  5,  4,  3,  2,  2,  1,  1,  0,  0,  0

; --- Group Names (3 x 20 tile indices, full row width) ----------------------

GroupNames:
    ; 0: "    CHURCH MODES    "
    db TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK
    db TILE_C, TILE_H, TILE_U, TILE_R, TILE_C, TILE_H, TILE_BLANK, TILE_M, TILE_O, TILE_D, TILE_E, TILE_S
    db TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK
    ; 1: " HARMONIC MINOR    " (shifted left 1 to free col 16 for page indicator)
    db TILE_BLANK, TILE_BLANK
    db TILE_H, TILE_A, TILE_R, TILE_M, TILE_O, TILE_N, TILE_I, TILE_C, TILE_BLANK, TILE_M, TILE_I, TILE_N, TILE_O, TILE_R
    db TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK
    ; 2: "      MESSIAEN      "
    db TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK
    db TILE_M, TILE_E, TILE_S, TILE_S, TILE_I, TILE_A, TILE_E, TILE_N
    db TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK
    ; 3: "     ETHIOPIAN      "
    db TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK
    db TILE_E, TILE_T, TILE_H, TILE_I, TILE_O, TILE_P, TILE_I, TILE_A, TILE_N
    db TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK

; --- Wave Names (4 x 3 tile indices) ----------------------------------------

WaveNames:
    db TILE_S, TILE_T, TILE_D    ; 0 STD
    db TILE_T, TILE_H, TILE_N    ; 1 THN
    db TILE_L, TILE_N, TILE_G    ; 2 LNG
    db TILE_N, TILE_R, TILE_W    ; 3 NRW

; --- Attack Presets (4 envelope bytes for NR22) ------------------------------

AttackPresets:
    db $F1    ; 0 OFF: (not used, waveform envelope applies)
    db $89    ; 1: vol 8, increase, period 1 (subtle soft onset)
    db $59    ; 2: vol 5, increase, period 1 (noticeable soft attack)
    db $1A    ; 3: vol 1, increase, period 2 (slow swell, best at low speed)

; --- Start Screen Data (addr_lo, addr_hi, length, tiles...) -----------------

StartScreenData:
    ; Row 1, col 7: DMGARP
    db $27, $98, 6
    db TILE_D, TILE_M, TILE_G, TILE_A, TILE_R, TILE_P

    ; Row 3, col 5: KENNHARTWIG
    db $65, $98, 11
    db TILE_K, TILE_E, TILE_N, TILE_N, TILE_H, TILE_A, TILE_R, TILE_T, TILE_W, TILE_I, TILE_G

    ; Row 4, col 5: GITHUB.COM
    db $85, $98, 10
    db TILE_G, TILE_I, TILE_T, TILE_H, TILE_U, TILE_B, TILE_DOT, TILE_C, TILE_O, TILE_M

    ; Row 6, col 7: V0.38.2
    db $C7, $98, 7
    db TILE_V, TILE_DIGIT0 + VERSION_RELEASE, TILE_DOT
    db TILE_DIGIT0 + 3, TILE_DIGIT0 + 8, TILE_DOT
    db TILE_DIGIT0 + VERSION_FIX

    ; Row 7, col 5: 2026.07.07
    db $E5, $98, 10
    db TILE_DIGIT0 + 2, TILE_DIGIT0, TILE_DIGIT0 + 2, TILE_DIGIT0 + 6, TILE_DOT
    db TILE_DIGIT0, TILE_DIGIT0 + 7, TILE_DOT
    db TILE_DIGIT0, TILE_DIGIT0 + 7

    ; Row 9, col 2: A+LEFT FOR SOUND
    db $22, $99, 16
    db TILE_A, TILE_PLUS, TILE_L, TILE_E, TILE_F, TILE_T, TILE_BLANK
    db TILE_F, TILE_O, TILE_R, TILE_BLANK
    db TILE_S, TILE_O, TILE_U, TILE_N, TILE_D

    ; Row 10, col 2: SELECT FOR MORE
    db $42, $99, 15
    db TILE_S, TILE_E, TILE_L, TILE_E, TILE_C, TILE_T, TILE_BLANK
    db TILE_F, TILE_O, TILE_R, TILE_BLANK
    db TILE_M, TILE_O, TILE_R, TILE_E

    ; Row 15, col 5: PRESS START
    db $E5, $99, 11
    db TILE_P, TILE_R, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_S, TILE_T, TILE_A, TILE_R, TILE_T

    ; Terminator
    db $00, $00, 0

; --- Controls Reference Data (drawn on gameplay screen) ---------------------

ControlsData:
    ; Row 3, col 1: NOTE           ↑↓
    db $61, $98, 13
    db TILE_N, TILE_O, TILE_T, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 4, col 1: PATTERN        LR
    db $81, $98, 13
    db TILE_P, TILE_A, TILE_T, TILE_T, TILE_E, TILE_R, TILE_N, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 6, col 1: SPEED      A+↑↓
    db $C1, $98, 13
    db TILE_S, TILE_P, TILE_E, TILE_E, TILE_D, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 7, col 1: GATE       A+LR
    db $E1, $98, 13
    db TILE_G, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 8, col 1: OCTAVE     B+↑↓
    db $01, $99, 13
    db TILE_O, TILE_C, TILE_T, TILE_A, TILE_V, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 9, col 1: MODE       B+LR
    db $21, $99, 13
    db TILE_M, TILE_O, TILE_D, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 10, col 1: ATTACK   AB+LR
    db $41, $99, 13
    db TILE_A, TILE_T, TILE_T, TILE_A, TILE_C, TILE_K, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 11, col 1: STRIDE   AB+↑↓
    db $61, $99, 13
    db TILE_S, TILE_T, TILE_R, TILE_I, TILE_D, TILE_E, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 12, col 1: RANGE    ST+↑↓
    db $81, $99, 13
    db TILE_R, TILE_A, TILE_N, TILE_G, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_S, TILE_T, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 13, col 1: WAVE     ST+LR
    db $A1, $99, 13
    db TILE_W, TILE_A, TILE_V, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_S, TILE_T, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Terminator
    db $00, $00, 0

; --- Controls Page 2 (CH1 controls) -------------------------------------------

ControlsPage2:
    ; Row 0: title bar "CHANNEL 1" (inverted) + page indicator "2/10"
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_C, INV_TILE_H, INV_TILE_A, INV_TILE_N, INV_TILE_N, INV_TILE_E, INV_TILE_L, INV_TILE_BLANK, INV_TILE_DIGIT0+1
    db INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+2, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: empty inverted bar (no subtitle, but black for visual consistency)
    db $20, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

    ; Row 6, col 1: VOICING  A+LR
    db $C1, $98, 13
    db TILE_V, TILE_O, TILE_I, TILE_C, TILE_I, TILE_N, TILE_G, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 7: drawn dynamically (sub-param label), NOT in DrawData

    ; Row 8, col 1: LEVEL   B+↑↓
    db $01, $99, 13
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 9, col 1: ATTACK   B+LR
    db $21, $99, 13
    db TILE_A, TILE_T, TILE_T, TILE_A, TILE_C, TILE_K, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 11, col 1: DUTY  ST+LR
    db $61, $99, 13
    db TILE_D, TILE_U, TILE_T, TILE_Y, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK
    db TILE_S, TILE_T, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 12, col 1: OFFSET  AB+↑↓
    db $81, $99, 13
    db TILE_O, TILE_F, TILE_F, TILE_S, TILE_E, TILE_T, TILE_BLANK, TILE_BLANK
    db TILE_A, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Terminator
    db $00, $00, 0

ControlsPage3:
    ; Row 0: title bar "TIMING" (inverted) + page indicator "3/10"
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_T, INV_TILE_I, INV_TILE_M, INV_TILE_I, INV_TILE_N, INV_TILE_G
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+3, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: empty inverted bar (no subtitle, but black for visual consistency)
    db $20, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

    ; Row 6, col 1: TAP TEMPO     B
    db $C1, $98, 13
    db TILE_T, TILE_A, TILE_P, TILE_BLANK, TILE_T, TILE_E, TILE_M, TILE_P, TILE_O, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B

    ; Row 7, col 1: SUBDIV     A+↑↓
    db $E1, $98, 13
    db TILE_S, TILE_U, TILE_B, TILE_D, TILE_I, TILE_V, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 8, col 1: SWING      A+LR
    db $01, $99, 13
    db TILE_S, TILE_W, TILE_I, TILE_N, TILE_G, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Terminator
    db $00, $00, 0

; --- CH1 Mode Names (6 x 3 tile indices) --------------------------------------

CH1Names:
    db TILE_O, TILE_F, TILE_F          ; 0 OFF
    db TILE_O, TILE_C, TILE_PLUS       ; 1 OC+
    db TILE_O, TILE_C, TILE_DASH       ; 2 OC-
    db TILE_D, TILE_E, TILE_T          ; 3 DET
    db TILE_I, TILE_N, TILE_T          ; 4 INT
    db TILE_S, TILE_C, TILE_L          ; 5 SCL

; --- CH1 Volume Table (8 NR12 envelope bytes) ---------------------------------

CH1VolTable:
    db $08, $20, $40, $60, $90, $B0, $D0, $F0

; --- CH1 Attack Names (3 x 3 tile indices) ------------------------------------

CH1AtkNames:
    db TILE_O, TILE_F, TILE_F          ; 0 OFF
    db TILE_S, TILE_A, TILE_M          ; 1 SAM
    db TILE_I, TILE_N, TILE_D          ; 2 IND

; --- CH1 Sub-Parameter Labels (13 tiles each) ---------------------------------

SubLabel_DET:
    db TILE_D, TILE_E, TILE_T, TILE_U, TILE_N, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

SubLabel_INT:
    db TILE_I, TILE_N, TILE_T, TILE_R, TILE_V, TILE_A, TILE_L, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

SubLabel_SCL:
    db TILE_D, TILE_E, TILE_G, TILE_R, TILE_E, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

SubLabel_IATK:
    db TILE_I, TILE_N, TILE_D, TILE_E, TILE_P, TILE_E, TILE_N, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

DetuneOffsets:
    db 1, 2, 4, 8, 14      ; DT1-DT5: subtle → aggressive chorus

; --- CH1 Duty Cycle Table (4 entries, NR11 duty byte) -------------------------

CH1DutyTable:
    db $00    ; 0: 12.5%
    db $40    ; 1: 25%
    db $80    ; 2: 50% (default)
    db $C0    ; 3: 75%

; --- CH1 Offset Names (8 x 3 tile indices) ------------------------------------

CH1OffsetNames:
    db TILE_O, TILE_F, TILE_F                       ; 0  OFF
    db TILE_BLANK, TILE_DIGIT0,   TILE_DIGIT0+6     ; 1  06
    db TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+2     ; 2  12
    db TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+9     ; 3  19
    db TILE_BLANK, TILE_DIGIT0+2, TILE_DIGIT0+5     ; 4  25
    db TILE_BLANK, TILE_DIGIT0+3, TILE_DIGIT0+1     ; 5  31
    db TILE_BLANK, TILE_DIGIT0+3, TILE_DIGIT0+7     ; 6  37
    db TILE_BLANK, TILE_DIGIT0+4, TILE_DIGIT0+4     ; 7  44
    db TILE_BLANK, TILE_DIGIT0+5, TILE_DIGIT0       ; 8  50
    db TILE_BLANK, TILE_DIGIT0+5, TILE_DIGIT0+6     ; 9  56
    db TILE_BLANK, TILE_DIGIT0+6, TILE_DIGIT0+2     ; 10 62
    db TILE_BLANK, TILE_DIGIT0+6, TILE_DIGIT0+9     ; 11 69
    db TILE_BLANK, TILE_DIGIT0+7, TILE_DIGIT0+5     ; 12 75
    db TILE_BLANK, TILE_DIGIT0+8, TILE_DIGIT0+1     ; 13 81
    db TILE_BLANK, TILE_DIGIT0+8, TILE_DIGIT0+7     ; 14 87

; --- CH1 Wave Names (4 x 3 tile indices) --------------------------------------

CH1WaveNames:
    db TILE_N, TILE_R, TILE_W    ; 0: NRW (12.5%)
    db TILE_T, TILE_H, TILE_N    ; 1: THN (25%)
    db TILE_S, TILE_T, TILE_D    ; 2: STD (50%, default)
    db TILE_W, TILE_D, TILE_E    ; 3: WDE (75%)

; --- CH1 Interval Names (19 x 3 tile indices) ---------------------------------

CH1IntNames:
    db TILE_m, TILE_DIGIT0+2, TILE_DOT       ;  1: m2·
    db TILE_M, TILE_J, TILE_DIGIT0+2         ;  2: Mj2
    db TILE_m, TILE_DIGIT0+3, TILE_DOT       ;  3: m3·
    db TILE_M, TILE_J, TILE_DIGIT0+3         ;  4: Mj3
    db TILE_P, TILE_DIGIT0+4, TILE_DOT       ;  5: P4·
    db TILE_T, TILE_R, TILE_I                ;  6: tri
    db TILE_P, TILE_DIGIT0+5, TILE_DOT       ;  7: P5·
    db TILE_m, TILE_DIGIT0+6, TILE_DOT       ;  8: m6·
    db TILE_M, TILE_J, TILE_DIGIT0+6         ;  9: Mj6
    db TILE_m, TILE_DIGIT0+7, TILE_DOT       ; 10: m7·
    db TILE_M, TILE_J, TILE_DIGIT0+7         ; 11: Mj7
    db TILE_O, TILE_C, TILE_T                ; 12: Oct
    db TILE_m, TILE_DIGIT0+9, TILE_DOT       ; 13: m9·
    db TILE_M, TILE_J, TILE_DIGIT0+9         ; 14: Mj9
    db TILE_m, TILE_DIGIT0+1, TILE_DIGIT0+0  ; 15: m10
    db TILE_M, TILE_DIGIT0+1, TILE_DIGIT0+0  ; 16: M10
    db TILE_P, TILE_DIGIT0+1, TILE_DIGIT0+1  ; 17: P11
    db TILE_T, TILE_R, TILE_DIGIT0+2         ; 18: tr2
    db TILE_P, TILE_DIGIT0+1, TILE_DIGIT0+2  ; 19: P12

; --- CH3 Wavetable Presets (5 x 16 bytes = 80 bytes) ---------------------------
; 32 samples per wave, 4 bits each, packed high nibble first
; Wave RAM $FF30-$FF3F

WavetableData:
    ; 0 SIN — approximated sine wave
    db $01, $23, $45, $67, $89, $AB, $CD, $EF
    db $FE, $DC, $BA, $98, $76, $54, $32, $10
    ; 1 SAW — sawtooth (ramp up)
    db $01, $12, $23, $34, $45, $56, $67, $78
    db $89, $9A, $AB, $BC, $CD, $DE, $EF, $FF
    ; 2 TRI — triangle wave
    db $01, $23, $45, $67, $89, $AB, $CD, $EF
    db $EF, $CD, $AB, $89, $67, $45, $23, $01
    ; 3 ORG — organ (fundamental + 3rd harmonic)
    db $0E, $FC, $DA, $60, $03, $5A, $CF, $E0
    db $0E, $FC, $DA, $60, $03, $5A, $CF, $E0
    ; 4 BAS — bass (heavy fundamental, slight 2nd harmonic)
    db $02, $46, $8A, $CE, $FF, $FE, $ED, $CB
    db $A8, $64, $21, $00, $00, $12, $34, $01

; --- CH3 Mode Names (3 x 3 tile indices) ----------------------------------------

CH3ModeNames:
    db TILE_O, TILE_F, TILE_F                   ; 0 OFF
    db TILE_W, TILE_A, TILE_V                   ; 1 WAV
    db TILE_M, TILE_I, TILE_X                   ; 2 MIX

; --- CH3 Wave Names (5 x 3 tile indices) ----------------------------------------

CH3WaveNames:
    db TILE_S, TILE_I, TILE_N                   ; 0 SIN
    db TILE_S, TILE_A, TILE_W                   ; 1 SAW
    db TILE_T, TILE_R, TILE_I                   ; 2 TRI
    db TILE_O, TILE_R, TILE_G                   ; 3 ORG
    db TILE_B, TILE_A, TILE_S                   ; 4 BAS

; --- CH3 Volume Names (4 x 3 tile indices) --------------------------------------

CH3VolNames:
    db TILE_BLANK, TILE_BLANK, TILE_DIGIT0                      ; 0 mute "  0"
    db TILE_BLANK, TILE_DIGIT0 + 2, TILE_DIGIT0 + 5            ; 1 " 25"
    db TILE_BLANK, TILE_DIGIT0 + 5, TILE_DIGIT0                ; 2 " 50"
    db TILE_DIGIT0 + 1, TILE_DIGIT0, TILE_DIGIT0               ; 3 "100"

; --- CH3 NR32 Volume Lookup (4 bytes) -------------------------------------------

CH3VolNR32:
    db $00          ; 0: mute   (NR32 bits 6-5 = 00)
    db $60          ; 1: 25%    (NR32 bits 6-5 = 11)
    db $40          ; 2: 50%    (NR32 bits 6-5 = 10)
    db $20          ; 3: 100%   (NR32 bits 6-5 = 01)

; --- CH3 Shape Table ---------------------------------------------------------
; Format per entry: db loop_flag, length, NR32_value_0, NR32_value_1, ...
;   loop_flag: 0=one-shot (stops at end, holds last value), 1=loop (wraps)
;   length: number of NR32 values
;   RND shape: loop_flag=1, length=4; engine generates random values (ignores stored bytes)
; Indexed via CH3ShapePointers (words), shape 1..7 = indices 0..6.

CH3ShapePointers:
    dw CH3Shape_PLK
    dw CH3Shape_DCY
    dw CH3Shape_ATK
    dw CH3Shape_AD
    dw CH3Shape_TRM
    dw CH3Shape_GAT
    dw CH3Shape_RND

CH3Shape_PLK:           ; pluck: 100→25→mute (one-shot)
    db 0, 3
    db $20, $60, $00

CH3Shape_DCY:           ; decay: 100→50→25→mute (one-shot)
    db 0, 4
    db $20, $40, $60, $00

CH3Shape_ATK:           ; attack: mute→25→50→100 hold (one-shot)
    db 0, 4
    db $00, $60, $40, $20

CH3Shape_AD:            ; attack-decay: mute→50→100→50→25→mute (one-shot)
    db 0, 6
    db $00, $40, $20, $40, $60, $00

CH3Shape_TRM:           ; tremolo: 100→25 (loop)
    db 1, 2
    db $20, $60

CH3Shape_GAT:           ; gate: 100→mute (loop)
    db 1, 2
    db $20, $00

CH3Shape_RND:           ; random: generates random NR32 each step (loop)
    db 1, 4
    db $00, $00, $00, $00   ; dummy — engine uses NextRandomByte

; --- CH3 Shape Names (8 x 3 tile indices) —- OFF plus 7 shapes ---------------

CH3ShapeNames:
    db TILE_O, TILE_F, TILE_F               ; 0 OFF
    db TILE_P, TILE_L, TILE_K               ; 1 PLK
    db TILE_D, TILE_C, TILE_Y               ; 2 DCY
    db TILE_A, TILE_T, TILE_K               ; 3 ATK
    db TILE_A, TILE_D, TILE_BLANK           ; 4 AD
    db TILE_T, TILE_R, TILE_M               ; 5 TRM
    db TILE_G, TILE_A, TILE_T               ; 6 GAT
    db TILE_R, TILE_N, TILE_D               ; 7 RND

; --- CH3ShapeInit — start / retrigger the shape engine -----------------------
; Call at note-on to arm a one-shot, or to start a looping shape first time.
; Writes NR32 value[0], sets HRAM state, sets hCH3ShapeRunning=1.
; Precondition: wCH3Shape != 0. Clobbers a, b, c, d, e, h, l.
CH3ShapeInit:
    ; Load shape entry pointer
    ld a, [wCH3Shape]
    dec a                   ; 0-indexed
    add a                   ; ×2 for word pointer table
    ld hl, CH3ShapePointers
    add l
    ld l, a
    jr nc, .csI_ncP
    inc h
.csI_ncP:
    ld a, [hli]
    ld h, [hl]
    ld l, a                 ; hl = shape entry (loop_flag, length, NR32...)

    inc hl                  ; skip loop_flag
    ld c, [hl]              ; c = length
    inc hl                  ; hl → first NR32 value

    ; Write NR32 value[0] and cache it for note-on restore
    ld a, [wCH3Shape]
    cp CH3_SHAPE_RND
    jr nz, .csI_tableVal
    call NextRandomByte
    and %01100000
    ldh [hCH3ShapeLast], a
    ldh [rNR32], a
    jr .csI_valDone
.csI_tableVal:
    ld a, [hl]
    ldh [hCH3ShapeLast], a
    ldh [rNR32], a
.csI_valDone:

    ; Compute per-step frames: total = RATE × step_frames (capped), base = total / length
    call LoadSpeedFrames    ; a = step_frames (respects tap tempo)
    ld d, a                 ; d = step_frames
    ld a, [wCH3Rate]        ; a = RATE (1..8; 0 treated as 1 below)
    and a
    jr nz, .csI_rateOk
    ld a, 1                 ; clamp 0→1 for compat
.csI_rateOk:
    ld e, a                 ; e = RATE loop count
    xor a                   ; accumulator = 0
.csI_mulLoop:
    add d               ; A += step_frames
    jr c, .csI_mulOvf   ; carry → overflow → cap at 255
    dec e
    jr nz, .csI_mulLoop
    jr .csI_mulOk
.csI_mulOvf:
    ld a, 255
.csI_mulOk:
    ; a = min(RATE × step_frames, 255) = total_envelope_frames
    ; Divide by length (c) to get per-step frames
    ld b, 0             ; quotient
.csI_divLoop:
    cp c
    jr c, .csI_divDone
    sub c
    inc b
    jr .csI_divLoop
.csI_divDone:
    ld a, b
    and a
    jr nz, .csI_baseOk
    ld a, 1             ; minimum 1 frame per step
.csI_baseOk:
    ldh [hCH3ShapeBase], a
    ldh [hCH3ShapeCnt], a   ; prime countdown with one full base period

    ; Set running state
    xor a
    ldh [hCH3ShapeIdx], a
    ld a, 1
    ldh [hCH3ShapeRunning], a
    ret

; --- CH3ShapeTick — advance shape engine one frame ---------------------------
; Called from UpdateHUD and sub-page path each VBlank. Writes NR32 on step.
; Clobbers a, b, c, h, l.
CH3ShapeTick:
    ld a, [wCH3Shape]
    and a
    ret z                   ; SHAPE=OFF → engine disabled
    ld a, [wCH3Mode]
    and a
    ret z                   ; CH3 mode=OFF → engine paused

    ldh a, [hCH3ShapeRunning]
    and a
    ret z                   ; engine idle

    ; Decrement countdown
    ldh a, [hCH3ShapeCnt]
    and a
    jr z, .cst_step         ; cnt already 0 → step now (handles init)
    dec a
    ldh [hCH3ShapeCnt], a
    ret nz                  ; not zero yet → done
    ; cnt just hit 0 → fall through to advance

.cst_step:
    ; Load shape entry
    ld a, [wCH3Shape]
    dec a
    add a                   ; ×2
    ld hl, CH3ShapePointers
    add l
    ld l, a
    jr nc, .cst_ncP
    inc h
.cst_ncP:
    ld a, [hli]
    ld h, [hl]
    ld l, a                 ; hl = shape entry
    ld b, [hl]              ; b = loop_flag
    inc hl
    ld c, [hl]              ; c = length
    inc hl                  ; hl → NR32 values

    ; Advance index
    ldh a, [hCH3ShapeIdx]
    inc a                   ; a = next index
    cp c                    ; >= length?
    jr c, .cst_idxOk
    ; Past end
    ld a, b
    and a
    jr nz, .cst_loop
    ; One-shot exhausted: write last value, stop engine
    ld a, c
    dec a                   ; index of last value
    add l                   ; A = L + (length-1)
    ld l, a
    jr nc, .cst_ncOS
    inc h
.cst_ncOS:
    ld a, [wCH3Shape]
    cp CH3_SHAPE_RND
    jr nz, .cst_osTable
    call NextRandomByte
    and %01100000
    ldh [hCH3ShapeLast], a
    ld b, a
    ldh a, [hCH3ShapeMuted]
    and a
    ld a, b
    jr z, .cst_wOS_rnd
    xor a
.cst_wOS_rnd:
    ldh [rNR32], a
    jr .cst_stop
.cst_osTable:
    ld a, [hl]
    ldh [hCH3ShapeLast], a
    ld b, a
    ldh a, [hCH3ShapeMuted]
    and a
    ld a, b
    jr z, .cst_wOS_tbl
    xor a
.cst_wOS_tbl:
    ldh [rNR32], a
.cst_stop:
    xor a
    ldh [hCH3ShapeRunning], a
    ret
.cst_loop:
    xor a                   ; wrap to 0
.cst_idxOk:
    ldh [hCH3ShapeIdx], a   ; store new index

    ; Write NR32
    ld a, [wCH3Shape]
    cp CH3_SHAPE_RND
    jr nz, .cst_table
    call NextRandomByte
    and %01100000
    ldh [hCH3ShapeLast], a
    ld b, a
    ldh a, [hCH3ShapeMuted]
    and a
    ld a, b
    jr z, .cst_wLp_rnd
    xor a
.cst_wLp_rnd:
    ldh [rNR32], a
    jr .cst_reload
.cst_table:
    ldh a, [hCH3ShapeIdx]
    add l                   ; A = L + new_idx
    ld l, a
    jr nc, .cst_ncT
    inc h
.cst_ncT:
    ld a, [hl]
    ldh [hCH3ShapeLast], a
    ld b, a
    ldh a, [hCH3ShapeMuted]
    and a
    ld a, b
    jr z, .cst_wLp_tbl
    xor a
.cst_wLp_tbl:
    ldh [rNR32], a
.cst_reload:
    ldh a, [hCH3ShapeBase]
    ldh [hCH3ShapeCnt], a
    ret

; --- Controls Page 4 (CH3 Wave Channel) -----------------------------------------

ControlsPage4:
    ; Row 0: title bar "CHANNEL 3" (inverted) + page indicator "4/10"
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_C, INV_TILE_H, INV_TILE_A, INV_TILE_N, INV_TILE_N, INV_TILE_E, INV_TILE_L, INV_TILE_BLANK, INV_TILE_DIGIT0+3
    db INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+4, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar "WAVE" (inverted, 20-tile bar with text centered)
    db $20, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_W, INV_TILE_A, INV_TILE_V, INV_TILE_E
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

    ; Row 6, col 1: MODE       A+LR
    db $C1, $98, 13
    db TILE_M, TILE_O, TILE_D, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 7, col 1: WAVE       A+↑↓
    db $E1, $98, 13
    db TILE_W, TILE_A, TILE_V, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 8, col 1: VOLUME     B+↑↓
    db $01, $99, 13
    db TILE_V, TILE_O, TILE_L, TILE_U, TILE_M, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 9, col 1: SHAPE     B+LR
    db $21, $99, 13
    db TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 10, col 1: RATE    AB+↑↓
    db $41, $99, 13
    db TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Terminator
    db $00, $00, 0

ControlsAccentPage:
    ; Row 0: title bar "CHANNEL 4" (inverted) + page indicator "5/10"
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_C, INV_TILE_H, INV_TILE_A, INV_TILE_N, INV_TILE_N, INV_TILE_E, INV_TILE_L, INV_TILE_BLANK, INV_TILE_DIGIT0+4
    db INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+5, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar "ACCENT" (inverted, 20-tile bar with text centered)
    db $20, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_A, INV_TILE_C, INV_TILE_C, INV_TILE_E, INV_TILE_N, INV_TILE_T
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

    ; Row 6, col 1: ACCENT     A+LR
    db $C1, $98, 13
    db TILE_A, TILE_C, TILE_C, TILE_E, TILE_N, TILE_T, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Rows 7-10 reserved for #6 Euclidean drum machine (HITS/LEN/ROT/SOUND).

    ; Terminator
    db $00, $00, 0

ControlsFillPage:
    ; Row 0: title bar "CHANNEL 4" (inverted) + page indicator "6/10"
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_C, INV_TILE_H, INV_TILE_A, INV_TILE_N, INV_TILE_N, INV_TILE_E, INV_TILE_L, INV_TILE_BLANK, INV_TILE_DIGIT0+4
    db INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+6, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar "FILL" (inverted, 20-tile bar with text centered)
    db $20, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_F, INV_TILE_I, INV_TILE_L, INV_TILE_L
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

    ; Row 2: "NOISE WHEN GATE OFF" — FILL fires CH4 noise during each step's
    ; gate-OFF gap. 19 chars + 1 trailing blank = 20 tiles.
    db $40, $98, 20
    db TILE_N, TILE_O, TILE_I, TILE_S, TILE_E, TILE_BLANK
    db TILE_W, TILE_H, TILE_E, TILE_N, TILE_BLANK
    db TILE_G, TILE_A, TILE_T, TILE_E, TILE_BLANK
    db TILE_O, TILE_F, TILE_F
    db TILE_BLANK

    ; Row 6, col 1: LEVEL      A+UD
    db $C1, $98, 13
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 7, col 1: COLOR      B+LR
    db $E1, $98, 13
    db TILE_C, TILE_O, TILE_L, TILE_O, TILE_R, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 8, col 1: PITCH      B+UD
    db $01, $99, 13
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 9, col 1: FREQ      AB+UD
    db $21, $99, 13
    db TILE_F, TILE_R, TILE_E, TILE_Q, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 10, col 1: SHAPE    AB+LR
    db $41, $99, 13
    db TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Terminator
    db $00, $00, 0

; --- Controls Page 7 (TONAL NOISE) ------------------------------------------
ControlsTonalPage:
    ; Row 0: title bar "CHANNEL 4" (inverted) + page indicator "7/10"
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_C, INV_TILE_H, INV_TILE_A, INV_TILE_N, INV_TILE_N, INV_TILE_E, INV_TILE_L, INV_TILE_BLANK, INV_TILE_DIGIT0+4
    db INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+7, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar "TONAL" (inverted, 20-tile bar with text centered).
    ; All A-Z inverted glyphs already exist in VRAM (InvertTiles auto-inverts
    ; every original tile at boot — see line 4411). Only the DEF aliases are
    ; opt-in; INV_TILE_O was added at line 116 specifically for this row.
    db $20, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_T, INV_TILE_O, INV_TILE_N, INV_TILE_A, INV_TILE_L
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

    ; Row 6, col 1: MODE       A+LR
    db $C1, $98, 13
    db TILE_M, TILE_O, TILE_D, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 7, col 1: LEVEL      A+UD
    db $E1, $98, 13
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 8, col 1: MAP        B+LR
    db $01, $99, 13
    db TILE_M, TILE_A, TILE_P, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 9, col 1: WIDTH      B+UD
    db $21, $99, 13
    db TILE_W, TILE_I, TILE_D, TILE_T, TILE_H, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 10, col 1: DECAY    AB+LR
    db $41, $99, 13
    db TILE_D, TILE_E, TILE_C, TILE_A, TILE_Y, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 11, col 1: TRANSP   AB+UD
    db $61, $99, 13
    db TILE_T, TILE_R, TILE_A, TILE_N, TILE_S, TILE_P, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 12, col 1: TRIG     ST+LR
    db $81, $99, 13
    db TILE_T, TILE_R, TILE_I, TILE_G, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_S, TILE_T, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 13, col 1: PRI      ST+UD
    db $A1, $99, 13
    db TILE_P, TILE_R, TILE_I, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_S, TILE_T, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 14, col 1: LOCK     ↑↓ (bare UP/DOWN, no modifier prefix)
    db $C1, $99, 13
    db TILE_L, TILE_O, TILE_C, TILE_K, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_UP_ARROW, TILE_DN_ARROW

    ; Terminator
    db $00, $00, 0

; --- Controls Page 8 (EUCLID KICK) ------------------------------------------
; Layout matches the other parameterized pages: one parameter per row with the
; label at cols 1+ and the button-combo indicator at cols 10-13. Row 5 holds
; the pattern visualizer (V37: computed into wEuclidVisBuf outside VBlank, blitted in page8Values).
ControlsEuclidPage:
    ; Row 0: title bar "CHANNEL 1" (inverted) + page indicator "8/10"
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_C, INV_TILE_H, INV_TILE_A, INV_TILE_N, INV_TILE_N, INV_TILE_E, INV_TILE_L, INV_TILE_BLANK, INV_TILE_DIGIT0+1
    db INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+8, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar "EUCLID KICK" (inverted, 20-tile bar with text centered)
    db $20, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_E, INV_TILE_U, INV_TILE_C, INV_TILE_L, INV_TILE_I, INV_TILE_D, INV_TILE_BLANK, INV_TILE_K, INV_TILE_I, INV_TILE_C, INV_TILE_K
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

    ; Row 6, cols 1-6: HITS  ; cols 10-13: A+UD
    db $C1, $98, 13
    db TILE_H, TILE_I, TILE_T, TILE_S, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 7, cols 1-6: LENGTH ; cols 10-13: A+LR
    db $E1, $98, 13
    db TILE_L, TILE_E, TILE_N, TILE_G, TILE_T, TILE_H, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 8, cols 1-6: LEVEL  ; cols 10-13: B+LR
    db $01, $99, 13
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 9, cols 1-6: PITCH  ; cols 10-13: B+UD  (V27)
    db $21, $99, 13
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 10, cols 1-6: SOUND  ; cols 9-13: AB+UD
    db $41, $99, 13
    db TILE_S, TILE_O, TILE_U, TILE_N, TILE_D, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 11, cols 1-6: DECAY  ; cols 9-13: AB+LR
    db $61, $99, 13
    db TILE_D, TILE_E, TILE_C, TILE_A, TILE_Y, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 12, cols 1-6: ROTATE ; cols 12-13: ← → (plain LR, no modifier)
    db $81, $99, 13
    db TILE_R, TILE_O, TILE_T, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 13, cols 1-6: LOCK   ; cols 12-13: ↑ ↓ (plain UD, no modifier)
    db $A1, $99, 13
    db TILE_L, TILE_O, TILE_C, TILE_K, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 14, cols 1-19: "PRESS START FOR MOD" navigation hint
    db $C1, $99, 19
    db TILE_P, TILE_R, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_S, TILE_T, TILE_A, TILE_R, TILE_T, TILE_BLANK, TILE_F, TILE_O, TILE_R, TILE_BLANK, TILE_M, TILE_O, TILE_D

    ; Terminator
    db $00, $00, 0

ControlsEuclidModPage:
    ; Row 0: title bar "SUB PAGE 8/10" (inverted)
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_S, INV_TILE_U, INV_TILE_B, INV_TILE_BLANK, INV_TILE_P, INV_TILE_A, INV_TILE_G, INV_TILE_E
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+8, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar "EUC KICK MODULATION" (inverted, 19 tiles + 1 leading blank)
    db $20, $98, 20
    db INV_TILE_BLANK
    db INV_TILE_E, INV_TILE_U, INV_TILE_C, INV_TILE_BLANK, INV_TILE_K, INV_TILE_I, INV_TILE_C, INV_TILE_K
    db INV_TILE_BLANK, INV_TILE_M, INV_TILE_O, INV_TILE_D, INV_TILE_U, INV_TILE_L, INV_TILE_A, INV_TILE_T, INV_TILE_I, INV_TILE_O, INV_TILE_N

    ; Row 6, cols 1-7: P SHAPE  ; cols 10-13: A+LR
    db $C1, $98, 13
    db TILE_P, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 7, cols 1-6: P RATE  ; cols 10-13: A+UD
    db $E1, $98, 13
    db TILE_P, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 8, cols 1-7: V SHAPE  ; cols 10-13: B+LR
    db $01, $99, 13
    db TILE_V, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 9, cols 1-6: V RATE  ; cols 10-13: B+UD
    db $21, $99, 13
    db TILE_V, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 10, cols 1-7: P DEPTH  ; cols 9-13: AB+LR
    db $41, $99, 13
    db TILE_P, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_LF_ARROW, TILE_RT_ARROW

    ; Row 11, cols 1-7: V DEPTH  ; cols 9-13: AB+UD
    db $61, $99, 13
    db TILE_V, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_A, TILE_B, TILE_PLUS, TILE_UP_ARROW, TILE_DN_ARROW

    ; Row 13, cols 1-19: "PRESS START GO BACK" navigation hint
    db $A1, $99, 19
    db TILE_P, TILE_R, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_S, TILE_T, TILE_A, TILE_R, TILE_T, TILE_BLANK, TILE_G, TILE_O, TILE_BLANK, TILE_B, TILE_A, TILE_C, TILE_K

    ; Terminator
    db $00, $00, 0

; --- Controls Page 9 (MIXER) ------------------------------------------------
ControlsMixerPage:
    ; Row 0: title bar "MIXER" (inverted) + page indicator "9/10"
    ; Cols 0-4: blanks, cols 5-9: MIXER, cols 10-15: blanks, cols 16-19: 9/10
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_M, INV_TILE_I, INV_TILE_X, INV_TILE_E, INV_TILE_R
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+9, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar (blank, inverted)
    db $20, $98, 20
    ds 20, INV_TILE_BLANK

    ; Row 6, cols 1-13: CH1 (label left, button hint right — matches DMGARP convention)
    db $C1, $98, 13
    db TILE_C, TILE_H, TILE_DIGIT0+1, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_UP_ARROW

    ; Row 7, cols 1-13: CH2
    db $E1, $98, 13
    db TILE_C, TILE_H, TILE_DIGIT0+2, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_DN_ARROW

    ; Row 8, cols 1-13: CH3
    db $01, $99, 13
    db TILE_C, TILE_H, TILE_DIGIT0+3, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_LF_ARROW

    ; Row 9, cols 1-13: CH4
    db $21, $99, 13
    db TILE_C, TILE_H, TILE_DIGIT0+4, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_RT_ARROW

    ; Row 10, cols 1-13: EUC (A button)
    db $41, $99, 13
    db TILE_E, TILE_U, TILE_C, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A

    ; Terminator
    db $00, $00, 0

ControlsPage9_Base:
    ; Row 0: title bar "CONTROLS 10/10" (inverted)
    db $00, $98, 20
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_C, INV_TILE_O, INV_TILE_N, INV_TILE_T, INV_TILE_R, INV_TILE_O, INV_TILE_L, INV_TILE_S
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_DIGIT0+1, INV_TILE_DIGIT0, INV_TILE_SLASH, INV_TILE_DIGIT0+1, INV_TILE_DIGIT0

    ; Row 1: subtitle bar (blank, inverted)
    db $20, $98, 20
    ds 20, INV_TILE_BLANK

    ; Row 3, cols 1-13: "SAVE" label + "A+↑" hint
    db $61, $98, 13
    db TILE_S, TILE_A, TILE_V, TILE_E, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_UP_ARROW

    ; Row 4, cols 1-13: "LOAD" label + "B+↓" hint
    db $81, $98, 13
    db TILE_L, TILE_O, TILE_A, TILE_D, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_B, TILE_PLUS, TILE_DN_ARROW

    ; Row 5, cols 1-13: "RND ALL" label + "ST+↑" hint (WILD randomize)
    db $A1, $98, 13
    db TILE_R, TILE_N, TILE_D, TILE_BLANK, TILE_A, TILE_L, TILE_L, TILE_BLANK, TILE_BLANK, TILE_S, TILE_T, TILE_PLUS, TILE_UP_ARROW

    ; Row 6, cols 1-13: "RND FX" label + "ST+↓" hint (MILD randomize)
    db $C1, $98, 13
    db TILE_R, TILE_N, TILE_D, TILE_BLANK, TILE_F, TILE_X, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_S, TILE_T, TILE_PLUS, TILE_DN_ARROW

    ; Row 7, cols 1-13: "PRESET" label + "A+→" hint (V38 preset matrix)
    db $E1, $98, 13
    db TILE_P, TILE_R, TILE_E, TILE_S, TILE_E, TILE_T, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_BLANK, TILE_A, TILE_PLUS, TILE_RT_ARROW

    ; Terminator
    db $00, $00, 0

; Sub-page title bars (20 inverted tiles each)
SubPageSaveTitleBar:
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_S, INV_TILE_A, INV_TILE_V, INV_TILE_E, INV_TILE_BLANK
    db INV_TILE_L, INV_TILE_I, INV_TILE_S, INV_TILE_T
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

SubPageLoadTitleBar:
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_L, INV_TILE_O, INV_TILE_A, INV_TILE_D, INV_TILE_BLANK
    db INV_TILE_L, INV_TILE_I, INV_TILE_S, INV_TILE_T
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

; V38 preset matrix title bar (20 inverted tiles): "PRESETS"
SubPageMatrixTitleBar:
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK
    db INV_TILE_P, INV_TILE_R, INV_TILE_E, INV_TILE_S, INV_TILE_E, INV_TILE_T, INV_TILE_S
    db INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK, INV_TILE_BLANK

; V38 preset matrix static hint rows (20 tiles each; V38.1: A=save, B=load)
MatrixHintRow1:
    ; " A SAV B LOD ST DEL "
    db TILE_BLANK
    db TILE_A, TILE_BLANK, TILE_S, TILE_A, TILE_V, TILE_BLANK
    db TILE_B, TILE_BLANK, TILE_L, TILE_O, TILE_D, TILE_BLANK
    db TILE_S, TILE_T, TILE_BLANK, TILE_D, TILE_E, TILE_L
    db TILE_BLANK
MatrixHintRow2:
    ; " SEL BACK"
    db TILE_BLANK
    db TILE_S, TILE_E, TILE_L, TILE_BLANK, TILE_B, TILE_A, TILE_C, TILE_K
    ds 11, TILE_BLANK

; V38.1 slot-list static hint rows (20 tiles each, row 13)
SubPageSaveHintRow:
    ; " A SAV B BACK"
    db TILE_BLANK
    db TILE_A, TILE_BLANK, TILE_S, TILE_A, TILE_V, TILE_BLANK
    db TILE_B, TILE_BLANK, TILE_B, TILE_A, TILE_C, TILE_K
    ds 7, TILE_BLANK
SubPageLoadHintRow:
    ; " A LOD B BACK"
    db TILE_BLANK
    db TILE_A, TILE_BLANK, TILE_L, TILE_O, TILE_D, TILE_BLANK
    db TILE_B, TILE_BLANK, TILE_B, TILE_A, TILE_C, TILE_K
    ds 7, TILE_BLANK

; --- Speed Table (32 entries, logarithmic spacing) -------------------------------

SpeedTable:
    db 1, 2, 3, 4, 5, 6, 7, 8          ; 0-7: fast (every frame)
    db 10, 12, 14, 17, 20, 24, 28, 32   ; 8-15: mid (~15-20% per step)
    db 36, 40, 45, 50, 56, 64, 72, 80   ; 16-23: slow
    db 90, 100, 112, 128, 150, 180, 210, 250  ; 24-31: very slow (up to 4.2s/note)

; --- Gate Names (5 x 3 tile indices) ------------------------------------------

GateNames:
    db TILE_O, TILE_F, TILE_F                       ; 0 OFF (no gate)
    db TILE_BLANK, TILE_DIGIT0 + 7, TILE_DIGIT0 + 5 ; 1  75%
    db TILE_BLANK, TILE_DIGIT0 + 5, TILE_DIGIT0     ; 2  50%
    db TILE_BLANK, TILE_DIGIT0 + 2, TILE_DIGIT0 + 5 ; 3  25%
    db TILE_S, TILE_I, TILE_L                        ; 4 SIL (silence)

; --- Help Strings (long-name spellings for abbreviated values) -----------------
; Each entry is exactly HELP_LEN (20) bytes, padded with TILE_BLANK. Indexed
; per-control by ShowHelpByIndex with hl=base, a=value.

HelpStr_Pattern:
    ; 0 ASC → ASCENDING
    db TILE_A, TILE_S, TILE_C, TILE_E, TILE_N, TILE_D, TILE_I, TILE_N, TILE_G
    ds 11, TILE_BLANK
    ; 1 DSC → DESCENDING
    db TILE_D, TILE_E, TILE_S, TILE_C, TILE_E, TILE_N, TILE_D, TILE_I, TILE_N, TILE_G
    ds 10, TILE_BLANK
    ; 2 PNG → PINGPONG
    db TILE_P, TILE_I, TILE_N, TILE_G, TILE_P, TILE_O, TILE_N, TILE_G
    ds 12, TILE_BLANK
    ; 3 RND → RANDOM
    db TILE_R, TILE_A, TILE_N, TILE_D, TILE_O, TILE_M
    ds 14, TILE_BLANK

HelpStr_Gate:
    ; 0 OFF → GATE OFF
    db TILE_G, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 12, TILE_BLANK
    ; 1 75% → GATE 75 PCT
    db TILE_G, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+7, TILE_DIGIT0+5, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 9, TILE_BLANK
    ; 2 50% → GATE 50 PCT
    db TILE_G, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+5, TILE_DIGIT0, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 9, TILE_BLANK
    ; 3 25% → GATE 25 PCT
    db TILE_G, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+2, TILE_DIGIT0+5, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 9, TILE_BLANK
    ; 4 SIL → CH2 SILENT
    db TILE_C, TILE_H, TILE_DIGIT0+2, TILE_BLANK, TILE_S, TILE_I, TILE_L, TILE_E, TILE_N, TILE_T
    ds 10, TILE_BLANK

HelpStr_CH1Mode:
    ; 0 OFF
    db TILE_O, TILE_F, TILE_F
    ds 17, TILE_BLANK
    ; 1 OC+ → OCTAVE UP
    db TILE_O, TILE_C, TILE_T, TILE_A, TILE_V, TILE_E, TILE_BLANK, TILE_U, TILE_P
    ds 11, TILE_BLANK
    ; 2 OC- → OCTAVE DOWN
    db TILE_O, TILE_C, TILE_T, TILE_A, TILE_V, TILE_E, TILE_BLANK, TILE_D, TILE_O, TILE_W, TILE_N
    ds 9, TILE_BLANK
    ; 3 DET → DETUNE
    db TILE_D, TILE_E, TILE_T, TILE_U, TILE_N, TILE_E
    ds 14, TILE_BLANK
    ; 4 INT → INTERVAL
    db TILE_I, TILE_N, TILE_T, TILE_E, TILE_R, TILE_V, TILE_A, TILE_L
    ds 12, TILE_BLANK
    ; 5 SCL → SCALE DEGREE
    db TILE_S, TILE_C, TILE_A, TILE_L, TILE_E, TILE_BLANK, TILE_D, TILE_E, TILE_G, TILE_R, TILE_E, TILE_E
    ds 8, TILE_BLANK

HelpStr_CH2Wave:
    ; wDutyCycle: 0 STD, 1 THN, 2 LNG, 3 NRW (per WaveNames ordering)
    ; 0 STD → STANDARD 50 PCT
    db TILE_S, TILE_T, TILE_A, TILE_N, TILE_D, TILE_A, TILE_R, TILE_D, TILE_BLANK, TILE_DIGIT0+5, TILE_DIGIT0, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 5, TILE_BLANK
    ; 1 THN → THIN 25 PCT
    db TILE_T, TILE_H, TILE_I, TILE_N, TILE_BLANK, TILE_DIGIT0+2, TILE_DIGIT0+5, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 9, TILE_BLANK
    ; 2 LNG → LONG SUSTAIN
    db TILE_L, TILE_O, TILE_N, TILE_G, TILE_BLANK, TILE_S, TILE_U, TILE_S, TILE_T, TILE_A, TILE_I, TILE_N
    ds 8, TILE_BLANK
    ; 3 NRW → NARROW 12 PCT
    db TILE_N, TILE_A, TILE_R, TILE_R, TILE_O, TILE_W, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+2, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 7, TILE_BLANK

HelpStr_CH1Offset:
    ; wCH1Offset 0..14 → OFF / 06-87% (tooltip shows value only, per convention)
    ; 0 OFF
    db TILE_O, TILE_F, TILE_F
    ds 17, TILE_BLANK
    ; 1 06 PCT
    db TILE_DIGIT0, TILE_DIGIT0+6, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 2 12 PCT
    db TILE_DIGIT0+1, TILE_DIGIT0+2, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 3 19 PCT
    db TILE_DIGIT0+1, TILE_DIGIT0+9, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 4 25 PCT
    db TILE_DIGIT0+2, TILE_DIGIT0+5, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 5 31 PCT
    db TILE_DIGIT0+3, TILE_DIGIT0+1, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 6 37 PCT
    db TILE_DIGIT0+3, TILE_DIGIT0+7, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 7 44 PCT
    db TILE_DIGIT0+4, TILE_DIGIT0+4, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 8 50 PCT
    db TILE_DIGIT0+5, TILE_DIGIT0, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 9 56 PCT
    db TILE_DIGIT0+5, TILE_DIGIT0+6, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 10 62 PCT
    db TILE_DIGIT0+6, TILE_DIGIT0+2, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 11 69 PCT
    db TILE_DIGIT0+6, TILE_DIGIT0+9, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 12 75 PCT
    db TILE_DIGIT0+7, TILE_DIGIT0+5, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 13 81 PCT
    db TILE_DIGIT0+8, TILE_DIGIT0+1, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK
    ; 14 87 PCT
    db TILE_DIGIT0+8, TILE_DIGIT0+7, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 14, TILE_BLANK

HelpStr_CH1Wave:
    ; wCH1Wave: 0 NRW, 1 THN, 2 STD, 3 WDE (per CH1WaveNames ordering)
    ; 0 NRW → NARROW 12 PCT
    db TILE_N, TILE_A, TILE_R, TILE_R, TILE_O, TILE_W, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+2, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 7, TILE_BLANK
    ; 1 THN → THIN 25 PCT
    db TILE_T, TILE_H, TILE_I, TILE_N, TILE_BLANK, TILE_DIGIT0+2, TILE_DIGIT0+5, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 9, TILE_BLANK
    ; 2 STD → STANDARD 50 PCT
    db TILE_S, TILE_T, TILE_A, TILE_N, TILE_D, TILE_A, TILE_R, TILE_D, TILE_BLANK, TILE_DIGIT0+5, TILE_DIGIT0, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 5, TILE_BLANK
    ; 3 WDE → WIDE 75 PCT
    db TILE_W, TILE_I, TILE_D, TILE_E, TILE_BLANK, TILE_DIGIT0+7, TILE_DIGIT0+5, TILE_BLANK, TILE_P, TILE_C, TILE_T
    ds 9, TILE_BLANK

HelpStr_CH1Atk:
    ; 0 OFF
    db TILE_O, TILE_F, TILE_F
    ds 17, TILE_BLANK
    ; 1 SAM → SAME AS CH2
    db TILE_S, TILE_A, TILE_M, TILE_E, TILE_BLANK, TILE_A, TILE_S, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+2
    ds 9, TILE_BLANK
    ; 2 IND → INDEPENDENT
    db TILE_I, TILE_N, TILE_D, TILE_E, TILE_P, TILE_E, TILE_N, TILE_D, TILE_E, TILE_N, TILE_T
    ds 9, TILE_BLANK

HelpStr_CH1Int:
    ; 19 entries — wCH1Interval 0..18 maps to semitones 1..19
    ; 0 → MINOR 2ND
    db TILE_M, TILE_I, TILE_N, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+2, TILE_N, TILE_D
    ds 11, TILE_BLANK
    ; 1 → MAJOR 2ND
    db TILE_M, TILE_A, TILE_J, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+2, TILE_N, TILE_D
    ds 11, TILE_BLANK
    ; 2 → MINOR 3RD
    db TILE_M, TILE_I, TILE_N, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+3, TILE_R, TILE_D
    ds 11, TILE_BLANK
    ; 3 → MAJOR 3RD
    db TILE_M, TILE_A, TILE_J, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+3, TILE_R, TILE_D
    ds 11, TILE_BLANK
    ; 4 → PERFECT 4TH
    db TILE_P, TILE_E, TILE_R, TILE_F, TILE_E, TILE_C, TILE_T, TILE_BLANK, TILE_DIGIT0+4, TILE_T, TILE_H
    ds 9, TILE_BLANK
    ; 5 → TRITONE
    db TILE_T, TILE_R, TILE_I, TILE_T, TILE_O, TILE_N, TILE_E
    ds 13, TILE_BLANK
    ; 6 → PERFECT 5TH
    db TILE_P, TILE_E, TILE_R, TILE_F, TILE_E, TILE_C, TILE_T, TILE_BLANK, TILE_DIGIT0+5, TILE_T, TILE_H
    ds 9, TILE_BLANK
    ; 7 → MINOR 6TH
    db TILE_M, TILE_I, TILE_N, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+6, TILE_T, TILE_H
    ds 11, TILE_BLANK
    ; 8 → MAJOR 6TH
    db TILE_M, TILE_A, TILE_J, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+6, TILE_T, TILE_H
    ds 11, TILE_BLANK
    ; 9 → MINOR 7TH
    db TILE_M, TILE_I, TILE_N, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+7, TILE_T, TILE_H
    ds 11, TILE_BLANK
    ; 10 → MAJOR 7TH
    db TILE_M, TILE_A, TILE_J, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+7, TILE_T, TILE_H
    ds 11, TILE_BLANK
    ; 11 → OCTAVE
    db TILE_O, TILE_C, TILE_T, TILE_A, TILE_V, TILE_E
    ds 14, TILE_BLANK
    ; 12 → MINOR 9TH
    db TILE_M, TILE_I, TILE_N, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+9, TILE_T, TILE_H
    ds 11, TILE_BLANK
    ; 13 → MAJOR 9TH
    db TILE_M, TILE_A, TILE_J, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+9, TILE_T, TILE_H
    ds 11, TILE_BLANK
    ; 14 → MINOR 10TH
    db TILE_M, TILE_I, TILE_N, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0, TILE_T, TILE_H
    ds 10, TILE_BLANK
    ; 15 → MAJOR 10TH
    db TILE_M, TILE_A, TILE_J, TILE_O, TILE_R, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0, TILE_T, TILE_H
    ds 10, TILE_BLANK
    ; 16 → PERFECT 11TH
    db TILE_P, TILE_E, TILE_R, TILE_F, TILE_E, TILE_C, TILE_T, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+1, TILE_T, TILE_H
    ds 8, TILE_BLANK
    ; 17 → TRITONE PLUS 1
    db TILE_T, TILE_R, TILE_I, TILE_T, TILE_O, TILE_N, TILE_E, TILE_BLANK, TILE_P, TILE_L, TILE_U, TILE_S, TILE_BLANK, TILE_DIGIT0+1
    ds 6, TILE_BLANK
    ; 18 → PERFECT 12TH
    db TILE_P, TILE_E, TILE_R, TILE_F, TILE_E, TILE_C, TILE_T, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+2, TILE_T, TILE_H
    ds 8, TILE_BLANK

HelpStr_CH3Mode:
    ; 0 OFF
    db TILE_O, TILE_F, TILE_F
    ds 17, TILE_BLANK
    ; 1 WAV → WAVE ONLY
    db TILE_W, TILE_A, TILE_V, TILE_E, TILE_BLANK, TILE_O, TILE_N, TILE_L, TILE_Y
    ds 11, TILE_BLANK
    ; 2 MIX → MIX W/ SQUARES
    db TILE_M, TILE_I, TILE_X, TILE_BLANK, TILE_W, TILE_SLASH, TILE_BLANK, TILE_S, TILE_Q, TILE_U, TILE_A, TILE_R, TILE_E, TILE_S
    ds 6, TILE_BLANK

HelpStr_CH3Wave:
    ; 0 SIN → SINE
    db TILE_S, TILE_I, TILE_N, TILE_E
    ds 16, TILE_BLANK
    ; 1 SAW → SAWTOOTH
    db TILE_S, TILE_A, TILE_W, TILE_T, TILE_O, TILE_O, TILE_T, TILE_H
    ds 12, TILE_BLANK
    ; 2 TRI → TRIANGLE
    db TILE_T, TILE_R, TILE_I, TILE_A, TILE_N, TILE_G, TILE_L, TILE_E
    ds 12, TILE_BLANK
    ; 3 ORG → ORGAN
    db TILE_O, TILE_R, TILE_G, TILE_A, TILE_N
    ds 15, TILE_BLANK
    ; 4 BAS → BASS
    db TILE_B, TILE_A, TILE_S, TILE_S
    ds 16, TILE_BLANK

HelpStr_CH3Shape:
    ; 0 OFF → DISABLED
    db TILE_D, TILE_I, TILE_S, TILE_A, TILE_B, TILE_L, TILE_E, TILE_D
    ds 12, TILE_BLANK
    ; 1 PLK → PLUCK
    db TILE_P, TILE_L, TILE_U, TILE_C, TILE_K
    ds 15, TILE_BLANK
    ; 2 DCY → DECAY
    db TILE_D, TILE_E, TILE_C, TILE_A, TILE_Y
    ds 15, TILE_BLANK
    ; 3 ATK → ATTACK
    db TILE_A, TILE_T, TILE_T, TILE_A, TILE_C, TILE_K
    ds 14, TILE_BLANK
    ; 4 AD → ATTACK DECAY
    db TILE_A, TILE_T, TILE_T, TILE_A, TILE_C, TILE_K, TILE_BLANK, TILE_D, TILE_E, TILE_C, TILE_A, TILE_Y
    ds 8, TILE_BLANK
    ; 5 TRM → TREMOLO
    db TILE_T, TILE_R, TILE_E, TILE_M, TILE_O, TILE_L, TILE_O
    ds 13, TILE_BLANK
    ; 6 GAT → GATE
    db TILE_G, TILE_A, TILE_T, TILE_E
    ds 16, TILE_BLANK
    ; 7 RND → RANDOM
    db TILE_R, TILE_A, TILE_N, TILE_D, TILE_O, TILE_M
    ds 14, TILE_BLANK

HelpStr_CH3Rate:
    ; index 0 only (rate is numeric; show generic label)
    db TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E
    ds 10, TILE_BLANK

HelpStr_Accent:
    ; 0 OFF
    db TILE_O, TILE_F, TILE_F
    ds 17, TILE_BLANK
    ; 1 KIK → KICK
    db TILE_K, TILE_I, TILE_C, TILE_K
    ds 16, TILE_BLANK
    ; 2 SNR → SNARE
    db TILE_S, TILE_N, TILE_A, TILE_R, TILE_E
    ds 15, TILE_BLANK
    ; 3 RIM → RIM SHOT
    db TILE_R, TILE_I, TILE_M, TILE_BLANK, TILE_S, TILE_H, TILE_O, TILE_T
    ds 12, TILE_BLANK

HelpStr_FillColor:
    ; 0 HIS → HISS
    db TILE_H, TILE_I, TILE_S, TILE_S
    ds 16, TILE_BLANK
    ; 1 MTL → METALLIC
    db TILE_M, TILE_E, TILE_T, TILE_A, TILE_L, TILE_L, TILE_I, TILE_C
    ds 12, TILE_BLANK

HelpStr_FillShape:
    ; 0 FLT → FLAT
    db TILE_F, TILE_L, TILE_A, TILE_T
    ds 16, TILE_BLANK
    ; 1 ER↑ → EXP RAMP UP
    db TILE_E, TILE_X, TILE_P, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_U, TILE_P
    ds 9, TILE_BLANK
    ; 2 ER↓ → EXP RAMP DOWN
    db TILE_E, TILE_X, TILE_P, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_D, TILE_O, TILE_W, TILE_N
    ds 7, TILE_BLANK
    ; 3 LR↑ → LIN RAMP UP
    db TILE_L, TILE_I, TILE_N, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_U, TILE_P
    ds 9, TILE_BLANK
    ; 4 LR↓ → LIN RAMP DOWN
    db TILE_L, TILE_I, TILE_N, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_D, TILE_O, TILE_W, TILE_N
    ds 7, TILE_BLANK

; --- Page 7 (TONAL NOISE) help strings ---
; All entries are 20 bytes (TILE_BLANK-padded). Indexed by the wTonal* value
; via ShowHelpByIndex (base + a*20). HelpFor_TonalTransp is a documented
; special case: it forces a=0 against this 1-entry HelpStr_TonalTransp table.

HelpStr_TonalMode:
    ; 0 OFF
    db TILE_O, TILE_F, TILE_F
    ds 17, TILE_BLANK
    ; 1 CH4 SHADOW MELODY
    db TILE_C, TILE_H, TILE_DIGIT0+4, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_D, TILE_O, TILE_W, TILE_BLANK, TILE_M, TILE_E, TILE_L, TILE_O, TILE_D, TILE_Y
    ds 3, TILE_BLANK

HelpStr_TonalLock:
    ; 0 FRE → FREE
    db TILE_F, TILE_R, TILE_E, TILE_E
    ds 16, TILE_BLANK
    ; 1 LOK → LOCKED
    db TILE_L, TILE_O, TILE_C, TILE_K, TILE_E, TILE_D
    ds 14, TILE_BLANK

HelpStr_TonalLevel:
    ; 0 MUTE
    db TILE_M, TILE_U, TILE_T, TILE_E
    ds 16, TILE_BLANK
    ; 1 LEVEL 1
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_DIGIT0+1
    ds 13, TILE_BLANK
    ; 2 LEVEL 2
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_DIGIT0+2
    ds 13, TILE_BLANK
    ; 3 LEVEL 3
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_DIGIT0+3
    ds 13, TILE_BLANK
    ; 4 LEVEL 4
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_DIGIT0+4
    ds 13, TILE_BLANK
    ; 5 LEVEL 5
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_DIGIT0+5
    ds 13, TILE_BLANK
    ; 6 LEVEL 6
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_DIGIT0+6
    ds 13, TILE_BLANK
    ; 7 LEVEL 7
    db TILE_L, TILE_E, TILE_V, TILE_E, TILE_L, TILE_BLANK, TILE_DIGIT0+7
    ds 13, TILE_BLANK

HelpStr_TonalMap:
    ; 0 TRK → TRACK MELODY
    db TILE_T, TILE_R, TILE_A, TILE_C, TILE_K, TILE_BLANK, TILE_M, TILE_E, TILE_L, TILE_O, TILE_D, TILE_Y
    ds 8, TILE_BLANK
    ; 1 GML → GAMELAN VOICING
    db TILE_G, TILE_A, TILE_M, TILE_E, TILE_L, TILE_A, TILE_N, TILE_BLANK, TILE_V, TILE_O, TILE_I, TILE_C, TILE_I, TILE_N, TILE_G
    ds 5, TILE_BLANK
    ; 2 INV → INVERTED CONTOUR
    db TILE_I, TILE_N, TILE_V, TILE_E, TILE_R, TILE_T, TILE_E, TILE_D, TILE_BLANK, TILE_C, TILE_O, TILE_N, TILE_T, TILE_O, TILE_U, TILE_R
    ds 4, TILE_BLANK

HelpStr_TonalWidth:
    ; 0 15 → 15-BIT WHITE NOISE
    db TILE_DIGIT0+1, TILE_DIGIT0+5, TILE_DASH, TILE_B, TILE_I, TILE_T, TILE_BLANK, TILE_W, TILE_H, TILE_I, TILE_T, TILE_E, TILE_BLANK, TILE_N, TILE_O, TILE_I, TILE_S, TILE_E
    ds 2, TILE_BLANK
    ; 1 7B → 7-BIT METALLIC
    db TILE_DIGIT0+7, TILE_DASH, TILE_B, TILE_I, TILE_T, TILE_BLANK, TILE_M, TILE_E, TILE_T, TILE_A, TILE_L, TILE_L, TILE_I, TILE_C
    ds 6, TILE_BLANK

HelpStr_TonalDecay:
    ; 0 PNG → SHORT PING
    db TILE_S, TILE_H, TILE_O, TILE_R, TILE_T, TILE_BLANK, TILE_P, TILE_I, TILE_N, TILE_G
    ds 10, TILE_BLANK
    ; 1 RNG → LONG RING
    db TILE_L, TILE_O, TILE_N, TILE_G, TILE_BLANK, TILE_R, TILE_I, TILE_N, TILE_G
    ds 11, TILE_BLANK
    ; 2 CUT → SUSTAIN TIL GATE
    db TILE_S, TILE_U, TILE_S, TILE_T, TILE_A, TILE_I, TILE_N, TILE_BLANK, TILE_T, TILE_I, TILE_L, TILE_BLANK, TILE_G, TILE_A, TILE_T, TILE_E
    ds 4, TILE_BLANK

HelpStr_TonalTransp:
    ; Single static label — HelpFor_TonalTransp forces index 0.
    db TILE_T, TILE_R, TILE_A, TILE_N, TILE_S, TILE_P, TILE_O, TILE_S, TILE_E, TILE_BLANK, TILE_S, TILE_E, TILE_M, TILE_I, TILE_T, TILE_O, TILE_N, TILE_E, TILE_S
    ds 1, TILE_BLANK

HelpStr_TonalTrig:
    ; 0 EVR → EVERY NOTE
    db TILE_E, TILE_V, TILE_E, TILE_R, TILE_Y, TILE_BLANK, TILE_N, TILE_O, TILE_T, TILE_E
    ds 10, TILE_BLANK
    ; 1 HLF → EVERY 2ND NOTE
    db TILE_E, TILE_V, TILE_E, TILE_R, TILE_Y, TILE_BLANK, TILE_DIGIT0+2, TILE_N, TILE_D, TILE_BLANK, TILE_N, TILE_O, TILE_T, TILE_E
    ds 6, TILE_BLANK
    ; 2 Q4 → EVERY 4TH NOTE
    db TILE_E, TILE_V, TILE_E, TILE_R, TILE_Y, TILE_BLANK, TILE_DIGIT0+4, TILE_T, TILE_H, TILE_BLANK, TILE_N, TILE_O, TILE_T, TILE_E
    ds 6, TILE_BLANK

HelpStr_TonalPri:
    ; 0 ALL  → TONAL+FILL+ACCENT
    db TILE_T, TILE_O, TILE_N, TILE_A, TILE_L, TILE_PLUS, TILE_F, TILE_I, TILE_L, TILE_L, TILE_PLUS, TILE_A, TILE_C, TILE_C, TILE_E, TILE_N, TILE_T
    ds 3, TILE_BLANK
    ; 1 +ACC → TONAL+KICK NO FILL
    db TILE_T, TILE_O, TILE_N, TILE_A, TILE_L, TILE_PLUS, TILE_K, TILE_I, TILE_C, TILE_K, TILE_BLANK, TILE_N, TILE_O, TILE_BLANK, TILE_F, TILE_I, TILE_L, TILE_L
    ds 2, TILE_BLANK
    ; 2 +FIL → TONAL+FILL NO KICK
    db TILE_T, TILE_O, TILE_N, TILE_A, TILE_L, TILE_PLUS, TILE_F, TILE_I, TILE_L, TILE_L, TILE_BLANK, TILE_N, TILE_O, TILE_BLANK, TILE_K, TILE_I, TILE_C, TILE_K
    ds 2, TILE_BLANK
    ; 3 SOLO → TONAL ONLY
    db TILE_T, TILE_O, TILE_N, TILE_A, TILE_L, TILE_BLANK, TILE_O, TILE_N, TILE_L, TILE_Y
    ds 10, TILE_BLANK

; --- V26.1/V26.2/V26.3: Euclidean Drum Machine help strings (Page 8) --------
; Only SOUND/DECAY entries kept. V26.3: long-form value name only — the on-row
; label already says SOUND / DECAY, so the tooltip just expands the 3-letter
; abbreviation. Each entry is exactly HELP_LEN (20) bytes, padded with TILE_BLANK.

HelpStr_EuclidKickSound:
    ; 0 TGT → TIGHT
    db TILE_T, TILE_I, TILE_G, TILE_H, TILE_T
    ds 15, TILE_BLANK
    ; 1 BOM → BOOM
    db TILE_B, TILE_O, TILE_O, TILE_M
    ds 16, TILE_BLANK
    ; 2 SUB → SUB
    db TILE_S, TILE_U, TILE_B
    ds 17, TILE_BLANK
    ; 3 PCH → PUNCH
    db TILE_P, TILE_U, TILE_N, TILE_C, TILE_H
    ds 15, TILE_BLANK

HelpStr_EuclidKickDecay:
    ; 0 SHT → SHORT
    db TILE_S, TILE_H, TILE_O, TILE_R, TILE_T
    ds 15, TILE_BLANK
    ; 1 MID → MID
    db TILE_M, TILE_I, TILE_D
    ds 17, TILE_BLANK
    ; 2 LNG → LONG
    db TILE_L, TILE_O, TILE_N, TILE_G
    ds 16, TILE_BLANK

; --- V35 Euclid MOD LFO help strings (each exactly HELP_LEN = 20 bytes) -------
HelpStr_EucPLfoShape:
    ; 0 OFF → "PITCH SHAPE OFF" (15)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 5, TILE_BLANK
    ; 1 UP → "PITCH SHAPE RAMP UP" (19)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_U, TILE_P
    ds 1, TILE_BLANK
    ; 2 DN → "PITCH SHAPE RAMP DN" (19) — "RAMP DOWN" overflows 20-tile row
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_D, TILE_N
    ds 1, TILE_BLANK
    ; 3 TRI → "PITCH SHAPE TRIANGLE" (20)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_T, TILE_R, TILE_I, TILE_A, TILE_N, TILE_G, TILE_L, TILE_E
    ; 4 SIN → "PITCH SHAPE SINE" (16)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_S, TILE_I, TILE_N, TILE_E
    ds 4, TILE_BLANK
    ; 5 RND → "PITCH SHAPE RANDOM" (18)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_R, TILE_A, TILE_N, TILE_D, TILE_O, TILE_M
    ds 2, TILE_BLANK

HelpStr_EucPLfoRate:
    ; 0 2ST → "PITCH RATE 2 STEPS" (18)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+2, TILE_BLANK, TILE_S, TILE_T, TILE_E, TILE_P, TILE_S
    ds 2, TILE_BLANK
    ; 1 4ST → "PITCH RATE 4 STEPS" (18)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+4, TILE_BLANK, TILE_S, TILE_T, TILE_E, TILE_P, TILE_S
    ds 2, TILE_BLANK
    ; 2 8ST → "PITCH RATE 8 STEPS" (18)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+8, TILE_BLANK, TILE_S, TILE_T, TILE_E, TILE_P, TILE_S
    ds 2, TILE_BLANK
    ; 3 1BR → "PITCH RATE 1 BAR" (16)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+1, TILE_BLANK, TILE_B, TILE_A, TILE_R
    ds 4, TILE_BLANK
    ; 4 2BR → "PITCH RATE 2 BARS" (17)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+2, TILE_BLANK, TILE_B, TILE_A, TILE_R, TILE_S
    ds 3, TILE_BLANK
    ; 5 4BR → "PITCH RATE 4 BARS" (17)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+4, TILE_BLANK, TILE_B, TILE_A, TILE_R, TILE_S
    ds 3, TILE_BLANK
    ; 6 8BR → "PITCH RATE 8 BARS" (17)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+8, TILE_BLANK, TILE_B, TILE_A, TILE_R, TILE_S
    ds 3, TILE_BLANK

HelpStr_EucPLfoDepth:
    ; 0 → "PITCH DEPTH OFF" (15)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 5, TILE_BLANK
    ; 1..9 → "PITCH DEPTH N" (13 + 1 digit = 14)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+2
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+3
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+4
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+5
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+6
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+7
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+8
    ds 7, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+9
    ds 7, TILE_BLANK
    ; 10..15 → "PITCH DEPTH NN" (12 prefix + 2 digits = 14)
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+0
    ds 6, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+1
    ds 6, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+2
    ds 6, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+3
    ds 6, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+4
    ds 6, TILE_BLANK
    db TILE_P, TILE_I, TILE_T, TILE_C, TILE_H, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1, TILE_DIGIT0+5
    ds 6, TILE_BLANK

HelpStr_EucVLfoShape:
    ; 0 OFF → "VELO SHAPE OFF" (14)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 6, TILE_BLANK
    ; 1 UP → "VELO SHAPE RAMP UP" (18)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_U, TILE_P
    ds 2, TILE_BLANK
    ; 2 DN → "VELO SHAPE RAMP DN" (18)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_R, TILE_A, TILE_M, TILE_P, TILE_BLANK, TILE_D, TILE_N
    ds 2, TILE_BLANK
    ; 3 TRI → "VELO SHAPE TRIANGLE" (19)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_T, TILE_R, TILE_I, TILE_A, TILE_N, TILE_G, TILE_L, TILE_E
    ds 1, TILE_BLANK
    ; 4 SIN → "VELO SHAPE SINE" (15)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_S, TILE_I, TILE_N, TILE_E
    ds 5, TILE_BLANK
    ; 5 RND → "VELO SHAPE RANDOM" (17)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_S, TILE_H, TILE_A, TILE_P, TILE_E, TILE_BLANK, TILE_R, TILE_A, TILE_N, TILE_D, TILE_O, TILE_M
    ds 3, TILE_BLANK

HelpStr_EucVLfoRate:
    ; 0 2ST → "VELO RATE 2 STEPS" (17)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+2, TILE_BLANK, TILE_S, TILE_T, TILE_E, TILE_P, TILE_S
    ds 3, TILE_BLANK
    ; 1 4ST → "VELO RATE 4 STEPS" (17)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+4, TILE_BLANK, TILE_S, TILE_T, TILE_E, TILE_P, TILE_S
    ds 3, TILE_BLANK
    ; 2 8ST → "VELO RATE 8 STEPS" (17)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+8, TILE_BLANK, TILE_S, TILE_T, TILE_E, TILE_P, TILE_S
    ds 3, TILE_BLANK
    ; 3 1BR → "VELO RATE 1 BAR" (15)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+1, TILE_BLANK, TILE_B, TILE_A, TILE_R
    ds 5, TILE_BLANK
    ; 4 2BR → "VELO RATE 2 BARS" (16)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+2, TILE_BLANK, TILE_B, TILE_A, TILE_R, TILE_S
    ds 4, TILE_BLANK
    ; 5 4BR → "VELO RATE 4 BARS" (16)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+4, TILE_BLANK, TILE_B, TILE_A, TILE_R, TILE_S
    ds 4, TILE_BLANK
    ; 6 8BR → "VELO RATE 8 BARS" (16)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_R, TILE_A, TILE_T, TILE_E, TILE_BLANK, TILE_DIGIT0+8, TILE_BLANK, TILE_B, TILE_A, TILE_R, TILE_S
    ds 4, TILE_BLANK

HelpStr_EucVLfoDepth:
    ; 0 → "VELO DEPTH OFF" (14)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 6, TILE_BLANK
    ; 1..7 → "VELO DEPTH N" (12 + 1 digit = 13)
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+1
    ds 8, TILE_BLANK
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+2
    ds 8, TILE_BLANK
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+3
    ds 8, TILE_BLANK
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+4
    ds 8, TILE_BLANK
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+5
    ds 8, TILE_BLANK
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+6
    ds 8, TILE_BLANK
    db TILE_V, TILE_E, TILE_L, TILE_O, TILE_BLANK, TILE_D, TILE_E, TILE_P, TILE_T, TILE_H, TILE_BLANK, TILE_DIGIT0+7
    ds 8, TILE_BLANK

HelpStr_Saved:
    db TILE_S, TILE_A, TILE_V, TILE_E, TILE_D
    ds 15, TILE_BLANK

HelpStr_SaveFail:
    db TILE_S, TILE_A, TILE_V, TILE_E, TILE_BLANK
    db TILE_F, TILE_A, TILE_I, TILE_L, TILE_E, TILE_D
    ds 9, TILE_BLANK

HelpStr_Loaded:
    db TILE_L, TILE_O, TILE_A, TILE_D, TILE_E, TILE_D
    ds 14, TILE_BLANK

HelpStr_PressAgainSave:
    db TILE_P, TILE_R, TILE_E, TILE_S, TILE_S, TILE_BLANK
    db TILE_A, TILE_G, TILE_A, TILE_I, TILE_N, TILE_BLANK
    db TILE_T, TILE_O, TILE_BLANK
    db TILE_S, TILE_A, TILE_V, TILE_E, TILE_BLANK

HelpStr_PressAgainOverwr:
    db TILE_P, TILE_R, TILE_E, TILE_S, TILE_S, TILE_BLANK
    db TILE_A, TILE_G, TILE_A, TILE_I, TILE_N, TILE_BLANK
    db TILE_T, TILE_O, TILE_BLANK
    db TILE_O, TILE_V, TILE_R, TILE_W, TILE_R

HelpStr_EmptySlot:
    db TILE_E, TILE_M, TILE_P, TILE_T, TILE_Y, TILE_BLANK
    db TILE_S, TILE_L, TILE_O, TILE_T
    ds 10, TILE_BLANK

; --- V31 Randomize help strings (each exactly HELP_LEN = 20 bytes) ---
HelpStr_RndWild:
    ; "RANDOMIZED" (10) + 10 blanks = 20
    db TILE_R, TILE_A, TILE_N, TILE_D, TILE_O, TILE_M, TILE_I, TILE_Z, TILE_E, TILE_D
    ds 10, TILE_BLANK

HelpStr_RndMild:
    ; "KEPT KEY+TEMPO" (14) + 6 blanks = 20
    db TILE_K, TILE_E, TILE_P, TILE_T, TILE_BLANK, TILE_K, TILE_E, TILE_Y, TILE_PLUS, TILE_T, TILE_E, TILE_M, TILE_P, TILE_O
    ds 6, TILE_BLANK

; --- V38 preset matrix help strings (each exactly HELP_LEN = 20 bytes) ---
HelpStr_PressAgainDelete:
    ; "PRESS ST AGAIN DEL" (18) + 2 blanks = 20
    db TILE_P, TILE_R, TILE_E, TILE_S, TILE_S, TILE_BLANK, TILE_S, TILE_T, TILE_BLANK
    db TILE_A, TILE_G, TILE_A, TILE_I, TILE_N, TILE_BLANK, TILE_D, TILE_E, TILE_L
    ds 2, TILE_BLANK

HelpStr_Deleted:
    ; "DELETED" (7) + 13 blanks = 20
    db TILE_D, TILE_E, TILE_L, TILE_E, TILE_T, TILE_E, TILE_D
    ds 13, TILE_BLANK

; --- V32 MUTE CH4 help strings (each exactly HELP_LEN = 20 bytes) ---
HelpStr_MuteOn:
    ; "MUTE CH4 ON" (11) + 9 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+4, TILE_BLANK, TILE_O, TILE_N
    ds 9, TILE_BLANK

HelpStr_MuteOff:
    ; "MUTE CH4 OFF" (12) + 8 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+4, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 8, TILE_BLANK

; --- V32.1 MUTE EUC help strings (each exactly HELP_LEN = 20 bytes) ---
HelpStr_MuteEucOn:
    ; "MUTE EUC ON" (11) + 9 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_E, TILE_U, TILE_C, TILE_BLANK, TILE_O, TILE_N
    ds 9, TILE_BLANK

HelpStr_MuteEucOff:
    ; "MUTE EUC OFF" (12) + 8 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_E, TILE_U, TILE_C, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 8, TILE_BLANK

; --- V36 MIXER page mute help strings (each exactly HELP_LEN = 20 bytes) ---
HelpStr_MuteCH1On:
    ; "MUTE CH1 ON" (11) + 9 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+1, TILE_BLANK, TILE_O, TILE_N
    ds 9, TILE_BLANK

HelpStr_MuteCH1Off:
    ; "MUTE CH1 OFF" (12) + 8 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+1, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 8, TILE_BLANK

HelpStr_MuteCH2On:
    ; "MUTE CH2 ON" (11) + 9 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+2, TILE_BLANK, TILE_O, TILE_N
    ds 9, TILE_BLANK

HelpStr_MuteCH2Off:
    ; "MUTE CH2 OFF" (12) + 8 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+2, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 8, TILE_BLANK

HelpStr_MuteCH3On:
    ; "MUTE CH3 ON" (11) + 9 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+3, TILE_BLANK, TILE_O, TILE_N
    ds 9, TILE_BLANK

HelpStr_MuteCH3Off:
    ; "MUTE CH3 OFF" (12) + 8 blanks = 20
    db TILE_M, TILE_U, TILE_T, TILE_E, TILE_BLANK, TILE_C, TILE_H, TILE_DIGIT0+3, TILE_BLANK, TILE_O, TILE_F, TILE_F
    ds 8, TILE_BLANK

; --- Save Word Table (96 words x 7 bytes, tile-index encoded, TILE_BLANK padded) ---
SaveWordTable:
    db TILE_A,TILE_U,TILE_R,TILE_O,TILE_R,TILE_A,TILE_BLANK  ; AURORA
    db TILE_B,TILE_L,TILE_A,TILE_D,TILE_E,TILE_BLANK,TILE_BLANK  ; BLADE
    db TILE_C,TILE_O,TILE_M,TILE_E,TILE_T,TILE_BLANK,TILE_BLANK  ; COMET
    db TILE_D,TILE_E,TILE_L,TILE_T,TILE_A,TILE_BLANK,TILE_BLANK  ; DELTA
    db TILE_E,TILE_M,TILE_B,TILE_E,TILE_R,TILE_BLANK,TILE_BLANK  ; EMBER
    db TILE_F,TILE_L,TILE_A,TILE_R,TILE_E,TILE_BLANK,TILE_BLANK  ; FLARE
    db TILE_G,TILE_A,TILE_L,TILE_E,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; GALE
    db TILE_H,TILE_A,TILE_Z,TILE_E,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; HAZE
    db TILE_I,TILE_N,TILE_D,TILE_I,TILE_G,TILE_O,TILE_BLANK  ; INDIGO
    db TILE_J,TILE_A,TILE_D,TILE_E,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; JADE
    db TILE_K,TILE_I,TILE_T,TILE_E,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; KITE
    db TILE_L,TILE_U,TILE_N,TILE_A,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; LUNA
    db TILE_M,TILE_I,TILE_S,TILE_T,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; MIST
    db TILE_N,TILE_O,TILE_V,TILE_A,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; NOVA
    db TILE_O,TILE_R,TILE_B,TILE_I,TILE_T,TILE_BLANK,TILE_BLANK  ; ORBIT
    db TILE_P,TILE_R,TILE_I,TILE_S,TILE_M,TILE_BLANK,TILE_BLANK  ; PRISM
    db TILE_R,TILE_I,TILE_D,TILE_G,TILE_E,TILE_BLANK,TILE_BLANK  ; RIDGE
    db TILE_S,TILE_O,TILE_L,TILE_A,TILE_R,TILE_BLANK,TILE_BLANK  ; SOLAR
    db TILE_T,TILE_I,TILE_T,TILE_A,TILE_N,TILE_BLANK,TILE_BLANK  ; TITAN
    db TILE_U,TILE_M,TILE_B,TILE_R,TILE_A,TILE_BLANK,TILE_BLANK  ; UMBRA
    db TILE_V,TILE_O,TILE_R,TILE_T,TILE_E,TILE_X,TILE_BLANK  ; VORTEX
    db TILE_W,TILE_A,TILE_V,TILE_E,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; WAVE
    db TILE_X,TILE_E,TILE_N,TILE_O,TILE_N,TILE_BLANK,TILE_BLANK  ; XENON
    db TILE_Z,TILE_E,TILE_N,TILE_I,TILE_T,TILE_H,TILE_BLANK  ; ZENITH
    db TILE_A,TILE_E,TILE_G,TILE_I,TILE_S,TILE_BLANK,TILE_BLANK  ; AEGIS
    db TILE_B,TILE_O,TILE_L,TILE_T,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; BOLT
    db TILE_C,TILE_R,TILE_E,TILE_S,TILE_T,TILE_BLANK,TILE_BLANK  ; CREST
    db TILE_D,TILE_U,TILE_S,TILE_K,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; DUSK
    db TILE_E,TILE_C,TILE_H,TILE_O,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; ECHO
    db TILE_F,TILE_A,TILE_Z,TILE_E,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; FAZE
    db TILE_G,TILE_L,TILE_I,TILE_D,TILE_E,TILE_BLANK,TILE_BLANK  ; GLIDE
    db TILE_H,TILE_A,TILE_L,TILE_O,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; HALO
    db TILE_I,TILE_O,TILE_N,TILE_BLANK,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; ION
    db TILE_L,TILE_A,TILE_N,TILE_C,TILE_E,TILE_BLANK,TILE_BLANK  ; LANCE
    db TILE_L,TILE_Y,TILE_R,TILE_I,TILE_C,TILE_BLANK,TILE_BLANK  ; LYRIC
    db TILE_M,TILE_E,TILE_T,TILE_R,TILE_O,TILE_BLANK,TILE_BLANK  ; METRO
    db TILE_N,TILE_O,TILE_O,TILE_N,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; NOON
    db TILE_O,TILE_A,TILE_K,TILE_BLANK,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; OAK
    db TILE_P,TILE_U,TILE_L,TILE_S,TILE_E,TILE_BLANK,TILE_BLANK  ; PULSE
    db TILE_Q,TILE_U,TILE_I,TILE_L,TILE_L,TILE_BLANK,TILE_BLANK  ; QUILL
    db TILE_R,TILE_E,TILE_I,TILE_G,TILE_N,TILE_BLANK,TILE_BLANK  ; REIGN
    db TILE_S,TILE_A,TILE_B,TILE_R,TILE_E,TILE_BLANK,TILE_BLANK  ; SABRE
    db TILE_S,TILE_H,TILE_I,TILE_V,TILE_A,TILE_BLANK,TILE_BLANK  ; SHIVA
    db TILE_S,TILE_K,TILE_E,TILE_W,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; SKEW
    db TILE_S,TILE_L,TILE_I,TILE_C,TILE_K,TILE_BLANK,TILE_BLANK  ; SLICK
    db TILE_S,TILE_O,TILE_L,TILE_A,TILE_C,TILE_E,TILE_BLANK  ; SOLACE
    db TILE_S,TILE_P,TILE_I,TILE_R,TILE_E,TILE_BLANK,TILE_BLANK  ; SPIRE
    db TILE_S,TILE_Q,TILE_U,TILE_A,TILE_L,TILE_L,TILE_BLANK  ; SQUALL
    db TILE_S,TILE_T,TILE_A,TILE_R,TILE_K,TILE_BLANK,TILE_BLANK  ; STARK
    db TILE_S,TILE_T,TILE_E,TILE_E,TILE_L,TILE_BLANK,TILE_BLANK  ; STEEL
    db TILE_S,TILE_T,TILE_O,TILE_N,TILE_E,TILE_BLANK,TILE_BLANK  ; STONE
    db TILE_S,TILE_T,TILE_O,TILE_R,TILE_M,TILE_BLANK,TILE_BLANK  ; STORM
    db TILE_S,TILE_T,TILE_R,TILE_I,TILE_K,TILE_E,TILE_BLANK  ; STRIKE
    db TILE_S,TILE_T,TILE_R,TILE_U,TILE_M,TILE_BLANK,TILE_BLANK  ; STRUM
    db TILE_S,TILE_U,TILE_R,TILE_G,TILE_E,TILE_BLANK,TILE_BLANK  ; SURGE
    db TILE_S,TILE_W,TILE_I,TILE_F,TILE_T,TILE_BLANK,TILE_BLANK  ; SWIFT
    db TILE_S,TILE_Y,TILE_N,TILE_C,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; SYNC
    db TILE_T,TILE_E,TILE_R,TILE_R,TILE_A,TILE_BLANK,TILE_BLANK  ; TERRA
    db TILE_T,TILE_H,TILE_E,TILE_T,TILE_A,TILE_BLANK,TILE_BLANK  ; THETA
    db TILE_T,TILE_H,TILE_O,TILE_R,TILE_N,TILE_BLANK,TILE_BLANK  ; THORN
    db TILE_T,TILE_I,TILE_D,TILE_E,TILE_BLANK,TILE_BLANK,TILE_BLANK  ; TIDE
    db TILE_T,TILE_R,TILE_A,TILE_C,TILE_E,TILE_BLANK,TILE_BLANK  ; TRACE
    db TILE_T,TILE_R,TILE_A,TILE_I,TILE_L,TILE_BLANK,TILE_BLANK  ; TRAIL
    db TILE_T,TILE_R,TILE_I,TILE_L,TILE_L,TILE_BLANK,TILE_BLANK  ; TRILL

; --- Save Param Table (list of WRAM addresses to snapshot; zero-terminated) ------
SaveParamTable:
    dw wCurrentBank
    dw wRootNote
    dw wRootOctave
    dw wPatternType
    dw wSpeed
    dw wDutyCycle
    dw wOctaveRange
    dw wGateLength
    dw wStride
    dw wAttackSpeed
    dw wSwing
    dw wCH1Mode
    dw wCH1Volume
    dw wCH1Detune
    dw wCH1Interval
    dw wCH1ScaleDeg
    dw wCH1Attack
    dw wCH1AtkType
    dw wCH1Wave
    dw wCH1Offset
    dw wTapSubdiv
    dw wTapEffective
    dw wCH3Mode
    dw wCH3Wave
    dw wCH3Volume
    dw wCH3Shape
    dw wCH3Rate
    dw wNoiseAccent
    dw wFillLevel
    dw wFillColor
    dw wFillPitch
    dw wFillFreq
    dw wFillShape
    dw wTonalMode
    dw wTonalLevel
    dw wTonalMap
    dw wTonalWidth
    dw wTonalDecay
    dw wTonalTransp
    dw wTonalTrig
    dw wTonalPri
    dw wTonalLock
    dw wEuclidKickK
    dw wEuclidKickN
    dw wEuclidKickRot
    dw wEuclidKickLevel
    dw wEuclidKickSound
    dw wEuclidKickDecay
    dw wEuclidKickPitch
    dw wEuclidKickLock            ; V37 arp-cycle LEN lock
    dw wEucPLfoShape              ; V35 Euclid MOD LFO params
    dw wEucPLfoRate
    dw wEucPLfoDepth
    dw wEucVLfoShape
    dw wEucVLfoRate
    dw wEucVLfoDepth
    dw wMuteCH4                  ; V36 mute matrix (all 5 voices)
    dw wMuteEuc
    dw wMuteCH1
    dw wMuteCH2
    dw wMuteCH3
    dw 0                         ; terminator

; Per-field (min, max) bounds parallel to SaveParamTable (must stay in sync).
; Used by ValidateSlot to range-check SRAM payload before applying to WRAM.
SaveParamRangeTable:
    db 0, ARP_BANK_COUNT - 1            ; wCurrentBank:    0..27
    db 0, 11                            ; wRootNote:       0..11
    db 0, 4                             ; wRootOctave:     0..4
    db 0, PAT_COUNT - 1                 ; wPatternType:    0..3
    db MIN_SPEED, MAX_SPEED             ; wSpeed:          0..31
    db 0, WAVE_COUNT - 1                ; wDutyCycle:      0..3
    db MIN_OCTAVE_RANGE, MAX_OCTAVE_RANGE ; wOctaveRange:  1..3
    db 0, MAX_GATE                      ; wGateLength:     0..4
    db 1, MAX_STRIDE                    ; wStride:         1..4  (0 hangs ComputeNoteCount)
    db 0, MAX_ATTACK                    ; wAttackSpeed:    0..3
    db 0, MAX_SWING                     ; wSwing:          0..7
    db 0, MAX_CH1MODE                   ; wCH1Mode:        0..5
    db 0, MAX_CH1VOL                    ; wCH1Volume:      0..7
    db 0, MAX_CH1DET                    ; wCH1Detune:      0..4
    db 0, MAX_CH1INT                    ; wCH1Interval:    0..18
    db 0, MAX_CH1DEG                    ; wCH1ScaleDeg:    0..6
    db 0, MAX_CH1ATK                    ; wCH1Attack:      0..2
    db 1, MAX_CH1ATKTYPE                ; wCH1AtkType:     1..3  (index 0 unused)
    db 0, MAX_CH1WAVE                   ; wCH1Wave:        0..3
    db 0, MAX_CH1OFFSET                 ; wCH1Offset:      0..14
    db 1, 4                             ; wTapSubdiv:      1..4
    db 0, 255                           ; wTapEffective:   full byte (tap frame count)
    db 0, MAX_CH3MODE                   ; wCH3Mode:        0..2
    db 0, CH3_WAVE_COUNT - 1            ; wCH3Wave:        0..4
    db 0, MAX_CH3VOL                    ; wCH3Volume:      0..3
    db 0, MAX_CH3SHAPE                  ; wCH3Shape:       0..7 (0=OFF)
    db 0, MAX_CH3RATE                   ; wCH3Rate:        0..8 (0=compat default)
    db 0, MAX_NOISE_ACCENT              ; wNoiseAccent:    0..3
    db 0, MAX_FILL_LEVEL                ; wFillLevel:      0..7
    db 0, MAX_FILL_COLOR                ; wFillColor:      0..1
    db 0, MAX_FILL_PITCH                ; wFillPitch:      0..7
    db 0, MAX_FILL_FREQ                 ; wFillFreq:       0..7
    db 0, MAX_FILL_SHAPE                ; wFillShape:      0..4
    db 0, 1                             ; wTonalMode:      0..1
    db 0, MAX_TONAL_LEVEL               ; wTonalLevel:     0..7
    db 0, MAX_TONAL_MAP                 ; wTonalMap:       0..2
    db 0, MAX_TONAL_WIDTH               ; wTonalWidth:     0..1
    db 0, MAX_TONAL_DECAY               ; wTonalDecay:     0..2
    db 0, MAX_TONAL_TRANSP              ; wTonalTransp:    0..24  (offset-binary)
    db 0, MAX_TONAL_TRIG                ; wTonalTrig:      0..2
    db 0, MAX_TONAL_PRI                 ; wTonalPri:       0..3
    db 0, 1                             ; wTonalLock:      0..1
    db 0, MAX_EUCLID_KICK_N             ; wEuclidKickK:    0..16
    db MIN_EUCLID_KICK_N, MAX_EUCLID_KICK_N ; wEuclidKickN: 2..16
    db 0, MAX_EUCLID_KICK_N - 1         ; wEuclidKickRot:  0..15
    db 0, MAX_EUCLID_KICK_LEVEL         ; wEuclidKickLevel: 0..7
    db 0, MAX_EUCLID_KICK_SOUND         ; wEuclidKickSound: 0..3
    db 0, MAX_EUCLID_KICK_DECAY         ; wEuclidKickDecay: 0..2
    db 0, MAX_EUCLID_KICK_PITCH         ; wEuclidKickPitch: 0..63
    db 0, 1                             ; wEuclidKickLock:  0..1
    db 0, MAX_EUCLID_PLFO_SHAPE         ; wEucPLfoShape:    0..5
    db 0, MAX_EUCLID_PLFO_RATE          ; wEucPLfoRate:     0..6
    db 0, MAX_EUCLID_PLFO_DEPTH         ; wEucPLfoDepth:    0..15
    db 0, MAX_EUCLID_VLFO_SHAPE         ; wEucVLfoShape:    0..5
    db 0, MAX_EUCLID_VLFO_RATE          ; wEucVLfoRate:     0..6
    db 0, MAX_EUCLID_VLFO_DEPTH         ; wEucVLfoDepth:    0..7
    db 0, 1                             ; wMuteCH4:         0..1
    db 0, 1                             ; wMuteEuc:         0..1
    db 0, 1                             ; wMuteCH1:         0..1
    db 0, 1                             ; wMuteCH2:         0..1
    db 0, 1                             ; wMuteCH3:         0..1

; =============================================================================
; Tile Data (45 tiles x 16 bytes = 720 bytes)
; 2bpp format: each row = 2 bytes (low plane, high plane)
; High plane always $00 for single-color tiles
; =============================================================================

TileData:

; Tile 0: BLANK
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00

; Tile 1: UP_ARROW
    db $18, $00, $3C, $00, $7E, $00, $18, $00
    db $18, $00, $18, $00, $3C, $00, $00, $00

; Tile 2: DN_ARROW
    db $3C, $00, $18, $00, $18, $00, $18, $00
    db $7E, $00, $3C, $00, $18, $00, $00, $00

; Tile 3: PINGPONG (double vertical arrow)
    db $18, $00, $3C, $00, $7E, $00, $18, $00
    db $18, $00, $7E, $00, $3C, $00, $18, $00

; Tile 4: RANDOM (? question mark)
    db $3C, $00, $66, $00, $06, $00, $1C, $00
    db $18, $00, $00, $00, $18, $00, $00, $00

; Tile 5: PLAY (right triangle)
    db $60, $00, $78, $00, $7E, $00, $7F, $00
    db $7E, $00, $78, $00, $60, $00, $00, $00

; Tile 6: PAUSE (two vertical bars)
    db $66, $00, $66, $00, $66, $00, $66, $00
    db $66, $00, $66, $00, $66, $00, $00, $00

; Tile 7: SHARP (#)
    db $24, $00, $24, $00, $7E, $00, $24, $00
    db $7E, $00, $24, $00, $24, $00, $00, $00

; Tile 8: DIGIT 0
    db $3C, $00, $66, $00, $6E, $00, $76, $00
    db $66, $00, $66, $00, $3C, $00, $00, $00

; Tile 9: DIGIT 1
    db $18, $00, $38, $00, $18, $00, $18, $00
    db $18, $00, $18, $00, $3C, $00, $00, $00

; Tile 10: DIGIT 2
    db $3C, $00, $66, $00, $06, $00, $0C, $00
    db $30, $00, $60, $00, $7E, $00, $00, $00

; Tile 11: DIGIT 3
    db $3C, $00, $66, $00, $06, $00, $1C, $00
    db $06, $00, $66, $00, $3C, $00, $00, $00

; Tile 12: DIGIT 4
    db $0C, $00, $1C, $00, $2C, $00, $4C, $00
    db $7E, $00, $0C, $00, $1E, $00, $00, $00

; Tile 13: DIGIT 5
    db $7E, $00, $60, $00, $7C, $00, $06, $00
    db $06, $00, $66, $00, $3C, $00, $00, $00

; Tile 14: DIGIT 6
    db $3C, $00, $66, $00, $60, $00, $7C, $00
    db $66, $00, $66, $00, $3C, $00, $00, $00

; Tile 15: DIGIT 7
    db $7E, $00, $06, $00, $0C, $00, $18, $00
    db $30, $00, $30, $00, $30, $00, $00, $00

; Tile 16: DIGIT 8
    db $3C, $00, $66, $00, $66, $00, $3C, $00
    db $66, $00, $66, $00, $3C, $00, $00, $00

; Tile 17: DIGIT 9
    db $3C, $00, $66, $00, $66, $00, $3E, $00
    db $06, $00, $66, $00, $3C, $00, $00, $00

; Tile 18: A
    db $3C, $00, $66, $00, $C3, $00, $FF, $00
    db $C3, $00, $C3, $00, $C3, $00, $00, $00

; Tile 19: B
    db $FC, $00, $C6, $00, $C6, $00, $FC, $00
    db $C6, $00, $C6, $00, $FC, $00, $00, $00

; Tile 20: C
    db $3C, $00, $66, $00, $C0, $00, $C0, $00
    db $C0, $00, $66, $00, $3C, $00, $00, $00

; Tile 21: D
    db $F8, $00, $CC, $00, $C6, $00, $C6, $00
    db $C6, $00, $CC, $00, $F8, $00, $00, $00

; Tile 22: E
    db $FE, $00, $C0, $00, $C0, $00, $FC, $00
    db $C0, $00, $C0, $00, $FE, $00, $00, $00

; Tile 23: F
    db $FE, $00, $C0, $00, $C0, $00, $FC, $00
    db $C0, $00, $C0, $00, $C0, $00, $00, $00

; Tile 24: G
    db $3C, $00, $66, $00, $C0, $00, $CE, $00
    db $C6, $00, $66, $00, $3C, $00, $00, $00

; Tile 25: H
    db $C6, $00, $C6, $00, $C6, $00, $FE, $00
    db $C6, $00, $C6, $00, $C6, $00, $00, $00

; Tile 26: I
    db $3C, $00, $18, $00, $18, $00, $18, $00
    db $18, $00, $18, $00, $3C, $00, $00, $00

; Tile 27: L
    db $C0, $00, $C0, $00, $C0, $00, $C0, $00
    db $C0, $00, $C0, $00, $FE, $00, $00, $00

; Tile 28: M
    db $63, $00, $77, $00, $7F, $00, $6B, $00
    db $63, $00, $63, $00, $63, $00, $00, $00

; Tile 29: N
    db $63, $00, $73, $00, $7B, $00, $6F, $00
    db $67, $00, $63, $00, $63, $00, $00, $00

; Tile 30: O
    db $3C, $00, $66, $00, $66, $00, $66, $00
    db $66, $00, $66, $00, $3C, $00, $00, $00

; Tile 31: P
    db $FC, $00, $C6, $00, $C6, $00, $FC, $00
    db $C0, $00, $C0, $00, $C0, $00, $00, $00

; Tile 32: R
    db $FC, $00, $C6, $00, $C6, $00, $FC, $00
    db $CC, $00, $C6, $00, $C3, $00, $00, $00

; Tile 33: S
    db $3C, $00, $66, $00, $60, $00, $3C, $00
    db $06, $00, $66, $00, $3C, $00, $00, $00

; Tile 34: T
    db $7E, $00, $5A, $00, $18, $00, $18, $00
    db $18, $00, $18, $00, $3C, $00, $00, $00

; Tile 35: V
    db $63, $00, $63, $00, $63, $00, $63, $00
    db $63, $00, $36, $00, $1C, $00, $00, $00

; Tile 36: X
    db $63, $00, $36, $00, $1C, $00, $08, $00
    db $1C, $00, $36, $00, $63, $00, $00, $00

; Tile 37: Y
    db $C3, $00, $66, $00, $3C, $00, $18, $00
    db $18, $00, $18, $00, $18, $00, $00, $00

; Tile 38: K
    db $C6, $00, $CC, $00, $D8, $00, $F0, $00
    db $D8, $00, $CC, $00, $C6, $00, $00, $00

; Tile 39: W
    db $63, $00, $63, $00, $63, $00, $6B, $00
    db $7F, $00, $77, $00, $63, $00, $00, $00

; Tile 40: U
    db $C6, $00, $C6, $00, $C6, $00, $C6, $00
    db $C6, $00, $C6, $00, $7C, $00, $00, $00

; Tile 41: DOT (.)
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $18, $00, $18, $00, $00, $00

; Tile 42: SLASH (/)
    db $06, $00, $0C, $00, $18, $00, $30, $00
    db $60, $00, $C0, $00, $80, $00, $00, $00

; Tile 43: PLUS (+)
    db $00, $00, $18, $00, $18, $00, $7E, $00
    db $18, $00, $18, $00, $00, $00, $00, $00

; Tile 44: DASH (-)
    db $00, $00, $00, $00, $00, $00, $7E, $00
    db $00, $00, $00, $00, $00, $00, $00, $00

; Tile 45: Z
    db $7E, $00, $06, $00, $0C, $00, $18, $00
    db $30, $00, $60, $00, $7E, $00, $00, $00

; Tile 46: J
    db $1E, $00, $0C, $00, $0C, $00, $0C, $00
    db $CC, $00, $CC, $00, $78, $00, $00, $00

; Tile 47: lowercase m (three-legged arc)
    db $00, $00, $00, $00, $6C, $00, $7E, $00
    db $66, $00, $66, $00, $66, $00, $00, $00

; Tile 48: LEFT arrow
    db $00, $00, $10, $00, $30, $00, $7E, $00
    db $7E, $00, $30, $00, $10, $00, $00, $00

; Tile 49: RIGHT arrow
    db $00, $00, $08, $00, $0C, $00, $7E, $00
    db $7E, $00, $0C, $00, $08, $00, $00, $00

; Tile 50: Q
    db $3C, $00, $66, $00, $66, $00, $66, $00
    db $66, $00, $6A, $00, $3C, $00, $06, $00

TileDataEnd:
