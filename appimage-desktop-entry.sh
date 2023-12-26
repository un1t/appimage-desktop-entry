#!/bin/bash

APPIMAGE_PATH=$1

if [ -z "$APPIMAGE_PATH" ]; then
    echo "Missing argument: appimage"
    exit 1
fi

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "File not found:" $APPIMAGE_PATH
    exit 1
fi


APPIMAGE_FULLPATH=$(readlink -e "$APPIMAGE_PATH")
APPIMAGE_FILENAME=$(basename "$APPIMAGE_PATH")
APP_NAME="${APPIMAGE_FILENAME%.*}"

rm -rf /tmp/squashfs-root/
cd /tmp/
"$APPIMAGE_FULLPATH" --appimage-extract
cd /tmp/squashfs-root/

echo "Choose icon: "
FILENAMES=($(ls -d *.png))
i=1
for filename in ${FILENAMES[*]}
do
    printf " %d) %s\n" $i  $filename
    i=$(expr $i + 1)
done

read SELECTED_INDEX

ICON_SRC=${FILENAMES[$(expr $SELECTED_INDEX - 1)]}
ICON_EXT="${ICON_SRC##*.}"
ICON_DST="${HOME}/.local/share/icons/$APP_NAME.$ICON_EXT"
cp "$ICON_SRC" "$ICON_DST"

DESKTOP_ENTRY_PATH="${HOME}/.local/share/applications/$APP_NAME.desktop"


cat <<EOT >> "$DESKTOP_ENTRY_PATH"
[Desktop Entry]
Name=$APP_NAME
Exec=$APPIMAGE_FULLPATH
Icon=$ICON_DST
Type=Application
Terminal=false
EOT

