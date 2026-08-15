# Omarchy laptop battery policy

This module configures an early battery warning and automatic hibernation on an Omarchy laptop.

## Behavior

| Battery level | Behavior |
|---|---|
| 20% | UPower marks the battery as low. |
| 15% | UPower marks it critical and the Omarchy shell shows one critical “Time to recharge!” notification. |
| 7% | UPower requests hibernation. |

The warning only fires while the battery is discharging. It resets after charging or returning above 15%, so it can warn again during a later discharge cycle. The shell checks the battery every 30 seconds, so the notification may appear shortly after crossing 15%.

The percentages must remain strictly descending (`Low > Critical > Action`) or UPower will fall back to its default thresholds.

## Components

- `upower/90-critical-battery.conf` — system policy installed into `/etc/UPower/UPower.conf.d/`.
- `omarchy/fayi.battery/` — user-owned clone of Quattro's `omarchy.battery` shell service, with its warning threshold changed from 10% to 15%.
- `setup.sh` — idempotently installs the UPower policy, links the custom plugin, enables it, and restarts UPower.
- `../setup-laptop.sh` — laptop setup entry point; calls this module and can host additional laptop-specific setup later.

The live plugin path is a symlink:

```text
~/.config/omarchy/plugins/fayi.battery
  -> $DOTFILES/battery/omarchy/fayi.battery
```

The stock plugin under `/usr/share/omarchy/` is never modified.

## Install or restore

Hibernation must work before installing the 7% policy. Otherwise UPower can fall back to powering off.

```bash
omarchy hibernation setup  # only needed when hibernation is unavailable
"$DOTFILES/setup-laptop.sh"
```

`battery/setup.sh` refuses to install the policy unless `omarchy hibernation available` succeeds.

## Verify

```bash
cat /etc/UPower/UPower.conf.d/90-critical-battery.conf
upower --dump | grep critical-action
omarchy hibernation available
omarchy plugin list | grep -E '(^fayi\.battery|^omarchy\.battery)'
grep batteryThreshold ~/.config/omarchy/plugins/fayi.battery/Service.qml
```

Expected plugin state:

```text
omarchy.battery  disabled
fayi.battery     enabled
```

After an actual low-battery event, verify that UPower requested hibernation rather than power-off:

```bash
journalctl --since '2 days ago' | grep -E '(hibernate|poweroff) requested.*upowerd'
```

## Checking for upstream Omarchy battery fixes

The custom plugin survives Omarchy upgrades, but it also stops automatically receiving changes made to the stock `omarchy.battery` plugin. After a major Omarchy update, compare the current stock implementation with this clone:

```bash
stock=/usr/share/omarchy/shell/plugins/services/battery
custom="$DOTFILES/battery/omarchy/fayi.battery"

diff -u "$stock/BatteryModel.js" "$custom/BatteryModel.js" || true
diff -u "$stock/Service.qml" "$custom/Service.qml" || true
diff -u "$stock/manifest.json" "$custom/manifest.json" || true
```

Expected differences are:

- `Service.qml`: `batteryThreshold` is 15 here instead of the stock value.
- `manifest.json`: this clone uses the ID `fayi.battery` and declares `clonedFrom: omarchy.battery`.

Any other difference may be an upstream fix or API change worth pulling in. Review it rather than replacing the custom directory wholesale:

1. Copy or merge upstream changes to `BatteryModel.js`.
2. Merge upstream `Service.qml` changes while preserving `batteryThreshold: 15`.
3. Preserve the clone-specific `manifest.json` ID and `clonedFrom` metadata.
4. Reapply and verify:

   ```bash
   "$DOTFILES/battery/setup.sh"
   omarchy plugin list | grep -E '(^fayi\.battery|^omarchy\.battery)'
   ```

Never edit `/usr/share/omarchy/`; package updates replace files there.

## Upgrade and recovery notes

Normal Pacman, Omarchy, and kernel upgrades should not overwrite the UPower drop-in or the user plugin because neither is package-owned. A kernel or driver update can still affect whether hibernation itself works, so rerun the verification commands after major upgrades.

`omarchy refresh shell`, a factory reset, or a reinstall may reset the enabled-plugin selection or remove live configuration. The tracked files remain in the dotfiles repository; rerun `setup-laptop.sh` to restore them.
