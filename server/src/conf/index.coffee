#Database
if process.env.NODE_ENV is 'development'
    db = { name: 'fora-db-dev', host: '127.0.0.1', port: 27017 }
    models = new (require '../models').Models(db)
    twitter = {
        TWITTER_CONSUMER_KEY: 'YOUR_TWITTER_KEY'
        TWITTER_SECRET: 'YOUR_TWITTER_SECRET',
        TWITTER_CALLBACK: "YOUR_TWITTER_CB",
    }

else
    db = { name: 'fora-db', host: '127.0.0.1', port: 27017 }        
    models = new (require '../models').Models(db)
    twitter = {
        TWITTER_CONSUMER_KEY: 'YOUR_TWITTER_KEY'
        TWITTER_SECRET: 'YOUR_TWITTER_SECRET',
        TWITTER_CALLBACK: "YOUR_TWITTER_CB",
    }

#Auth
auth = {    
    twitter,
    adminkeys: { 
        default: 'RANDOM_STRING_HERE'
    }
}

#Admins
admins = [
    { username: 'adminuser', domain: 'tw' },
]
 
foraProject = new models.Network {
    name: 'Fora',
    stub: 'fora',
    domain: 'local.foraproject.org',
    templates: {
        home: 'welcome/index.hbs'
    },
    admins: [ 
        {
            id: '__',
            domain: 'tw',
            username: 'jeswin',
            name: 'Jeswin Kumar',
            domainIdType: 'username'
        }           
    ],

    adminkeys: { 
        default: 'gorilla^007~5'
    }
} 
    
networks = [foraProject]
    
exports = {
    db,
    auth,
    admins,
    networks
}
