Sandbox = require 'react-sandbox'
conf = require '../../conf'
db = require('../app').db
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../app-lib/web/auth'
fields = require '../../models/fields'
LoginView = require('../views/users/login')

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
        


exports.item = auth.handler (username) ->*
    user = yield models.User.get { username }, {}, db
    
    if user
        posts = yield user.getPosts 12, db.setRowId({}, -1)
        
        for post in posts
            template = widgets.parse yield post.getTemplate 'card'
            post.html = template.render {
                post,
                forum: post.forum,
            }

        coverContent = "
            <h1>#{user.name}</h1>"
            
        user.cover ?= new fields.Cover { image: new fields.Image { src: '/images/user-cover.jpg', small: '/images/user-cover-small.jpg', alt: user.name } }
        
        yield @renderPage 'forums/item', { 
            posts,
            user,            
            pageName: 'user-page',
            coverInfo: {
                cover: user.cover,
                content: coverContent
            }
        }
