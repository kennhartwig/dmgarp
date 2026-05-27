#!/usr/bin/env bash
# Build the patched ems-flasher CLI for writing ROMs to the EMS USB 64M Smart Card.
# Clones the upstream source to /tmp/ems-flasher and applies three patches required
# for auto-boot flashing (see docs/FLASHING.md for details).
#
# The resulting binary is /tmp/ems-flasher/ems-flasher-real.
# /tmp is cleared on reboot — re-run this script each new session before flashing.
#
# System requirements: git, gcc, make, libusb-1.0-0-dev, build-essential

set -euo pipefail

DEST="/tmp/ems-flasher"

if [[ -x "$DEST/ems-flasher-real" ]]; then
    echo "ems-flasher already built at $DEST/ems-flasher-real"
    exit 0
fi

cd /tmp
git clone https://github.com/mikeryan/ems-flasher.git
cd ems-flasher

# Patch 1: match the Windows-EMS cart menu title ("GB16M" instead of upstream "MENU#")
sed -i 's/#define MENUTITLE "MENU#"/#define MENUTITLE "GB16M"/' cmd.c

# Patch 2: force listing.count=0 so the tool treats the page as empty and places
# the ROM at offset 0, which makes the Game Boy auto-boot directly into it
sed -i 's|/\* Abort if there is no valid menu|listing.count = 0; /* bypass: write ROM at offset 0 (auto-boot) */\n\n    /* Abort if there is no valid menu|' cmd.c

# Patch 3: disable the auto-insertion of menu.gb on empty pages so DMGARP
# lands at offset 0 instead of offset 2
sed -i 's/if (listing.count == 0 && romfiles\[0\].header.romsize < PAGESIZE)/if (0 \&\& romfiles[0].header.romsize < PAGESIZE)/' cmd.c

echo "Verifying patches..."
grep -n "MENUTITLE\|listing.count = 0\|if (0 &&" cmd.c

sh config.sh && make
echo ""
echo "Built: $DEST/ems-flasher-real"
