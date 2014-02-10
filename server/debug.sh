#!/bin/bash
./compile.sh --debug
./run.sh
node --harmony app/scripts/debug/watch.js
