#!/bin/sh
# build.sh - a script to construct a redcapcustodian Docker image

# Parse options to the `build.sh` command
while getopts ":hd" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    build.sh -h                      Display this help message."
      echo "    build.sh                         Build the redcapcustodian Docker image"
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

shared_image=redcapcustodian
echo "Building $shared_image image"
docker build -t $shared_image . && docker tag $shared_image:latest $shared_image:`cat VERSION` && docker image ls $shared_image | head -n 5
