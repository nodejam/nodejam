#!/bin/bash

# Configuration for Fora
# Tested only in Ubuntu

help() {
echo "usage: ./configure.sh [options]
options:
  --host hostname       eg: --host dev.myfora.org. hostname defaults to local.foraproject.org
  --nginx               Setup Fora to run with nginx. Ngnix must be installed previously.
  --help                Print the help screen
Examples:
  ./configure.sh --host dev.myfora.org --nginx"
}

if [ $# -eq 0 ]
  then
    help
    exit 0
fi

host=local.foraproject.org
nginx=false

while :
do
    case $1 in
        -h | --help | -\?)
            help
            exit 0      # This is not an error, User asked help. Don't do "exit 1"
            ;;
        --host)
            host=$2
            shift 2
            ;;
        --nginx)
            nginx=true
            shift
            ;;
        *)  # no more options. Stop while loop        
            break
            ;;
    esac
done


