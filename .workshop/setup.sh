#!/bin/bash

set -euo pipefail

die() {
  echo "error: $*" >&2
  exit 1
}

WORKSHOP_NAME="${WORKSHOP_NAME:-dev}"

# Launch the workshop if it is not already launched; otherwise refresh it so
# any definition changes (e.g. newly added mounts in dev.yaml) are applied.
#
# A non-zero exit from `workshop info` means the workshop does not exist yet, so
# it must be launched. Run it separately from the `awk` filter (rather than in a
# pipeline, whose status `pipefail` would take from `awk`) and guard it with
# `|| true` so `set -e` doesn't abort here.
info="$(workshop info "$WORKSHOP_NAME" 2>/dev/null || true)"
status="$(awk '/^status:/ {print $2; exit}' <<<"$info")"
if [[ -z "$status" || "$status" == "off" ]]; then
  echo "Launching workshop '$WORKSHOP_NAME'..." >&2
  workshop launch "$WORKSHOP_NAME"
else
  echo "Workshop '$WORKSHOP_NAME' already launched (status: $status); refreshing to apply definition..." >&2
  workshop refresh "$WORKSHOP_NAME"
fi

# Bind the mount-interface plugs declared in dev.yaml onto real host paths.
#
# `workshop refresh` only binds each mount target to an auto-allocated host
# directory; pointing a plug at a specific host path requires `workshop
# remount`. Because these sources are populated, the swap can't happen live, so
# we stop the workshop, remount, then start it again. A remount is durable
# (survives future refreshes), so we only do the stop/remount/start dance when a
# plug isn't already pointing at the desired source.
#
# Format: "<SDK>:<PLUG>=<HOST_SOURCE>"
mounts=(
  "copilot:copilot-config=${HOME}/.copilot"
  "opencode:opencode-config=${HOME}/.config/opencode"
  "openspec:openspec-dashboard=${HOME}/canonical/openspec/web-dashboard"
)

info="$(workshop info "$WORKSHOP_NAME" 2>/dev/null || true)"
pending=()
for m in "${mounts[@]}"; do
  src="${m#*=}"
  # `workshop info` prints the current host-source for each bound plug; if the
  # absolute source path already appears, the plug is mounted correctly.
  if ! grep -qF -- "$src" <<<"$info"; then
    pending+=("$m")
  fi
done

if [[ ${#pending[@]} -gt 0 ]]; then
  echo "Binding host mounts (${#pending[@]} to remount)..." >&2
  workshop stop "$WORKSHOP_NAME"
  for m in "${pending[@]}"; do
    plug="${m%%=*}"
    src="${m#*=}"
    if [[ ! -e "$src" ]]; then
      die "mount source does not exist on host: $src (for $plug)"
    fi
    echo "  remount $WORKSHOP_NAME/$plug -> $src" >&2
    workshop remount "$WORKSHOP_NAME/$plug" "$src"
  done
  workshop start "$WORKSHOP_NAME"
fi
