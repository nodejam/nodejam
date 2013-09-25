#!/bin/bash

help() {
echo "usage: ./compile [--debug]"
}

debug=false
dont_delete=false

while :
do
    case $1 in
        --debug)
            debug=true 
            shift
            ;;
        --dont_delete)
            dont_delete=true
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


if [ ! $dont_delete ]; then
    echo "Deleting the app directory"
    rm -rf app
    mkdir app
else
    echo "Not deleting the app directory"
fi

echo "Copying src to app.."
cp -r src _temp
find _temp -name '*.coffee' | xargs rm -rf
find _temp -name '*.*~' | xargs rm -rf
cp -r _temp/* app
rm -rf _temp

# echo Compiling coffee to js
echo "Compiling CS files.."
coffee -o app/ -c src/

echo "Running LESS.."
lessc app/www/css/main.less app/www/css/main.css

if $debug; then
    node --harmony app/scripts/deploy/package.js --debug
    cp src/website/views/layouts/default-debug.hbs app/website/views/layouts/default.hbs
else
    node --harmony app/scripts/deploy/package.js
fi
