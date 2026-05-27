# Flashing to Cartridge

This guide covers writing DMGARP to a flash cartridge using the open-source
`ems-flasher` CLI on Linux. The tested hardware is the EMS USB 64M Smart Card
(USB ID `4670:9394`).

Other flash carts may require different tools. The patching procedure below is
specific to the EMS cart's auto-boot setup.

---

## Tool

Use the `ems-flasher` CLI:
[github.com/mikeryan/ems-flasher](https://github.com/mikeryan/ems-flasher)

**Do not use `ems-qart` (GUI).** It fails to claim the EMS device before the
cart's USB idle timeout fires.

### Build (one-time per session)

A helper script handles the clone, patches, and build:

```bash
./scripts/build-ems-flasher.sh
```

This produces the binary at `/tmp/ems-flasher/ems-flasher-real`.

Note: `/tmp` is cleared on reboot. Re-run the script at the start of each new
session before flashing.

System dependencies: `git`, `gcc`, `make`, `libusb-1.0-0-dev`, `build-essential`.

### Why three patches are required

The EMS 64M cart uses Windows-formatted flash headers and a specific menu-ROM
title. Upstream `ems-flasher` expects different defaults. Flashing DMGARP
without patches results in an error or a game-selection menu wrapping the ROM
instead of an auto-boot.

- **Patch 1 — MENUTITLE:** Upstream expects `"MENU#"`. This cart uses
  `"GB16M"`. Without it: `error: no valid menu ROM found at bank 0`.
- **Patch 2 — listing.count=0:** Forces the tool to treat the page as empty,
  placing DMGARP at offset 0. The Game Boy reads from address 0 → DMGARP
  auto-boots without a selection screen.
- **Patch 3 — disable menu auto-insert:** Prevents the tool from prepending
  `menu.gb` at offset 0 when the page appears empty.

---

## USB access

Add a udev rule so no `sudo` is needed:

```
SUBSYSTEM=="usb", ATTR{idVendor}=="4670", ATTR{idProduct}=="9394", \
  GROUP="plugdev", MODE="0664"
```

Place this in `/etc/udev/rules.d/50_ems_gb_flash.rules` and ensure your user
is in the `plugdev` group. Reload: `sudo udevadm control --reload-rules`.

---

## Build the ROM

```bash
make build        # assembles src/arpeggio.asm → roms/dmg-arp.gb
```

Verify the timestamp before flashing:

```bash
ls -l roms/dmg-arp.gb
```

---

## Flash procedure

The EMS 64M cart has two physical 4 MB banks (pages 1 and 2). Determine which
bank your specific cartridge loads on the Game Boy, then use that bank number
for all commands. The two pages are independent.

```bash
# 1. Check connectivity
lsusb | grep 4670:9394

# 2. Write DMGARP (with retry for USB idle resets)
for i in $(seq 1 5); do
  /tmp/ems-flasher/ems-flasher-real --verbose --bank <N> \
      --write roms/dmg-arp.gb && break
  sleep 2
done

# 3. Verify the write landed on the correct bank
/tmp/ems-flasher/ems-flasher-real --verbose --bank <N> --title
```

Replace `<N>` with your cart's Game-Boy-accessible bank number.

The `listing.count=0` patch causes `--write` to always place the ROM at
offset 0 of the target bank. No `--delete` is needed first — the cart's
firmware auto-erases the first erase block (128 KB) when writing at offset 0.

---

## Common errors

**`LIBUSB_ERROR_IO` on first attempt** — The cart's USB controller resets on
the first `open()`/`claim()` after idle. Retry immediately; the second attempt
almost always succeeds.

**Stalled `--title` read** — Can occur if a previous `ems-flasher-real`
process still holds the device. Fix: `pkill -9 ems-flasher-real`, then retry.

**`error: no valid menu ROM found`** — Patch 1 was not applied correctly.
Check with: `grep MENUTITLE /tmp/ems-flasher/cmd.c`

---

## Verify both banks after writing

To confirm the write landed where intended and did not alias to the other bank,
read both banks after each flash:

```bash
/tmp/ems-flasher/ems-flasher-real --verbose --bank 1 --title
/tmp/ems-flasher/ems-flasher-real --verbose --bank 2 --title
```

The bank you wrote should show `DMGARP` at bank 0. The other bank should be
unchanged.
