path = require 'path'
fs = require 'fs'
thunkify = require 'thunkify'
conf = require '../conf'


dirsAreValid = (dirs) ->
    regex = /[a-zA-z0-9][a-zA-z0-9_\-]*/
    if dirs instanceof Array
        for d in dirs
            if not regex.test d
                return false
        return true

    

filenameIsValid = (file) ->
    #At the moment we allow only abcdef.xyz
    /[a-zA-z0-9][a-zA-z0-9_\-]*\.[a-zA-z]{3}/.test file



getDirPath = (dir, subdir) ->
    if dirsAreValid [dir, subdir]    
        if ['assets', 'images', 'original-images'].indexOf(dir) > -1
            if not isNaN parseInt(subdir) 
                return path.join.apply null, [conf.pubdir].concat [dir, subdir]
    
    throw new Error "Invalid directory #{dir}/#{subdir}"



getFilePath = (dir, subdir, file) ->
    if dirsAreValid([dir, subdir]) and filenameIsValid(file)
        if ['assets', 'images', 'original-images'].indexOf(dir) > -1
            if not isNaN parseInt(subdir)
                return path.join.apply null, [conf.pubdir].concat [dir, subdir, file]

    throw new Error "Invalid path #{dir}/#{subdir}/#{file}"
    


getRandomFilePath = (dir, file) ->
    if dirsAreValid([dir]) and filenameIsValid(file)
        random = (Date.now() % conf.userDirCount).toString()
        if ['assets', 'images', 'original-images'].indexOf(dir) > -1
            return path.join.apply null, [conf.pubdir].concat [dir, random, file]

    throw new Error "Invalid path #{dir}/#{file}"
            


copyFile = (src, dest) ->*
    src = fs.createReadStream src
    dest = fs.createWriteStream dest
    src.pipe dest
    yield thunkify(src.on).call src, 'end'



formatDate = (date = new Date()) ->
    year = date.getFullYear()
    month = if date.getMonth() < 9 then "0#{date.getMonth() + 1}" else "#{date.getMonth() + 1}"
    dayNum = if date.getDate() < 10 then "0#{date.getDate()}" else "#{date.getDate()}"
    "#{year}-#{month}-#{dayNum}"



exports.formatDate = formatDate
exports.getDirPath = getDirPath
exports.getFilePath = getFilePath
exports.getRandomFilePath = getRandomFilePath
exports.copyFile = copyFile

