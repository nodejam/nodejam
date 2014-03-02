conf = require '../../conf'
db = require('../app').db
models = require '../../models'
utils = require('../../lib/utils')
auth = require '../../common/web/auth'


exports.index = auth.handler ->*
    editorsPicks = yield models.Post.find { meta: 'pick', 'forum.network': @network.stub }, { sort: { _id: -1 }, limit: 1 }, {}, db
    featured = yield models.Post.find { meta: 'featured', 'forum.network': @network.stub }, { sort: { _id: -1 }, limit: 12 }, {}, db
    featured = (f for f in featured when (x._id for x in editorsPicks).indexOf(f._id) is -1)

    for post in editorsPicks.concat(featured)
        post.html = yield models.Post.render 'card', { post, forum: post.forum, author: post.createdBy }
        
    coverContent = "<h1>Editor's Picks</h1>
                    <p>Fora is a place to share ideas. To Discuss and to debate. Everything on Fora is free. Right?</p>"

    yield @renderPage 'home/index', { 
        pageName: 'home-page',
        editorsPicks,
        featured,
        coverInfo: {
            cover: {
                image: { src: '/images/cover.jpg' },
            },
            content: coverContent
        }
    }



exports.login = ->*
    yield @renderPage 'home/login', { 
        pageName: 'login-page'
    }
