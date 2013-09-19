Article = require('./article').Article

exports.getTemplate = (name, postType) ->
    switch postType
        when 'article'
            new Article()
    
