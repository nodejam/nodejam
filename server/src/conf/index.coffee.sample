models = require '../models'

#Database
if process.env.NODE_ENV is 'development'
    db = { name: 'fora-db-dev', host: '127.0.0.1', port: 27017 }
    twitter = {
        TWITTER_CONSUMER_KEY: 'YOUR_TWITTER_KEY'
        TWITTER_SECRET: 'YOUR_TWITTER_SECRET',
        TWITTER_CALLBACK: "YOUR_TWITTER_CB",
    }

else
    db = { name: 'fora-db', host: '127.0.0.1', port: 27017 }        
    twitter = {
        TWITTER_CONSUMER_KEY: 'YOUR_TWITTER_KEY'
        TWITTER_SECRET: 'YOUR_TWITTER_SECRET',
        TWITTER_CALLBACK: "YOUR_TWITTER_CB",
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
        domain: 'users',
        username: 'jeswin',
        name: 'Jeswin Kumar',
        domainIdType: 'username'
    }           
]

defaultViews =   {
    defaultLayout: 'layouts/default',
    home: {
        index: 'home/index.hbs',
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
    domain: 'local.foraproject.org',
    views: defaultViews,
    templates: {
        home: 'welcome/index.hbs'
    }
} 
    
networks = [foraProject]
    
module.exports = {
    db,
    auth,
    admins,
    defaultViews,
    networks
}
