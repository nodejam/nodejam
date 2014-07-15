url = require 'url'
fs = require 'fs-extra'
gm = require 'gm'
thunkify = require 'thunkify'
logger = require './logger'
randomizer = require './randomizer'
fsutils = require './fsutils'
exec = require('child_process').exec
spawn = require('child_process').spawn


downloadImage = (imageUrl) ->*
    parseResult = url.parse imageUrl
    hostArr = parseResult.hostname?.split '.'
    extension = parseResult.pathname.split('/').pop().split('.').pop()
    filename = "#{randomizer.uniqueId(8)}_#{Date.now()}.#{extension.toLowerCase()}"

    if ['jpg', 'jpeg', 'png', 'gif', 'bmp'].indexOf(extension.toLowerCase()) is -1
        logger.log "Cannot download image. Invalid file extension in #{imageUrl}."

    filePath = fsutils.getFilePath "temp", filename

    _curl = "curl --proto =http,https --proto-redir =http,https --max-filesize 5000000 " + imageUrl + " > #{filePath}"

    exec = thunkify exec
    yield exec _curl

    logger.log "Downloaded #{imageUrl} to #{filePath}"
    filePath

exports.downloadImage = downloadImage
