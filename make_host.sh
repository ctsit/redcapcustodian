#!/bin/bash

while getopts ":ht:" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    make_host.sh -h                      Display this help message."
      echo "    make_host.sh <host>                  make <host>."
      echo "    make_host.sh -t <template> <host>    Use <template> to make <host>."
      echo ""
      echo "Please provide a name for the host you are creating"
      echo "Using this name, this script will copy the host_template folder"
      echo "to a new folder under ./hosts and configure with the new host name." 
      echo ""
      echo "We recommend usage something like this:"
      echo ""
      echo "   ./make_host.sh example"
      echo ""
      echo "Or specify your own template like this:"
      echo ""
      echo "   ./make_host.sh -t hosts/my_template example"
      echo ""
      exit 0
      ;;
    t )
      TEMPLATE_FOLDER=$OPTARG
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     exit 1
     ;;
  esac
done
shift $((OPTIND -1))

HOST_NAME=$1; shift

if [ -z $HOST_NAME ]; then
  echo "Please specify a hostname"
  exit
fi

if [ -z ${TEMPLATE_FOLDER} ]; then
  TEMPLATE_FOLDER=host_template
fi

if [ ! -d ${TEMPLATE_FOLDER} ]; then
  echo ${TEMPLATE_FOLDER} does not exist.
  exit
fi

TARGET_DIR=hosts/${HOST_NAME}

SOURCE_ENV_FILE=${TEMPLATE_FOLDER}/example.env
TARGET_ENV_FOLDER=${TARGET_DIR}/env
TARGET_ENV_FILE=${TARGET_ENV_FOLDER}/.env

if [ -e ${TARGET_DIR} ]; then
    echo "The ${TARGET_DIR} folder already exists.  I will not proceed lest I damage an existing host"
    exit
else
    echo "Creating ${TARGET_DIR} from the ${TEMPLATE_FOLDER} folder"
fi

rsync -r ${TEMPLATE_FOLDER}/ ${TARGET_DIR}

mkdir ${TARGET_ENV_FOLDER}
cat ${SOURCE_ENV_FILE} | sed -e "s/Development/${HOST_NAME}/;" > ${TARGET_ENV_FILE}
