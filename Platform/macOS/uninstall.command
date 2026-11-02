#!/bin/sh
# SpaceCadetPinball uninstaller for macOS.
# Shipped inside the DMG next to SpaceCadetPinball.app; copy it wherever
# convenient (it locates the app relative to its own folder first).
# Double-clickable: opens Terminal.
#
#   double-click            → interactive prompt
#   uninstall.command --all        → remove app + game data, no prompt
#   uninstall.command --keep-data  → remove app only, keep data folder

APP_NAME="SpaceCadetPinball.app"
DATA="$HOME/Library/Application Support/SpaceCadetPinball"
HERE="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

MODE="ask"
[ "$1" = "--all" ] && MODE="all"
[ "$1" = "--keep-data" ] && MODE="keep"

echo "SpaceCadetPinball uninstaller"

# Locate the app: same folder as this script, then usual install spots.
# Never treat a mounted DMG (/Volumes) as the install — it's read-only.
APP=""
for dir in "$HERE" "$HOME/Applications" /Applications; do
  case "$dir" in /Volumes/*) continue ;; esac
  if [ -d "$dir/$APP_NAME" ]; then APP="$dir/$APP_NAME"; break; fi
done

echo "App : ${APP:-<not found>}"
echo "Data: $DATA"
echo

if [ "$MODE" = "ask" ]; then
  printf "Also delete game data folder (DATs, SOUND, settings, high scores)? [y/N] "
  read -r ans
  case "$ans" in [Yy]*) MODE="all" ;; *) MODE="keep" ;; esac
fi

if [ -n "$APP" ]; then
  rm -rf "$APP" && echo "✓ app removed: $APP"
else
  echo "– app not found in ~/Applications or /Applications; remove it manually if placed elsewhere"
fi

if [ "$MODE" = "all" ]; then
  if [ -d "$DATA" ]; then
    rm -rf "$DATA" && echo "✓ data folder removed"
  else
    echo "– data folder not found"
  fi
else
  echo "· kept data folder (settings + scores preserved)"
fi

echo "Done."
if [ "$MODE" = "ask" ]; then
  printf "\nPress any key to close…"
  read -r _
fi
