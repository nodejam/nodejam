path = require 'path'
fs = require 'fs'
utils = require './utils'

conf = ->
    require '../conf'


dirIsValid = (dir) ->
    not /(^\/|[~.])/.test dir


fileIsValid = (file) ->
    not /(\.\.|~|\/)/.test file


getTempBasePath = ->    
    path.join conf().pubdir, 'temp'
    

getAssetBasePath = ->
    path.join conf().pubdir, 'assetpaths'


getTempFilePath = (filename) ->
    if fileIsValid filename
        path.join conf().pubdir, "temp", filename 


getDateFormattedDir = (date) ->
    date = new Date(date)
    year = date.getFullYear()
    month = if date.getMonth() < 9 then "0#{date.getMonth() + 1}" else "#{date.getMonth() + 1}"
    dayNum = if date.getDate() < 10 then "0#{date.getDate()}" else "#{date.getDate()}"
    "#{year}-#{month}-#{dayNum}"


getAssetFilePath = (assetUrl, filename) ->
    dir = assetUrl.split('/').pop()
    if dirIsValid(dir) and fileIsValid(filename)
        path.join(getAssetBasePath(), dir, filename)

    
exports.getTempBasePath = getTempBasePath
exports.getAssetBasePath = getAssetBasePath
exports.getTempFilePath = getTempFilePath
exports.getDateFormattedDir = getDateFormattedDir
exports.getAssetFilePath = getAssetFilePath



