Q = require '../lib/q'
utils = require '../lib/utils'
fsutils = require './fsutils'
url = require 'url'
fs = require 'fs-extra'
gm = require 'gm'
exec = require('child_process').exec
spawn = require('child_process').spawn


downloadImage = (imageUrl) ->
    (Q.async ->
        parseResult = url.parse imageUrl
        hostArr = parseResult.hostname?.split '.'
        extension = parseResult.pathname.split('/').pop().split('.').pop()
        filename = "#{utils.uniqueId(8)}_#{Date.now()}.#{extension.toLowerCase()}"
        
        if ['jpg', 'jpeg', 'png', 'gif', 'bmp'].indexOf(extension.toLowerCase()) is -1
            utils.log "Cannot download image. Invalid file extension in #{imageUrl}."

        filePath = fsutils.getFilePath "temp", filename
        
        _curl = "curl --proto =http,https --proto-redir =http,https --max-filesize 5000000 " + imageUrl + " > #{filePath}"
        yield Q.nfcall exec, _curl

        utils.log "Downloaded #{imageUrl} to #{filePath}"            
        filePath
    )()
    
exports.downloadImage = downloadImage
