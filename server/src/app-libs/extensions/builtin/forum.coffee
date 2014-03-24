path = require 'path'

class Forum

    constructor: (@typeDefinition) ->
        
        
        
    init: ->*
        extDir = path.join conf.extensionsDir, 'forums', @typeDefinition.name
        @pages = require("#{extDir}/pages")
        @api = require("#{extDir}/api")
        @model = require("#{extDir}/model")
            
    
    
    getPages: ->*
        @pages
        
        
        
    getApi: ->*
        @api
        


    getModel: ->*
        @model
        
    
module.exports = Forum
