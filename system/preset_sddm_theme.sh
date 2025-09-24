#!/usr/bin/env bash
# set -x

USER="$1"

THEME_DIR="/usr/share/sddm/themes/SquareDDM/"
THEME_CONFIG_FILE="$THEME_DIR/theme.conf"
WALL_CACHE="/home/$USER/.cache/.current_wallpaper"

strip_ansi() {
	echo "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g"
}

get_accent_color_fallback() {
	local COLORS_FILE="$1"

	if [[ -z "$COLORS_FILE" ]]; then
		echo "Error: COLORS_FILE argument is missing." >&2
		return 1
	fi
	if [[ ! -f "$COLORS_FILE" ]]; then
		echo "Error: Colors file '$COLORS_FILE' not found." >&2
		return 1
	fi

	local COLOR
	COLOR=$(grep "color14" "$COLORS_FILE" | head -n 1 | awk '{print $2}' | tr -d '\n')

	COLOR=$(tr "[*.#:]" " " <<<"$COLOR" | xargs)
	COLOR=$(echo "$COLOR" | sed 's/[^0-9a-fA-F]//g')

	if [[ -z "$COLOR" ]]; then
		echo "Error: Could not extract color5 from '$COLORS_FILE'." >&2
		return 1
	fi

	if [[ ${#COLOR} != 6 && ${#COLOR} != 8 ]]; then
		echo "Error: Invalid color format '$COLOR' should be length 6 or 8 hexadecimal chars without leading #" >&2
		return 1
	fi

	echo "#$COLOR"
	return 0
}

get_random_image_from_dir() {
	local WALLS_DIR="/home/$USER/.config/hypr-wallpapers"

	if [[ ! -d "$WALLS_DIR" ]]; then
		echo "Error: '$WALLS_DIR' is not a valid directory." >&2
		return 1
	fi

	local PICS=()
	while IFS= read -r -d $'\0' file; do
		PICS+=("$file")
	done < <(find -L "$WALLS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)

	if [[ ${#PICS[@]} -eq 0 ]]; then
		echo "No image files found in '$WALLS_DIR'." >&2
		return 1
	fi

	local RAND=$((RANDOM % ${#PICS[@]}))
	local SELECTED="${PICS[$RAND]}"

	echo "$SELECTED"
	return 0
}

IMAGE=$(get_random_image_from_dir)

if [[ -z "$IMAGE" ]]; then
	echo "Error: No image selected." >&2
	exit 1
fi

if [[ ! -f "$IMAGE" ]]; then
	echo "Error: Image file '$IMAGE' not found." >&2
	exit 1
fi

cp "$IMAGE" "${THEME_DIR}background.png"
ln -sf "$IMAGE" "$WALL_CACHE"
echo "$IMAGE" >"/tmp/initwall"

if [[ $? -ne 0 ]]; then
	echo "Error: Failed to setup the image." >&2
	exit 1
fi

FALLBACK_COLORS_FILE="/home/$USER/.cache/wallust/targets/Xresources"
WALLUST_BIN="/home/$USER/.config/cargo/bin/wallust"
WALLUST_OUTPUT=$(runuser -u "$USER" -- "$WALLUST_BIN" run "$IMAGE" -sT 2>&1)

CACHE_LINE=$(echo "$WALLUST_OUTPUT" | grep "Using cache" | head -n 1)

UP_TO_DATE_CACHE_PATH_UNCLEANED=$(echo "$CACHE_LINE" | awk '{print $5}' | tr -d '\n')
UP_TO_DATE_CACHE_PATH=$(strip_ansi "$UP_TO_DATE_CACHE_PATH_UNCLEANED")

if [[ -n "$UP_TO_DATE_CACHE_PATH" && -f "$UP_TO_DATE_CACHE_PATH" ]]; then
	ACCENT_COLOR=$(get_accent_color_fallback "$UP_TO_DATE_CACHE_PATH")
else
	ACCENT_COLOR=$(get_accent_color_fallback "$FALLBACK_COLORS_FILE")
fi

if [[ ! -f "$THEME_CONFIG_FILE" ]]; then
	echo "Error: Theme config file '$THEME_CONFIG_FILE' not found." >&2
	exit 1
fi

sed -i "s/^AccentColor=.*/AccentColor=$ACCENT_COLOR/" "$THEME_CONFIG_FILE"
