import { print, getLogger } from "../utils/logging";
import foraUtils from "../utils/fora";

let version = function*(siteConfig) {
    var version = yield* foraUtils.getVersion();
    print(`fora ${version}`);
};

export default version;
