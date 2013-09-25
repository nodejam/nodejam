#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo switched to $DIR
cd $DIR

help() {
echo "usage: ./run [--debug]"
}

debug=false

while :
do
    case $1 in
        -debug)
            debug=true 
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

if [ $debug ] ; then
    ./compile.sh --debug
else
    ./compile.sh    
fi


#export PATH=`pwd`/node_modules/.bin:"$PATH"
echo Fora application starting...
cd app

if [ $debug ] ; then
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
