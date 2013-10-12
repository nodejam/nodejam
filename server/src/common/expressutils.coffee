express = require 'express'
utils = require './utils'
validator = require 'validator'
conf = require '../conf'


sanitize = (sources, options) ->
    if not options?.skip
        for inputs in sources
            if inputs
                for key, val of inputs
                    if not options?.exclude?.indexOf(key) isnt -1
                        val = inputs[key]
                        if typeof(val) is 'string'
                            if (not options?.allowHtml is '*') or (not options?.allowHtml?.indexOf(key) isnt -1)
                                val = val.replace '<', '&lt;'
                                val = val.replace '>', '&gt;'                    
                            inputs[key] = validator.sanitize(val).xss()



errorHandler = (err, req, res, next) ->
    utils.dumpError err
    res.send(500, { error: err.message })
    process.exit()



http404 = (req, res, next) ->
    res.status 404
    res.render('404', { url: req.url });
    res.send(404, { error: 'HTTP 404. There is no water here.' })
    
###
    A safe wrapper around the request, to hide access to query, params and body.
    This allows us to sanitize those fields when requested.    
###
class RequestWrapper

    constructor: (@raw) ->
        @headers = @raw.headers
    
    
    getParameter: (src, name, type = 'string') =>
        @raw[src][name]
        
    
    params: (name, type) ->
        @getParameter 'params', name, type
        
    
    query: (name, type) ->
        @getParameter 'query', name, type


    body: (name, type) ->
        @getParameter 'body', name, type
    
    
    files: (name) ->
        @getParameter 'files', name
    


setup = (app, getController, cb) ->

    getNetwork = (hostName) ->    
        matches = (n for n in conf.networks when n.domains.indexOf(hostName) isnt -1)
        if matches.length then matches[0]
    
    app.use express.bodyParser {
        uploadDir:'../../www-user/temp',
        limit: '6mb'
    }
    
    app.use express.limit '6mb'
    app.use express.cookieParser()
    #app.use validate
    
    cb (name, getHandler) ->
        controller = getController name
        handler = getHandler(controller)
        
        (req, res, next) ->
            #req = new RequestWrapper _req
            
            network = getNetwork req.headers.host
            if network
                req.network = network
                handler(req, res, next)
            else            
                next new Error 'Invalid Network'
    
    app.use(app.router)
    app.use errorHandler
    app.use http404

    

exports.setup = setup    
    
