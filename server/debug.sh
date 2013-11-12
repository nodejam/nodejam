#!/bin/bash

compile=true
es6=true
production=false

while :
do
    case $1 in
        --no-compile)
            compile=false
            echo "Skipping compilation"
            shift
            ;;
        --es5)
            es6=false
            echo "Debugging ES5 code"
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

if $compile; then
    if $production; then
        if ! $es6; then
            ./compile.sh --es5
        else
            ./compile.sh
        fi
    else
        if ! $es6; then
            ./compile.sh --debug --es5
        else
            ./compile.sh --debug
        fi
    fi
fi

#export PATH=`pwd`/node_modules/.bin:"$PATH"
echo Debugging Fora...

echo Killing node if it is running..
killall node

if ! $es6; then
    node app/website/app.js localhost 10981 &
    node app/api/app.js localhost 10982 &
else
    node --harmony app/website/app.js localhost 10981 &
    node --harmony app/api/app.js localhost 10982 &
fi    


