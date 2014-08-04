#!/bin/bash
cd ${0%/*}

export NODE_PATH=$NODE_PATH:`pwd`/app/lib

if [ $NODE_ENV = "development" ]; then
    echo "Longer stack traces are on: --stack-trace-limit=1000"
    long_stack="--stack-trace-limit=1000"
fi

api_debug=""
web_debug=""

for i; do
    case $i in
        --debug-api)
            api_debug="--debug"
            ;;
        --debug-brk-api)
            api_debug="--debug-brk"
            ;;
        --debug-web)
            web_debug="--debug"
            ;;
        --debug-brk-web)
            web_debug="--debug-brk"
            ;;
    esac
done

start_processes() {
    #fora_website and fora_api are simply identifiers, so that we can find and kill
    echo Killing all running fora processes...
    kill $(ps ax | grep 'fora_[website|api]' | awk '{print $1}') 2>/dev/null

    node --harmony $api_debug $long_stack app/api/app.js localhost 10982 fora_api "$@" 2> apierrors.log &
    node --harmony $web_debug $long_stack app/website/app.js localhost 10981 fora_website "$@" 2> weberrors.log &
}

start_processes $@
