path = require 'path'
fs = require 'fs'
utils = require '../lib/utils'
conf = require '../conf'

conf = ->
    require '../conf'


dirsAreValid = (dirs) ->
    regex = /[a-zA-z0-9][a-zA-z0-9\-]*/
    if dirs instanceof Array
        for d in dirs
            if not regex.test d
                return false
        return true
    

filenameIsValid = (file) ->
    #At the moment we allow only abcdef.xyz
    /[a-zA-z0-9][a-zA-z0-9\-]*\.[a-zA-z]{3}/.test file


getDirPath = (dirs, options) ->
    if ['assets', 'images', 'originalimages'].indexOf(dirs[0]) > -1
        if dirsAreValid(dirs)
            path.join.apply null, [conf().pubdir].concat dirs        
        else
            console.log "Invalid directory"
    else
        console.log "dir[0] must be one of assets, images or originalimages"


getRandomFilePath = (file, dirs, options) ->
    random = Date.now() % conf.userDirCount
    if ['assets', 'images', 'originalimages'].indexOf dirs[0] > -1 and dirsAreValid(dirs) and filenameIsValid(file)
        path.join.apply null, [conf().pubdir].concat(dirs).concat(file)
        

copyFile = (src, dest, cb) ->
    src = fs.createReadStream src
    dest = fs.createWriteStream dest
    src.pipe dest
    src.on 'end', cb
    src.on 'error', cb 


formatDate = (date = new Date()) ->
    year = date.getFullYear()
    month = if date.getMonth() < 9 then "0#{date.getMonth() + 1}" else "#{date.getMonth() + 1}"
    dayNum = if date.getDate() < 10 then "0#{date.getDate()}" else "#{date.getDate()}"
    "#{year}-#{month}-#{dayNum}"


exports.formatDate = formatDate
exports.getDirPath = getDirPath
exports.getRandomFilePath = getRandomFilePath
exports.copyFile = copyFile

