#!/usr/bin/env bash

set -e

function usage()
{
  echo "Uploads a network with NxM prefix, where N=filters and M=blocks"
  echo ""
  echo "./upload.sh"
  echo "  -h --help"
  echo "  -u --upload   The upload url"
  echo "  -d --netdir   The directory where new networks arrive"
  echo "  -f --filters  Number of filters"
  echo "  -b --blocks   Number of blocks"
  echo ""
  echo "Example: ./upload.sh -d=/tmp -u=http://upload.me -f=64 -b=6"
  echo ""
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -h | --help)
        usage
        exit
        ;;
    -u | --upload)
        UPLOADURL=$VALUE
        ;;
    -d | --netdir)
        NETDIR=$VALUE
        ;;
    -f | --filters)
        FILTERS=$VALUE
        ;;
    -b | --blocks)
        BLOCKS=$VALUE
        ;;
    *)
        echo "ERROR: unknown parameter \"$PARAM\""
        usage
        exit 1
        ;;
  esac
  shift
done

netarch="${FILTERS}x${BLOCKS}"

echo "start upload monitor for $netarch*.gz"

inotifywait -q -m -e close_write $NETDIR | 
while read -r dir events file
do
  if [[ $file = ${netarch}*.gz ]]
  then
    echo -n "uploading ${file}..."
    curl -s -F "file=@${dir}/${file}" -F "training_id=1" -F "layers=${BLOCKS}" -F "filters=${FILTERS}" $UPLOADURL
    echo "[done]"
  else
    echo "ignoring ${file}"
  fi
done