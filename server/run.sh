#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo switched to $DIR
cd $DIR

./compile.sh $1
echo Fora application starting...

cd app

if [ "$1" == "--trace" ]; then
    echo Killing node if it is running..
    killall node
    cd website
    node --harmony app.js &
    cd ..
    cd api
    node --harmony app.js &
    cd ..
else
    cd website
    forever start -c "node --harmony" app.js
    cd ..
    cd api
    forever start -c "node --harmony" app.js
    cd ..
fi
cd ..
