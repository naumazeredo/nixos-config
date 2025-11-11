#!/usr/bin/env bash

config_folder=$(pwd)/config

#cp /etc/nixos/configuration.nix configuration.nix

if [ ! -d ${config_folder} ]; then
    echo config folder not present
    exit 1
fi

ln -s -b ${config_folder}/* ~/.config
#cp -r ${config_folder}/* ~/.config
