gm = require 'gm'
thunkify = require 'thunkify'
logger = require '../../lib/logger'
randomizer = require '../../lib/randomizer'
fsutils = require '../../lib/fsutils'
validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp']

module.exports = ({typeUtils, models, fields, db, conf, auth, mapper, loader }) -> {
    upload: auth.handler { session: 'any' }, ->*
        if @query.src_size
            [srcWidth, srcHeight] = (parseInt(x) for x in @query.src_size.split('x'))

        if @query.small_size
            [smallWidth, smallHeight] = (parseInt(x) for x in @query.small_size.split('x'))
        
        #validations
        if @query.gravity
            validGravity = ['Center']
            if validGravity.indexOf(@query.gravity) isnt -1
                gravity = @query.gravity
            else
                logger.log "Gravity must be one of #{JSON.stringify validGravity}"
                return
                
        
        if @query.type
            imageType = @query.type
        
        if srcWidth > 4000 or srcHeight > 4000 or smallWidth > 4000 or smallHeight > 4000
            logger.log "Invalid width or height setting #{srcWidth}, #{srcHeight}, #{smallWidth}, #{smallHeight}"
            return
                
        files = yield @parser.files()
        
        if files.length    
            file = files[0]
            timestamp = Date.now()
            extension = file.filename.split('.').pop().toLowerCase()
            #Validate the extension                
            if validExtensions.indexOf(extension) isnt -1
                filename = "#{randomizer.uniqueId(8)}_#{timestamp}.#{extension}"
        
                #copy to originals directory
                original = fsutils.getRandomFilePath 'original-images', filename
                yield fsutils.copyFile file.path, original
        
                image = fsutils.getRandomFilePath 'images', filename
                smallImage = image.replace /(.*)\//,"$1/small_"

                #resize
                yield resizeImage original, image, { width: srcWidth, height: srcHeight, gravity, imageType }
                yield resizeImage original, smallImage, { width: smallWidth, height: smallHeight, gravity, imageType }

                [x..., dir, filename] = image.split '/'
                src = "/public/images/#{dir}/#{filename}"

                [x..., dir, filename] = smallImage.split '/'
                small = "/public/images/#{dir}/#{filename}"
                
                @body = { src, small }
}                    


resizeImage = (src, dest, options) ->*
        utils.log "Resizing #{src}..."
        img = gm(src)

        if options.gravity
            img = img.gravity(options.gravity)
        
        switch options.imageType
            when 'thumbnail'
                img = img.resize(options.width, options.height + "^")
                img = img.crop options.width, options.height
            else
                img = img.resize(options.width, options.height)    
        
        yield thunkify(img.write).call img, dest
        utils.log "Resized #{src} to #{dest} [#{JSON.stringify options}]"
        
