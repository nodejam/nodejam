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
        collections: {
            index: 'collections/index.hbs',
            item: 'collections/item.hbs',
            about: 'collections/about.hbs',
            collectioncard: '/views/collections/collectioncard.hbs'
        },
        records: {
            recordcard: '/views/records/recordcard.hbs',
        }
        recordtypes: {
            article: 'recordtypes/article.hbs'
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

module.exports = {
    app: settings.app,
    db: settings.db,
    auth: settings.auth,
    admins: settings.admins,
    pubdir: settings.pubdir,
    networks,
    templates
}
