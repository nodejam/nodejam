path = require 'path'
conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
Q = require 'q'

class Controller        

    ensureSession: (args, fn) =>
        [req, res, next] = args 
        (Q.async =>
            token = if req.query('token') then req.query('token') else req.cookies('token')
            user = yield @getUserWithToken token
            if user.id
                req.user = user
                fn()
            else
                res.send { error: 'NO_SESSION' }
        )()



    attachUser: (args, fn) =>
        [req, res, next] = args
        (Q.async =>
            token = if req.query('token') then req.query('token') else req.cookies('token')
            user = yield @getUserWithToken token
            req.user = user
            fn()
        )()



    getUserWithToken: (token) =>
        (Q.async => 
            if token
                credentials = yield models.Credentials.get({ token }, {}, db)
                if credentials
                    user = yield credentials.getUser({}, db)
                    user?.summarize()                
                else
                    null
            else
                null)()
        

    
    isAdmin: (user) =>
        (u for u in conf.admins when u is user?.username).length        
                
                
        
    getValue: (src, field, safe = true) =>
        src[field]



    handleError: (onError) ->
        (fn) ->
            return ->
                if arguments[0]
                    onError arguments[0]
                else
                    fn.apply undefined, arguments
    
    
    
    setValues: (target, src, fields, options = {}) =>
    
        if not options.safe?
            options.safe = true
        if not options.ignoreEmpty
            options.ignoreEmpty = true

        setValue = (src, targetField, srcField) =>
            val = @getValue src, srcField, options.safe
            if options.ignoreEmpty
                if val?
                    target[field] = val
            else
                target[field] = val

        if fields.constructor == Array
            for field in fields
                setValue src, field, field
        else
            for ft, fsrc of fields
                setValue src, ft, fsrc
                


exports.Controller = Controller
