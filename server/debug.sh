#!/bin/bash

harmony=true
production=false

while :
do
    case $1 in
        --no-harmony)
            harmony=false
            echo "Compiling for node harmony"
            shift
            ;;
        --production)
            production=true 
            echo "Compiling in production mode"
            shift
            ;;
        -*)
            echo "WARN: Unknown option (ignored): $1" >&2
            shift
            ;;
        *)  # no more options. Stop while loop        
            break
            ;;
    esac
done

if $production; then
    if ! $harmony; then
        ./compile.sh --no-harmony
    else
        ./compile.sh
    fi
else
    if ! $harmony; then
        ./compile.sh --debug --no-harmony
    else
        ./compile.sh --debug
    fi
fi

#export PATH=`pwd`/node_modules/.bin:"$PATH"
echo Debugging Fora...

echo Killing node if it is running..
killall node

if ! $harmony; then
    node app/website/app.js localhost 10981 &
    node app/api/app.js localhost 10982 &
else
    node --harmony app/website/app.js localhost 10981 &
    node --harmony app/api/app.js localhost 10982 &
fi    


