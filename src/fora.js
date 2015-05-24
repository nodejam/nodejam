#!/usr/bin/env node

require("babel/polyfill");

import co from "co";
import optimist from "optimist";
import * as commands from "./commands";
import { print } from "./utils/logging";

let argv = optimist.argv;

//debug mode?
if (argv.debug) {
    GLOBAL.CO_PARALLEL_TOOLS_DEBUG = true;
}

//Commands might need the templates directory. Easier from root.
GLOBAL.__libdir = __dirname;

let getCommand = function() {
    return (
        (argv.help || argv.h) ? "help" :
        (argv.version || argv.v) ? "version" :
        process.argv[2]
    );
};


co(function*() {
    try {
        let commandName = getCommand();
        if (commandName) {
            let command = commands[`_${commandName}`];
            yield* command();
        } else {
            print("Invalid command. Use --help for more information.");
        }
    }
    catch(err) {
        print(err.stack);
        print("Use --help for more information.");
    }
});
