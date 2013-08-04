#!/bin/bash
if [ "$1" != "--nodel" ]; then
    echo Deleting ./app 
    rm -rf app
    mkdir app
else
    echo Not deleting ./app
fi

echo Copying src to app
cp -r src _temp
find _temp -name '*.coffee' | xargs rm -rf
find _temp -name '*.*~' | xargs rm -rf
cp -r _temp/* app
rm -rf _temp

# echo Compiling coffee to js
coffee -o app/ -c src/

if [ "$1" == "--debug" ] || [ "$1" == "--trace" ]; then
echo "Running LESS.."
    lessc app/www/css/main.less app/www/css/main.css
    echo Running packaging script\/debug ...
    node --harmony app/scripts/deploy/package.js $1
    cp src/website/views/layouts/default-debug.hbs app/website/views/layouts/default.hbs
else
echo "Running LESS.."
    lessc app/www/css/main.less app/www/css/main.css
    echo Running packaging script\/production ...
    node --harmony app/scripts/deploy/package.js $1
fi    
