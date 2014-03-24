path = require 'path'
conf = require('../../../conf')
fs = require('fs')
thunkify = require('thunkify')

class Post

    constructor: (@typeDefinition) ->
        
        
        
    init: =>*
        extDir = path.join conf.extensionsDir, @typeDefinition.name
        @model = require("#{extDir}/model")
        
        @templates = {}
        files = yield thunkify(fs.readdir).call fs, "#{extDir}/templates"
        for file in files
            template = file.match /[a-z]*/
            @templates[template] = require("#{extDir}/templates/#{template}")
                    
            
    
    getTemplates: =>
        @templates
        
        
        
    getModel: =>
        @model
        
        
module.exports = Post
