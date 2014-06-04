#!/bin/bash
cd ${0%/*}

export NODE_PATH=$NODE_PATH:`pwd`/app/app-lib

debugapi=false
debugweb=false

while :
do
    case $1 in
        --debugapi)
            debugapi=true
            shift
            ;;
        --debugweb)
            debugweb=true
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

start_processes() {
    #fora_website and fora_api are simply identifiers, so that we can find and kill
    echo Killing all running fora processes...
    kill $(ps ax | grep 'fora_[website|api]' | awk '{print $1}') 2>/dev/null

    if ! $debugapi ; then
        node --harmony app/api/app.js localhost 10982 fora_api &
    else
        node --debug-brk --harmony app/api/app.js localhost 10982 fora_api &
    fi

    if ! $debugweb ; then
        node --harmony app/website/app.js localhost 10981 fora_website &
    else
        node --debug-brk --harmony app/website/app.js localhost 10981 fora_website &
    fi

}

start_processes

