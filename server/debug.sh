#!/bin/bash
./compile.sh --debug
cd ../www-client
./compile.sh --debug
cd ../server
export NODE_PATH=$NODE_PATH:app/app-lib
./run.sh
node --harmony app/scripts/debug/watch.js
