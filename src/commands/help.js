import { print } from "../utils/logging";

let help = function*() {
    print(`
        fora 0.0.1 -- fora is a blog-aware, static site generator in NodeJS

        Usage:

          fora <subcommand> [options]

        Options:
                -s, --source [DIR]      Source directory (defaults to ./)
                -d, --destination [DIR] Destination directory (defaults to ./_site)
                -h, --help              Show this message
                -v, --version           Print the name and version

        Build and Serve options
                -n, --no-static         Do not create static html files
                --db <DB name>          Mongo database name
                --db-host [DB Host]     MongoDb server (defaults to localhost)
                --db-port [DB Port]     MongoDb port (defaults to 27017)

        Subcommands:
          build, b              Build your site
          new                   Creates a new fora site scaffold in PATH
          help                  Show the help message, optionally for a given subcommand.
          serve, s              Serve your site locally
          make, m               Same as build --no-static
          run, r                Same as serve --no-static
    `);
};

export default help;
