models = require '../models'

#Database
if process.env.NODE_ENV is 'development'
    db = { name: 'fora-db-dev', host: '127.0.0.1', port: 27017 }
    twitterCB = "http://local.foraproject.org/auth/twitter/callback"
else
    db = { name: 'fora-db', host: '127.0.0.1', port: 27017 }        
    twitterCB = "YOUR_TWITTER_CB_URL"

twitter = {
    TWITTER_CONSUMER_KEY: process.env.FORA_TWITTER_CONSUMER_KEY,
    TWITTER_CONSUMER_SECRET: process.env.FORA_TWITTER_CONSUMER_SECRET,
    TWITTER_CALLBACK: twitterCB
}

auth = {
    twitter,
    adminkeys: { 
        default: 'gorilla^007~5'
    }
}

admins = [ 
    {
        id: '__',
        username: 'jeswin',
        name: 'Jeswin Kumar',
    }           
]

defaultViews =   {
    defaultLayout: 'layouts/default',
    auth: {
        selectusername: 'auth/selectusername'
    },
    home: {
        index: 'home/index.hbs',
        login: 'home/login.hbs',        
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
    name: 'Fora',
    stub: 'fora',
    domains: ['local.foraproject.org', 'www.local.foraproject.org'],
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
