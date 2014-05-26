#!/bin/bash
cd ${0%/*}

export NODE_PATH=$NODE_PATH:`pwd`/app/app-lib

start_processes() {
    #fora_website and fora_api are simply identifiers, so that we can find and kill
    echo Killing all running fora processes...
    kill $(ps ax | grep 'fora_[website|api]' | awk '{print $1}') 2>/dev/null

    node --harmony app/website/app.js localhost 10981 fora_website &
    node --harmony app/api/app.js localhost 10982 fora_api &
}

start_processes

