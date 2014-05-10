path = require 'path'
conf = require('../../../conf')
fs = require('fs')
thunkify = require('thunkify')
pathToRegexp = require 'path-to-regexp'

class Forum

    
    class Routes

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
        
        constructor: (@routes, @loader) ->


        handle: (context) =>*
            context.api = {
                extensionLoader: @loader
            }
            
            for route in @routes.pages.routingTable
                if route.method isnt context.client.request.method
                    continue
            
                url = context.client.request.url.split('/').slice(2).join("/")
                m = route.re.exec url
                if m
                    args = m.slice(1)
                    result = yield route.handler.apply context, args
                    return result
                    

    constructor: (@typeDefinition, @loader) ->
        
        
        
    init: =>*
        extDir = path.join conf.extensionsDir, @typeDefinition.name

        extensionSetup = {
            routes: {
                pages: new Routes()
            }
        }

        pages = require("#{extDir}/pages")
        yield pages.init.call extensionSetup
        @pages = new Router extensionSetup.routes, @loader
        
        if fs.existsSync "#{extDir}/model.js"
            @model = require("#{extDir}/model")

        @templateModules = {}
        @templateSource = {}
        files = yield thunkify(fs.readdir).call fs, "#{extDir}/templates"
        for file in files
            template = file.match /[a-z]*/
            @templateModules[template] = require "#{extDir}/templates/#{template}"
            @templateSource[template] = fs.readFileSync "#{extDir}/templates/#{template}.js"

    
    
    getPages: =>*
        @pages
        
        
        
    getApi: =>*
        throw new Error 'not implemented'
        


    getModel: =>*
        @model
        


    getTemplateModule: (name) =>*
        @templateModules[name]
    
    
    
    getClientScript: (name) =>*
        @templateSource[name]           
        
    
    
module.exports = Forum
