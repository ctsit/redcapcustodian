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
      echo "    build.sh -d                      Build the images and deploy all configuration files"
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

sitepath='./site'
image_name=rcc.site

if [ $deploy ]; then
  echo Deploying redcapcustodian
  TARGET_CRON_FOLDER=/etc/cron.d/
  if [ -f $TARGET_CRON_FOLDER ]; then
    echo Copying cron files
    old_pwd=$(pwd)
    cd $sitepath
    find . -type d -iname cron -exec ls -d {} \; | \
    xargs -i find {} -type f | sed "s/.\{2\}//;" | \
    perl -n -e 'chop(); $src=$_; $target=$_; $target =~ s/\//-/g; system("cp $src ~/temp/rcc-$target\n");'
    cd $old_pwd
  fi

  # Deploy environment files
  # Specify the target folder for environment files
  ENV_FILES_FOLDER=/rcc
  if [ -e $sitepath/.env ]; then
    . $sitepath/.env
  fi
  # make the target folder for env files if it does not exist
  if [ ! -d $ENV_FILES_FOLDER ]; then 
    mkdir -p $ENV_FILES_FOLDER
  fi

  # Copy all of the env files from the site project to the config folder.  
  if [ -e $sitepath/.env ]; then
    cp $sitepath/.env $ENV_FILES_FOLDER
  fi

  # Deploy all env folders
  old_pwd=$(pwd)
  cd $sitepath
  find . -type d -iname "env" | xargs -i mkdir -p ${ENV_FILES_FOLDER}/{} 
  find . -type d -iname "env" | xargs -i rsync -arcv {}/ ${ENV_FILES_FOLDER}/{} 
  cd $old_pwd

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
