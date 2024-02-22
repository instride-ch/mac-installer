#!/bin/bash

###############################################################################
# Variables                                                                   #
###############################################################################

BIN=~/MacInstaller/bin                 # shell scripts

###############################################################################
# Menu                                                                        #
###############################################################################

# logging
function notify() { echo -e "\n\033[1m$@\033[0m"; }

clear
notify 'Welcome to Woche-Pass AG, this script will install the Apps you need
in order to be up and running as quickly as possible'
notify 'Before you start: Check if you manually signed in to the Mac App Store!'

#while :
#do
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
    #  (3) instride - PL                                                   #
    #  (4) instride - Dev                                                  #
    #  (5) Update                                                          #
    #  (0) Exit                                                            #
    #                                                                      #
    ########################################################################
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  notify "WoPa - Dispo..."                         | $BIN/wopa_dispo.sh    ;;
    "2")  notify "WoPa - Vorstufe..."                      | $BIN/wopa_vorstufe.sh ;;
    "3")  notify "instride - PL..."                        | $BIN/instride_pl.sh   ;;
    "4")  notify "instride - Dev..."                       | $BIN/instride_dev.sh  ;;
    "5")  notify "Update..."                               | $BIN/update.sh        ;;
    "0")  exit                                                                     ;;
     * )  notify "Invalid option!"                                                 ;;
    esac
#    sleep 1
#done
