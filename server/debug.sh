#!/bin/bash
./compile.sh --debug
cd ../www-client
./compile.sh --debug
cd ../server
./run.sh
node --harmony app/scripts/debug/watch.js
