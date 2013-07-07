conf = require '../../conf'
models = new (require '../../models').Models(conf.db)
AppError = require('../../common/apperror').AppError


class Controller        

    ensureSession: (args, fn) =>
        [req, res, next] = args 
        @getUserWithPasskey (req.query.passkey ? req.cookies.passkey), req.network, (err, user) =>
            if user?.id and user?.domain and user?.username
                req.user = user
                fn()
            else
                res.send { error: 'NO_SESSION' }



    attachUser: (args, fn) ->
        [req, res, next] = args
        @getUserWithPasskey (req.query.passkey ? req.cookies.passkey), req.network, (err, user) =>
            req.user = user ? { id: 0 }
            fn()



    getUserWithPasskey: (passkey, network, cb) ->
        if passkey
            models.Session.get { passkey, network: network.stub }, {}, (err, session) =>
                if not err
                    if session
                        models.User.getById session.userid, {}, (err, user) =>
                            user = user?.summarize()
                            cb err, user
                    else
                        cb()
                else
                    cb err
        else                
            cb()


    
    isSameUser: (user1, user2) =>
        user1.domain is user2.domain and user1.username is user2.username and user1.network is user2.network



    isAdmin: (user, network) =>
        (u for u in network.admins when u.username is user?.username and u.domain is user?.domain).length        
                
        
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
