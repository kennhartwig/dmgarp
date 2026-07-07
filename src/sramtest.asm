; =============================================================================
; sramtest.asm — EMS 64M MBC1-header RAM-banking probe (throwaway, V38 Phase 0)
; =============================================================================
; Purpose: decide whether DMGARP can claim 32 KB banked SRAM (header $0147=$03
; MBC1+RAM+BATTERY, $0149=$03 = 32 KB / 4 banks) on the EMS GB USB Smart Card
; 64M, whose mapper is MBC5-based hardware.
;
; What it does on every boot:
;   1. KEPT pass — before writing anything, check whether the per-bank
;      signatures from a previous run are already present (battery retention).
;   2. Write pass — select RAM banks 0..3 via $4000 (MBC1 mode 1 set via
;      $6000, which MBC5-style hardware ignores) and write a distinct 16-byte
;      signature at both $A000 and $BFF0 of each bank.
;   3. LIVE pass — re-read all four banks and compare.
;
; Screen:
;   BANK  0 1 2 3
;   KEPT  P P P P      <- battery retention from previous run (F F F F on 1st boot)
;   LIVE  P P P P      <- banking works right now
;
; Expected results:
;   - Banking works:   LIVE = P P P P
;   - No banking (all writes alias one 8 KB bank): LIVE = F F F P
;   - After a power cycle, KEPT = P P P P proves battery retention across banks.
; =============================================================================

; --- Hardware registers ---
DEF rLCDC EQU $FF40
DEF rSCY  EQU $FF42
DEF rSCX  EQU $FF43
DEF rLY   EQU $FF44
DEF rBGP  EQU $FF47

; --- Tiles ---
DEF TILE_BLANK EQU 0
DEF TILE_P     EQU 1
DEF TILE_F     EQU 2
DEF FONT_COUNT EQU 19

CHARMAP " ", 0
CHARMAP "P", 1
CHARMAP "F", 2
CHARMAP "S", 3
CHARMAP "R", 4
CHARMAP "A", 5
CHARMAP "M", 6
CHARMAP "B", 7
CHARMAP "N", 8
CHARMAP "K", 9
CHARMAP "T", 10
CHARMAP "E", 11
CHARMAP "I", 12
CHARMAP "L", 13
CHARMAP "V", 14
CHARMAP "0", 15
CHARMAP "1", 16
CHARMAP "2", 17
CHARMAP "3", 18

; =============================================================================
; Interrupt vectors (unused — ROM never enables interrupts)
; =============================================================================

SECTION "VBlank_ISR", ROM0[$0040]
    reti

; =============================================================================
; Header
; =============================================================================

SECTION "Header", ROM0[$0100]
    nop
    jp EntryPoint
    ds $150 - @, 0

; =============================================================================
; WRAM
; =============================================================================

SECTION "WRAM", WRAM0

wKept: ds 4   ; per-bank retention result (1=signature found at boot)
wLive: ds 4   ; per-bank write/readback result (1=pass)

; =============================================================================
; Main
; =============================================================================

SECTION "Main", ROM0[$0150]

EntryPoint:
    di
.waitVBlank:
    ldh a, [rLY]
    cp 144
    jr c, .waitVBlank
    xor a
    ldh [rLCDC], a              ; LCD off — free VRAM access
    ldh [rSCY], a
    ldh [rSCX], a
    ld a, %11100100
    ldh [rBGP], a

    ; Copy font tiles to $8000 ($8000 addressing, LCDC bit 4 set at LCD-on)
    ld de, FontTiles
    ld hl, $8000
    ld bc, FONT_COUNT * 16
.copyTiles:
    ld a, [de]
    inc de
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .copyTiles

    ; Clear BG map with blank tile
    ld hl, $9800
    ld bc, $0400
.clearMap:
    ld [hl], TILE_BLANK
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, .clearMap

    ; --- SRAM banking test ---
    ld a, $0A
    ld [$0000], a               ; enable SRAM
    ld a, 1
    ld [$6000], a               ; MBC1 mode 1 (RAM banking); MBC5 hw ignores this

    ; KEPT pass: probe existing signatures before any write
    ld b, 0
.keptLoop:
    ld a, b
    push bc
    call CheckBank
    pop bc
    ld hl, wKept
    call StoreResult
    inc b
    ld a, b
    cp 4
    jr nz, .keptLoop

    ; Write pass: all four banks first, then verify — if banking is dead,
    ; bank 3's writes overwrite banks 0-2 and LIVE reads F F F P.
    ld b, 0
.writeLoop:
    ld a, b
    push bc
    call WriteBank
    pop bc
    inc b
    ld a, b
    cp 4
    jr nz, .writeLoop

    ; LIVE pass: re-read and compare
    ld b, 0
.liveLoop:
    ld a, b
    push bc
    call CheckBank
    pop bc
    ld hl, wLive
    call StoreResult
    inc b
    ld a, b
    cp 4
    jr nz, .liveLoop

    xor a
    ld [$4000], a               ; back to RAM bank 0
    ld [$0000], a               ; disable SRAM

    ; --- Draw results ---
    ld hl, $9803
    ld de, StrTitle
    call DrawStr
    ld hl, $9843
    ld de, StrHeader
    call DrawStr
    ld hl, $9883
    ld de, StrKept
    call DrawStr
    ld hl, $98C3
    ld de, StrLive
    call DrawStr
    ld hl, $9923
    ld de, StrLegend
    call DrawStr

    ld hl, $9880 + 9            ; KEPT results under the 0 1 2 3 header
    ld de, wKept
    call DrawRes4
    ld hl, $98C0 + 9            ; LIVE results
    ld de, wLive
    call DrawRes4

    ld a, %10010001             ; LCD on, BG on, $8000 tiles, $9800 map
    ldh [rLCDC], a
