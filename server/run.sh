#!/bin/bash
echo Debugging Fora...

es6=true

#Parse options
while :
do
    case $1 in
        --es5)
            es6=false
            echo "Debugging ES5 code"
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
    kill $(ps ax | grep 'fora_[website|api]' | awk '{print $1}')

    if ! $es6; then
        node app/website/app.js localhost 10981 fora_website &
        node app/api/app.js localhost 10982 fora_api &
    else
        node --harmony app/website/app.js localhost 10981 fora_website &
        node --harmony app/api/app.js localhost 10982 fora_api &
    fi
}

start_processes

