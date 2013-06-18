BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class Comment extends BaseModel

    ###
        Fields
        - forum (string)
        - itemid (string)
        - data
        - createdBy (summarized user)
    ###
    
    validate: =>
        errors = super().errors

        if not @forum
            errors.push 'Missing forum.'

        if not @itemid
            errors.push 'Missing itemid.'
            
        if not @data
            errors.push 'Missing data.'
        
        _errors = Comment._models.User.validateSummary(@createdBy)
        if _errors.length
            errors.push 'Invalid createdBy.'
            errors = errors.concat _errors
                       
        { isValid: errors.length is 0, errors }
        
    
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
        

        
    
exports.Comment = Comment
