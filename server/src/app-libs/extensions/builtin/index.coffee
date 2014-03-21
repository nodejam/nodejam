ForumScript = require './forumscript'

class BuiltInExtension

    constructor: (@typeDefinition) ->
    
    
    
    getForumScript: ->
        new ForumScript @typeDefinition
    

module.exports = BuiltInExtension
