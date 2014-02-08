#!/bin/bash

echo Debugging Fora...

compile=true
es6=true
production=false
watch=false

#Parse options
while :
do
    case $1 in
        --no-compile)
            compile=false
            echo "Skipping compilation"
            shift
            ;;
        --watch)
            compile=false
            watch=true
            echo "Skipping compilation and watching for changes"
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

#Compile?
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

last_restart=0
restart_processes() {
    current_time=$(date +%s)
    difference=$((current_time - last_restart))

    if ((difference > 5)); then
        echo "$difference seconds since last restart"
        last_restart=$current_time

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
    fi
    
}

#Watch?
if $watch; then
    while read i;
    do
      restart_processes      
    done < <(coffee -o app/ -cw src/)    
fi

restart_processes


