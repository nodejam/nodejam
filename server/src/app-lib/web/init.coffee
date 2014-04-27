RequestParser = require('fora-webrequestparser')
ForaTypeUtils = require('../../models/foratypeutils')
typeUtils = new ForaTypeUtils()
conf = require '../../conf'

module.exports = (app) ->
    app.use (next) ->*

        if @method is 'POST' or @method is 'PUT' or @method is 'PATCH'
            @parser =  new RequestParser(@, typeUtils)

        network = (n for n in conf.networks when n.domains.indexOf(@host) isnt -1)
        if network.length
            @network = network[0]
        else
            throw new Error "Invalid network"
        
        @renderPage = (view, params) ->            
            params.theme ?= @network.theme         
            params.coverInfo?.class ?= "auto-cover"                            
            if @session
                params._session ?= @session.user
        
            @render view, params
        
        yield next
