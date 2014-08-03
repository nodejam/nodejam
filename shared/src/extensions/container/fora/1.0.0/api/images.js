(function() {
    "use strict";

    var gm = require 'gm'
        thunkify = require 'fora-node-thunkify',
        logger = require '../../lib/logger',
        randomizer = require '../../lib/randomizer',
        fsutils = require '../../lib/fsutils',
        validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];

    module.exports = function(params) {
        var typeService = params.typeService,
            models = params.models,
            db = params.db,
            conf = params.conf,
            auth = params.auth,
            mapper = params.mapper,
            loader = params.loader;

        var resizeImage = function*(src, dest, options) {
            logger.log("Resizing #{src}...");
            var img = gm(src);

            if (options.gravity)
                img = img.gravity(options.gravity);

            switch(options.imageType) {
                case 'thumbnail':
                    img = img.resize(options.width, options.height + "^");
                    img = img.crop options.width, options.height;
                    break;
                default:
                    img = img.resize(options.width, options.height);
            }

            yield* thunkify(img.write).call(img, dest);
            logger.log("Resized #{src} to #{dest} [#{JSON.stringify options}]");
        };

        var upload = function*() {
            if(this.query.src_size) {
                var srcArr = this.query.src_size.split('x').map(parseInt);
                var srcWidth = srcArr[0];
                var srcHeight = srcArr[1];
            }

            if(this.query.small_size) {
                var smallArr = this.query.src_size.split('x').map(parseInt);
                var smallWidth = smallArr[0];
                var smallHeight = smallArr[1];
            }

            //validate
            if(this.query.gravity) {
                var validGravity = ['Center'];
                if (validGravity.indexOf(this.query.gravity) !== -1)
                    gravity = this.query.gravity;
                else
                    throw new Error("Gravity must be one of #{JSON.stringify validGravity}");
            }

            if(this.query.type)
                var imageType = this.query.type

            if (srcWidth > 4000 || srcHeight > 4000 || smallWidth > 4000 || smallHeight > 4000) {
                throw new Error("Invalid width or height setting #{srcWidth}, #{srcHeight}, #{smallWidth}, #{smallHeight}");
            }

            var files = yield* this.parser.files();

            if (files.length) {
                var file = files[0]
                var timestamp = Date.now()
                var extension = file.filename.split('.').pop().toLowerCase()

                //Validate the extension
                if (validExtensions.indexOf(extension) !== -1) {
                    var filename = "#{randomizer.uniqueId(8)}_#{timestamp}.#{extension}"

                    //copy to originals directory
                    var original = fsutils.getRandomFilePath('original-images', filename);
                    yield* fsutils.copyFile(file.path, original);

                    var image = fsutils.getRandomFilePath('images', filename);
                    var smallImage = image.replace(/(.*)\//,"$1/small_");

                    //resize
                    yield* resizeImage(original, image, { width: srcWidth, height: srcHeight, gravity, imageType });
                    yield* resizeImage(original, smallImage, { width: smallWidth, height: smallHeight, gravity, imageType });

                    var pathArr = image.split('/');
                    var filename = pathArr.pop();
                    var dir = pathArr.pop();
                    var src = "/public/images/" + dir + "/" + filename;

                    pathArr = smallImage.split('/');
                    filename = pathArr.pop();
                    dir = pathArr.pop();
                    var small = "/public/images/" + dir + "/" + filename

                    this.body = { src: src, small: small };
                }
            }
        };

        return { upload: auth.handler({ session: 'any' }, upload) };
    };
})();
