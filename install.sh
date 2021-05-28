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
    # Version : 2.0.0                                                      #
    ########################################################################
    #                                                                      #
    #  Please enter your choice:                                           #
    #                                                                      #
    #  (1) WoPa - Dispo                                                    #
    #  (2) WoPa - Vorstufe                                                 #
    #  (3) w-vision - PL                                                   #
    #  (4) w-vision - Dev                                                  #
    #  (5) Update                                                          #
    #  (0) Exit                                                            #
    #                                                                      #
    ########################################################################
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  echo "WoPa - Dispo..."                         | $BIN/wopa_dispo.sh    ;;
    "2")  echo "WoPa - Vorstufe..."                      | $BIN/wopa_vorstufe.sh ;;
    "3")  echo "w-vision - PL..."                        | $BIN/w-vision_pl.sh   ;;
    "4")  echo "w-vision - Dev..."                       | $BIN/w-vision_dev.sh  ;;
    "5")  echo "Update..."                               | $BIN/update.sh        ;;
    "0")  exit                                                                   ;;
     * )  echo "Invalid option!"                                                 ;;
    esac
    sleep 1
done
