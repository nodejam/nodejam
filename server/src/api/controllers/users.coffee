shttps = require 'https'
co = require 'co'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'

    
exports.create = auth.handler ->*

    token = yield @parser.body('token')

    session = yield models.Session.get { token }, {}, db
    if session

        user = new models.User {
            username: yield @parser.body('username'),
            credentialId: session.credentialId,
            name: yield @parser.body('name'),
            location: yield @parser.body('location'),
            picture: yield @parser.body('picture'),
            thumbnail: yield @parser.body('thumbnail'),
            email: (yield @parser.body('email') ? 'unknown@foraproject.org'),
            about: yield @parser.body('about')
            lastLogin: Date.now(),
        }
    
        user = yield user.save {}, db
        session = yield user.upgradeSession session, {}, db

        @body = { id: db.getRowId(user), username: user.username, name: user.name, assets: user.assets, token: session.token }
        


exports.item = auth.handler (username) ->*
    user = yield models.User.get { username }, {}, db        
    if user
        @body = user.summarize {}, db
        


