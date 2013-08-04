#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo switched to $DIR
cd $DIR

./compile.sh $1
echo Fora application starting...

cd app

cd website
if [ "$1" == "--trace" ]; then
    echo Killing node if it is running..
    killall node
    node --harmony app.js localhost 9000 &
else
    forever stopall
    forever start --harmony app.js localhost 9000
fi
cd ..
