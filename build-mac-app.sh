#!/usr/bin/env bash

set -xe

cd "$(dirname "$0")"
game_data_dir="${GAME_DATA_DIR:-$PWD/GameData}"
if [ -d "$game_data_dir" ]; then
	game_data_dir="$(cd "$game_data_dir" && pwd)"
	# Any of the tables' DAT files suffices; missing tables just stay greyed out.
	if ! ls "$game_data_dir" | grep -iqE "^(pinball|cadet|demo|dragon|pirates)\.dat$"; then
		echo "No supported game DAT file found in $game_data_dir" >&2
		exit 1
	fi
elif [ -n "${GAME_DATA_DIR:-}" ]; then
	echo "Game data directory does not exist: $game_data_dir" >&2
	exit 1
else
	echo "Warning: building without game data. See docs/setup.md for setup instructions." >&2
fi

# SDL3 + SDL3_mixer are vendored: the macos preset builds them from pinned
# sources and links them statically, so no frameworks go into the bundle.
cmake --preset macos
cmake --build --preset macos

sw_version='2.1.1'

mkdir -p SpaceCadetPinball.app/Contents/MacOS
mkdir -p SpaceCadetPinball.app/Contents/Resources

cp -a Platform/macOS/Info.plist SpaceCadetPinball.app/Contents/
sed -i '' "s/CHANGEME_SW_VERSION/$sw_version/" SpaceCadetPinball.app/Contents/Info.plist
cp -a Platform/macOS/SpaceCadetPinball.icns SpaceCadetPinball.app/Contents/Resources/
if [ -d "$game_data_dir" ]; then
	cp -a "$game_data_dir/." SpaceCadetPinball.app/Contents/Resources/
fi
cp -a bin/SpaceCadetPinball SpaceCadetPinball.app/Contents/MacOS/

# Stage a DMG root containing the .app plus a double-clickable
# uninstaller that removes the app and its Application Support data.
mkdir -p dmg_root
mv SpaceCadetPinball.app dmg_root/
cp -a Platform/macOS/uninstall.command dmg_root/

hdiutil create -fs HFS+ -srcfolder dmg_root -volname "SpaceCadetPinball $sw_version" "SpaceCadetPinball-$sw_version-mac.dmg"

rm -r dmg_root
