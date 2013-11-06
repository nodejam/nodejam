path = require 'path'
fs = require 'fs'
utils = require '../lib/utils'

conf = ->
    require '../conf'


dirIsValid = (dir) ->
    not /(^\/|[~.])/.test dir


fileIsValid = (file) ->
    not /(\.\.|~|\/)/.test file


filePathIsValid = (filePath) ->
    not /(\.\.|~|^\/)/.test filePath


getBasePath = (name) ->
    if ['images', 'originalimages', 'temp', 'assetpaths'].indexOf(name) > -1
        path.join conf().pubdir, name    


getFilePath = (base, file) ->
    basePath = getBasePath base
    if basePath and filePathIsValid(file)
        path.join basePath, file


getRandomDir = ->
    Date.now() % 1000


getDateFormattedDir = (date = new Date()) ->
    year = date.getFullYear()
    month = if date.getMonth() < 9 then "0#{date.getMonth() + 1}" else "#{date.getMonth() + 1}"
    dayNum = if date.getDate() < 10 then "0#{date.getDate()}" else "#{date.getDate()}"
    "#{year}-#{month}-#{dayNum}"


copyFile = (src, dest, cb) ->
    src = fs.createReadStream src
    dest = fs.createWriteStream dest
    src.pipe dest
    src.on 'end', cb
    src.on 'error', cb 
    

exports.getBasePath = getBasePath
exports.getFilePath = getFilePath

exports.getRandomDir = getRandomDir
exports.getDateFormattedDir = getDateFormattedDir

exports.copyFile = copyFile

