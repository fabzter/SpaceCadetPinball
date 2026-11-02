#!/usr/bin/env bash

set -xe

mkdir -p Libs

cd Libs

sdl_version='2.30.4'
sdl_filename="SDL2-$sdl_version.dmg"
sdl_url="https://github.com/libsdl-org/SDL/releases/download/release-$sdl_version/$sdl_filename"

sdl_mixer_version='2.8.0'
sdl_mixer_filename="SDL2_mixer-$sdl_mixer_version.dmg"
sdl_mixer_url="https://github.com/libsdl-org/SDL_mixer/releases/download/release-$sdl_mixer_version/$sdl_mixer_filename"

mount_point="$(mktemp -d)"

if [ ! -f "$sdl_filename" ]; then
	curl -sSf -L -O "$sdl_url"
fi

echo "2bf2cb8f6b44d584b14e8d4ca7437080d1d968fe3962303be27217b336b82249  $sdl_filename" | shasum -a 256 -c
hdiutil attach "$sdl_filename" -mountpoint "$mount_point" -quiet
cp -a "$mount_point/SDL2.framework" .
hdiutil detach "$mount_point"

if [ ! -f "$sdl_mixer_filename" ]; then
	curl -sSf -L -O "$sdl_mixer_url"
fi

echo "aea973d78f2949b0b2404379dfe775ac367c69485c1d25a5c59f109797f18adf  $sdl_mixer_filename" | shasum -a 256 -c
hdiutil attach "$sdl_mixer_filename" -mountpoint "$mount_point" -quiet
cp -a "$mount_point/SDL2_mixer.framework" .
hdiutil detach "$mount_point"

cd ..

cmake .
cmake --build .

sw_version='2.1.1'

mkdir -p SpaceCadetPinball.app/Contents/MacOS
mkdir -p SpaceCadetPinball.app/Contents/Resources
mkdir -p SpaceCadetPinball.app/Contents/Frameworks

cp -a Platform/macOS/Info.plist SpaceCadetPinball.app/Contents/
cp -a Platform/macOS/SpaceCadetPinball.icns SpaceCadetPinball.app/Contents/Resources/
cp -a Libs/SDL2.framework SpaceCadetPinball.app/Contents/Frameworks/
cp -a Libs/SDL2_mixer.framework SpaceCadetPinball.app/Contents/Frameworks/
cp -a bin/SpaceCadetPinball SpaceCadetPinball.app/Contents/MacOS/

# Stage a DMG root containing the .app plus a double-clickable
# uninstaller that removes the app and its Application Support data.
mkdir -p dmg_root
mv SpaceCadetPinball.app dmg_root/
cp -a Platform/macOS/uninstall.command dmg_root/

hdiutil create -fs HFS+ -srcfolder dmg_root -volname "SpaceCadetPinball $sw_version" "SpaceCadetPinball-$sw_version-mac.dmg"

rm -r dmg_root

