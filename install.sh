#!/bin/bash

################################ USAGE #######################################

usage=$(
cat <<EOF
Usage:
$0 [OPTION]
-h, --help      show this message.
-n, --no-sudo   work without sudo, but requires modifications to bashrc

EOF
)

########################### OPTIONS PARSING #################################

#parse options
TMP=`getopt --name=$0 -a --longoptions=no-sudo,help -o n,h -- $@`

if [[ $? == 1 ]]
then
    echo
    echo "$usage"
    exit
fi

eval set -- $TMP

until [[ $1 == -- ]]; do
    case $1 in
        -n|--no-sudo)
            SUDO=false
            ;;
        -h|--help)
            echo "$usage"
            exit
            ;;
    esac
    shift # move the arg list to the next option or '--'
done
shift # remove the '--', now $1 positioned at first argument if any

#default values
SUDO=${SUDO:=true}

########################## START INSTALLATION ################################

SCRIPT_NAME=`basename "$0"`
SCRIPT_PATH=${0%`basename "$0"`}
PLUGIN_PATH="${HOME}/.local/share/rhythmbox/plugins/RhythmboxRandomAlbumPlayer/"
GLIB_SCHEME="org.gnome.rhythmbox.plugins.randomalbumplayer.gschema.xml"
SCHEMA_FOLDER=""
if [[ $SUDO == true ]]
then
    GLIB_DIR="${HOME}/.local/share/glib-2.0/schemas/"
fi
if [[ $SUDO == false ]]
then
    GLIB_DIR="${HOME}/.local/share/glib-2.0/schemas/"
fi

#build the dirs
mkdir -p $PLUGIN_PATH

#copy the files
cp -r "${SCRIPT_PATH}"* "$PLUGIN_PATH"

#install the plugin
mv "$PLUGIN_PATH"rhythmbox-random-album-player.plugin "$PLUGIN_PATH"rhythmbox-random-album-player.plugin

#remove the install script from the dir (not needed)
rm "${PLUGIN_PATH}${SCRIPT_NAME}"

#install the glib schema
if [[ $SUDO == true ]]
then
    echo "Installing the glib schema (password needed)"
    sudo cp "${PLUGIN_PATH}${SCHEMA_FOLDER}${GLIB_SCHEME}" "$GLIB_DIR"
    sudo glib-compile-schemas "$GLIB_DIR"
fi
if [[ $SUDO == false ]]
then
    echo "Installing the glib schema"
    mkdir -p $GLIB_DIR
    cp "${PLUGIN_PATH}${SCHEMA_FOLDER}${GLIB_SCHEME}" "$GLIB_DIR"
    glib-compile-schemas "$GLIB_DIR"

    echo "Add this in your .bashrc if it is not already:"
    echo "export XDG_DATA_DIRS=\$HOME/.local/share:\$XDG_DATA_DIRS"
fi
