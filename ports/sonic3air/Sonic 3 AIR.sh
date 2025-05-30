#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
get_controls

source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Variables
GAMEDIR="/$directory/ports/sonic3air"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Create config dir
mkdir -p "config"
bind_directories "$XDG_DATA_HOME/Sonic3AIR" "$GAMEDIR/config"

# Game only supports 4:3, 16:9 and 16:10 aspect ratios
if [ $ASPECT_X == 16 ]; then
  ASPECT=400
else
  ASPECT=320
fi
WINDOW_SIZE="$DISPLAY_WIDTH x $DISPLAY_HEIGHT"

# Modifies screen variables in files
sed -i 's/"WindowSize": "[^"]*"/"WindowSize": "'"$WINDOW_SIZE"'"/' "$GAMEDIR/config.json"
sed -i "s/\"Screen Width\" : [0-9]\+/\"Screen Width\" : $ASPECT/" "$GAMEDIR/config/settings.json"

# Run the game
$GPTOKEYB "sonic3air_linux" -c "sonic.gptk" &
./sonic3air_linux

# Cleanup
unset HOME
pm_finish
printf "\033c" > /dev/tty1
