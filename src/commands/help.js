import { print } from "../utils/logging";
import foraUtils from "../utils/fora";

let help = function*() {
    var version =  yield* foraUtils.getVersion();
    print(`
        fora ${version} -- A full-stack isomorphic framework for Node.JS and Browser

        Usage:
            fora <command> <params> <flags>

        Commands:
            install: Installs a new template from npm or git
                fora install <template_name> [--git]
                    template_name should be in npm, or you must use the --git parameter
                    --git clones from git. template_name must be a git url.

                eg: fora install fora-template-blog
                eg: fora install fora-template-something --git

            new: Create a new site
                fora new <project_name> <template> [-d destination] [--force] [--recreate]
                    -d or --destination may be used to install to a separate directory.

                eg: fora new my-blog blog --recreate
                eg: fora new my-blog -d ~/code/fora_apps/ --recreate

            build: Build a site
                fora build [<source>] [-d <destination>]
                    source defaults to current directory
                    destination defaults to source/_site
                    -d or --destination may be used to override the default destination.

                eg: fora build
                eg: fora build ~/code/my-blog

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
