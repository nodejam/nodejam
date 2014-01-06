models = require '../models'

templates =   {
    layouts: {
        default: 'layouts/default',    
    },
    views: {    
        home: {
            index: 'home/index',
            login: 'home/login',        
        },
        users: {
            selectusername: 'users/selectusername'
        },
        forums: {
            index: 'forums/index',
            item: 'forums/item',
            about: 'forums/about',
            forumcard: '/views/forums/forumcard',
            create: 'forums/create'
        },
        posts: {
            postcard: '/views/posts/postcard',
            post: 'posts/post'
        }
    }
}

#We will do everything synchronously.
fs = require 'fs'
path = require 'path'
files = (f for f in fs.readdirSync(__dirname) when /\.config$/.test(f))

networks = []
for file in files
    contents = JSON.parse fs.readFileSync(path.resolve __dirname, file)
    switch file
        when 'settings.config'
            settings = contents
        else
            contents.defaultTemplates = templates
            networks.push new models.Network(contents)

settings.pubdir ?= path.resolve __dirname, '../../www-user'

exports.app = settings.app
exports.db = settings.db
exports.auth = settings.auth
exports.admins = settings.admins
exports.pubdir = settings.pubdir
exports.networks = networks
exports.templates = templates
