path = require 'path'
co = require 'co'
conf = require '../../conf'
utils = require '../../lib/utils'
models = require '../../models'
ForaTypeUtils = require('../../models/foratypeutils')
typeUtils = new ForaTypeUtils()
Database = require '../../lib/data/database'
db = new Database(conf.db, typeUtils.getTypeDefinitions())

handler = ->
    if arguments.length is 1
        fn = arguments[0]
    else
        [options, fn] = arguments
    
    options ?= {}

    ->*
        token = @query.token ? @cookies.get('token')          
        
        if token
            @session = yield models.Session.get { token }, {}, db

        switch options.session
            when 'admin'                    
                if not @session or not @session.user
                    return @throw 'no session', 403
                else if not (u for u in conf.admins when u is @session.user.username).length > 0
                    return @throw 'not admin', 403                            
                @session.admin = true
            
            when 'credential', 'any'
                if not @session
                    return @throw 'no session', 403
                
            when 'user'
                if not @session or not @session.user
                    return @throw 'no session', 403
                    
        yield fn.apply @, arguments                
        

exports.handler = handler
