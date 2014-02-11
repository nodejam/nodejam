path = require 'path'
co = require 'co'
conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
utils = require '../../lib/utils'
models = require '../../models'

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
        credentials = yield models.Credentials.get({ token }, {}, db)
        if credentials
            user = yield credentials.link('user', {}, db)
            user?.summarize()
    

exports.handler = handler
