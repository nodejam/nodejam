path = require 'path'
conf = require('../../../conf')
fs = require('fs')
thunkify = require('thunkify')
pathToRegexp = require 'path-to-regexp'

class Forum

    
    class PagesContext

        constructor: ->
            @routingTable = []
            
    
        add: =>
            if arguments.length is 3
                [url, method, handler] = arguments
            else
                [url, handler] = arguments
                method = 'GET'
            
            method = method.toUpperCase()
            re = pathToRegexp(url)
            @routingTable.push { url, re, method, handler }
    
    
    class Router
        
        constructor: (@context, @loader) ->


        handle: (req) =>*
            req.api = {
                extensionLoader: @loader
            }
            
            for route in @context.pages.routingTable
                if route.method isnt req.context.request.method
                    continue
            
                url = req.context.request.url.split('/').slice(2).join("/")
                m = route.re.exec url
                if m
                    args = m.slice(1)
                    result = yield route.handler.apply req, args
                    return result
                    

    constructor: (@typeDefinition, @loader) ->
        
        
        
    init: =>*
        extDir = path.join conf.extensionsDir, @typeDefinition.name
        pages = require("#{extDir}/pages")
        context = {
            pages: new PagesContext()
        }
        yield pages.init.call context
        @pages = new Router context, @loader
        
        if fs.existsSync "#{extDir}/model.js"
            @model = require("#{extDir}/model")

    
    
    getPages: =>*
        @pages
        
        
        
    getApi: =>*
        throw new Error 'not implemented'
        


    getModel: =>*
        @model
        
    
    
module.exports = Forum
