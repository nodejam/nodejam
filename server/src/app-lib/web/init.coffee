Sandbox = require 'react-sandbox'
RequestParser = require('fora-webrequestparser')
ForaTypeUtils = require('../../models/foratypeutils')
typeUtils = new ForaTypeUtils()
conf = require '../../conf'

templateModuleCache = {}

module.exports = (app) ->
    app.use (next) ->*

        if @method is 'POST' or @method is 'PUT' or @method is 'PATCH'
            @parser =  new RequestParser(@, typeUtils)

        network = (n for n in conf.networks when n.domains.indexOf(@host) isnt -1)
        if network.length
            @network = network[0]
        else
            throw new Error "Invalid network"
            
        @renderView = (view, props = {}, params = {}) ->*
            if not templateModuleCache[view]
                module = require("../../website/views/#{view}")
                templateModuleCache[view] = module

            component = templateModuleCache[view] props
            if component.type.componentInit and not component.__isInitted
                yield component.type.componentInit component

            script = "
                <script>
                    var page = new Fora.Views.Page(
                        '/shared/website/views/#{view}.js',
                        #{JSON.stringify(props)}
                    );
                </script>"

            params.html = "
                #{script}
                #{Sandbox.renderComponentToString(component)}"

            params.pageName = view.split('/').join('-')
            
            params.theme ?= @network.theme         
            params.coverInfo?.class ?= "auto-cover"                            

            if @session
                params._session ?= @session.user
        
            yield @render "page", params
            
        yield next
            
