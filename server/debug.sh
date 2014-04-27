#!/bin/bash
./build.sh --debug
cd ../www-client
./build.sh --debug
cd ../server
./run.sh
node --harmony app/scripts/debug/watch.js
