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
        if options.session or options.admin
            user = yield getUserWithToken token
            if user.id
                isAdmin = (u for u in conf.admins when u is user?.username).length > 0
                if options.admin and not isAdmin
                    throw new Error "NOT_ADMIN"
                else
                    @session = { user }
                    @session.admin = isAdmin
                    yield fn.apply @, arguments
            else
                throw new Error "NO_SESSION"
        else
            if token
                user = yield getUserWithToken token
                if user.id
                    @session = { user }
            yield fn.apply @, arguments



getUserWithToken = (token) ->*
    if token
        credentials = yield models.Credentials.get({ token }, {}, db)
        if credentials
            user = yield credentials.getUser({}, db)
            user?.summarize()
    

exports.handler = handler
