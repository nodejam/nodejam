import React from "react";
import path from "path";
import frontMatter from "front-matter";
import markdown from "node-markdown";
import fsutils from "../../../../utils/fs";
import pretty from "pretty";
import { print, getLogger } from "../../../../utils/logging";

const md = markdown.Markdown;

export default async function(page, sourcePath, layout, makePath, siteConfig) {
    const logger = getLogger(siteConfig.quiet, "jekyll html generator");
    const jekyllConfig = siteConfig.jekyll;

    try {
        let layoutsourcePath, params, component;

        //Source path and layout are the same only when generating plain JSX templates (without frontmatter)
        if (sourcePath !== layout) {
            layoutsourcePath = path.resolve(siteConfig.destination, `${jekyllConfig.dirs_layouts}/${page.layout || layout}`);
            params = { page: page, content: page.content, site: siteConfig };
        } else {
            page = {};
            layoutsourcePath = path.resolve(siteConfig.destination, layout);
            params = { page: page, content: "", site: siteConfig };
        }
        component = React.createFactory(require(layoutsourcePath))(params);
        const reactHtml = React.renderToString(component);
        const html = `<!DOCTYPE html>` + siteConfig.beautify ? pretty(reactHtml) : reactHtml;

        const outputPath = path.resolve(
            siteConfig.destination,
            makePath(sourcePath, page)
        );

        const outputDir = path.dirname(outputPath);
        if (!(await fsutils.exists(outputDir))) {
            await fsutils.mkdirp(outputDir);
        }

        logger(`${sourcePath} -> ${outputPath}`);

        await fsutils.writeFile(outputPath, html);

        return { page };
    } catch(err) {
        logger(`cannot process ${sourcePath} with template ${layout}.`);
        throw err;
    }
}
