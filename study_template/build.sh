#!/bin/sh
# build.sh - a script to construct and optionally deploy an rcc.* container

# Parse options to the `build.sh` command
while getopts ":hd" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    build.sh -h                      Display this help message."
      echo "    build.sh                         Build the rcc.* Docker image."
      echo "    build.sh -d                      Build the image and deploy all configuration files"
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

sitepath='.'
export image_name=$(ls -1 rcc.*.Rproj | cut -d. -f1-2)

if [ $deploy ]; then
  echo Deploying ${image_name}
  TARGET_CRON_FOLDER=/etc/cron.d/
  if [ -d $TARGET_CRON_FOLDER ]; then
    echo Copying cron files
    old_pwd=$(pwd)
    cd $sitepath
    export image_name_cron=$(echo $image_name | sed 's/\./_/g;')
    rm -f /etc/cron.d/rcc-$image_name_cron*
    find . -type d -iname cron -exec ls -d {} \; | \
    xargs -i find {} -type f | sed "s/.\{2\}//;" | \
    grep -v dummy | \
    perl -n -e 'chop(); $src=$_; $target=$_; $target =~ s/\//-/g; $cmd = "cp $src /etc/cron.d/rcc-$ENV{image_name_cron}-$target\n"; print $cmd; system($cmd);'
    ls -ltr /etc/cron.d/rcc-$image_name_cron*
    cd $old_pwd
  fi

  # Deploy environment files
  ENV_FILES_FOLDER=/rcc/${image_name}
  # Allow the project to override the default target folder for environment files
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

site_image=${image_name}
echo "Building $site_image"
old_pwd=$(pwd)
cd $sitepath
docker build -t $site_image . && docker tag $site_image:latest $site_image:`cat VERSION` && docker image ls $site_image | head -n 5
cd $old_pwd
