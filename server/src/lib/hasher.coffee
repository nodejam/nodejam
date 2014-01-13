crypto = require 'crypto'

hasher = (opts, callback) ->
    # Generate a random 8-character base64 password if none provided
    if not opts.plaintext
        return crypto.randomBytes 6, (err, buf) ->
            if err
                callback err
            else
                opts.plaintext = buf.toString 'base64'
                hasher opts, callback
    # Generate random 512-bit salt if no salt provided
    if not opts.salt
        return crypto.randomBytes 64, (err, buf) ->
            if err
                callback err 
            else
                opts.salt = buf
                hasher opts, callback
    # Node.js PBKDF2 forces sha1
    opts.iterations = opts.iterations ? 10000
    crypto.pbkdf2 opts.plaintext, opts.salt, opts.iterations, 64, (err, key) ->
        if err        
            callback err
        else
            opts.key = new Buffer(key)
            callback null, opts
    
module.exports = hasher
