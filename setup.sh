#!/usr/bin/env bash

config_folder=$(pwd)/config

#cp /etc/nixos/configuration.nix configuration.nix

if [[ ! -d ${config_folder} ]]; then
    echo config folder not present
    exit 1
fi

user_config_folder=$HOME/.config

for config in $(ls -d ${config_folder}/*/);
do
    user_config_name=$(basename ${config})
    user_config_path="${user_config_folder}/${user_config_name}"

    # Check if config exists
    if [[ -e ${user_config_path} ]]; then
        if [[ ! -L ${user_config_path} ]]; then
            #ln -s -b ${config} ${user_config_folder} 
            echo ${user_config_name} exists.

            config_backup=${user_config_path}~
            # If there's a backup config, confirm if we should proceed to erase it
            if [[ -e ${config_backup} ]]; then
                read -p "${user_config_name} backup exists and will be overwritten. Continue? [yn] " -n 1 -r
                echo # new line
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf ${config_backup}
                    mv ${user_config_path} ${config_backup}
                    ln -s -b ${config} ${user_config_folder}
                    echo ${user_config_name} backup updated and config created!
                else
                    echo ${user_config_name} ignored!
                fi
            else
                mv ${user_config_path} ${config_backup}
                ln -s -b ${config} ${user_config_folder}
                echo ${user_config_name} backup created and config created.
            fi
        fi
    else
        echo ${user_config_name} config created.
        ln -s -b ${config} ${user_config_folder}
    fi
done
