#!/bin/bash

#############################################################################################
# This script builds Marlin firmware from git. How to use
# chmod +x ./build.sh
# ./build.sh

# Exit on any error
set -e



#############################################################################################
# you can override behaviour of build script with the variables in this block. Beyond this,
# variables are not intended for tweaking unless you know what you're doing.

# printer to target. Path must exist in marlin config repo under /config/examples
PRINTER_PROFILE="Creality/Ender-3/CrealityV427"

# By default, this script builds the latest tag in the Marlin. You should always build release
# tags, and not the latest code in master. 
BUILD_TAG=""

# source for marlin + configs. Change this if you want to build code from another git repo.
MARLIN_MAIN_REPO=https://github.com/MarlinFirmware/Marlin
MARLIN_CONFIG_REPO=https://github.com/MarlinFirmware/Configurations

#############################################################################################

CWD=$(pwd)

# folder to clone marlin into
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



# overwrite marlin stock config with printer profiles
cp $PRINTER_PROFILE_SOURCE/. -R $PRINTER_PROFILE_TARGET

# overwrite platformio vars with required
DEFAULT_ENVS="default_envs = mega2560"
REQUIRED_ENVS="default_envs = STM32F103RET6_creality"
sed -i "s/$DEFAULT_ENVS/$REQUIRED_ENVS/" $MARLIN_MAIN_DIR/platformio.ini

# install avr for mega support
#arduino-cli core install arduino:avr
#arduino-cli lib install U8glib-HAL
cd $MARLIN_MAIN_DIR
pio run

# build with arduino-cli
#arduino-cli \
#    compile \
#    --fqbn arduino:avr:mega:cpu=atmega2560 \
#    --build-path build \
#    --build-cache-path build-cache \
#    -v \
#    "${PRINTER_PROFILE_TARGET}/Marlin.ino"