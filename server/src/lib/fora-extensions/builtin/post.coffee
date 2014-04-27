path = require 'path'
conf = require('../../../conf')
fs = require('fs')
thunkify = require('thunkify')

class Post

    constructor: (@typeDefinition, @loader) ->
        
        
        
    init: =>*
        extDir = path.join conf.extensionsDir, @typeDefinition.name
        @model = require("#{extDir}/model")
        
        @templateModules = {}
        @templateSource = {}
        files = yield thunkify(fs.readdir).call fs, "#{extDir}/templates"
        for file in files
            template = file.match /[a-z]*/
            @templateModules[template] = require "#{extDir}/templates/#{template}"
            @templateSource[template] = fs.readFileSync "#{extDir}/templates/#{template}.js"
            
    
    getModel: =>*
        @model
        
        
        
    getTemplateModule: (name) =>*
        @templateModules[name]
    
    
    
    getClientScript: (name) =>*
        @templateSource[name]        
        
        
module.exports = Post
