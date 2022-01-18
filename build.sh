#!/bin/sh
# build.sh - a script to construct and optionally deploy a redcapcustodian
#   container

# This script requires a single parameter that names the host for which
# the container will be built. The parameter can be either full or 
# relative path to the host folder or the name of the host folder itself.
# In the latter case, "./site/" will be prepended to the parameter 
# given in an attempt to locate the host folder

# Parse options to the `build.sh` command
while getopts ":hd" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    build.sh -h                      Display this help message."
      echo "    build.sh                         Build the redcapcustodian and rcc.site Docker images."
      echo "    build.sh <host>                  Also build the image for <host>."
      echo "    build.sh -d <host>               Also build and deploy the image for <host>."
      exit 0
      ;;
    d )
      deploy=1
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     exit 1
     ;;
  esac
done
shift $((OPTIND -1))

hostopt=''
hostopt=$1; shift

if [ -d ./site/$hostopt -a -e "./site/${hostopt}/.env" ]; then
  hostpath=./site/$hostopt
  host=`basename ${hostpath}`
else
  hostpath='./site'
  host='site'
fi

image_name=rcc.$host

if [ $deploy ]; then 
  echo Deploying redcapcustodian for $host
  # Copy the cron files from $hostpath/cron/ if they have changed
  CRON_DIR=$hostpath/cron
  TARGET_CRON_FILE=/etc/cron.d/$image_name
  TEMP_CRON_FILE=$(mktemp)
  cat $CRON_DIR/* > $TEMP_CRON_FILE
  if [ -f $TARGET_CRON_FILE ]; then
    diff -q -u $TARGET_CRON_FILE $TEMP_CRON_FILE
    if [ $? = 1 ]; then
      echo Updating cron files for $host
      echo ""
      diff -u $TARGET_CRON_FILE $TEMP_CRON_FILE
      echo ""
      cp -v $TEMP_CRON_FILE $TARGET_CRON_FILE
      echo ""
    fi
  else
    echo Copying cron files for $host
    cp $TEMP_CRON_FILE $TARGET_CRON_FILE
  fi

  # Deploy environment files
  # Specify the target folder for environment files
  ENV_FILES_FOLDER=/rcc/$host
  if [ -e $hostpath/.env ]; then
    . $hostpath/.env
  fi
  # make the target folder for env files if it does not exist
  if [ ! -d $ENV_FILES_FOLDER ]; then 
    mkdir -p $ENV_FILES_FOLDER
  fi
  # Copy all of the host's env files to the config folder.
  if [ -e $hostpath/.env ]; then
    cp $hostpath/.env $ENV_FILES_FOLDER
  fi
  if [ -d $hostpath/env/ ]; then
    cp $hostpath/env/* $ENV_FILES_FOLDER
  fi
fi

shared_image=redcapcustodian
echo "Building $shared_image image"
docker build -t $shared_image . && docker tag $shared_image:latest $shared_image:`cat VERSION` && docker image ls $shared_image | head -n 5

site_image=rcc.site
echo "Building site-specific redcapcustodian image $site_image"
old_pwd=$(pwd)
cd site
docker build -t $site_image . && docker tag $site_image:latest $site_image:`cat VERSION` && docker image ls $site_image | head -n 5
cd $old_pwd

if [ $host != 'site' ]; then
  echo "Building host-specific redcapcustodian image $image_name for $host"
  old_pwd=$(pwd)
  cd $hostpath
  docker build -t $image_name . && docker tag $image_name:latest $image_name:`cat VERSION` && docker image ls $image_name | head -n 5
  cd $old_pwd
fi
