# Iris Rev. 7 Vial: Add, Build, and Flash a Fifth Layer

This records the complete Windows workflow used to add a fifth dynamic Vial
layer to a Keebio Iris Rev. 7, build the firmware, clear the incompatible old
EEPROM layout, flash both halves, and restore the current Vial configuration.

## Result

- Keyboard: Keebio Iris Rev. 7
- MCU: ATmega32U4
- Bootloader: Atmel DFU
- Firmware tree: `C:\Users\boser\vial-qmk`
- QMK MSYS path: `/c/Users/boser/vial-qmk`
- Dynamic Vial layers: five, numbered 0 through 4
- Layer 4 default: entirely transparent
- Built firmware: `keebio_iris_rev7_vial.hex`
- Reproducibility patch: `iris-rev7-vial-five-layer.patch`
- Firmware SHA-256:
  `f88acc05b57579771a4d0da0f9c60f3c18024895a50aeb77a23c7361c5648899`

The successful build used 27,948 of 28,672 available firmware bytes, leaving
724 bytes free. QMK therefore reported a size warning, but not an overflow.

## 1. Install the Windows tools

Install:

1. [QMK MSYS](https://github.com/qmk/qmk_distro_msys/releases/latest)
2. [QMK Toolbox](https://github.com/qmk/qmk_toolbox/releases/latest)
3. [Vial](https://get.vial.today/download/)

Use the dedicated **QMK MSYS** terminal for QMK build commands. QMK Toolbox is
used for the graphical erase and flash procedure.

## 2. Back up the live keyboard state

Before changing the firmware, connect the working keyboard and use Vial's
**File > Save current layout** command. The live layout used here was saved as:

```text
C:\Users\boser\Documents\colemak.vil
```

Also preserve any existing firmware artifact before rebuilding it. From
PowerShell:

```powershell
Copy-Item `
  'C:\Users\boser\vial-qmk\keebio_iris_rev7_vial.hex' `
  'C:\Users\boser\vial-qmk\keebio_iris_rev7_vial.pre-five-layer-2023.hex'
```

This recovery copy is not needed during the normal upgrade, but it provides a
known previous image if rollback is ever required.

## 3. Change the firmware source

### Advertise five dynamic layers

Add this to `keyboards/keebio/iris/keymaps/vial/config.h` in the Vial-QMK
checkout:

```c
#define DYNAMIC_KEYMAP_LAYER_COUNT 5
```

This is the setting Vial uses to determine how many editable layers the
firmware exposes.

### Add the fifth compiled default layer

In `keyboards/keebio/iris/keymaps/vial/keymap.c`:

1. Ensure the preceding layer entry ends with a comma.
2. Add a `[4] = LAYOUT(...)` entry.
3. Supply exactly 56 `KC_TRNS` entries, one for every physical position in the
   Iris `LAYOUT` macro.

The complete `[4]` entry is present in the linked source file. Making it fully
transparent gives Vial a safe, inert fifth layer to configure later.

The following changes were already present in this checkout and were preserved,
but are not required merely to increase the layer count:

- `VIAL_INSECURE = yes` in the Vial keymap's `rules.mk`;
- the generated/customized definitions for layers 0 through 3;
- the Rev. 7 tapping-term settings.

The exact working-tree changes used for the successful build are stored beside
this guide as `iris-rev7-vial-five-layer.patch`. They are based on Vial-QMK
commit `bdeb7ae0a4`. To reproduce the source state in a clean checkout at that
commit, use:

```sh
git apply --check \
  /c/Users/boser/dotfiles/hardware/keyboards/iris-rev7/iris-rev7-vial-five-layer.patch
git apply \
  /c/Users/boser/dotfiles/hardware/keyboards/iris-rev7/iris-rev7-vial-five-layer.patch
```

Validate the source before building:

```sh
git diff --check
git diff -- keyboards/keebio/iris/keymaps/vial/config.h \
  keyboards/keebio/iris/keymaps/vial/keymap.c
```

## 4. Prepare a five-layer Vial layout backup

The original `colemak.vil` contains exactly four layers, so it should not be
loaded directly after the firmware begins advertising five. A compatible copy
was created at:

```text
C:\Users\boser\dotfiles\hardware\keyboards\iris-rev7\colemak-five-layers.vil
```

A `.vil` file is JSON. The compatible copy was made by:

- preserving the keyboard UID, layers 0 through 3, macros, layout options, and
  other settings unchanged;
- appending a fifth matrix layout containing `KC_TRNS` at every real key
  position and `-1` at the nonexistent matrix positions;
- appending a fifth empty entry to `encoder_layout`.

The result was parsed and checked to contain five `layout` entries and five
`encoder_layout` entries. Its first four layers, macros, and UID were also
compared with `colemak.vil` and confirmed unchanged.

This migration matters because clearing EEPROM restores the compiled defaults,
which may be older than the layout currently stored on the keyboard.

## 5. Configure and verify QMK MSYS

Open **QMK MSYS** and run:

```sh
qmk --version
make --version
avr-gcc --version

cd /c/Users/boser/vial-qmk
pwd
git status --short
qmk config user.qmk_home=/c/Users/boser/vial-qmk
git submodule update --init --recursive
qmk doctor
```

Confirm that `pwd` shows the outer checkout above. Do not build from the
untracked nested `vial-qmk/vial-qmk` directory, and do not run a plain
`qmk setup`, which may select a different QMK tree.

In this run, `qmk doctor` confirmed that all dependencies and submodules were
present. It warned about uncommitted changes, the remote layout, and AVR-GCC 15
being newer than the version recommended by this older Vial-QMK checkout. The
subsequent complete build succeeded with that toolchain.

## 6. Compile the firmware

From the checkout root in QMK MSYS:

```sh
qmk compile -kb keebio/iris/rev7 -km vial
```

If an installed QMK CLI is incompatible with an older checkout, use the direct
Make target instead:

```sh
make keebio/iris/rev7:vial
```

The successful build ended with:

```text
The firmware size is approaching the maximum - 27948/28672
(97%, 724 bytes free)
```

It produced:

```text
C:\Users\boser\vial-qmk\keebio_iris_rev7_vial.hex
```

Optionally verify the exact artifact from PowerShell:

```powershell
certutil -hashfile `
  C:\Users\boser\vial-qmk\keebio_iris_rev7_vial.hex SHA256
```

Do not flash if compilation fails or QMK reports that the firmware exceeds the
28,672-byte limit.

## 7. Understand why EEPROM must be cleared

Vial stores the editable keymap in EEPROM. Increasing
`DYNAMIC_KEYMAP_LAYER_COUNT` changes the addresses and amount of EEPROM used by
the dynamic keymap. Leaving the valid four-layer data in place can cause the
five-layer firmware to interpret old keymap, encoder, or macro bytes at the
wrong offsets.

The Iris Rev. 7 defines `SPLIT_HAND_PIN D5` in its hardware configuration. That
physical handedness signal takes precedence over the Vial keymap's redundant
`EE_HANDS` definition. Consequently, clearing EEPROM does not make the halves
forget which side they are, and the same `.hex` file can safely be used on both.

## 8. Prepare QMK Toolbox

1. Close Vial so it is not polling the keyboard during flashing.
2. Open QMK Toolbox.
3. Ensure **Auto-Flash is unchecked**. EEPROM must be cleared before the manual
   flash begins.
4. Load:

   ```text
   C:\Users\boser\vial-qmk\keebio_iris_rev7_vial.hex
   ```

5. If necessary, install the Toolbox drivers. A correctly detected Rev. 7 in
   bootloader mode was reported as:

   ```text
   Atmel DFU device connected (WinUSB):
   Atmel Corp. ATm32U4DFU (03EB:2FF4:0000)
   ```

## 9. Clear and flash the left half

Flash only one half at a time:

1. Unplug USB power from the keyboard.
2. Disconnect the USB-C interconnect cable between the halves.
3. Connect the left half directly to the computer with the host USB cable.
4. Press and release the physical reset button on the left PCB.
5. Wait for the Atmel DFU/WinUSB connection message in Toolbox.
6. Click **Clear EEPROM** once and wait for all commands to complete.

The successful clear ended with:

```text
0x80 bytes written into 0x400 bytes memory (12.50%).
Please reflash device with firmware now
EEPROM clear complete
```

The flash application is erased during this operation, so do not unplug the
half at this point.

7. Click **Flash** once.
8. Wait for programming, reading, validation, reset, and `Flash complete`.

The successful flash included:

```text
Programming 0x6D80 bytes... Success
Reading 0x7000 bytes... Success
Validating... Success
0x6D80 bytes written into 0x7000 bytes memory (97.77%).
Flash complete
```

The half then disconnected from Atmel DFU and reconnected as the normal
`CB10:7256:0700` Iris USB device.

## 10. Clear and flash the right half

1. Unplug the successfully flashed left half.
2. Keep the interconnect cable disconnected.
3. Connect the right half directly to the computer.
4. Confirm Auto-Flash is still off and the same `.hex` is loaded.
5. Press and release the right half's physical reset button.
6. Wait for the Atmel DFU connection message.
7. Click **Clear EEPROM** and wait for `EEPROM clear complete`.
8. Without unplugging, click **Flash**.
9. Wait for successful programming, validation, reset, and USB reconnection.

Both halves received the exact same firmware image and produced the same
successful size and validation messages.

## 11. Reconnect and restore the current layout

1. Unplug USB from the right half.
2. With both halves unpowered, reconnect their USB-C interconnect cable.
3. Attach the host USB cable to the normal host half, typically the left.
4. Close and reopen Vial.
5. Confirm Vial identifies the Iris Rev. 7 and displays layers 0 through 4.

Immediately after the EEPROM clear, Vial displayed the older layout compiled
into `keymap.c`. This was expected. Restore the current assignments with
**File > Load saved layout**, selecting:

```text
C:\Users\boser\dotfiles\hardware\keyboards\iris-rev7\colemak-five-layers.vil
```

The migrated file successfully restored the recent four-layer layout and its
macros while retaining the new transparent fifth layer.

Finally:

- assign a key such as `MO(4)`, `TG(4)`, `TO(4)`, or `OSL(4)` if a way to reach
  layer 4 is not already present;
- configure layer 4 in Vial;
- test keys on both halves, macros, encoders, and lighting;
- save a fresh five-layer `.vil` backup under a new name.

## Troubleshooting

- **Vial still shows four layers:** confirm the newly built `.hex` was selected
  and that both flash operations completed successfully, then restart Vial.
- **The old compiled layout appears:** load the migrated five-layer `.vil` file;
  this is expected after clearing EEPROM.
- **No Atmel DFU connection appears:** use the physical reset button and verify
  that Toolbox has installed the WinUSB driver.
- **Toolbox reports `NO DRIVER`:** install drivers from Toolbox, disconnect the
  half, reconnect it, and enter bootloader mode again.
- **One half behaves incorrectly:** power down, separate the halves, and repeat
  the clear-and-flash procedure on that half with the same firmware.
- **Firmware is too large:** do not flash it. Disable an unused Vial/QMK feature
  or reduce another dynamic allocation, then rebuild and recheck the size.

## References

- [QMK flashing and Atmel DFU](https://docs.qmk.fm/flashing)
- [QMK keymap EEPROM behavior](https://docs.qmk.fm/faq_keymap)
- [Keebio flashing split keyboards](https://docs.keeb.io/flashing-firmware/)
- [Keebio clearing EEPROM](https://docs.keeb.io/reset-eeprom)
- [Vial firmware size and dynamic layer settings](https://get.vial.today/docs/firmware-size.html)
