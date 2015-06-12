import { print, getLogger } from "../utils/logging";
import foraUtils from "../utils/fora";

const version = function*(siteConfig) {
    var ver = yield* foraUtils.getVersion();
    print(`fora ${ver}`);
};

export default version;
