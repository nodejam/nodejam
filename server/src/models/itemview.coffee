BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class ItemView extends BaseModel

    ###
        Fields
            - network (string)        
            - collection (string)
            - collectionType (string)
            - itemid (string)
            - type (string)
            - data (string)
            - meta (list of string),
            - createdBy (user)
            - publishedAt
            - state
    ###    
        
    @_meta: {
        type: ItemView,
        collection: 'itemviews',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },
        logging: {
            isLogged: false,
        }
    }



    @search: (criteria, settings, context, cb) =>
        limit = @getLimit settings.limit, 100, 1000
                
        params = {}
        for k, v of criteria
            params[k] = v
        
        ItemView.find params, ((cursor) -> cursor.sort(settings.sort).limit limit), context, cb     
        
            

    constructor: (params) ->
        @meta ?= []
        super
        
        

    save: (context, cb) =>            
        super
            
            

    validate: =>
        errors = super().errors

        if not @network or typeof @network isnt 'string'
            errors.push 'Invalid network.'      
                    
        if not @collection
            errors.push 'Invalid collection.'

        if not @collectionType
            errors.push 'Invalid collectionType.'

        if not @data
            errors.push 'data missing.'
            
        for item in @meta
            if typeof item isnt 'string'
                errors.push "Invalid item(#{item}) in meta."

        _errors = ItemView._models.User.validateSummary(@createdBy)
        if _errors.length            
            errors.push 'Invalid createdBy.'
            errors = errors.concat _errors
            
        if not @type or ['featured', 'post'].indexOf(@type) is -1
            errors.push "Invalid type."
        
        if @publishedAt and isNaN(@publishedAt)
            errors.push 'PublishedAt must be a number.'

        if not @state
            errors.push 'Invalid state.'

        { isValid: errors.length is 0, errors }
    
    
    
exports.ItemView = ItemView
