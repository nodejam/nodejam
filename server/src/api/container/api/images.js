(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        typeHelpers = require('fora-app-type-helpers'),
        conf = require('../../../config');

    var Parser = require('fora-request-parser');


    var resizeImage = function*(src, dest, options) {
        logger.log("Resizing #{src}...");
        var img = gm(src);

        if (options.gravity)
            img = img.gravity(options.gravity);

        switch(options.imageType) {
            case 'thumbnail':
                img = img.resize(options.width, options.height + "^");
                img = img.crop(options.width, options.height);
                break;
            default:
                img = img.resize(options.width, options.height);
        }

        _ = yield* thunkify(img.write).call(img, dest);
        logger.log("Resized #{src} to #{dest} [#{JSON.stringify options}]");
    };


    var upload = function*() {
        var srcArr, srcWidth, srcHeight;
        var smallArr, smallWidth, smallHeight;

        if(this.query.src_size) {
            srcArr = this.query.src_size.split('x').map(parseInt);
            srcWidth = srcArr[0];
            srcHeight = srcArr[1];
        }

        if(this.query.small_size) {
            smallArr = this.query.src_size.split('x').map(parseInt);
            smallWidth = smallArr[0];
            smallHeight = smallArr[1];
        }

        //validate
        var validGravity;
        if(this.query.gravity) {
            validGravity = ['Center'];
            if (validGravity.indexOf(this.query.gravity) !== -1)
                gravity = this.query.gravity;
            else
                throw new Error("Gravity must be one of #{JSON.stringify validGravity}");
        }

        var imageType = this.query.type;

        if (srcWidth > 4000 || srcHeight > 4000 || smallWidth > 4000 || smallHeight > 4000) {
            throw new Error("Invalid width or height setting #{srcWidth}, #{srcHeight}, #{smallWidth}, #{smallHeight}");
        }

        var typesService = services.get('types');
        var parser = new Parser(this, typesService);

        var files = yield* parser.files();

        var file, timestamp, extension, filename;
        var pathArr, src, dir;

        if (files.length) {
            file = files[0];
            timestamp = Date.now();
            extension = file.filename.split('.').pop().toLowerCase();

            //Validate the extension
            if (validExtensions.indexOf(extension) !== -1) {
                filename = randomizer.uniqueId(8) + "_" + timestamp + "." + extension;

                //copy to originals directory
                var original = fsutils.getRandomFilePath('original-images', filename);
                _ = yield* fsutils.copyFile(file.path, original);

                var image = fsutils.getRandomFilePath('images', filename);
                var smallImage = image.replace(/(.*)\//,"$1/small_");

                //resize
                _ = yield* resizeImage(original, image, { width: srcWidth, height: srcHeight, gravity: gravity, imageType: imageType });
                _ = yield* resizeImage(original, smallImage, { width: smallWidth, height: smallHeight, gravity: gravity, imageType: imageType });

                pathArr = image.split('/');
                filename = pathArr.pop();
                dir = pathArr.pop();
                src = "/public/images/" + dir + "/" + filename;

                pathArr = smallImage.split('/');
                filename = pathArr.pop();
                dir = pathArr.pop();
                var small = "/public/images/" + dir + "/" + filename;

                this.body = { src: src, small: small };
            }
        }
    };

    var auth = require('fora-app-auth-service');
    module.exports = { upload: auth({ session: 'any' }, upload) };

})();
