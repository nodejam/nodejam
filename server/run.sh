#!/bin/bash
cd ${0%/*}

export NODE_PATH=$NODE_PATH:`pwd`/app/app-lib

debugapi=false
debugweb=false

for i; do
    case $i in
        --debugapi)
            debugapi=true
            ;;
        --debugweb)
            debugweb=true
            ;;
    esac
done

start_processes() {
    #fora_website and fora_api are simply identifiers, so that we can find and kill
    echo Killing all running fora processes...
    kill $(ps ax | grep 'fora_[website|api]' | awk '{print $1}') 2>/dev/null

    if ! $debugapi ; then
        node --harmony app/api/app.js localhost 10982 fora_api "$@" 2> apierrors.log &
    else
        node --debug-brk --harmony app/api/app.js localhost 10982 fora_api "$@" 2> apierrors.log &
    fi

    if ! $debugweb ; then
        node --harmony app/website/app.js localhost 10981 fora_website "$@" 2> weberrors.log &
    else
        node --debug-brk --harmony app/website/app.js localhost 10981 fora_website 2> weberrors.log &
    fi
}

start_processes $@
