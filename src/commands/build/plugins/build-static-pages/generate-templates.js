import path from "path";
import doLayout from "./do-layout";
import fsutils from "../../../../utils/fs";

export default function(siteConfig) {

  const jekyllConfig = siteConfig.jekyll;

  const makePath = function(filePath, page) {
    const permalink = siteConfig.permalink;

    const dir = path.dirname(filePath);
    const extension = path.extname(filePath);
    const basename = path.basename(filePath, extension);

    return path.join(dir, `${basename}.html`);
  };

  /*
  Templates are JSX files outside the _layouts directory
  */
  const fn = function() {
    const extensions = [`${path.resolve(siteConfig.destination)}/*.js`];

    const excluded = ["!app.bundle.js"]
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

    this.watch(extensions.concat(excluded), async function(filePath, ev, matches) {
      const result = await doLayout(null, filePath, filePath, makePath, siteConfig);
    }, `build_templates`);
  };

  return { build: true, fn: fn };
}
