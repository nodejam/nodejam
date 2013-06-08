BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class Comment extends BaseModel

    ###
        Fields
        - collection (string)
        - itemid (string)
        - data
        - createdBy (summarized user)
    ###
    
    @_meta: {
        type: Comment,
        collection: 'comments',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },        
        logging: {
            isLogged: true,
            onInsert: 'NEW_COMMENT'
        },
        validateMultiRecordOperationParams: (params) ->            
            params.postid
    }
    
    
    save: (context, cb) =>
        super context, cb
        
        
        
    validate: =>
        errors = super().errors

        if not @collection
            errors.push 'Missing collection.'

        if not @itemid
            errors.push 'Missing itemid.'
            
        if not @data
            errors.push 'Missing data.'
        
        _errors = Comment._models.User.validateSummary(@createdBy)
        if _errors.length
            errors.push 'Invalid createdBy.'
            errors = errors.concat _errors
                       
        { isValid: errors.length is 0, errors }
        
        
    
exports.Comment = Comment
