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



exports.Models = Models
