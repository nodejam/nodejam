Article = require('./article').Article

exports.getTemplate = (name, post) ->
    typeDefinition = post.constructor.getTypeDefinition()
    switch typeDefinition.name
        when 'article'
            new Article()
    
