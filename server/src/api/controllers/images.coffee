gm = require 'gm'
thunkify = require 'thunkify'
utils = require '../../lib/utils'
fsutils = require '../../common/fsutils'
auth = require '../../common/web/auth'


validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp']

exports.upload = auth.handler { session: 'any' }, ->*
    if @query.src_size
        [srcWidth, srcHeight] = (parseInt(x) for x in @query.src_size.split('x'))

    if @query.small_size
        [smallWidth, smallHeight] = (parseInt(x) for x in @query.small_size.split('x'))
    
    #validations
    if @query.gravity
        validGravity = ['center']
        if validGravity.indexOf(@query.gravity) isnt -1
            utils.log "Gravity must be one of #{JSON.stringify validGravity}"
            return
        else
            gravity = @query.gravity
    
    if srcWidth > 4000 or srcHeight > 4000 or smallWidth > 4000 or smallHeight > 4000
        utils.log "Invalid width or height setting #{srcWidth}, #{srcHeight}, #{smallWidth}, #{smallHeight}"
        return
            
    files = yield @parser.files()
    if files.length    
        file = files[0]
        timestamp = Date.now()
        extension = file.filename.split('.').pop().toLowerCase()
        #Validate the extension                
        if validExtensions.indexOf(extension) isnt -1
            filename = "#{utils.uniqueId(8)}_#{timestamp}.#{extension}"
            
            #copy to originals directory
            original = fsutils.getRandomFilePath 'original-images', filename, 
            yield thunkify(fsutils.copyFile).call null, file.path, original

            image = fsutils.getRandomFilePath 'images', filename
            smallImage = fsutils.getRandomFilePath 'images', "small_#{filename}"

            #resize
            yield resizeImage original, image, { width: srcWidth, height: srcHeight, gravity }
            yield resizeImage original, smallImage, { width: smallWidth, height: smallHeight, gravity }

            [x..., dir, filename] = image.split '/'
            src = "/public/images/#{dir}/#{filename}"

            [x..., dir, filename] = smallImage.split '/'
            small = "/public/images/#{dir}/#{filename}"
            
            @body = { src, small }
                    


resizeImage = (src, dest, options, cb) ->*
    utils.log "Resizing #{src}..."
    img = gm(src)
    if options.gravity
        img = img.gravity(options.gravity)
    img.resize(options.width, options.height)    
    yield thunkify(img.write).call img, dest
    utils.log "Resized #{src} to #{dest}"
    
