path = require 'path'
fs = require 'fs'
utils = require './utils'

dirIsValid = (dir) ->
    not /(^\/|[~.])/.test dir


fileIsValid = (file) ->
    not /(\.\.|~|\/)/.test file


pubdir = path.resolve __dirname, '../../www-user'
tempBasePath = path.join pubdir, 'temp'
assetBasePath = path.join pubdir, 'assetpaths'


getTempFilePath = (filename) ->
    if fileIsValid filename
        path.join pubdir, "temp", filename 


getDateFormattedDir = (date) ->
    date = new Date(date)
    year = date.getFullYear()
    month = if date.getMonth() < 9 then "0#{date.getMonth() + 1}" else "#{date.getMonth() + 1}"
    dayNum = if date.getDate() < 10 then "0#{date.getDate()}" else "#{date.getDate()}"
    "#{year}-#{month}-#{dayNum}"


getAssetFilePath = (assetUrl, filename) ->
    dir = assetUrl.split('/').pop()
    if dirIsValid(dir) and fileIsValid(filename)
        path.join(assetBasePath, dir, filename)

exports.tempBasePath = tempBasePath       
exports.assetBasePath = assetBasePath       

exports.getDateFormattedDir = getDateFormattedDir
exports.getTempFilePath = getTempFilePath
exports.getAssetFilePath = getAssetFilePath
