import { print, getLogger } from "../utils/logging";
import foraUtils from "../utils/fora";

const version = async function(siteConfig) {
    const ver = await foraUtils.getVersion();
    print(`fora ${ver}`);
};

export default version;
