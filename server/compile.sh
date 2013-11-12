#!/bin/bash

help() {
echo "usage: ./compile [--debug]"
}

debug=false
dont_delete=false
es6=true

while :
do
    case $1 in
        --debug)
            debug=true 
            echo "Compiling in debug mode"
            shift
            ;;
        --es5)
            es6=false
            echo "Compiling for ES5"
            shift
            ;;
        --dont-delete)
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


if ! $dont_delete; then
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

#Run it through generator.
#This step is unnecessary if we are using node --harmony
compile_to_es5() {
    dir=`pwd`/$1
    echo Processing $dir
    find $dir -name *.js -type f -exec cp {} {}.es6 \; -exec sh -c 'regenerator --include-runtime {}.es6 > {}' \; 
}

if ! $es6; then
    echo Running regenerator..
    compile_to_es5 "app/api"
    compile_to_es5 "app/common"
    compile_to_es5 "app/conf"
    compile_to_es5 "app/lib"
    compile_to_es5 "app/models"
    compile_to_es5 "app/scripts"
    compile_to_es5 "app/website"
fi

echo "Running LESS.."
lessc app/www/css/main.less app/www/css/main.css

if $debug; then
    if ! $es6; then
        node app/scripts/deploy/package.js --debug
    else
        node --harmony app/scripts/deploy/package.js --debug
    fi
    cp src/website/views/layouts/default-debug.hbs app/website/views/layouts/default.hbs
else
    if ! $es6; then
        node app/scripts/deploy/package.js
    else
        node --harmony app/scripts/deploy/package.js
    fi
fi
