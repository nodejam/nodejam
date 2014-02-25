shttps = require 'https'
co = require 'co'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'

    
exports.create = auth.handler ->*

    user = new models.User {
        username: yield @parser.body('username'),
        credentialId: yield @parser.body('credentialId'),
        name: yield @parser.body('name'),
        location: yield @parser.body('location'),
        picture: yield @parser.body('picture'),
        thumbnail: yield @parser.body('thumbnail'),
        email: (yield @parser.body('email') ? 'unknown@foraproject.org'),
        about: yield @parser.body('about')
        lastLogin: Date.now(),
    }
    
    user = yield user.save {}, db    
    session = yield user.updateSession {}, db

    @body = { id: user._id, username: user.username, name: user.name, assets: user.assets, token: session.token }
    


