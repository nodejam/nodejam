gm = require 'gm'
thunkify = require 'thunkify'
utils = require '../../lib/utils'
fsutils = require '../../common/fsutils'
auth = require '../../common/web/auth'


validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp']

exports.upload = auth.handler { session: true }, ->*
    files = yield @parser.files()
    if files.length    
        file = files[0]
        timestamp = Date.now()
        extension = file.originalFilename.split('.').pop().toLowerCase()
        #Validate the extension                
        if validExtensions.indexOf(extension) isnt -1
            filename = "#{utils.uniqueId(8)}_#{timestamp}.#{extension}"
            original = fsutils.getRandomFilePath filename, ['originalimages']
            image = fsutils.getRandomFilePath filename, ['images']
            smallImage = fsutils.getRandomFilePath "#small_#{filename}", ['images']
            yield thunkify(fsutils.copyFile).call file.path, original
            yield @resizeImage original, image, { width: 1600, height: 1600 }
            yield @resizeImage original, smallImage, { width: 400, height: 400 }
            @body = { src: "/public/images/#{dir}/#{filename}", small: "/pub/images/#{dir}/small_#{filename}" }
                    


exports.resizeImage = (src, dest, options, cb) ->*
    utils.log "Resizing #{src}..."
    img = gm(src).resize options.width
    yield thunkify(img.write).call img, dest
    utils.log "Resized #{src} to #{dest}"
