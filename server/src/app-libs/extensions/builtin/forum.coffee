path = require 'path'
conf = require('../../../conf')
fs = require('fs')
thunkify = require('thunkify')
pathToRegexp = require 'path-to-regexp'

class Forum

    
    class PagesContext

        routingTable: []
    
        add: ->
            if arguments.length is 3
                [url, method, handler] = arguments
            else
                [url, handler] = arguments
                method = 'get'
            
            method = method.toUpperCase()
            re = pathToRegexp(url)
            @routingTable.push { url, re, method, handler }
    
    
    class Router
        
        constructor: (@context) ->

        handle: (req) ->*
            for route in @context.pages.routingTable
                if route.method isnt req.context.request.method
                    continue
            
                m = route.re.exec(req.context.request.url)
                if m
                    args = m.slice(1)
                    yield route.handler.apply [context].concat args
                    return            
     

    constructor: (@typeDefinition) ->
        
        
        
    init: =>*
        extDir = path.join conf.extensionsDir, @typeDefinition.name
        
        pages = require("#{extDir}/pages")
        context = {
            pages: new PagesContext()
        }
        yield pages.init context
        @pages = new Router context
        
        @model = require("#{extDir}/model")
            
    
    
    getPages: =>*
        @pages
        
        
        
    getApi: =>*
        throw new Error 'not implemented'
        


    getModel: =>*
        @model
        
    
    
module.exports = Forum
