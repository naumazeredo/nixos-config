#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

while getopts "vc" opt; do
    case ${opt} in
        v)
            verbose=1
            ;;
        c)
            check=1
            ;;
        ?)
            exit 1
            ;;
    esac
done

#cp /etc/nixos/configuration.nix configuration.nix

setup_configs () {
    config_folder=$1
    user_config_folder=$2
    if [[ -v verbose ]]; then
        echo "VERBOSE: config_folder: ${config_folder}"
        echo "VERBOSE: user_config_folder: ${user_config_folder}"
    fi

    if [[ ! -d ${config_folder} ]]; then
        echo -e "${config_folder} ${RED}not found!${NC}"
    else
        for config in $(ls -A ${config_folder});
        do
            config_name=$(basename ${config})
            config_path="${config_folder}/${config_name}"
            user_config_path="${user_config_folder}/${config_name}"
            if [[ -v verbose ]]; then
                echo "VERBOSE: config_path: ${config_path}"
                echo "VERBOSE: user_config_path: ${user_config_path}"
            fi

            # Check if config exists
            if [[ -L ${user_config_path} ]]; then
                if [[ -v verbose ]]; then
                    echo "VERBOSE: link already exists"
                fi

                if [[ ! -e ${user_config_path} ]]; then
                    if [[ -v verbose ]]; then
                        echo "VERBOSE: link is broken"
                    fi


                    if [[ -v check ]]; then
                        echo "CHECK: ln -s -b ${config_path} ${user_config_path}"
                    else
                        ln -s -b ${config_path} ${user_config_path}
                    fi
                    echo -e "${config_name} with ${YELLOW}broken link${NC}. ${GREEN}Config overwritten.${NC}"
                else
                    echo "${config_name} already set."
                fi
            else
                if [[ -v verbose ]]; then
                    echo "VERBOSE: link does not exist"
                fi

                if [[ -e ${user_config_path} ]]; then
                    if [[ -v verbose ]]; then
                        echo "VERBOSE: file exists"
                    fi

                    echo -n -e "${config_name} ${YELLOW}exists:${NC} "

                    config_backup=${user_config_path}~
                    # If there's a backup config, confirm if we should proceed to erase it
                    if [[ -e ${config_backup} ]]; then
                        read -p "backup exists and will be overwritten. Continue? [yn] " -n 1 -r
                        echo # new line
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            if [[ -v check ]]; then
                                echo "CHECK: rm -rf ${config_backup}"
                                echo "CHECK: mv ${user_config_path} ${config_backup}"
                                echo "CHECK: ln -s -b ${config_path} ${user_config_path}"
                            else
                                rm -rf ${config_backup}
                                mv ${user_config_path} ${config_backup}
                                ln -s -b ${config_path} ${user_config_path}
                            fi
                            echo -e " 󱞩 ${GREEN}backup updated and config created!${NC}"
                        else
                            echo -e " 󱞩 ${RED}ignored!${NC}"
                        fi
                    else
                        if [[ -v check ]]; then
                            echo "CHECK: mv ${user_config_path} ${config_backup}"
                            echo "CHECK: ln -s -b ${config_path} ${user_config_path}"
                        else
                            mv ${user_config_path} ${config_backup}
                            ln -s -b ${config_path} ${user_config_path}
                        fi
                        echo "backup created and config created!"
                    fi
                else
                    if [[ -v check ]]; then
                        echo "CHECK: ln -s -b ${config_path} ${user_config_path}"
                    else
                        ln -s -b ${config_path} ${user_config_path}
                    fi
                    echo -e "${config_name} ${GREEN}config created.${NC}"
                fi
            fi
        done
    fi
}

echo -e "${BLUE}Setting up ~/.config${NC}"
setup_configs $(pwd)/config $HOME/.config

echo -e "\n${BLUE}Setting up ~/${NC}"
setup_configs $(pwd)/home $HOME
