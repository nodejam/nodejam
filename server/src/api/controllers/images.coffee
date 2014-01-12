conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
fsutils = require '../../common/fsutils'
fs = require 'fs-extra'
gm = require 'gm'
auth = require '../../common/web/auth'

exports.upload = auth.handler { session: true }, ->*
    req.files (err, files) =>
        file = files.file[0]
        if not err
            timestamp = Date.now()
            extension = file.originalFilename.split('.').pop().toLowerCase()
            #Validate the extension                
            if ['jpg', 'jpeg', 'png', 'gif', 'bmp'].indexOf(extension) is -1
                next new AppError "Invalid file extension", "INVALID_FILE_EXTENSION"
            else
                try
                    dir = fsutils.getRandomDir()                        
                    filename = "#{utils.uniqueId(8)}_#{timestamp}.#{extension}"
                    original = fsutils.getFilePath 'originalimages', "#{dir}/#{filename}"
                    image = fsutils.getFilePath 'images', "#{dir}/#{filename}"
                    smallImage = fsutils.getFilePath 'images', "#{dir}/small_#{filename}"
                    fsutils.copyFile file.path, original, (err) =>
                        @resizeImage original, image, { width: 1600, height: 1600 }, (err) =>
                            @resizeImage original, smallImage, { width: 400, height: 400 }, (err) =>
                                res.set 'Content-Type', 'text/html'
                                res.send { image: "/public/images/#{dir}/#{filename}", small: "/pub/images/#{dir}/small_#{filename}" }
                catch e
                    next e
        else
            res.send "error"
                    


exports.resizeImage = (src, dest, options, cb) ->*
    utils.log "Resizing #{src}..."
    gm(src).size (err, size) =>
        gm(src).resize(options.width).write dest, (err) =>
            utils.log "Resized #{src} to #{dest}"
            cb()
