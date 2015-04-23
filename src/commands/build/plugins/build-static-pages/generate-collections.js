import path from "path";
import frontMatter from "front-matter";
import doLayout from "./do-layout";
import fsutils from "../../../../utils/fs";

export default function(siteConfig) {

    GLOBAL.site.collections = [];

    var getMakePath = function(collection) {
        return function(filePath, page) {
            var permalink = page.permalink || collection.permalink || siteConfig.jekyll.permalink;
            var dir = path.dirname(filePath);
            var extension = path.extname(filePath);
            var basename = path.basename(filePath, extension);

            if (/\/$/.test(permalink))
                permalink += "index.html";

            return permalink === "pretty" ?
                path.join(dir, basename, "index.html") :
                path.join(dir, `${basename}.html`);
        };
    };

    var makePostPath = function(filePath, page) {
        var permalink = page.permalink || siteConfig.jekyll.permalink;

        var dir = path.dirname(filePath);
        var extension = path.extname(filePath);
        var basename = path.basename(filePath, extension);

        var [year, month, day, ...titleArr] = basename.split("-");
        var placeholders = {
            year: year,
            month: month,
            day: day,
            title: titleArr.join("-"),
            imonth: parseInt(month).toString(),
            iday: parseInt(day).toString(),
            short_year: parseInt(year) - parseInt(parseInt(year)/1000)*1000,
            categories: page.categories ? page.categories.split(/\s+/).join("/") : ""
        };

        var parsePlaceholders = function(permalink) {
            for (var key in placeholders) {
                var regex = new RegExp(`\:\\b${key}\\b`);
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

    var makePagePath = function(filePath, page) {
        var permalink = page.permalink || siteConfig.permalink;

        var dir = path.dirname(filePath);
        var extension = path.extname(filePath);
        var basename = path.basename(filePath, extension);

        return permalink === "pretty" ?
            path.join(dir, basename, "index.html") :
            path.join(dir, `${basename}.html`);
    };

    var fn = function*() {
        for (let collectionName in siteConfig.collections) {
            let collection = siteConfig.collections[collectionName];
            if (collection.output) {
                for (let item of GLOBAL.site.data[collectionName]) {
                    var makePath = collectionName === "posts" ? makePostPath :
                        collectionName === "pages" ? makePagePath :
                        getMakePath(collection);

                    //If we don't have a filename, we don't need to process it individually.
                    if (item.__filePath) {
                        yield* doLayout(item, item.__filePath, collection.layout || "default", makePath, siteConfig);
                    }
                }
            }
        }
    };

    return { build: false, fn: fn };
}
