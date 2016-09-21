#!/usr/bin/env node
import optimist from "optimist";
import * as commands from "./commands";
import { print } from "./utils/logging";

const argv = optimist.argv;

//Commands might need the templates directory. Easier from root.
GLOBAL.__libdir = __dirname;

const getCommand = function() {
  return (
    (argv.help || argv.h) ? "help" :
    (argv.version || argv.v) ? "version" :
    process.argv[2]
  );
};

const commandName = getCommand();
if (commandName) {
  const command = commands[`_${commandName}`];
  command().catch((err) => { print(err); print("Use --help for more information."); });
}
