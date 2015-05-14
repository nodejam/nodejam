import { print } from "../utils/logging";

let help = function*() {
    print(`
        fora 1.0.0 -- A full-stack isomorphic framework for Node.JS and Browser

        Usage:

          fora <command> [options]

        Commands:
            new: Create a new site
                fora new -n <name> -t <template> -d <destination> [--force] [--recreate]
                eg: fora new -n my-blog -t blog -d ~/code --recreate

            build: Build a site
                fora build -s <source> [-d <destination>]

            help: Show this screen
                fora help
                fora -h
                fora --help

            version: Display the version number
                fora version
                fora -v
                fora --version
    `);
};

export default help;
