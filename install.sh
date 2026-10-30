#!/bin/bash
set -euo pipefail

###############################################################################
# Variables                                                                   #
###############################################################################

VERSION=3.0.0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # repository root
ROLES=(wopa instride_pl instride_dev instride_ux)

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/defaults.sh"

# log everything for support cases (without color / clear-screen escape codes)
exec > >(tee >(sed -l $'s/\033\\[[0-9;]*[A-Za-z]//g' >> "$SCRIPT_DIR/install.log")) 2>&1

###############################################################################
# Menu                                                                        #
###############################################################################

clear || true
notify 'Welcome to Woche-Pass AG / instride AG! This script installs the apps you need
in order to be up and running as quickly as possible.'
notify 'Before you start: Check if you manually signed in to the Mac App Store!'

while :
do
    cat<<EOF
    ########################################################################
    # MacInstaller                                                         #
    # Version : $VERSION                                                   #
    ########################################################################
    #                                                                      #
    #  Please enter your choice:                                           #
    #                                                                      #
    #  (1) WoPa                                                            #
    #  (2) instride – PL                                                   #
    #  (3) instride – Dev                                                  #
    #  (4) instride – UX                                                   #
    #  (0) Exit                                                            #
    #                                                                      #
    ########################################################################
EOF
    read -r -n1 -s choice
    # shellcheck source=roles/instride_dev.sh
    case "$choice" in
    [1-4]) source "$SCRIPT_DIR/roles/${ROLES[choice - 1]}.sh"; break     ;;
    "0")   exit 0                                                            ;;
     * )   notify 'Invalid option!'                                          ;;
    esac
done

###############################################################################
# Installation                                                                #
###############################################################################

notify "$ROLE_NAME..."

keep_sudo_alive
ensure_clt
ensure_brew
install_brewfiles "${BREWFILES[@]}"

if [[ "$SETUP_NODE" == true ]]; then setup_node; fi

if mount_share; then
    copy_from_share "${BASE_SHARE_ITEMS[@]}" "${SHARE_ITEMS[@]}"
else
    MISSING_ITEMS+=("${BASE_SHARE_ITEMS[@]}" "${SHARE_ITEMS[@]}")
fi

defaults_base
restart_ui

print_summary