.forever:
    jr .forever

; -----------------------------------------------------------------------------
; StoreResult — hl = result array base, b = bank index, a = result (0/1)
; Preserves b. Clobbers a, d, e, hl.
StoreResult:
    ld d, 0
    ld e, b
    add hl, de
    ld [hl], a
    ret

; -----------------------------------------------------------------------------
; SigBase — a = bank (0..3) → a = signature base byte ($50 + bank*16)
SigBase:
    add a
    add a
    add a
    add a
    add $50
    ret

; -----------------------------------------------------------------------------
; WriteBank — a = bank. Selects the bank and writes signatures:
;   $A000+i = base + i  (i = 0..15)
;   $BFF0+i = (base + i) ^ $FF
; Clobbers a, c, d, e, hl.
WriteBank:
    ld [$4000], a               ; select RAM bank
    ld c, a
    call SigBase
    ld d, a
    ld hl, $A000
    ld e, 16
.wrLow:
    ld a, d
    ld [hli], a
    inc d
    dec e
    jr nz, .wrLow
    ld a, c
    call SigBase
    cpl                         ; complement pattern for the top of the bank
    ld d, a
    ld hl, $BFF0
    ld e, 16
.wrHigh:
    ld a, d
    ld [hli], a
    dec d                       ; (base+i)^$FF decrements as i increments
    dec e
    jr nz, .wrHigh
    ret

; -----------------------------------------------------------------------------
; CheckBank — a = bank → a = 1 if both signature blocks match, else 0.
; Clobbers a, c, d, e, hl.
CheckBank:
    ld [$4000], a               ; select RAM bank
    ld c, a
    call SigBase
    ld d, a
    ld hl, $A000
    ld e, 16
.ckLow:
    ld a, [hli]
    cp d
    jr nz, .fail
    inc d
    dec e
    jr nz, .ckLow
    ld a, c
    call SigBase
    cpl
    ld d, a
    ld hl, $BFF0
    ld e, 16
.ckHigh:
    ld a, [hli]
    cp d
    jr nz, .fail
    dec d
    dec e
    jr nz, .ckHigh
    ld a, 1
    ret
.fail:
    xor a
    ret

; -----------------------------------------------------------------------------
; DrawStr — hl = VRAM dest, de = length-prefixed string
DrawStr:
    ld a, [de]
    inc de
    ld b, a
.dsLoop:
    ld a, [de]
    inc de
    ld [hli], a
    dec b
    jr nz, .dsLoop
    ret

; -----------------------------------------------------------------------------
; DrawRes4 — hl = VRAM dest of first result char, de = 4-byte result array.
; Writes P (1) or F (0) every second column.
DrawRes4:
    ld b, 4
.drLoop:
    ld a, [de]
    inc de
    and a
    ld c, TILE_F
    jr z, .drPut
    ld c, TILE_P
.drPut:
    ld [hl], c
    inc hl
    inc hl
    dec b
    jr nz, .drLoop
    ret

; =============================================================================
; Data
; =============================================================================

StrTitle:
    db 14, "SRAM BANK TEST"
StrHeader:
    db 13, "BANK  0 1 2 3"
StrKept:
    db 4, "KEPT"
StrLive:
    db 4, "LIVE"
StrLegend:
    db 14, "P PASS  F FAIL"

; --- Font: 19 tiles, 2bpp, both planes identical (colors 0/3) ---------------
MACRO TROW
    REPT _NARG
        db \1, \1
        SHIFT
    ENDR
ENDM

FontTiles:
    ; 0 blank
    TROW $00, $00, $00, $00, $00, $00, $00, $00
    ; 1 P
    TROW $7C, $66, $66, $7C, $60, $60, $60, $00
    ; 2 F
    TROW $7E, $60, $60, $7C, $60, $60, $60, $00
    ; 3 S
    TROW $3E, $60, $60, $3C, $06, $06, $7C, $00
    ; 4 R
    TROW $7C, $66, $66, $7C, $78, $6C, $66, $00
    ; 5 A
    TROW $3C, $66, $66, $7E, $66, $66, $66, $00
    ; 6 M
    TROW $C6, $EE, $FE, $D6, $C6, $C6, $C6, $00
    ; 7 B
    TROW $7C, $66, $66, $7C, $66, $66, $7C, $00
    ; 8 N
    TROW $66, $76, $7E, $6E, $66, $66, $66, $00
    ; 9 K
    TROW $66, $6C, $78, $70, $78, $6C, $66, $00
    ; 10 T
    TROW $7E, $18, $18, $18, $18, $18, $18, $00
    ; 11 E
    TROW $7E, $60, $60, $7C, $60, $60, $7E, $00
    ; 12 I
    TROW $3C, $18, $18, $18, $18, $18, $3C, $00
    ; 13 L
    TROW $60, $60, $60, $60, $60, $60, $7E, $00
    ; 14 V
    TROW $66, $66, $66, $66, $66, $3C, $18, $00
    ; 15 digit 0
    TROW $3C, $66, $6E, $76, $66, $66, $3C, $00
    ; 16 digit 1
    TROW $18, $38, $18, $18, $18, $18, $3C, $00
    ; 17 digit 2
    TROW $3C, $66, $06, $0C, $18, $30, $7E, $00
    ; 18 digit 3
    TROW $3C, $66, $06, $1C, $06, $66, $3C, $00
