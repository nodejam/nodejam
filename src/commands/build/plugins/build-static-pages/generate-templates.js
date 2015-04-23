import path from "path";
import doLayout from "./do-layout";
import fsutils from "../../../../utils/fs";

export default function(siteConfig) {

    var jekyllConfig = siteConfig.jekyll;

    var makePath = function(filePath, page) {
        var permalink = siteConfig.permalink;

        var dir = path.dirname(filePath);
        var extension = path.extname(filePath);
        var basename = path.basename(filePath, extension);

        return path.join(dir, `${basename}.html`);
    };

    /*
        Templates are JSX files outside the _layouts directory
    */
    var fn = function() {
        var extensions = [`${path.resolve(siteConfig.destination)}/*.js`];

        var excluded = ["!app.bundle.js"]
            .concat(
                siteConfig.dirs_exclude
                    .concat(siteConfig.dirs_client_vendor)
                    .concat(siteConfig.dir_client_build)
                    .concat(siteConfig.dir_dev_build)
                    .concat(siteConfig.dir_custom_tasks)
                    .concat(jekyllConfig.dirs_includes)
                    .concat(jekyllConfig.dirs_layouts)
                    .concat(jekyllConfig.dir_fora)
                    .map(dir => `!${dir}/`)
                    .concat(siteConfig.patterns_exclude)
            );

        this.watch(extensions.concat(excluded), function*(filePath, ev, matches) {
            var result = yield* doLayout(null, filePath, filePath, makePath, siteConfig);
        }, `build_templates`);
    };

    return { build: true, fn: fn };
}
