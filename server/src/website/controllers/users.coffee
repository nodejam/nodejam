Sandbox = require 'react-sandbox'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
utils = require '../../app-lib/utils'
auth = require '../../app-lib/web/auth'
fields = require '../../models/fields'
LoginView = require('../views/users/login').Login

exports.login = ->*
    token = yield models.Token.get { key: @query.key }, {}, db
    
    if token
        if token.type is 'twitter-login-token'
            credential = yield models.Credential.get { 'twitter.username': token.value.userDetails.username }, {}, db
            users = yield credential.link 'users'
        
        session = yield credential.createSession {}, db
        
        for user in users
            user.image = user.getAssetUrl() + "/" + user.username + "_t.jpg"
        
        if not users.length
            nickname = token.value.userDetails.username
        
        cover = {
            type: "fixed full-cover",
            image: { src: '/images/cover.jpg' },
        }
        coverContent = "<p>On the internet nobody knows you are a dog.</p>"

        component = LoginView { users, cover, coverContent, nickname, token: session.token }    
        
        yield @renderPage 'users/login', { 
            pageName: 'login-page',
            token: session.token,
            html: Sandbox.renderComponentToString component
        }
        
