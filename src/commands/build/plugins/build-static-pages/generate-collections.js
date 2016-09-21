import path from "path";
import frontMatter from "front-matter";
import doLayout from "./do-layout";
import fsutils from "../../../../utils/fs";

export default function(siteConfig) {

  GLOBAL.site.collections = [];

  const getMakePath = function(collection) {
    return function(filePath, page) {
      let permalink = page.permalink || collection.permalink || siteConfig.jekyll.permalink;
      const dir = path.dirname(filePath);
      const extension = path.extname(filePath);
      const basename = path.basename(filePath, extension);

      if (/\/$/.test(permalink))
      permalink += "index.html";

      return permalink === "pretty" ?
      path.join(dir, basename, "index.html") :
      path.join(dir, `${basename}.html`);
    };
  };

  const makePostPath = function(filePath, page) {
    let permalink = page.permalink || siteConfig.jekyll.permalink;

    const dir = path.dirname(filePath);
    const extension = path.extname(filePath);
    const basename = path.basename(filePath, extension);

    const [year, month, day, ...titleArr] = basename.split("-");
    const placeholders = {
      year: year,
      month: month,
      day: day,
      title: titleArr.join("-"),
      imonth: parseInt(month).toString(),
      iday: parseInt(day).toString(),
      short_year: parseInt(year) - parseInt(parseInt(year)/1000)*1000,
      categories: page.categories ? page.categories.split(/\s+/).join("/") : ""
    };

    const parsePlaceholders = function(permalink) {
      for (const key in placeholders) {
        const regex = new RegExp(`\:\\b${key}\\b`);
        permalink = permalink.replace(regex, placeholders[key]);
      }
      return permalink.replace(/^\/*/, "");
    };

    if (/\/$/.test(permalink))
    permalink += "index.html";

    return (
      permalink === "pretty" ? parsePlaceholders("/:categories/:year/:month/:day/:title/index.html") :
      permalink === "date" ? parsePlaceholders("/:categories/:year/:month/:day/:title.html") :
      permalink === "none" ? parsePlaceholders("/:categories/:title.html") :
      parsePlaceholders(permalink)
    );
  };

  const makePagePath = function(filePath, page) {
    const permalink = page.permalink || siteConfig.permalink;

    const dir = path.dirname(filePath);
    const extension = path.extname(filePath);
    const basename = path.basename(filePath, extension);

    return permalink === "pretty" ?
    path.join(dir, basename, "index.html") :
    path.join(dir, `${basename}.html`);
  };

  const fn = async function() {
    for (let collectionName in siteConfig.collections) {
      const collection = siteConfig.collections[collectionName];
      if (collection.output) {
        for (let item of GLOBAL.site.data[collectionName]) {
          const makePath = collectionName === "posts" ? makePostPath :
          collectionName === "pages" ? makePagePath :
          getMakePath(collection);

          //If we don't have a filename, we don't need to process it individually.
          if (item.__filePath) {
            await doLayout(item, item.__filePath, collection.layout || "default", makePath, siteConfig);
          }
        }
      }
    }
  };

  return { build: false, fn: fn };
}
