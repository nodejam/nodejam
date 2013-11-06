#!/bin/bash

production=false

while :
do
    case $1 in
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
    ./compile.sh
else
    ./compile.sh --debug
fi

#export PATH=`pwd`/node_modules/.bin:"$PATH"
echo Debugging Fora...

echo Killing node if it is running..
killall node

node --harmony app/website/app.js localhost 10981 &
node --harmony app/api/app.js localhost 10982 &


