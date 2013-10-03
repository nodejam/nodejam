conf = require '../../conf'
database = (require '../../common/data/database').Database
db = new database(conf.db)
models = require '../../models'
utils = require '../../common/utils'
Controller = require('./controller').Controller
Q = require('../../common/q')
mdparser = require('../../common/lib/markdownutil').marked


class Collections extends Controller

    index: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    featured = yield models.Collection.find({ network: req.network.stub }, ((cursor) -> cursor.sort({ 'stats.lastRecord': -1 }).limit 12), {}, db)
                    for collection in featured
                        collection.summary = collection.getView("card")
                        collection.summary.view = "standard"
                    
                    res.render req.network.getView('collections', 'index'), { 
                        featured, 
                        pageName: 'collections-page', 
                        pageType: 'cover-page', 
                        cover: '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()
            
    
    
    item: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    collection = yield models.Collection.get({ stub: req.params.collection, network: req.network.stub }, {}, db)
                    message = (yield collection.associations 'info').message

                    if message
                        message = mdparser message
                        
                    records = yield collection.getRecords(12, { _id: -1 })
                    for record in records
                            record.summary = record.getView("card")
                            record.summary.view = "standard"

                    options = {}
                    if req.user
                        membership = yield models.Membership.get { 'collection.id': collection._id.toString(), 'user.id': req.user.id }, {}, db
                        if membership
                            options.isMember = true
                            options.primaryRecordType = collection.recordTypes[0]
                            
                    res.render req.network.getView('collections', 'item'), { 
                        collection,
                        collectionJson: JSON.stringify(collection),
                        message,
                        records, 
                        options,
                        user: req.user,
                        pageName: 'collection-page', 
                        pageType: 'cover-page', 
                        cover: collection.cover ? '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()



    about: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try                
                    collection = yield models.Collection.get({ stub: req.params.collection, network: req.network.stub }, {}, db)        
                    about = (yield collection.associations 'info').about

                    #We query admins and mods seperately since the fetch limits the records returned per call
                    leaders = yield collection.getMemberships(['admin','moderator'])
                    admins = leaders.filter (u) -> u.roles.indexOf('admin') isnt -1
                    moderators = leaders.filter (u) -> u.roles.indexOf('moderator') isnt -1 and u.roles.indexOf('admin') is -1
                    members = (yield collection.getMemberships ['member']).filter (u) -> u.roles.indexOf('admin') is -1 and u.roles.indexOf('moderator') is -1
                    
                    res.render req.network.getView('collections', 'about'), {
                        collection,
                        about: if about then mdparser(about),
                        admins,
                        moderators,
                        members,
                        pageName: 'collection-about-page', 
                        pageType: 'cover-page', 
                        cover: collection.cover ? '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()
                    

exports.Collections = Collections
