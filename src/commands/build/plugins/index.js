import babel from "./babel";
import copyStaticFiles from "./copy-static-files";
import less from "./less";
import writeConfig from "./write-config";
import buildBrowserApp from "./build-browser-app";
import loadData from "./load-data";
//import buildStaticPages from "./build-static-pages";

export default {
    "babel": babel,
    "copy-static-files": copyStaticFiles,
    "less": less,
    "write-config": writeConfig,
    "build-browser-app": buildBrowserApp,
    "load-data": loadData,
    //"build-static-pages": buildStaticPages
};
