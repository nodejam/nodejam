recordModule = require('./record')
utils = require('../lib/utils')
Q = require 'q'
models = require('./')

class Conversation extends recordModule.Record
    
    @typeDefinition: {
            type: @,
            alias: 'Conversation',
            inherits: 'Record',
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
