#!/bin/sh
# run_in_host.sh

# Parse options to the `run_in_host.sh` command
while getopts ":h" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    run_in_host.sh -h                                     Display this help message."
      echo "    run_in_host.sh REDCAP_VERSION ENV_FILE SCRIPT_TO_RUN  run a script with a particular ENV file against a local container instantiated by redcap-docker-compose"
      echo "        REDCAP_VERSION - e.g. 1203 for REDCap version 12.0.3"
      echo "        ENV_FILE - a file of environment variables used to configure the container"
      echo "        SCRIPT_TO_RUN - The Rscript you want the container to run"
      exit 0
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     exit 1
     ;;
  esac
done
shift $((OPTIND -1))

if [ $# -ne 3 ]; then
    echo "Usage:"
    echo "    run_in_host.sh -h                                     Display this help message."
    echo "    run_in_host.sh REDCAP_VERSION ENV_FILE SCRIPT_TO_RUN  run a script with a particular ENV file against a local container instantiated by redcap-docker-compose"
    echo "        REDCAP_VERSION - e.g. 1203 for REDCap version 12.0.3"
    echo "        ENV_FILE - a file of environment variables used to configure the container"
    echo "        SCRIPT_TO_RUN - The Rscript you want the container to run"
    exit 0
fi

REDCAP_VERSION=$1; shift
ENV_FILE=$1; shift
SCRIPT_TO_RUN=$1; shift

REDCAP_BASENAME=rc${REDCAP_VERSION}
REDCAP_DB_CONTAINER_NAME=${REDCAP_BASENAME}_db
REDCAP_NETWORK_NAME=$(docker inspect -f '{{.HostConfig.NetworkMode}}' ${REDCAP_DB_CONTAINER_NAME})
REDCAP_DB_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${REDCAP_DB_CONTAINER_NAME})

REDCAP_WEB_CONTAINER_NAME=${REDCAP_BASENAME}_web
REDCAP_WEB_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${REDCAP_WEB_CONTAINER_NAME})

TEMPFILE=$(mktemp)
cat ${ENV_FILE} | sed -e "s/URI=.*/URI=${REDCAP_WEB_IP}\/api\//; s/REDCAP_DB_HOST=.*/REDCAP_DB_HOST=${REDCAP_DB_IP}/" > $TEMPFILE

echo "This is the environment file we will use in the container"
cat ${TEMPFILE}
echo ""

#./build.sh local && \
    docker run --network=${REDCAP_NETWORK_NAME} \
    --env-file $TEMPFILE \
    --rm rcc.site \
    Rscript ${SCRIPT_TO_RUN}
