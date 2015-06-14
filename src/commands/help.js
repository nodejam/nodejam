import { print } from "../utils/logging";
import foraUtils from "../utils/fora";

const help = function*() {
    const version =  yield* foraUtils.getVersion();
    print(`
        fora ${version} -- A full-stack isomorphic framework for Node.JS and Browser

        Usage:
            fora <command> <params> <options>

        Commands:
            build: Build a site
                fora build [<build-type>] [-s <source>] [-d <destination>]

                eg: fora build
                eg: fora build production
                eg: fora build -s ~/code/my-blog -d ~/some/destination/dir

                params:
                    build-type (optional)
                        Specify a build type. Defaults to "debug" or what's in config.json.
                        Built-in build types are production, debug and dev.

                options:
                    --source <source> (or -s <source>)
                        defaults to current directory

                    --destination <destination> (or -d <destination>)
                        defaults to <source>/_site


            install: Installs a new template from npm or git
                fora install <template_name> [--git]

                eg: fora install fora-template-blog
                eg: fora install http://www.github.com/onefora/fora-template-something --git

                params:
                    template_name
                        template_name should be a package in npm
                        But when used with the --git parameter, template_name should be a git location.

                options:
                    --git clones from git. template_name must be a git url.


            new: Create a new site
                fora new <template> <project_name> [-d <destination>] [--recreate]

                eg: fora new blog my-blog --recreate
                eg: fora new blog my-blog -d ~/code/fora_apps/

                params:
                    template
                        One of the installed fora templates. Use the install command to install a template.
                        If the template name is fora-template-blog, you may omit the 'fora-template' prefix and just use 'blog'

                options:
                    --destination <destination> (or -d <destination>)
                        defaults to <source>/_site

                    --recreate
                        Deletes the directory if it exists

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
