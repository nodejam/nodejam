conf = require '../../conf'
db = require('../app').db
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'
fields = require '../../models/fields'
widgets = require '../../common/widgets'


exports.loginForm = ->*
    token = yield models.Token.get { key: @query.token }, {}, db
    
    if token
        if token.type is 'twitter-login-token'
            credential = yield models.Credential.get { 'twitter.username': token.value.userDetails.username }, {}, db
            users = yield credential.link 'users'
        
        for user in users
            user.image = user.getAssetUrl() + "/" + user.username + "_t.jpg"
        
        if not users.length
            nickname = token.value.userDetails.username
        
        yield @renderPage 'users/login', {
            pageName: 'login-page', 
            users,
            nickname,
            token: token.key
        }
        
        yield token.destroy()



exports.selectUsername = ->*
    token = yield models.Token.get({ key: @query('token') }, {}, db)     
    token.value.userDetails.username = yield @parser.body 'username'
    token.value.userDetails.name = yield @parser.body 'name'
    token.value.userDetails.email = yield @parser.body 'email'
    result = yield models.User.create(token.value.userDetails, token.value.credentials, {}, db)
    if result?.success isnt false
        res.clearCookie "twitter_oauth_process_key"
        res.cookie "userId", db.getRowId(result.user)
        res.cookie "username", result.user.username
        res.cookie "fullName", result.user.name
        res.cookie "assets", result.user.assets
        res.cookie "token", result.token
        res.redirect "/"
    else
        next new Error "Could not save user"
        
    token.destroy {}, db       
    
    
    
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
