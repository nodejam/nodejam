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
            picture: {
                src: yield @parser.body('picture_src'),
                small: yield @parser.body('picture_small'),
            },
            email: (yield @parser.body('email') ? 'unknown@foraproject.org'),
            about: yield @parser.body('about')
            lastLogin: Date.now(),
        }
    
        user = yield user.save {}, db
        @body = user.summarize {}, db
        


exports.login = auth.handler ->*    
    token = yield @parser.body('token')    
    
    session = yield models.Session.get { token }, {}, db
    if session
        session = yield session.upgrade yield @parser.body('username')
        
        user = session.user
        user.token = session.token
        
        @cookies.set "userId", user.id.toString(), { httpOnly: false }
        @cookies.set "username", user.username, { httpOnly: false }
        @cookies.set "fullName", user.name, { httpOnly: false }
        @cookies.set "token", session.token
        
        @body = user
    


exports.item = auth.handler (username) ->*
    user = yield models.User.get { username }, {}, db        
    if user
        @body = user.summarize {}, db

