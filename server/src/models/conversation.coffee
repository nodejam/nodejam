postModule = require('./post')
utils = require('../lib/utils')
Q = require '../lib/q'
models = require('./')

class Conversation extends postModule.Post
    
    @typeDefinition: {
            type: @,
            alias: 'Conversation',
            inherits: 'Post',
            fields: {
                content: { type: 'string', required: false, maxLength: 50000 },
            }
        }



    constructor: (params) ->
        @type ?= 'conversation'
        super



    getView: (name = "standard") =>
        switch name
            when "snapshot"
                {
                } 
            when "card"
                {
                }
    


exports.Conversation = Conversation
