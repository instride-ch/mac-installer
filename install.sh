#!/usr/bin/env bash

###############################################################################
# Variables                                                                   #
###############################################################################

# ToDo: Really needed?
#BIN=~/MacInstaller/bin                # shell scripts
#CONFIG=~/MacInstaller/config          # configuration files directory
#SETUP=~/MacInstaller                  # root folder of MacInstaller
BIN=/bin                               # shell scripts
CONFIG=/bin/config                     # configuration files directory

###############################################################################
# Menu                                                                        #
###############################################################################

# logging
function notify() { echo -e "\n\033[1m$@\033[0m"; }


# ToDo: Consider generalizing scripts (or make git repo private?)
notify 'Welcome to Woche-Pass AG, this script will install the Apps you need'
notify 'in order to be up and running as quickly as possible'

while :
do
    clear
    cat<<EOF
    ########################################################################
    # MacInstaller                                                         #
    # Version : 1.0.0                                                      #
    ########################################################################
    #                                                                      #
    #  Please enter your choice:                                           #
    #                                                                      #
    #  (1) WoPa                                                            #
    #  (2) w-vision                                                        #
    #  (3) Update                                                          #
    #  (0) Exit                                                            #
    #                                                                      #
    ########################################################################
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  echo "WoPa..."                                 | $BIN/wopa.sh          ;;
    "2")  echo "w-vision..."                             | $BIN/w-vision.sh      ;;
    "3")  echo "Update..."                               | $BIN/update.sh        ;;
    "0")  exit                                                                   ;;
     * )  echo "Invalid option!"                                                 ;;
    esac
    sleep 1
done
