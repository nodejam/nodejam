express = require 'express'
utils = require './utils'
validator = require 'validator'
conf = require '../conf'
ExpressRequestWrapper = require('./expressrequestwrapper').ExpressRequestWrapper

errorHandler = (err, req, res, next) ->
    utils.printError err
    res.send(500, { error: err.message })
    process.exit()



http404 = (req, res, next) ->
    res.status 404
    res.render('404', { url: req.url });
    res.send(404, { error: 'HTTP 404. There is no water here.' })
    


setup = (config, cb) ->
    { app, getController, typeUtils } = config
    
    app.use express.json()
    app.use express.urlencoded()
    app.use express.cookieParser()
    
    getNetwork = (hostName) ->    
        matches = (n for n in conf.networks when n.domains.indexOf(hostName) isnt -1)
        if matches.length then matches[0]
    
    cb (name, getHandler) ->
        controller = getController name
        handler = getHandler(controller)
        
        (_req, res, next) ->
            req = new ExpressRequestWrapper _req, typeUtils
            
            network = getNetwork req.headers.host
            if network
                req.network = network
                handler(req, res, next)
            else            
                next new Error 'Invalid Network'
    
    app.use app.router
    app.use errorHandler
    app.use http404

    

exports.setup = setup    
    
