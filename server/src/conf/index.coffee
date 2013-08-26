models = require '../models'

templates =   {
    layouts: {
        default: 'layouts/default',    
    },
    views: {    
        home: {
            index: 'home/index.hbs',
            login: 'home/login.hbs',        
        },
        users: {
            selectusername: 'users/selectusername'
        },
        forums: {
            index: 'forums/index.hbs',
            item: 'forums/item.hbs',
            forumcard: '/views/forums/forumcard.hbs',
        },
        posts: {
            postcard: '/views/posts/postcard.hbs',
        },
        articles: {
            item: 'articles/item.hbs',        
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
        
    
module.exports = {
    app: settings.app,
    db: settings.db,
    auth: settings.auth,
    admins: settings.admins,
    networks,
    templates
}
