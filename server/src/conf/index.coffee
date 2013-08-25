models = require '../models'

db = { name: process.env.FORA_DB_NAME, host: process.env.FORA_DB_HOST, port: process.env.FORA_DB_PORT }        

twitter = {
    TWITTER_CONSUMER_KEY: process.env.FORA_TWITTER_CONSUMER_KEY,
    TWITTER_CONSUMER_SECRET: process.env.FORA_TWITTER_CONSUMER_SECRET,
    TWITTER_CALLBACK: process.env.FORA_TWITTER_CALLBACK
}

auth = {
    twitter,
    adminkeys: { 
        default: process.env.FORA_DEFAULT_ADMIN_KEY
    }
}

admins = [process.env.FORA_ADMIN_USERNAME]

defaultViews =   {
    defaultLayout: 'layouts/default',
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
    },
}

foraProject = new models.Network {
    name: process.env.FORA_DOMAIN_NAME,
    stub: process.env.FORA_DOMAIN_STUB,
    domains: [process.env.FORA_DOMAIN_HOST],
    views: defaultViews,
} 
    
networks = [foraProject]
    
module.exports = {
    db,
    auth,
    admins,
    defaultViews,
    networks
}
