mdparser = require('../../../../common/lib/markdownutil').marked

class Default

    render: (req, res, next, forum, post, user) =>
        templateInfo = (if typeof post.constructor.templateInfo is "function" then post.constructor.templateInfo() else post.constructor.templateInfo).default
        
        postFields = []
        
        for field in templateInfo.fields
            fieldDefinition = @getFieldDefinition field
            if post[fieldDefinition.field]
                param = switch fieldDefinition.type
                    when 'content'
                        { type: fieldDefinition.type, value: mdparser post[fieldDefinition.field] }
                    else
                        { type: fieldDefinition.type, value: post[fieldDefinition.field] }
                        
                postFields.push param
            
        res.render req.network.getView('templates', 'default'), { 
            post,
            user,
            forum,
            fields: postFields,        
            pageName: 'post-page', 
            pageType: 'std-page', 
        }

                
                
    getFieldDefinition: (def) =>
        if typeof def is 'string'
            fieldDef = {
                type: def,
                field: def
            }
        else
            fieldDef = def
            
        fieldDef

exports.Default = Default
