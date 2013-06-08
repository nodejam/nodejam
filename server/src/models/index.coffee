Session = require('./session').Session
User = require('./user').User
Post = require('./post').Post
Forum = require('./forum').Forum
Token = require('./token').Token
UserInfo = require('./userinfo').UserInfo
Message =  require('./message').Message
Network = require('./network').Network
ItemView = require('./itemview').ItemView
Comment = require('./comment').Comment

class Models

    constructor: (@dbconf) ->
        @Session = Session
        @User = User
        @Post = Post
        @Forum = Forum
        @Token = Token
        @UserInfo = UserInfo
        @Message = Message
        @Network = Network
        @ItemView = ItemView
        @Comment = Comment
        @initModel(model) for model in [Session, User, Post, Forum, Token, UserInfo, Message, Network, ItemView, Comment]



    initModel: (model) ->
        model._database = new (require '../common/database').Database(@dbconf)
        model._models = this



exports.Models = Models
