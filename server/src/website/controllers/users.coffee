React = require 'fora-react-sandbox'
LoginView = require('../views/users/login')

module.exports = ({typeService, models, fields, db, conf, auth, mapper, loader }) -> {
    login: ->*
        token = yield* models.Token.get { key: @query.key }, {}, db
        
        if token
            if token.type is 'twitter-login-token'
                credential = yield* models.Credential.get { 'twitter.username': token.value.userDetails.username }, {}, db
                users = yield* credential.link 'users'
            
            session = yield* credential.createSession {}, db
            
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
            
            yield* @renderPage 'users/login', { 
                pageName: 'login-page',
                token: session.token,
                html: React.renderComponentToString component
            }
}
