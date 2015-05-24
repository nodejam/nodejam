import { print } from "../utils/logging";
import foraUtils from "../utils/fora";

let help = function*() {
    var version =  yield* foraUtils.getVersion();
    print(`
        fora ${version} -- A full-stack isomorphic framework for Node.JS and Browser

        Usage:
            fora <command> <params> <options>

        Commands:
            build: Build a site
                fora build [<source>] [<destination>]
                    source defaults to current directory
                    destination defaults to source/_site

                eg: fora build
                eg: fora build ~/code/my-blog ~/some/destination/dir

                options:
                    -n <build-name> (or --build-name <build-name>)
                        Specify a build-name. Defaults to "client-debug" or what's in config.json

            install: Installs a new template from npm or git
                fora install <template_name> [--git]
                    template_name should be in npm, or you must use the --git parameter
                    --git clones from git. template_name must be a git url.

                eg: fora install fora-template-blog
                eg: fora install fora-template-something --git

            new: Create a new site
                fora new <template> <project_name> [-d <destination>] [--force] [--recreate]
                    destination defaults to current directory.

                eg: fora new blog my-blog --recreate
                eg: fora new blog my-blog -d ~/code/fora_apps/

            version: Display the version number
                fora version
                fora -v
                fora --version

            help: Show this screen
                fora help
                fora -h
                fora --help

    `);
};

export default help;
