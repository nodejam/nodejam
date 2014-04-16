#!/bin/bash
help() {
echo "usage: ./compile [options]"
echo "options: --debug, --es5, --dont-delete"
}

debug=false
dont_delete=false
skip_es5_transform=true

while :
do
    case $1 in
        --debug)
            debug=true 
            echo "Compiling in debug mode"
            shift
            ;;
        --es5)
            skip_es5_transform=false
            echo "Compiling for ES5"
            shift
            ;;
        --dont-delete)
            dont_delete=true
            shift
            ;;
        --help)
            help
            exit 0
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

temp=`mktemp -d`
echo "Copying src to app.."
cp -r src/* $temp
find $temp -name '*.coffee' | xargs rm -rf
find $temp -name '*.jsx' | xargs rm -rf
find $temp -name '*.*~' | xargs rm -rf
cp -r $temp/* app
rm -rf $temp

# echo Compiling coffee to js
echo "Compiling CoffeeScript files.."
coffee -o app/ -c src/
echo "Compiling JSX files.."
jsx -x jsx src/app-lib/fora-ui app/app-lib/fora-ui
jsx -x jsx src/extensions app/extensions

#Run it through generator.
#This step is unnecessary if we are using node --harmony
compile_to_es5() {
    dir=`pwd`/$1
    echo Processing $dir
    find $dir -name *.js -type f -exec cp {} {}.es6 \; -exec sh -c 'regenerator --include-runtime {}.es6 > {}' \; 
}

if ! $skip_es5_transform; then
    echo Running regenerator..
    compile_to_es5 "app/api"
    compile_to_es5 "app/common"
    compile_to_es5 "app/conf"
    compile_to_es5 "app/lib"
    compile_to_es5 "app/models"
    compile_to_es5 "app/scripts"
    compile_to_es5 "app/extensions"
    compile_to_es5 "app/website"
fi

if $debug; then
    cp src/website/views/layouts/default-debug.hbs app/website/views/layouts/default.hbs
fi
