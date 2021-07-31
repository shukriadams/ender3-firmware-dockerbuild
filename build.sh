#!/bin/bash

#############################################################################################
# This script builds Marlin firmware from git. 
# How to use
#
# chmod +x ./build.sh
# ./build.sh
#
# Note: there is no need to run this script with sudo
#############################################################################################

# exit on any error, this should always be enabled first in any build script
set -e

#############################################################################################
# This block contains variables you can set

# printer to target. Path must exist in marlin config repo under /config/examples
PRINTER_PROFILE="Creality/Ender-3/CrealityV427"

# platformio target platform. The default platform is "mega2560" and seems to require overriding
TARGET_PLATFORM="STM32F103RET6_creality"

# If you want to force a build branch or tag, do so here, else this script will always build 
# the latest tag.
BUILD_TAG=""

# source for marlin configs. Change these if you want to build code from another git repo.
MARLIN_MAIN_REPO=https://github.com/MarlinFirmware/Marlin
MARLIN_CONFIG_REPO=https://github.com/MarlinFirmware/Configurations
#############################################################################################




CWD=$(pwd)

# folders to clone marlin into
MARLIN_MAIN_DIR=$(readlink -f ./Marlin)
MARLIN_CONFIG_DIR=$(readlink -f ./MarlinConfig)

# clone or update marlin 
if [ ! -d $MARLIN_MAIN_DIR ]; then
    git clone $MARLIN_MAIN_REPO $MARLIN_MAIN_DIR 
else
    cd $MARLIN_MAIN_DIR

    # do a hard cleanup/reset so we can update and checkout tags without getting blocked
    git reset --hard
    git clean -fx

    git fetch
    cd $CWD
fi

# clone or update marlin config
if [ ! -d $MARLIN_CONFIG_DIR ]; then
    git clone $MARLIN_CONFIG_REPO $MARLIN_CONFIG_DIR 
else
    cd $MARLIN_CONFIG_DIR

    # do a hard cleanup/reset so we can update and checkout tags without getting blocked
    git reset --hard
    git clean -fx

    git fetch
    cd $CWD
fi


# if building tags, get latest tag in repo and check it out. If not building tags, build will 
# target latest master.
if [ -z "$BUILD_TAG" ] ; then
    cd $MARLIN_MAIN_DIR
    # gets latest tag across all branches. Marlin's tagging/branching creates a branch for reach release
    # then a tag in that branch.
    LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`) 
    echo "Latest tag/branch found is ${LATEST_TAG}"
    cd $CWD
fi


cd $MARLIN_MAIN_DIR
git checkout $LATEST_TAG
echo "Marlin main : Checked out ${LATEST_TAG}"
cd $MARLIN_CONFIG_DIR
git checkout $LATEST_TAG
echo "Marlin config : Checked out ${LATEST_TAG}"
cd $CWD

# ensure that printer profile exists
PRINTER_PROFILE_SOURCE="${MARLIN_CONFIG_DIR}/config/examples/${PRINTER_PROFILE}"
PRINTER_PROFILE_TARGET="${MARLIN_MAIN_DIR}/Marlin"
if [ ! -d "$PRINTER_PROFILE_SOURCE" ]; then
    echo "ERROR : Printer profile ${PRINTER_PROFILE_SOURCE} not found, please ensure profile exists under marlin configuration /config/examples" 
    exit 1
fi



# overwrite marlin stock config with requested profiles
cp $PRINTER_PROFILE_SOURCE/. -R $PRINTER_PROFILE_TARGET


# overwrite platformio vars with required variables to build
# building for mega2560 doesn't work, need to force STM32F103RET6_creality
DEFAULT_ENVS="default_envs = mega2560"
REQUIRED_ENVS="default_envs = ${TARGET_PLATFORM}"
sed -i "s/$DEFAULT_ENVS/$REQUIRED_ENVS/" $MARLIN_MAIN_DIR/platformio.ini

cd $MARLIN_MAIN_DIR
# running platformio run does all the building for us - easy!
pio run
