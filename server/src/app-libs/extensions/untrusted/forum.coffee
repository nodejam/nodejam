class Forum

    constructor: (@typeDefinition) ->
        
    
    
    getForumScript: ->
        new ForumScript @typeDefinition
    

module.exports = Forum
