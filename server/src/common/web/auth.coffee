path = require 'path'
co = require 'co'
conf = require '../../conf'
typeUtils = require('../../models/foratypeutils').typeUtils
Database = require '../../lib/data/database'
utils = require '../../lib/utils'
models = require '../../models'
db = new Database(conf.db, typeUtils.getTypeDefinitions())

handler = ->
    if arguments.length is 1
        fn = arguments[0]
    else
        [options, fn] = arguments
    options ?= {}
    ->*
        token = @query.token ? @cookies.get('token')                
        @session = {}
        if options.session or options.admin
            user = yield getUserWithToken token
            if user
                isAdmin = (u for u in conf.admins when u is user?.username).length > 0
                if options.admin and not isAdmin
                    throw new Error "NOT_ADMIN"
                else
                    @session.user = user
                    @session.admin = isAdmin
                    yield fn.apply @, arguments
            else
                throw new Error "NO_SESSION"
        else
            if token
                user = yield getUserWithToken token
                if user
                    @session.user = user
            yield fn.apply @, arguments



getUserWithToken = (token) ->*
    if token
        user = yield models.User.get({ token }, {}, db)
        user?.summarize()
    

exports.handler = handler
