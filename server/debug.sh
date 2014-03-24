#!/bin/bash
./compile.sh --debug
cd ../www-client
./compile.sh --debug
cd ../server
./run.sh
export NODE_PATH=$NODE_PATH:app/app-libs
node --harmony app/scripts/debug/watch.js
