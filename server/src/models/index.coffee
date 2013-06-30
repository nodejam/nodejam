modules = {
    session: 'Session',
    user: 'User',
    forum: 'Forum',
    post: 'Post',
    token: 'Token',
    userinfo: 'UserInfo',
    message: 'Message',
    network: 'Network',
    itemview: 'ItemView',
    comment: 'Comment',
    article: 'Article'
}

models = {}

for k,v of modules
    models[v] = require("./#{k}")[v]


class Models
    constructor: (@dbconf) ->
        for k, v of models
            @[k] = v
            @initModel v
        

    initModel: (model) ->
        model._database = new (require '../common/database').Database(@dbconf)
        model._models = this

Models.BaseModel = require('./basemodel').BaseModel
exports.Models = Models
