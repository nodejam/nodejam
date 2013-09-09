mdparser = require('../../../../common/lib/markdownutil').marked

class Default

    render: (req, res, next, forum, post, user) =>
        templateInfo = (if typeof post.constructor.templateInfo is "function" then post.constructor.templateInfo() else post.constructor.templateInfo).default
        
        sections = []
        
        for section in templateInfo.sections
            sections.push @getSectionDefinition post, section
            
        res.render req.network.getView('templates', 'default'), { 
            post,
            user,
            forum,
            sections,
            pageName: 'post-page', 
            pageType: 'std-page', 
        }

                
                
    getSectionDefinition: (post, def) =>
        if typeof def is 'string'
            sectionDefinition = {
                type: def,
                fields: [def]                  
            }
        else
            sectionDefinition = def
            
        switch sectionDefinition.type
            when 'content'
                sectionDefinition.contents = mdparser post[sectionDefinition.fields[0]]
        
        sectionDefinition

exports.Default = Default
