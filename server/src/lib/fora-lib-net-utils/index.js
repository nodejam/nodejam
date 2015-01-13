(function () {
    "use strict";

    var url = require('url'),
        fs = require('fs-extra'),
        gm = require('gm'),
        promisify = require('nodefunc-promisify'),
        logger = require('./logger'),
        randomizer = require('fora-lib-randomizer'),
        fsutils = require('./fsutils');

    var exec = promisify(require('child_process').exec);

    var downloadImage = function*(imageUrl) {
        var parseResult = url.parse(imageUrl);
        var hostArr = parseResult.hostname.split('.');
        var extension = parseResult.pathname.split('/').pop().split('.').pop();
        var filename = randomizer.uniqueId(8) + "_" + Date.now() + "." + extension.toLowerCase();

        if(['jpg', 'jpeg', 'png', 'gif', 'bmp'].indexOf(extension.toLowerCase()) !== -1) {
            var filePath = fsutils.getFilePath("temp", filename);
            var _curl = "curl --proto =http,https --proto-redir =http,https --max-filesize 5000000 " + imageUrl + " > " + filePath;
            yield exec(_curl);
            logger.log("Downloaded " + imageUrl + " to " + filePath);
            return filePath;
        } else {
            logger.log("Cannot download image. Invalid file extension for " + imageUrl);
        }
    };

    module.exports = {
        downloadImage: downloadImage
    };
})();
